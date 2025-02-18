#!/bin/bash
# Imports DoD root certificates into Linux CA store
# Version 0.5.21 updated 20241216 by AfroThundr
# SPDX-License-Identifier: GPL-3.0-or-later

# For issues or updated versions of this script, browse to the following URL:
# https://gist.github.com/AfroThundr3007730/ba99753dda66fc4abaf30fb5c0e5d012

# Dependencies: curl gawk openssl unzip wget xmllint(libxml2-utils)

set -euo pipefail
shopt -s extdebug nullglob

# Define pretty output variables
WARN='\033[1;33m'
RSET='\033[0m'
VERB='\033[1;34m'
HIGH='\033[1;32m'
FAIL='\033[1;31m'
PASS='\033[1;32m'

# Add debug flag
DEBUG=false

# Add debug function after color definitions
debug_metrics() {
    if ! $DEBUG; then
        return
    fi
    local location="$1"
    echo -e "${WARN}=== Metrics at $location ===${RSET}"
    echo "TOTAL_CERTS=$TOTAL_CERTS"
    echo "PEM_CERTS=$PEM_CERTS"
    echo "DER_CERTS=$DER_CERTS"
    echo "PKCS7_CERTS=$PKCS7_CERTS"
    echo "FAILED_CERTS=$FAILED_CERTS"
    echo "SKIPPED_CERTS=$SKIPPED_CERTS"

    # Print bundle metrics
    for bundle in dod org ca; do
        local processed=${BUNDLE_METRICS["${bundle}_processed"]-0}
        local failed=${BUNDLE_METRICS["${bundle}_failed"]-0}
        local skipped=${BUNDLE_METRICS["${bundle}_skipped"]-0}
        echo "${bundle^^} Bundle: processed=$processed failed=$failed skipped=$skipped"
    done
    echo -e "${WARN}=== End Metrics ===${RSET}"
}

# Define URLs and other configurable parameters
DOD_CERT_URL='https://public.cyber.mil/pki-pke/pkipke-document-library/'
ORG_CERT_BASE_URL='https://pkirepo.mitre.org/Certificates'
ORG_COMBINED_CERT_FILE='.devcontainer/extra-ca.pem'

# Array of organization certificates to download
ORG_CERTS=(
    "Entrust Managed Services NFI Root CA.crt"
    "Entrust NFI Medium Assurance SSP CA.crt"
    "MITRE BA NPE CA-3(1).crt"
    "MITRE BA NPE CA-3.crt"
    "MITRE BA NPE CA-4.crt"
    "MITRE BA ROOT.crt"
    "MITRE Corporation PE CA-2(1).crt"
    "MITRE Corporation PE CA-2(2).crt"
    "MITRE Corporation PE CA-2.crt"
    "MITRE Corporation PE Root CA-1.crt"
    "MITRE PE CA-4.crt"
    "MITRE-NPE-CA1.crt"
    "ZScaler_Root.crt"
)

# Flags to control which sections are executed
process_ca_certs_flag=true
process_dod_certs_flag=true
process_org_certs_flag=true
skip_update_flag=false

# Help function
show_help() {
    echo -e "${VERB}Usage: ${0##*/} [-c] [-d] [-o] [-p file] [-i] [-f] [-s] [-D] [-h|--help]${RSET}"
    echo "  -c  Skip processing ca-certificates.crt"
    echo "  -d  Skip processing DoD certificates"
    echo "  -o  Skip processing organization certificates"
    echo "  -p  Process organization certificates from combined PEM file (requires filename)"
    echo "  -i  Process individual organization certificates from repository"
    echo "  -f  Fetch certificate list dynamically from repository"
    echo "  -s  Skip updating CA certificates store"
    echo "  -D  Enable debug output"
    echo "  -h, --help  Display this help message"
    echo -e "\n${VERB}Examples:${RSET}"
    echo "  ${0##*/} -c -d -p my-combined-certs.pem    (process the combined org PEM file)"
    echo "  ${0##*/} -c -d -i                          (process static provided org cert list)"
    echo "  ${0##*/} -c -d -i -f                       (dynamically pull the latest org certs list)"
    exit 0
}

