#!/bin/bash

# Guard against multiple loading
if [[ -n "${PROCESSORS_LOADED:-}" ]]; then
    return 0
fi
declare -r PROCESSORS_LOADED=true

# Certificate processing module
# Provides centralized certificate processing functions

# Process a certificate bundle
process_bundle() {
    local bundle_file="$1"
    local target_dir="$2"
    local bundle_name="${3:-unknown}"
    local verbose="${4:-false}"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT

    debug "Processing bundle: $bundle_file"
    debug "Target directory: $target_dir"
    debug "Bundle name: $bundle_name"

    $verbose && echo -e "${VERB}Processing bundle: $bundle_file${RSET}"

    # Ensure target directory exists
    if ! sudo mkdir -p "$target_dir"; then
        echo -e "${FAIL}Failed to create target directory: $target_dir${RSET}"
        update_metric "$bundle_name" "failed"
        return 1
    fi

    # Split bundle into individual certificates
    if ! csplit -z -f "$tmp_dir/cert-" -b "%02d.crt" "$bundle_file" '/-----BEGIN CERTIFICATE-----/' '{*}' 2>/dev/null; then
        echo -e "${FAIL}Failed to split certificate bundle${RSET}"
        update_metric "$bundle_name" "failed"
        return 1
    fi

    # Process each certificate
    local processed_count=0
    for cert in "$tmp_dir"/cert-*.crt; do
        process_single_certificate "$cert" "$target_dir" "$bundle_name" "$verbose" && ((processed_count++))
    done

    $verbose && echo -e "${VERB}Processed $processed_count certificates from bundle${RSET}"
    return 0
}

# Process a single certificate
process_single_certificate() {
    local cert_file="$1"
    local target_dir="$2"
    local bundle_name="${3:-unknown}"
    local verbose="${4:-false}"

    debug "Processing certificate: $cert_file"

    # Validate certificate
    if ! validate_certificate "$cert_file" "$bundle_name" "$verbose"; then
        return 1
    fi

    # Generate unique name
    local cert_name
    cert_name=$(generate_cert_name "$cert_file")
    local target_path="$target_dir/$cert_name"

    # Handle duplicates
    if [[ -f "$target_path" ]]; then
        if ! cmp -s "$cert_file" "$target_path"; then
            local counter=1
            while [[ -f "${target_path%.*}_${counter}.crt" ]]; do
                ((counter++))
            done
            target_path="${target_path%.*}_${counter}.crt"
        else
            $verbose && echo -e "${WARN}Skipping duplicate certificate: $cert_name${RSET}"
            update_metric "$bundle_name" "skipped"
            return 1
        fi
    fi

    # Install certificate
    if ! sudo mv "$cert_file" "$target_path"; then
        echo -e "${FAIL}Failed to install certificate: $cert_name${RSET}"
        update_metric "$bundle_name" "failed"
        return 1
    fi

    if $verbose; then
        echo -e "${PASS}Installed certificate: $cert_name${RSET}"
        echo -e "${VERB}  Subject: $(get_cert_info "$target_path" "subject")${RSET}"
        echo -e "${VERB}  Issuer:  $(get_cert_info "$target_path" "issuer")${RSET}"
        echo -e "${VERB}  $(get_cert_info "$target_path" "dates")${RSET}"
    fi

    return 0
}

