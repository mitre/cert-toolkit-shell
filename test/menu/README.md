# Menu System Test Coverage

## Test Matrix

| Category            | Command            | Test Cases         | Status | File                      |
| ------------------- | ------------------ | ------------------ | ------ | ------------------------- |
| **Basic Commands**  |
|                     | No Args            | Help Display       | ✓      | menu_test.bats            |
|                     | --version          | Version Info       | ✓      | menu_test.bats            |
|                     | --help             | Help Display       | ✓      | menu_test.bats            |
| **Config Command**  |
|                     | config --list      | Config Display     | ✓      | menu_test.bats            |
|                     | config --verbose   | Detailed Config    | ✓      | menu_test.bats            |
|                     | config --set       | Value Setting      | TODO   | config_command_test.bats  |
|                     | config --help      | Command Help       | TODO   | config_command_test.bats  |
| **Process Command** |
|                     | process            | Default Processing | TODO   | process_command_test.bats |
|                     | process --ca-skip  | Skip CA Certs      | TODO   | process_command_test.bats |
|                     | process --dod-skip | Skip DoD Certs     | TODO   | process_command_test.bats |
|                     | process --org-skip | Skip Org Certs     | TODO   | process_command_test.bats |
|                     | process --pem-file | Use PEM File       | TODO   | process_command_test.bats |
| **Info Command**    |
|                     | info -s            | Show Subject       | TODO   | info_command_test.bats    |
|                     | info -i            | Show Issuer        | TODO   | info_command_test.bats    |
|                     | info -d            | Show Dates         | TODO   | info_command_test.bats    |
|                     | info -a            | Show All           | TODO   | info_command_test.bats    |
| **Error Cases**     |
|                     | Invalid Commands   | Error Message      | TODO   | error_test.bats           |
|                     | Missing Args       | Error Message      | TODO   | error_test.bats           |
|                     | Invalid Flags      | Error Message      | TODO   | error_test.bats           |
|                     | Bad Combinations   | Error Message      | TODO   | error_test.bats           |
| **Global Flags**    |
|                     | --debug            | Debug Output       | TODO   | flag_test.bats            |
|                     | --quiet            | Quiet Output       | TODO   | flag_test.bats            |
|                     | --verbose          | Verbose Output     | TODO   | flag_test.bats            |

## Test Categories

### 1. Basic Command Processing
- No arguments (help display)
- Version information (`--version`, `-v`)
- Help display (`--help`, `-h`)
- Invalid commands
- Unknown options

### 2. Global Flag Processing
```bash
# Global flags must work with all commands
--debug, -d     # Enable debug output
--help, -h      # Show help
--version, -v   # Show version
--quiet, -q     # Suppress normal output
--verbose       # Show detailed output
```

### 3. Command-Specific Options

#### Config Command
```bash
config --list              # Show current config
config --list --verbose    # Show detailed config
config --set KEY=VALUE     # Set config value
config --help             # Command-specific help
```

#### Process Command
```bash
process                   # Default processing
process --ca-skip        # Skip CA certs
process --dod-skip       # Skip DoD certs
process --org-skip       # Skip org certs
process --pem-file=FILE  # Use PEM file
process --individual     # Use individual certs
process --fetch-dynamic  # Use dynamic list
process --skip-update    # Skip store update
```

#### Info Command
```bash
info CERT -s    # Show subject
info CERT -i    # Show issuer
info CERT -d    # Show dates
info CERT -a    # Show all info
```

### 4. Error Handling

#### Command Errors
- Missing required arguments
- Invalid command combinations
- Unknown commands
- Wrong argument types

#### Flag Errors
- Invalid flag combinations
- Missing flag arguments
- Unknown flags
- Duplicate flags

#### Config Errors
- Invalid config keys
- Invalid config values
- Protected settings (DEBUG)
- Missing required values

## Test Organization

### 1. Basic Command Tests (`basic_command_test.bats`)
- Help display
- Version info
- No arguments
- Basic command recognition

### 2. Flag Processing Tests (`flag_test.bats`)
- Global flag handling
- Flag combinations
- Flag validation
- Flag precedence

### 3. Config Command Tests (`config_command_test.bats`)
- List operations
- Set operations
- Validation rules
- Error conditions

### 4. Process Command Tests (`process_command_test.bats`)
- Default processing
- Skip options
- File handling
- Update control

### 5. Info Command Tests (`info_command_test.bats`)
- Information display
- Format options
- Error handling
- Certificate parsing

### 6. Error Handling Tests (`error_test.bats`)
- Invalid inputs
- Missing arguments
- Wrong combinations
- Error messages

## Test Implementation Notes

1. Test Environment
   - Clean state before each test
   - Isolated configuration
   - Temporary directories
   - Mock certificates

2. Test Structure
   - Clear descriptions
   - Focused assertions
   - Error validation
   - Output verification

3. Best Practices
   - Test one thing per test
   - Verify all outputs
   - Check error states
   - Document edge cases