# Add variables for org cert processing mode and dynamic fetching
org_use_combined_pem=false
org_use_individual_certs=false
org_use_dynamic_list=false
org_pem_file=""

# If no arguments are passed or help is requested, show help
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_help
fi

# Parse command-line arguments
while getopts ":cdop:ifsDh" opt; do
    case $opt in
    c) process_ca_certs_flag=false ;;
    d) process_dod_certs_flag=false ;;
    o) process_org_certs_flag=false ;; # Changed from 'm' to 'o'
    p)
        if [ -z "$OPTARG" ]; then
            echo -e "${FAIL}Error: -p requires a filename argument${RSET}"
            show_help
            exit 1
        fi
        org_use_combined_pem=true
        org_pem_file="$OPTARG"
        ;;
    i) org_use_individual_certs=true ;;
    f)
        org_use_dynamic_list=true
        org_use_individual_certs=true
        ;;
    s) skip_update_flag=true ;;
    D) DEBUG=true ;;
    h) show_help ;; # Added explicit -h option
    :)
        echo -e "${FAIL}Error: Option -$OPTARG requires an argument${RSET}"
        show_help
        exit 1
        ;;
    \?)
        echo -e "${FAIL}Error: Invalid option -$OPTARG${RSET}"
        show_help
        exit 1
        ;;
    esac
done

# Function to check if a package is installed
is_package_installed() {
    local package=$1
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"; then
        return 0
    else
        return 1
    fi
}

# Function to install package based on distro
install_package() {
    local package=$1
    # Detect package manager
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y "$package"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$package"
    elif command -v yum &>/dev/null; then
        sudo yum install -y "$package"
    else
        echo -e "${FAIL}No supported package manager found${RSET}"
        return 1
    fi
}

# Check for required dependencies and install if missing
for cmd in curl gawk openssl unzip wget xmllint; do
    pkg_name="$cmd"
    # Map command names to package names where different
    case "$cmd" in
    xmllint)
        if command -v xmllint &>/dev/null; then
            continue # Skip package check if command exists
        fi
        pkg_name="libxml2-utils"
        if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
            pkg_name="libxml2"
        fi
        ;;
    esac

    if ! command -v "$cmd" &>/dev/null || ! is_package_installed "$pkg_name"; then
        echo -e "${VERB}Installing missing dependency: $pkg_name${RSET}"
        if ! install_package "$pkg_name"; then
            echo -e "${FAIL}Failed to install $pkg_name${RSET}"
            if [ "$cmd" = "xmllint" ]; then
                echo -e "${WARN}Will fall back to basic HTML parsing${RSET}"
            else
                exit 1
            fi
        fi
    fi
done

# Function to dynamically find the ca-certificates.crt file
find_ca_cert_file() {
    local ca_cert_file
    if [[ -f /etc/ssl/certs/ca-certificates.crt ]]; then
        ca_cert_file='/etc/ssl/certs/ca-certificates.crt'
    elif [[ -f /etc/pki/tls/certs/ca-bundle.crt ]]; then
        ca_cert_file='/etc/pki/tls/certs/ca-bundle.crt'
    elif [[ -f /etc/ssl/ca-bundle.pem ]]; then
        ca_cert_file='/etc/ssl/ca-bundle.pem'
    else
        echo -e "${FAIL}Could not find the ca-certificates.crt file${RSET}"
        exit 1
    fi
    echo "$ca_cert_file"
}

# Add summary tracking variables
declare -A BUNDLE_METRICS
declare -i TOTAL_CERTS=0
declare -i PEM_CERTS=0
declare -i DER_CERTS=0
declare -i PKCS7_CERTS=0
declare -i FAILED_CERTS=0
declare -i SKIPPED_CERTS=0

