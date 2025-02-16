# Certificate Management Tools Documentation

## Table of Contents

- [Overview](#overview)
- [Tool Comparison](#tool-comparison)
- [Installation & Dependencies](#installation--dependencies)
- [Usage Guide](#usage-guide)
- [Technical Details](#technical-details)
- [Development Guide](#development-guide)
- [Troubleshooting](#troubleshooting)

## Overview

The SAF Training Lab Environment provides two implementations for certificate management:

- **Python Implementation** (`scripts/add_dod_certs.py`): Modern, feature-rich solution
- **Shell Implementation** (`scripts/add-dod-certs.sh`): Lightweight, fast alternative

### Supported Certificate Types

- DoD Root Certificates
- Organization-specific Certificates
- System CA Certificates

## Tool Comparison

| Feature                    | Python Script | Shell Script |
|---------------------------|---------------|--------------|
| Certificate Chain Validation| ✅           | ❌           |
| Metrics Tracking          | ✅ Advanced    | ✅ Basic     |
| Duplicate Detection       | ✅ Content-based| ✅ Name-based|
| Format Conversion         | ✅ All formats | ✅ Basic     |
| Performance              | Standard      | ✅ Faster    |
| Dependencies             | More          | ✅ Minimal   |
| Error Handling           | ✅ Detailed    | Basic       |
| SSL Fallback Support     | ✅ Robust      | Basic       |

## Installation & Dependencies

### Python Implementation

Required packages:

- Python 3.8+
- cryptography
- requests
- urllib3
- OpenSSL

### Shell Implementation

Required packages:

- OpenSSL
- curl
- xmllint (optional)
- awk
- grep

## Usage Guide

Both scripts support the same command-line arguments:

### Certificate Processing Flow

#### Dependency Check

- Verify required tools are installed
- Install missing dependencies if possible

#### Certificate Source Processing

- System CA certificates
- DoD certificates
- Organization certificates

#### Certificate Validation

- Format validation (PEM/DER/PKCS7)
- Chain validation (Python only)
- Expiration check
- Duplicate detection

#### Installation

- Convert to appropriate format
- Generate unique filename
- Set proper permissions
- Update system CA store

#### Metrics and Reporting

- Track success/failure rates
- Count by certificate type
- Format conversion tracking
- Display detailed summary

## Technical Details

### Python Package Structure

```
saf-cert-manager/
├── src/
│   └── saf_cert_manager/
│       ├── __init__.py
│       ├── cli.py             # Command-line interface
│       ├── cert_manager.py    # Main CertificateManager class
│       ├── validators.py      # CertificateValidator class
│       ├── utils/
│       │   ├── __init__.py
│       │   ├── metrics.py     # CertMetrics class
│       │   ├── colors.py      # Colors class
│       │   └── package_mgr.py # PackageManager class
│       └── exceptions.py      # Custom exceptions
├── tests/
│   ├── __init__.py
│   ├── test_cert_manager.py
│   ├── test_validators.py
│   └── test_utils/
├── pyproject.toml
├── setup.cfg
├── requirements.txt
└── README.md
```

## Development Guide

### Process combined PEM file

```
./add_dod_certs.py -c -d -p my-combined-certs.pem
```

### Process individual certificates

```
./add_dod_certs.py -c -d -i
```

### Dynamic certificate list fetch

```
./add_dod_certs.py -c -d -i -f
```

## Additional Features

- Enhanced certificate chain validation
- Certificate revocation checking
- Automated backup/restore
- JSON/YAML configuration support
- API integration options

## Troubleshooting

### Common Issues

#### SSL Verification Failures

**Solution:** Check system CA certificates or use -s flag

#### Permission Errors

**Solution:** Run with sudo or check directory permissions

#### Certificate Format Issues

**Solution:** Ensure certificate is in valid format

### Logging

- Python script: Use -v flag for detailed logging
- Shell script: Set set -x for debug output

## Contributing

For details on:

- Code style
- Testing requirements
- Pull request process
- Documentation standards

See the Contributing Guide.
