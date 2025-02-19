# Test Coverage Matrix

## Command Tests

| Command | Flags | Test File | Status |
|---------|-------|-----------|---------|
| process | --ca-skip | menu/process_test.bats | ✓ |
| process | --dod-skip | menu/process_test.bats | ✓ |
| verify | <cert-file> | menu/verify_test.bats | ✓ |
| info | -s, -i, -d, -a | menu/info_test.bats | ✓ |
| config | --list, --verbose | menu/config_test.bats | ✓ |

## Edge Cases

- Empty certificate files
- Invalid PEM format
- Missing permissions
- Network failures
- Timeout conditions

## Performance Tests

- Large certificate bundles
- Multiple concurrent operations
- Memory consumption
- CPU utilization

## Menu System Tests

1. Exit Codes
   - Standard return values (0-5)
   - Error propagation
   - State cleanup

2. Error Messages
   - GNU format compliance
   - Help suggestions
   - Debug information

3. Option Handling
   - Long/short forms
   - Value processing
   - Combinations

4. Output Format
   - Level control
   - Stream selection
   - Debug output

## Test Coverage Matrix

| Component | Test File | Status |
|-----------|-----------|---------|
| Exit Codes | menu/exit_test.bats | TODO |
| Error Messages | menu/error_test.bats | TODO |
| Option Handling | menu/option_test.bats | TODO |
| Output Format | menu/output_test.bats | TODO |