# Process DoD certificates
process_dod_certs() {
    local target_dir="$1"
    local verbose="${2:-false}"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT

    # Download and extract DoD bundle
    local bundle_url
    bundle_url=$(curl -s "$DOD_CERT_URL" | awk -F '"' 'tolower($2) ~ /dod.zip/ {print $2}')

    if ! wget -qP "$tmp_dir" "$bundle_url"; then
        echo -e "${FAIL}Failed to download DoD bundle${RSET}"
        update_metric "dod" "failed"
        return 1
    fi

    if ! unzip -qj "$tmp_dir"/"${bundle_url##*/}" -d "$tmp_dir"; then
        echo -e "${FAIL}Failed to extract DoD bundle${RSET}"
        update_metric "dod" "failed"
        return 1
    fi

    # Find and process certificate bundle
    local cert_bundle
    if cert_bundle=$(find "$tmp_dir" -name "*_dod_pem.p7b" -print -quit); then
        $verbose && echo -e "${VERB}Found PEM formatted bundle${RSET}"
    elif cert_bundle=$(find "$tmp_dir" -name "*_dod_der.p7b" -print -quit); then
        $verbose && echo -e "${VERB}Found DER formatted bundle${RSET}"
    else
        echo -e "${FAIL}No valid DoD certificate bundles found${RSET}"
        update_metric "dod" "failed"
        return 1
    fi

    # Extract certificates to PEM format
    local extracted_certs="$tmp_dir/extracted_certs.pem"
    if ! openssl pkcs7 -print_certs -in "$cert_bundle" >"$extracted_certs" 2>/dev/null; then
        echo -e "${FAIL}Failed to extract certificates from bundle${RSET}"
        update_metric "dod" "failed"
        return 1
    fi

    # Process the extracted certificates
    process_bundle "$extracted_certs" "$target_dir" "dod" "$verbose"
}

# Update CA certificates store
update_ca_store() {
    local verbose="${1:-false}"
    local update_command
    local skipped_count=0

    if command -v update-ca-certificates &>/dev/null; then
        update_command="update-ca-certificates"
    elif command -v update-ca-trust &>/dev/null; then
        update_command="update-ca-trust extract"
    else
        echo -e "${FAIL}No supported CA certificate update mechanism found${RSET}"
        return 1
    fi

    local output
    output=$(sudo $update_command 2>&1)

    if [[ "$update_command" == "update-ca-certificates" ]]; then
        skipped_count=$(echo "$output" | grep -c "warning: skipping")
    else
        skipped_count=$(trust dump --filter "pkcs11:object-type=cert" 2>&1 | grep -c "duplicate certificate")
    fi

    if $verbose; then
        echo "$output"
        echo -e "${VERB}Skipped certificates during update: $skipped_count${RSET}"
    fi

    update_metric "system" "skipped" "$skipped_count"
    return 0
}

# Process CA certificates
process_ca_certificates() {
    local verbose="${1:-false}"
    local ca_cert_file

    debug "Looking for CA certificates file"
    if [[ -f /etc/ssl/certs/ca-certificates.crt ]]; then
        ca_cert_file='/etc/ssl/certs/ca-certificates.crt'
    elif [[ -f /etc/pki/tls/certs/ca-bundle.crt ]]; then
        ca_cert_file='/etc/pki/tls/certs/ca-bundle.crt'
    elif [[ -f /etc/ssl/ca-bundle.pem ]]; then
        ca_cert_file='/etc/ssl/ca-bundle.pem'
    else
        error "Could not find the ca-certificates.crt file"
        return 1
    fi

    debug "Found CA certificates file: $ca_cert_file"
    process_bundle "$ca_cert_file" "$(get_config CERT_DIR)" "ca" "$verbose"
}

# Process organization certificate
process_org_certificate() {
    local cert_name="$1"
    local target_dir="$2"
    local verbose="${3:-false}"
    local tmp_dir

    debug "Processing organization certificate: $cert_name"
    tmp_dir=$(create_temp_dir)
    trap 'cleanup_temp "$tmp_dir"' EXIT

    local cert_url="${ORG_CERT_BASE_URL}/${cert_name// /%20}"
    local cert_file="$tmp_dir/${cert_name##*/}"

    debug "Downloading from: $cert_url"
    if ! download_file "$cert_url" "$cert_file" "$verbose"; then
        error "Failed to download: $cert_name"
        return 1
    fi

    process_single_certificate "$cert_file" "$target_dir" "org" "$verbose"
}