# Update track_metric function with debugging
track_metric() {
    local bundle=$1
    local type=$2
    local count=${3:-1}
    local old_total=$TOTAL_CERTS
    local old_bundle=${BUNDLE_METRICS["${bundle}_${type}"]-0}

    BUNDLE_METRICS["${bundle}_${type}"]=$((old_bundle + count))

    case $type in
    processed)
        ((TOTAL_CERTS += count))
        ((PEM_CERTS += count))
        ;;
    failed)
        ((FAILED_CERTS += count))
        ;;
    skipped)
        ((SKIPPED_CERTS += count))
        ;;
    esac

    if $DEBUG; then
        echo -e "${VERB}Metric update: ${bundle}/${type} += ${count} (was: ${old_bundle})${RSET}"
        echo -e "${VERB}Total certs: ${old_total} -> ${TOTAL_CERTS}${RSET}"
    fi
}

# Function to process certificates from a given file
process_certificates() {
    local cert_file=$1
    local certdir=$2
    local bundle_name="${3:-unknown}"
    local processed_count=0

    debug_metrics "Start of process_certificates for $bundle_name"

    local tmp_process_dir=$(mktemp -d)
    trap '[[ -d ${tmp_process_dir:-} ]] && rm -fr "$tmp_process_dir"' EXIT INT TERM

    sudo mkdir -p "$certdir"

    # Split certificates into individual files - revert to original working version
    echo -e "${VERB}Splitting certificates from $cert_file${RSET}"
    csplit -z -f "$tmp_process_dir/cert-" -b "%02d.crt" "$cert_file" '/-----BEGIN CERTIFICATE-----/' '{*}' 2>/dev/null || true

    # Process each certificate
    for cert in "$tmp_process_dir"/cert-*.crt; do
        if [ ! -f "$cert" ]; then
            continue
        fi

        # Enhanced certificate validation
        local validation_output
        validation_output=$(openssl x509 -noout -text -in "$cert" 2>&1)
        if [ $? -eq 0 ]; then
            # Check certificate dates
            local not_before not_after current_time
            not_before=$(openssl x509 -noout -startdate -in "$cert" 2>/dev/null | cut -d= -f2-)
            not_after=$(openssl x509 -noout -enddate -in "$cert" 2>/dev/null | cut -d= -f2-)
            current_time=$(date)

            if ! openssl x509 -checkend 0 -in "$cert" >/dev/null 2>&1; then
                echo -e "${FAIL}Certificate expired:${RSET}"
                echo -e "${FAIL}  Not Before: $not_before${RSET}"
                echo -e "${FAIL}  Not After:  $not_after${RSET}"
                echo -e "${FAIL}  Current:    $current_time${RSET}"
                ((FAILED_CERTS++))
                track_metric "$bundle_name" "failed"
                continue
            fi

            # Get certificate subject and issuer
            local subject issuer
            subject=$(openssl x509 -noout -subject -in "$cert" 2>/dev/null | sed 's/^subject=\s*//')
            issuer=$(openssl x509 -noout -issuer -in "$cert" 2>/dev/null | sed 's/^issuer=\s*//')

            # Get unique name based on subject
            local cert_subject
            cert_subject=$(echo "$subject" | sed -n 's/.*CN = \([^,]*\).*/\1/p' | sed 's/[^a-zA-Z0-9._-]/_/g')

            if [ -z "$cert_subject" ]; then
                cert_subject=$(echo "$subject" | awk -F '(=|= )' '{print $NF}' | sed 's/[^a-zA-Z0-9._-]/_/g')
            fi

            local cert_name="${cert_subject}.crt"
            local target_path="$certdir/$cert_name"

            # Check for duplicates
            if [ -f "$target_path" ]; then
                if ! cmp -s "$cert" "$target_path"; then
                    local counter=1
                    while [ -f "${target_path%.*}_${counter}.crt" ]; do
                        ((counter++))
                    done
                    target_path="${target_path%.*}_${counter}.crt"
                else
                    echo -e "${WARN}Skipping duplicate certificate: $cert_name${RSET}"
                    echo -e "${VERB}  Subject: $subject${RSET}"
                    ((SKIPPED_CERTS++))
                    track_metric "$bundle_name" "skipped"
                    continue
                fi
            fi

            if ! sudo mv "$cert" "$target_path"; then
                echo -e "${FAIL}Failed to install certificate: $cert_name${RSET}"
                ((FAILED_CERTS++))
                track_metric "$bundle_name" "failed"
                continue
            fi

            echo -e "${PASS}Installed certificate: ${cert_name}${RSET}"
            if $DEBUG; then
                echo -e "${VERB}  Subject: $subject${RSET}"
                echo -e "${VERB}  Issuer:  $issuer${RSET}"
                echo -e "${VERB}  Valid:   $not_before -> $not_after${RSET}"
            fi

            ((TOTAL_CERTS++))
            ((PEM_CERTS++))
            ((processed_count++))
            track_metric "$bundle_name" "processed"
            debug_metrics "After installing $cert_name"
        else
            echo -e "${FAIL}Invalid certificate file: $cert${RSET}"
            if $DEBUG; then
                echo -e "${FAIL}Error: $validation_output${RSET}"
            fi
            ((FAILED_CERTS++))
            track_metric "$bundle_name" "failed"
            rm -f "$cert"
        fi
    done

    echo -e "${VERB}Processed $processed_count certificates from $bundle_name bundle${RSET}"
    debug_metrics "End of process_certificates for $bundle_name"
}

