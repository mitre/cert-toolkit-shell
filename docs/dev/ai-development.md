# AI Development Guide

## Project Context Setup

### Critical Files

```bash
/Users/alippold/github/mitre/cert-toolkit/cert-toolkit-shell/src/cert-manager.sh
/Users/alippold/github/mitre/cert-toolkit/cert-toolkit-shell/src/lib/core.sh
/Users/alippold/github/mitre/cert-toolkit/cert-toolkit-shell/src/lib/config.sh
/Users/alippold/github/mitre/cert-toolkit/cert-toolkit-shell/src/lib/menu.sh
```

### Context Requirements

Ensure Claude understands:

1. Current project state
2. Planned work
3. Standards references
4. Documentation requirements

## Successful Patterns

### 1. Documentation-First Development

- Start with clear documentation goals
- Establish standards early
- Keep documentation in sync with code
- Use documentation as development guide

### 2. Incremental Improvement

- Small, focused changes
- Verify each step
- Document progress
- Build on successes

### 3. Test-Driven Development

- Write test requirements first
- Document test scenarios
- Implement gradually
- Verify thoroughly

## Development Flow

1. Load critical files
2. Review current context
3. Follow implementation standards
4. Update documentation

## Development Workflow

### 1. Initial Setup

- Load critical files
- Review current context
- Check implementation standards
- Review test requirements

### 2. Implementation

- Follow module patterns
- Add test coverage
- Update documentation
- Verify standards

### 3. Testing

- Write unit tests
- Add integration tests
- Test edge cases
- Verify output

### 4. Documentation

- Update relevant docs
- Add cross-references
- Document changes
- Update progress

## Challenges & Solutions

### 1. Documentation Organization

Challenge:

- Large amount of documentation
- Multiple focus areas
- Cross-referencing needs
- Maintaining consistency

Solution:

- Clear directory structure
- Consistent naming
- Strong cross-references
- Regular organization review

### 2. Standards Implementation

Challenge:

- Multiple standards to follow
- Complex interactions
- Varying requirements
- Implementation details

Solution:

- Centralize standards documentation
- Clear implementation guides
- Practical examples
- Regular validation

### 3. Testing Framework

Challenge:

- Complex test scenarios
- Environment setup
- Cross-platform needs
- Maintaining consistency

Solution:

- Structured test organization
- Clear test documentation
- Container-based testing
- Comprehensive test matrix

## Best Practices

### 1. Working with AI

- Provide clear context
- Break down complex tasks
- Verify suggestions
- Document decisions

### 2. Documentation Management

- Keep related content together
- Use consistent formatting
- Maintain cross-references
- Regular updates

### 3. Implementation Approach

- Start with standards
- Document requirements
- Test thoroughly
- Verify implementation

## Tips for Success

### 1. Clear Communication

- Be specific about requirements
- Provide necessary context
- Ask for clarification
- Verify understanding

### 2. Incremental Progress

- Break down large tasks
- Document each step
- Verify progress
- Build on success

### 3. Quality Focus

- Follow standards
- Write tests
- Document changes
- Review thoroughly

## Lessons Learned

### What Worked Well

1. Documentation Organization
   - Clear structure
   - Consistent naming
   - Strong cross-references
   - Regular review

2. Standards Implementation
   - Centralized documentation
   - Clear requirements
   - Practical examples
   - Regular validation

3. Testing Approach
   - Structured organization
   - Clear documentation
   - Container-based testing
   - Comprehensive coverage

### Areas for Improvement

1. Initial Setup
   - More detailed context
   - Better environment docs
   - Clearer prerequisites
   - Setup verification

2. Progress Tracking
   - Better status updates
   - Clear milestones
   - Regular reviews
   - Documentation updates

3. Documentation Maintenance
   - Regular reviews
   - Consistency checks
   - Update verification
   - Cross-reference validation

## Future Recommendations

### 1. Project Setup

- Document context clearly
- Establish standards early
- Set up testing framework
- Create documentation structure

### 2. Development Flow

- Follow documented standards
- Write tests first
- Update documentation
- Regular reviews

### 3. Maintenance

- Regular updates
- Consistency checks
- Cross-reference validation
- Documentation review

## Related Documentation

- [Implementation Standards](standardization.md)
- [Development Progress](progress.md)
- [Testing Guide](../testing/README.md)
- [Documentation Standards](../standards/documentation.md)

## Quick References

- [Implementation Standards](standardization.md)
- [Development Progress](progress.md)
- [TODO List](todo.md)
- [Test Writing](../testing/writing-tests.md)
- [Module System](../tech/modules.md)

## Real-World Challenges & Lessons

### Avoiding Development Loops

1. The Mock Framework Trap
   - Initial Approach: Built complex mock framework
   - Problem: Spent days on framework instead of tests
   - Solution: Direct testing through application
   - Lesson: Sometimes simpler is better

2. Breaking Test-Edit Cycles
   Example Loop:
   ```bash
   Edit code → Tests fail
   Revert edit → Old tests pass
   Re-apply edit → Tests fail again
   ```
   Solution:
   - Add detailed debugging
   - Test manually first
   - Verify real-world behavior
   - Align test expectations
   - Document actual behavior

### Recognizing AI/User Loop Patterns

1. Signs of a Problematic Loop
   - Repeating same suggestions
   - Alternating between solutions
   - Growing complexity
   - Loss of clear progress

2. Breaking the Loop
   - Step back and reassess
   - Document current state
   - Verify assumptions
   - Start with manual testing
   - Build from working state

### Example: Debug System Development

Initial Loop:
```bash
# Problematic Approach
1. Complex mocking
2. State tracking
3. Indirect testing
4. Growing complexity

# Solution
1. Direct testing
2. Manual verification
3. Debug output
4. Clear expectations
```

### Practical Solutions

1. Early Warning Signs
   - Solution growing complex
   - Testing getting indirect
   - Repeating patterns
   - Lack of progress

2. Recovery Steps
   - Document current state
   - Test manually
   - Verify behavior
   - Simplify approach
   - Start with working code

3. Prevention Strategies
   - Regular progress checks
   - Clear success criteria
   - Direct testing first
   - Document assumptions

### Communication Patterns

1. Effective Approaches
   - Clear problem statements
   - Real-world examples
   - Direct testing results
   - Documentation focus

2. Warning Signs
   - Circular discussions
   - Growing complexity
   - Unclear progress
   - Repeated attempts

## Quick Escape Strategies

1. Documentation Checkpoint
   - Document current state
   - List assumptions
   - Define success criteria
   - Plan next steps

2. Testing Reset
   - Start with manual tests
   - Document behavior
   - Verify expectations
   - Build from working state

3. Communication Reset
   - Clear problem statement
   - Current state summary
   - Desired outcome
   - Step-by-step plan
