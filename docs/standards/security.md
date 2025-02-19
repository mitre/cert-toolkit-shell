# Security Standards

## Certificate Handling

- Use OpenSSL 3.x or later
- Validate certificate chains
- Check revocation status
- Verify signatures

## File Security

```bash
# Executable permissions
chmod 755 bin/* scripts/*

# Configuration files
chmod 644 config/*

# Private certificates
chmod 600 certs/private/*
```

## Input Validation

```bash
# Path validation
validate_path() {
    local path="$1"
    if [[ ! -f "$path" ]]; then
        error "Invalid path: $path"
        return 1
    fi
}

# Certificate validation
validate_cert() {
    local cert="$1"
    if ! openssl x509 -in "$cert" -noout; then
        error "Invalid certificate: $cert"
        return 1
    fi
}
```

## Error Recovery

```bash
# Cleanup trap
trap 'cleanup_temp_files' EXIT

# Secure temporary files
create_temp_file() {
    mktemp -t cert-toolkit.XXXXXX
}

# Protected operations
process_cert() {
    local cert="$1"
    local temp_file
    
    temp_file=$(create_temp_file)
    chmod 600 "$temp_file"
    
    # Process certificate
    if ! openssl x509 -in "$cert" -out "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
}
```

## Best Practices

1. File Operations
   - Use secure temporary files
   - Clean up on exit
   - Set restrictive permissions

2. Certificate Processing
   - Validate before use
   - Check chain integrity
   - Handle errors gracefully

3. Environment
   - Clear sensitive variables
   - Use secure paths
   - Validate configuration

## Related Documentation

- [Security Policy](../../SECURITY.md)              # Updated to point to root
- [License](../../../LICENSE.md)                 # Updated path
- [Contributing Guide](../dev/contributing.md)    # Fixed relative path
- [Architecture](../dev/architecture.md)         # Fixed relative path