# Function to download and process DoD certificates
process_dod_certs() {
    local bundle certdir tmpdir url
    tmpdir=$(mktemp -d)
    trap '[[ -d ${tmpdir:-} ]] && rm -fr $tmpdir' EXIT INT TERM

    # Location of bundle from DISA site
    url=$DOD_CERT_URL
    bundle=$(curl -s $url | awk -F '"' 'tolower($2) ~ /dod.zip/ {print $2}')

    # Debug output
    echo -e "${VERB}Bundle URL: $bundle${RSET}"

    # Extract the bundle with error checking
    if ! wget -qP "$tmpdir" "$bundle"; then
        echo -e "${FAIL}Failed to download DOD bundle${RSET}"
        return 1
    fi

    if ! unzip -qj "$tmpdir"/"${bundle##*/}" -d "$tmpdir"; then
        echo -e "${FAIL}Failed to extract DOD bundle${RSET}"
        return 1
    fi

    # Debug output for bundle contents
    echo -e "${VERB}Bundle contents:${RSET}"
    ls -l "$tmpdir"

    # Check for existence of PEM or DER format p7b with improved error handling
    local pem_file der_file certfile certform
    pem_file=$(find "$tmpdir" -name "*_dod_pem.p7b" -print -quit)
    der_file=$(find "$tmpdir" -name "*_dod_der.p7b" -print -quit)

    if [[ -n "$pem_file" ]]; then
        echo -e "${VERB}Found PEM formatted file: $(basename "$pem_file")${RSET}"
        certform="PEM"
        certfile="$pem_file"
        ((PKCS7_CERTS++))
    elif [[ -n "$der_file" ]]; then
        echo -e "${VERB}Found DER formatted file: $(basename "$der_file")${RSET}"
        certform="DER"
        certfile="$der_file"
        ((DER_CERTS++))
    else
        echo -e "${FAIL}No valid DoD certificate bundles found!${RSET}"
        return 1
    fi

    # Set cert directory based on OS
    [[ -f /etc/os-release ]] && source /etc/os-release
    if [[ ${ID:-} =~ (fedora|rhel|centos) || ${ID_LIKE:-} =~ (fedora|rhel|centos) ]]; then
        certdir=/etc/pki/ca-trust/source/anchors
    elif [[ ${ID:-} =~ (debian|ubuntu|mint) || ${ID_LIKE:-} =~ (debian|ubuntu|mint) ]]; then
        certdir=/usr/local/share/ca-certificates
    else
        certdir=${1:-}
    fi

    [[ ${certdir:-} ]] || {
        echo -e "${FAIL}Unable to autodetect OS using /etc/os-release${RSET}"
        return 1
    }

    echo -e "${VERB}Using certificate directory: $certdir${RSET}"

    # Create a temporary file for the extracted certificates
    local extracted_certs="$tmpdir/extracted_certs.pem"

    echo -e "${VERB}Extracting certificates from bundle...${RSET}"
    if ! openssl pkcs7 -print_certs -inform "$certform" -in "$certfile" >"$extracted_certs" 2>/dev/null; then
        echo -e "${FAIL}Failed to extract certificates from bundle${RSET}"
        return 1
    fi

    echo -e "${VERB}Processing extracted certificates...${RSET}"
    local initial_total=$TOTAL_CERTS
    process_certificates "$extracted_certs" "$certdir" "dod"
    local processed_count=$((TOTAL_CERTS - initial_total))

    echo -e "${VERB}Processed $processed_count certificates from DoD bundle${RSET}"

    # Clean up temporary files
    rm -f "$extracted_certs"

    if [ $processed_count -eq 0 ]; then
        echo -e "${FAIL}No certificates were processed from the DoD bundle${RSET}"
        return 1
    fi

    return 0
}

