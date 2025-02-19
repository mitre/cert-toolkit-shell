# Fix Permissions Script Example

The `fix-permissions.sh` script demonstrates several shell scripting best practices for handling file permissions and providing user feedback.

## Usage

```bash
# Normal run
./scripts/fix-permissions.sh

# With debug output
DEBUG=true ./scripts/fix-permissions.sh
```

## Example Output

```bash
Unit Tests:
✓ verify_setup.bats                    755

Test Libraries:
✓ debug_helper.bash                    755
✓ test_helper.bash                     755

Scripts:
➜ new_script.sh                        755  # Changed
✓ existing_script.sh                   755  # Already correct

All files verified!
Files checked: 5
Files changed: 1
```

## Key Features

### 1. Cross-Platform Compatibility

```bash
# Uses ls -l instead of stat for permissions
original_mode=$(ls -l "$file" | awk '{print $1}')
if [[ "$original_mode" == "-rwxr-xr-x" ]]; then
    # File is already executable
fi
```

### 2. Visual Status Indicators

- ✓ (green): File already has correct permissions
- ➜ (yellow): File permissions were updated
- Error messages in red
- Debug information in blue

### 3. State Tracking

```bash
# Using temp files to track counts across subshells
COUNTS_FILE=$(mktemp)
echo "0" > "$COUNTS_FILE"         # checked
echo "0" > "$COUNTS_FILE.changed" # changed

trap 'rm -f "$COUNTS_FILE" "$COUNTS_FILE.changed"' EXIT
```

### 4. Directory-Based Organization

```bash
test/unit:Unit Tests
test/integration:Integration Tests
test/lib:Test Libraries
...
```

## Common Patterns

1. **Permission Checking**:
   - Check current permissions before modifying
   - Use consistent comparison method
   - Handle errors gracefully

2. **User Feedback**:
   - Color-coded output for quick understanding
   - Different icons for different states
   - Summary statistics at the end

3. **Error Handling**:
   - Check directory existence and access
   - Validate permission changes
   - Report errors clearly

4. **Debug Support**:
   - Optional debug output
   - Show before/after states
   - Clear progress indicators

## Related Documentation

- [Security Standards](../standards/security.md)    # Updated relative path
- [Command Reference](../user/commands.md)         # Added missing reference
- [Configuration Guide](../tech/config.md)         # Added missing reference
