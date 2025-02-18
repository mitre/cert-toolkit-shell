# Certificate Toolkit Library Documentation

## Module Dependency Order

```
utils.sh        (base utilities)
   ↓
debug.sh       (logging system)
   ↓
metrics.sh     (metric tracking)
   ↓
config.sh      (configuration)
   ↓
validators.sh  (certificate validation)
   ↓
processors.sh  (certificate processing)
   ↓
menu.sh        (user interface)
   ↓
core.sh        (main orchestration)
```

## Module Details

### utils.sh

Base utility functions and common resources.

**Key Functions:**

- `is_package_installed(package)` - Check if a package is installed
- `install_package(package)` - Install a package using system package manager
- `ensure_directory(dir)` - Ensure a directory exists
- `create_temp_dir()` - Create a temporary directory
- `cleanup_temp(dir)` - Clean up a temporary directory
- `get_os_type()` - Detect operating system type
- `download_file(url, output_file, quiet)` - Download a file

### debug.sh

Centralized logging and debugging system.

**Key Functions:**

- `error(message)` - Log error messages
- `warn(message)` - Log warning messages
- `info(message)` - Log informational messages
- `debug(message)` - Log debug messages
- `trace(message)` - Log trace messages
- `debug_metrics(location)` - Display metrics at a specific point
- `debug_certificate(cert_file, message)` - Debug certificate information

**Debug Levels:**

- ERROR (0) - Critical errors
- WARN (1) - Warnings
- INFO (2) - General information
- DEBUG (3) - Debugging information
- TRACE (4) - Detailed tracing

### metrics.sh

Certificate processing metrics tracking.

**Key Functions:**

- `init_metrics()` - Initialize metrics tracking
- `update_metric(bundle, type, count)` - Update a specific metric
- `get_metric(bundle, type)` - Get metric value
- `print_metrics(verbose)` - Display metrics summary

**Tracked Metrics:**

- Total certificates processed
- PEM/DER/PKCS7 certificates
- Failed/skipped certificates
- Bundle-specific metrics

### config.sh

Configuration management system.

**Key Functions:**

- `init_config(config_file)` - Initialize configuration
- `get_config(key, default)` - Get configuration value
- `set_config(key, value)` - Set configuration value
- `update_config_from_args()` - Update config from command line
- `validate_config()` - Validate configuration
- `print_config(verbose)` - Display current configuration

**Configuration Categories:**

- URLs (DOD_CERT_URL, ORG_CERT_BASE_URL)
- File paths
- Processing flags
- Certificate processing options
- Debug settings

### validators.sh

Certificate validation functionality.

**Key Functions:**

- `validate_certificate(cert_file, bundle_name, verbose)` - Validate certificate
- `get_cert_info(cert_file, info_type)` - Get certificate information
- `generate_cert_name(cert_file)` - Generate unique certificate name

**Validation Types:**

- PEM format
- DER format
- PKCS7 format
- Private key detection
- Date validation

### processors.sh

Certificate processing operations.

**Key Functions:**

- `process_bundle(bundle_file, target_dir, bundle_name, verbose)` - Process certificate bundle
- `process_single_certificate(cert_file, target_dir, bundle_name, verbose)` - Process single certificate
- `process_dod_certs(target_dir, verbose)` - Process DoD certificates
- `process_ca_certificates(verbose)` - Process CA certificates
- `process_org_certificate(cert_name, target_dir, verbose)` - Process organization certificate
- `update_ca_store(verbose)` - Update CA certificate store

### menu.sh

Command-line interface and user interaction.

**Key Functions:**

- `show_help()` - Display main help
- `show_command_help(command)` - Display command-specific help
- `parse_args(args)` - Parse command line arguments
- `main_menu(args)` - Main menu handler

**Commands:**

- process - Process certificates
- verify - Verify certificate
- info - Show certificate information
- config - Show/update configuration
- help - Show help information

### core.sh

Main application orchestration.

**Key Functions:**

- `init_application(config_file)` - Initialize application
- `process_certificates(verbose)` - Main processing workflow
- `main(args)` - Main execution function

**Responsibilities:**

- Module coordination
- Application flow control
- Error handling
- Result reporting

## Usage Example

```bash
# Import core module
source "$(dirname "${BASH_SOURCE[0]}")/lib/core.sh"

# Initialize application
init_application || exit 1

# Process command line arguments
parse_args "$@" || exit 1

# Execute main processing
process_certificates true
```