# Function to fetch certificate list dynamically
fetch_cert_list() {
    echo -e "${VERB}Fetching certificate list from $ORG_CERT_BASE_URL${RSET}"

    # Create a temporary file for the raw HTML
    local tmp_html=$(mktemp)
    local tmp_fixed=$(mktemp)

    # Fetch the directory listing
    if ! curl -sL \
        -H "Accept: text/html" \
        -H "User-Agent: Mozilla/5.0" \
        "$ORG_CERT_BASE_URL/" >"$tmp_html"; then
        echo -e "${FAIL}Failed to fetch directory listing${RSET}" >&2
        rm -f "$tmp_html" "$tmp_fixed"
        return 1
    fi

    echo -e "${VERB}Parsing certificate list...${RSET}"

    # Try to fix malformed HTML and extract links
    if command -v xmllint &>/dev/null; then
        # Fix common HTML issues and convert to XHTML
        echo '<root>' >"$tmp_fixed"
        cat "$tmp_html" >>"$tmp_fixed"
        echo '</root>' >>"$tmp_fixed"

        # Use xmllint to parse and extract certificate links
        xmllint --html --xpath "//a[contains(@href, '.crt')]/@href" "$tmp_fixed" 2>/dev/null |
            sed -n 's/.*href="\([^"]*\.crt\)".*/\1/p' |
            while read -r line; do
                # Clean up the path and decode URL encoding
                basename=$(basename "$line")
                printf '%b\n' "${basename//%/\\x}"
            done
    else
        # Fallback to basic grep/sed if xmllint is not available
        grep -o 'href="[^"]*\.crt"' "$tmp_html" |
            sed -e 's/href="//g' -e 's/"$//g' -e 's/^\/Certificates\///g' |
            while read -r line; do
                basename=$(basename "$line")
                printf '%b\n' "${basename//%/\\x}"
            done
    fi

    rm -f "$tmp_html" "$tmp_fixed"
}

# Add global variables for metrics
declare -i TOTAL_CERTS=0
declare -i PEM_CERTS=0
declare -i DER_CERTS=0
declare -i PKCS7_CERTS=0
declare -i FAILED_CERTS=0
declare -i SKIPPED_CERTS=0 # Add skipped certificates counter

