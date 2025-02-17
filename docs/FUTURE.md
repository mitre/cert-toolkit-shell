# Future Enhancements

## Planned Features

### Certificate Verification

- Add glob pattern support to verify command
  - Support recursive directory traversal
  - Handle mixed inputs (files/directories/patterns)
  - Add progress indication for large sets
  - Parallel processing for large directories
  - Proper exit status when some files fail
  - Summary statistics across multiple files

  ```bash
  # Example usage:
  cert-manager.sh verify "certs/*.pem"              # Verify all .pem files
  cert-manager.sh verify -r "certs/"                # Recursive verify all files
  cert-manager.sh verify "certs/*.{pem,crt,key}"    # Multiple extensions
  ```

### Certificate Management

- Add certificate renewal tracking
- Add expiration notifications
- Support for certificate revocation lists (CRL)
- Support for OCSP validation

### Security Enhancements

- Add integrity verification for downloaded bundles
- Support for hardware security modules (HSM)
- Enhanced private key protection

### Performance Improvements

- Parallel processing for large certificate sets
- Caching of validation results
- Optimized certificate chain building

### User Interface

- Interactive mode for certificate operations
- Progress bars for long operations
- Better error reporting and recovery
