#!/bin/bash

# Guard against multiple loading
if [[ -n "${VALIDATORS_LOADED:-}" ]]; then
    return 0
fi
declare -r VALIDATORS_LOADED=true

# Certificate validation module
# Provides centralized certificate validation functions

# Validate certificate format and contents
validate_certificate() {
    local cert_file="$1"
    local bundle_name="${2:-unknown}"
    local verbose="${3:-false}"
    local validation_result=0
    local cert_type=""

    debug "Validating certificate: $cert_file"
    debug "Bundle name: $bundle_name"

    # Basic file checks
    if [[ ! -f "$cert_file" ]]; then
        $verbose && echo -e "${FAIL}Certificate file not found: $cert_file${RSET}"
        update_metric "$bundle_name" "failed"
        return 1
    fi

    if [[ ! -s "$cert_file" ]]; then
        $verbose && echo -e "${FAIL}Empty certificate file: $cert_file${RSET}"
        update_metric "$bundle_name" "failed"
        return 1
    fi

    # Check for private key content
    if grep -q "BEGIN.*PRIVATE KEY" "$cert_file" 2>/dev/null; then
        local key_type=""

        # Validate different key types
        if openssl rsa -check -noout -in "$cert_file" 2>/dev/null; then
            key_type="RSA"
        elif openssl dsa -check -noout -in "$cert_file" 2>/dev/null; then
            key_type="DSA"
        elif openssl ec -check -noout -in "$cert_file" 2>/dev/null; then
            key_type="EC"
        fi

        if [[ -n "$key_type" ]]; then
            $verbose && echo -e "${WARN}File contains valid $key_type private key${RSET}"
            update_metric "$bundle_name" "skipped"
            return 2
        fi
    fi

    # Try PEM format first
    if openssl x509 -noout -in "$cert_file" 2>/dev/null; then
        cert_type="PEM"
        validation_result=0
    # Try DER format
    elif openssl x509 -inform DER -noout -in "$cert_file" 2>/dev/null; then
        cert_type="DER"
        validation_result=0
    # Try PKCS7 format
    elif openssl pkcs7 -print_certs -in "$cert_file" 2>/dev/null | grep -q "BEGIN CERTIFICATE"; then
        cert_type="PKCS7"
        validation_result=0
    else
        $verbose && echo -e "${FAIL}Invalid or unsupported certificate format${RSET}"
        update_metric "$bundle_name" "failed"
        return 1
    fi

    # Additional validation for valid certificates
    if [[ $validation_result -eq 0 ]]; then
        local validation_output
        local temp_cert

        # Convert to PEM format if needed
        if [[ "$cert_type" != "PEM" ]]; then
            temp_cert=$(mktemp)
            case "$cert_type" in
            "DER")
                openssl x509 -inform DER -in "$cert_file" -out "$temp_cert" 2>/dev/null
                ;;
            "PKCS7")
                openssl pkcs7 -print_certs -in "$cert_file" -out "$temp_cert" 2>/dev/null
                ;;
            esac
            validation_output=$(openssl x509 -noout -text -in "$temp_cert" 2>&1)
            rm -f "$temp_cert"
        else
            validation_output=$(openssl x509 -noout -text -in "$cert_file" 2>&1)
        fi

        # Check certificate dates
        if ! openssl x509 -checkend 0 -in "$cert_file" >/dev/null 2>&1; then
            local not_before not_after current_time
            not_before=$(openssl x509 -noout -startdate -in "$cert_file" 2>/dev/null | cut -d= -f2-)
            not_after=$(openssl x509 -noout -enddate -in "$cert_file" 2>/dev/null | cut -d= -f2-)
            current_time=$(date)

            $verbose && {
                echo -e "${FAIL}Certificate expired:${RSET}"
                echo -e "${FAIL}  Not Before: $not_before${RSET}"
                echo -e "${FAIL}  Not After:  $not_after${RSET}"
                echo -e "${FAIL}  Current:    $current_time${RSET}"
            }

            update_metric "$bundle_name" "failed"
            return 1
        fi

        # Update metrics based on certificate type
        update_metric "$bundle_name" "${cert_type,,}"
        update_metric "$bundle_name" "processed"

        $verbose && echo -e "${PASS}Valid $cert_type certificate${RSET}"
        return 0
    fi

    update_metric "$bundle_name" "failed"
    return 1
}

# Get certificate information
get_cert_info() {
    local cert_file="$1"
    local info_type="$2" # subject, issuer, dates, all
    local output=""

    case "$info_type" in
    "subject")
        output=$(openssl x509 -noout -subject -in "$cert_file" 2>/dev/null | sed 's/^subject=\s*//')
        ;;
    "issuer")
        output=$(openssl x509 -noout -issuer -in "$cert_file" 2>/dev/null | sed 's/^issuer=\s*//')
        ;;
    "dates")
        local not_before not_after
        not_before=$(openssl x509 -noout -startdate -in "$cert_file" 2>/dev/null | cut -d= -f2-)
        not_after=$(openssl x509 -noout -enddate -in "$cert_file" 2>/dev/null | cut -d= -f2-)
        output="Not Before: $not_before\nNot After: $not_after"
        ;;
    "all")
        output=$(openssl x509 -noout -text -in "$cert_file" 2>/dev/null)
        ;;
    esac

    echo -e "$output"
}

# Generate unique certificate name
generate_cert_name() {
    local cert_file="$1"
    local subject

    subject=$(get_cert_info "$cert_file" "subject")

    # Try to extract CN first
    local cert_name
    cert_name=$(echo "$subject" | sed -n 's/.*CN = \([^,]*\).*/\1/p' | sed 's/[^a-zA-Z0-9._-]/_/g')

    # If no CN, use the last component of the subject
    if [[ -z "$cert_name" ]]; then
        cert_name=$(echo "$subject" | awk -F '(=|= )' '{print $NF}' | sed 's/[^a-zA-Z0-9._-]/_/g')
    fi

    echo "${cert_name}.crt"
}