# Update verify_certificate function to track metrics
verify_certificate() {
    local cert_file=$1
    local verbose=${2:-false}
    local temp_cert

    ((TOTAL_CERTS++))

    if [ ! -f "$cert_file" ] || [ ! -s "$cert_file" ]; then
        ((SKIPPED_CERTS++))
        ((TOTAL_CERTS--))
        return 1
    fi

    # Try different certificate formats
    if openssl x509 -noout -in "$cert_file" 2>/dev/null; then
        if $verbose; then
            echo -e "${VERB}Valid PEM certificate${RSET}"
        fi
        ((PEM_CERTS++))
        return 0
    fi

    # Try converting potential PKCS7 to PEM
    temp_cert=$(mktemp)
    if openssl pkcs7 -noout -in "$cert_file" 2>/dev/null; then
        if $verbose; then
            echo -e "${VERB}Converting PKCS7 to PEM...${RSET}"
        fi
        if openssl pkcs7 -print_certs -in "$cert_file" >"$temp_cert" 2>/dev/null; then
            mv "$temp_cert" "$cert_file"
            ((PKCS7_CERTS++))
            return 0
        fi
    fi
    rm -f "$temp_cert"

    # Try converting potential DER to PEM
    temp_cert=$(mktemp)
    if openssl x509 -inform DER -in "$cert_file" -out "$temp_cert" 2>/dev/null; then
        if $verbose; then
            echo -e "${VERB}Converting DER to PEM...${RSET}"
        fi
        mv "$temp_cert" "$cert_file"
        ((DER_CERTS++))
        return 0
    fi
    rm -f "$temp_cert"

    ((FAILED_CERTS++))
    ((TOTAL_CERTS--)) # Decrement total for failed certificates
    return 1
}

