# Test Categories Guide

## Unit Tests

Located in `test/unit/`

### Module Tests

```bash
# Example module test
@test "module: function performs specific action" {
    run module_function "input"
    assert_success
    assert_output "expected"
}
```

### Function Tests

```bash
# Example function isolation test
@test "function: handles edge case" {
    # Mock dependencies
    function dependency() { echo "mocked"; }
    
    # Test function
    run target_function
    
    # Verify behavior
    assert_success
}
```

### State Tests

```bash
# Example state management test
@test "state: maintains configuration" {
    # Set initial state
    CONFIG[KEY]="value"
    
    # Perform action
    run state_changing_function
    
    # Verify state maintained
    [ "${CONFIG[KEY]}" = "value" ]
}
```

## Integration Tests

Located in `test/integration/`

### Cross-Module Tests

```bash
# Example module interaction test
@test "integration: config affects processing" {
    # Set configuration
    run "${PROJECT_ROOT}/src/cert-manager.sh" config --set KEY=value
    
    # Test processing
    run "${PROJECT_ROOT}/src/cert-manager.sh" process
    
    # Verify interaction
    assert_success
}
```

## System Tests

Located in `test/system/`

### Workflow Tests

```bash
# Example end-to-end test
@test "workflow: certificate processing" {
    # Setup test certificates
    create_test_certs
    
    # Run full process
    run "${PROJECT_ROOT}/src/cert-manager.sh" process
    
    # Verify results
    assert_success
    assert_certs_installed
}
```
