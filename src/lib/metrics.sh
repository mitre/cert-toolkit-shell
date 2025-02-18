#!/bin/bash

# Guard against multiple loading
if [[ -n "${METRICS_LOADED:-}" ]]; then
    return 0
fi
declare -r METRICS_LOADED=true

# Initialize metrics storage
declare -A CERT_METRICS
declare -A BUNDLE_METRICS

# Metric types
METRIC_TYPES=(
    "total"
    "processed"
    "failed"
    "skipped"
    "pem"
    "der"
    "pkcs7"
)

# Initialize metrics
init_metrics() {
    debug "Initializing metrics system"
    # Initialize global counters
    for type in "${METRIC_TYPES[@]}"; do
        CERT_METRICS["${type}"]=0
    done

    # Initialize bundle-specific metrics
    for bundle in "dod" "org" "ca"; do
        for type in "${METRIC_TYPES[@]}"; do
            BUNDLE_METRICS["${bundle}_${type}"]=0
        done
    done
    debug "Metrics system initialized" # Fixed syntax error: removed extra `)}`
    return 0
}

# Update metrics with atomic operation
update_metric() {
    local bundle="$1"     # Bundle name (dod, org, ca)
    local type="$2"       # Metric type (processed, failed, etc.)
    local count="${3:-1}" # Amount to increment (default: 1)

    debug "Updating metric: ${bundle}/${type} += ${count}"
    # Update bundle-specific metric
    BUNDLE_METRICS["${bundle}_${type}"]=$((BUNDLE_METRICS["${bundle}_${type}"] + count))

    # Update global metric
    CERT_METRICS["${type}"]=$((CERT_METRICS["${type}"] + count))

    # Special handling for processed certificates
    if [[ "$type" == "processed" ]]; then
        CERT_METRICS["total"]=$((CERT_METRICS["total"] + count))
    fi
    debug "New value for ${bundle}/${type}: $(get_metric "$bundle" "$type")"
}

# Get metric value
get_metric() {
    local bundle="$1"
    local type="$2"

    if [[ -n "$bundle" ]]; then
        echo "${BUNDLE_METRICS["${bundle}_${type}"]:-0}"
    else
        echo "${CERT_METRICS["${type}"]:-0}"
    fi
}

# Print metrics report
print_metrics() {
    local verbose="${1:-false}"

    echo -e "\n${HIGH}Certificate Processing Summary:${RSET}"

    # Overall totals
    echo -e "\n${HIGH}Overall Results:${RSET}"
    echo -e "${VERB}Total certificates processed:${RSET} $(get_metric "" "total")"
    echo -e "${VERB}PEM certificates:${RSET} $(get_metric "" "pem")"
    echo -e "${VERB}DER certificates:${RSET} $(get_metric "" "der")"
    echo -e "${VERB}PKCS7 certificates:${RSET} $(get_metric "" "pkcs7")"

    # Bundle details
    echo -e "\n${HIGH}Bundle Details:${RSET}"
    for bundle in "dod" "org" "ca"; do
        local processed=$(get_metric "$bundle" "processed")
        local failed=$(get_metric "$bundle" "failed")
        local skipped=$(get_metric "$bundle" "skipped")

        if ((processed > 0 || failed > 0 || skipped > 0)); then
            echo -e "${VERB}${bundle^^} Bundle:${RSET}"
            echo -e "  Processed: $processed"
            ((failed > 0)) && echo -e "${FAIL}  Failed:    $failed${RSET}"
            ((skipped > 0)) && echo -e "${WARN}  Skipped:   $skipped${RSET}"
        fi
    done

    # Final status
    if (($(get_metric "" "failed") == 0 && $(get_metric "" "skipped") == 0)); then
        echo -e "\n${PASS}All certificates processed successfully${RSET}"
    else
        echo -e "\n${WARN}Processing completed with warnings/failures${RSET}"
    fi
}