# Function to download and process organization certificates
process_org_certs() {
    local certdir="/usr/local/share/ca-certificates/org"
    local tmpdir
    tmpdir=$(mktemp -d)
    trap '[[ -d ${tmpdir:-} ]] && rm -fr $tmpdir' EXIT INT TERM

    echo -e "${VERB}Processing organization certificates...${RSET}"
    echo -e "${VERB}Temp directory: $tmpdir${RSET}"
    echo -e "${VERB}Creating certificate directory: $certdir${RSET}"
    sudo mkdir -p "$certdir"

    # Verify that a processing mode is selected
    if ! $org_use_combined_pem && ! $org_use_individual_certs && $process_org_certs_flag; then
        echo -e "${FAIL}Error: Must specify -p <filename> for combined PEM file, -i for individual certificates, or -f for dynamic fetch${RSET}"
        exit 1
    fi

    # Process combined PEM file if specified
    if $org_use_combined_pem; then
        if [ ! -f "$org_pem_file" ]; then
            echo -e "${FAIL}Combined PEM file not found: $org_pem_file${RSET}"
            exit 1
        fi
        echo -e "${VERB}Processing combined certificate file: $org_pem_file${RSET}"
        process_certificates "$org_pem_file" "$certdir" "org"
        return
    fi

    # Process individual certificates if specified
    if $org_use_individual_certs; then
        local cert_list=()
        local processed_count=0

        if $org_use_dynamic_list; then
            echo -e "${VERB}Using dynamically fetched certificate list${RSET}"

            # Fetch and store the certificate list with better error handling
            while IFS= read -r line; do
                if [[ -n "$line" && "$line" == *.crt ]]; then
                    echo -e "${VERB}Found certificate: $line${RSET}"
                    cert_list+=("$line")
                fi
            done < <(fetch_cert_list)

            if [ ${#cert_list[@]} -eq 0 ]; then
                echo -e "${FAIL}No certificates found in repository${RSET}"
                echo -e "${VERB}Falling back to static list${RSET}"
                cert_list=("${ORG_CERTS[@]}")
            else
                echo -e "${VERB}Found ${#cert_list[@]} certificates in repository${RSET}"
                # Print found certificates
                for cert in "${cert_list[@]}"; do
                    echo -e "${VERB}- $cert${RSET}"
                done
            fi
        else
            echo -e "${VERB}Using static certificate list${RSET}"
            cert_list=("${ORG_CERTS[@]}")
        fi

        # Download and process each certificate
        for cert in "${cert_list[@]}"; do
            # Clean the certificate filename to remove any path components
            local cert_name="${cert##*/}"
            local cert_url="${ORG_CERT_BASE_URL}/${cert_name// /%20}"
            local cert_file="$tmpdir/${cert_name}"

            echo -e "${VERB}Downloading certificate: $cert_name${RSET}"
            echo -e "${VERB}URL: $cert_url${RSET}"

            if ! curl -sSL --fail "$cert_url" -o "$cert_file"; then
                echo -e "${FAIL}Failed to download certificate: $cert${RSET}"
                continue
            fi

            if [ ! -f "$cert_file" ] || [ ! -s "$cert_file" ]; then
                echo -e "${FAIL}Certificate file is empty or does not exist: $cert${RSET}"
                continue
            fi

            echo -e "${VERB}Verifying certificate: $cert${RSET}"
            if ! verify_certificate "$cert_file" true; then
                echo -e "${FAIL}Invalid certificate file: $cert${RSET}"
                continue
            fi

            echo -e "${VERB}Installing certificate: $cert${RSET}"
            if sudo cp "$cert_file" "$certdir/"; then
                echo -e "${PASS}Successfully installed certificate: $cert${RSET}"
                ((processed_count++))
                ((TOTAL_CERTS++))
                ((PEM_CERTS++))
                track_metric "org" "processed"
            else
                echo -e "${FAIL}Failed to install certificate: $cert${RSET}"
                ((FAILED_CERTS++))
                track_metric "org" "failed"
            fi
        done
        echo -e "${VERB}Processed $processed_count certificates from organization bundle${RSET}"
    fi
}

# Function to process ca-certificates.crt
process_ca_certificates() {
    local ca_cert_file
    ca_cert_file=$(find_ca_cert_file)
    local certdir=/usr/local/share/ca-certificates
    if [ -f "$ca_cert_file" ]; then
        local initial_total=$TOTAL_CERTS
        process_certificates "$ca_cert_file" "$certdir" "ca"
        local processed_count=$((TOTAL_CERTS - initial_total))
        echo -e "${VERB}Processed $processed_count certificates from ca-certificates${RSET}"
    else
        echo -e "${WARN}ca-certificates.crt not found in /etc/ssl/certs directory${RSET}"
    fi
}

# Add function to display summary
display_summary() {
    echo -e "\n${HIGH}Certificate Processing Summary:${RSET}"

    # Process each bundle type with counts
    echo -e "\n${HIGH}Bundle Details:${RSET}"
    local bundle_types=("dod" "org" "ca")
    local bundle_names=("DoD" "Organization" "CA")

    for i in "${!bundle_types[@]}"; do
        local type="${bundle_types[$i]}"
        local name="${bundle_names[$i]}"
        local processed=${BUNDLE_METRICS["${type}_processed"]-0}
        local failed=${BUNDLE_METRICS["${type}_failed"]-0}
        local skipped=${BUNDLE_METRICS["${type}_skipped"]-0}

        if [ $processed -gt 0 ] || [ $failed -gt 0 ] || [ $skipped -gt 0 ]; then
            echo -e "${VERB}${name} Bundle:${RSET}"
            echo -e "  Processed: $processed certificates"
            [ $failed -gt 0 ] && echo -e "${FAIL}  Failed:    $failed certificates${RSET}"
            [ $skipped -gt 0 ] && echo -e "${WARN}  Skipped:   $skipped duplicates${RSET}"
        fi
    done

    # Certificate type totals
    echo -e "\n${HIGH}Certificate Types:${RSET}"
    [ $PEM_CERTS -gt 0 ] && echo -e "${VERB}PEM certificates:${RSET} $PEM_CERTS"
    [ $DER_CERTS -gt 0 ] && echo -e "${VERB}DER certificates converted:${RSET} $DER_CERTS"
    [ $PKCS7_CERTS -gt 0 ] && echo -e "${VERB}PKCS7 certificates converted:${RSET} $PKCS7_CERTS"

    # Overall totals
    echo -e "\n${HIGH}Overall Results:${RSET}"
    echo -e "${VERB}Total certificates processed:${RSET} $TOTAL_CERTS"
    [ $FAILED_CERTS -gt 0 ] && echo -e "${FAIL}Failed certificates:${RSET} $FAILED_CERTS"
    [ $SKIPPED_CERTS -gt 0 ] && echo -e "${WARN}Skipped certificates:${RSET} $SKIPPED_CERTS"

    # Final status
    if [ $FAILED_CERTS -eq 0 ] && [ $SKIPPED_CERTS -eq 0 ]; then
        echo -e "\n${PASS}All certificates processed successfully${RSET}"
    else
        echo -e "\n${WARN}Processing completed with warnings/failures${RSET}"
    fi
}

# Function to update CA certificates based on distro
update_ca_certificates() {
    local skipped_count=0
    if command -v update-ca-certificates &>/dev/null; then
        # Capture output to parse for skipped certificates
        local output
        if $DEBUG; then
            output=$(sudo update-ca-certificates 2>&1)
            echo "$output"
        else
            output=$(sudo update-ca-certificates 2>&1 | grep -v "^rehash: warning: skipping")
            echo "$output"
        fi
        # Extract the number of added certificates
        local added_count
        added_count=$(echo "$output" | grep -o '[0-9]\+ added' | cut -d' ' -f1)
        # Add to our metrics if we found a number
        if [[ -n "$added_count" ]]; then
            TOTAL_CERTS=$((TOTAL_CERTS + added_count))
            PEM_CERTS=$((PEM_CERTS + added_count))
        fi
        skipped_count=$(echo "$output" | grep -c "warning: skipping")
    elif command -v update-ca-trust &>/dev/null; then
        if $DEBUG; then
            sudo update-ca-trust extract
            output=$(trust dump --filter "pkcs11:object-type=cert" 2>&1)
            echo "$output"
        else
            sudo update-ca-trust extract >/dev/null 2>&1
            output=$(trust dump --filter "pkcs11:object-type=cert" 2>&1 | grep -v "duplicate certificate")
            echo "$output"
        fi
        skipped_count=$(echo "$output" | grep -c "duplicate certificate")
    else
        echo -e "${FAIL}No supported CA certificate update mechanism found${RSET}"
        return 1
    fi

    # Only show total skipped count in non-debug mode
    echo "SKIPPED_IN_UPDATE=$skipped_count"
    SKIPPED_CERTS=$((SKIPPED_CERTS + skipped_count))
    track_metric "system" "skipped" "$skipped_count"
    debug_metrics "After update-ca-certificates"
}

# Only execute
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    # Initialize counters and arrays
    declare -A BUNDLE_METRICS
    BUNDLE_METRICS=() # Explicitly initialize the associative array
    TOTAL_CERTS=0
    PEM_CERTS=0
    DER_CERTS=0
    PKCS7_CERTS=0
    FAILED_CERTS=0
    SKIPPED_CERTS=0

    # Initialize bundle metrics
    for bundle in dod org ca; do
        BUNDLE_METRICS["${bundle}_processed"]=0
        BUNDLE_METRICS["${bundle}_failed"]=0
        BUNDLE_METRICS["${bundle}_skipped"]=0
    done

    debug_metrics "Initial state"

    # Process ca-certificates.crt
    if $process_ca_certs_flag; then
        echo -e "${VERB}Processing ca-certificates.crt...${RSET}"
        process_ca_certificates
    else
        echo -e "${VERB}Skipping ca-certificates.crt processing...${RSET}"
    fi

    # Process DoD certificates
    if $process_dod_certs_flag; then
        echo -e "${VERB}Processing DoD certificates...${RSET}"
        if ! process_dod_certs; then
            echo -e "${FAIL}DoD certificate processing failed${RSET}"
        fi
    else
        echo -e "${VERB}Skipping DoD certificates processing...${RSET}"
    fi

    # Process organization certificates
    if $process_org_certs_flag; then
        echo -e "${VERB}Processing organization certificates...${RSET}"
        process_org_certs
    else
        echo -e "${VERB}Skipping organization certificates processing...${RSET}"
    fi

    # Update CA certificates if not skipped
    if ! $skip_update_flag; then
        echo -e "${VERB}Updating CA certificates...${RSET}"
        update_ca_certificates
    else
        echo -e "${VERB}Skipping CA certificates update...${RSET}"
    fi

    # Always show summary regardless of debug mode
    display_summary

    # Final success message
    echo -e "${PASS}Certificate processing$(! $skip_update_flag && echo ' and update') completed successfully.${RSET}"
fi
