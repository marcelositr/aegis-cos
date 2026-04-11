---
title: Testing
title_pt: Testes
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - TestingOverview
description: Overview of software testing methodologies and practices.
description_pt: Visão geral das metodologias e práticas de testes de software.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Testing

## Description

Testing is the process of evaluating software to identify defects and verify functionality. It spans multiple levels and methodologies, from unit tests to end-to-end testing, each serving different purposes in the development lifecycle.

Effective testing strategies combine multiple approaches:
- **Unit Testing**: Testing individual components in isolation
- **Integration Testing**: Testing component interactions
- **System Testing**: Testing complete systems
- **Acceptance Testing**: Testing against user requirements

## Purpose

**When testing is essential:**
- For preventing regressions
- For ensuring code quality
- For enabling refactoring safely
- For validating requirements
- For compliance (safety-critical systems)

**When testing may be minimal:**
- For prototypes/MVPs with short lifespans
- For throwaway scripts
- When time to market is critical

**The key question:** What level of confidence do we need that this code works?
- **Integration Testing**: Testing how components work together
- **System Testing**: Testing complete system functionality
- **Acceptance Testing**: Verifying business requirements

## Testing Pyramid

```
        /\
       /  \      E2E Tests (few)
      /----\    Integration Tests (some)
     /______\   Unit Tests (many)
```

- Many fast unit tests at the base
- Fewer integration tests in the middle  
- Minimal E2E tests at the top

## Testing Types

### By Level

| Type | What it Tests | Speed | Examples |
|------|---------------|-------|----------|
| Unit | Individual functions/methods | Fast | pytest, JUnit |
| Integration | Component interactions | Medium | integration tests |
| System | Complete application | Slow | E2E tests |
| Acceptance | Business requirements | Slow | user acceptance tests |

### By Purpose

| Type | Purpose |
|------|---------|
| Functional | Feature correctness |
| Regression | No new bugs |
| Performance | Speed/load handling |
| Security | Vulnerability detection |
| Smoke | Basic functionality |

## Testing Best Practices

### 1. Test Behavior, Not Implementation

```python
# Good - test behavior
def test_order_total():
    order = Order(items=[Item(price=10), Item(price=20)])
    assert order.total() == 30

# Bad - test implementation
def test_order_total_uses_sum():
    # Don't test HOW it works, test WHAT it does
```

### 2. Use Descriptive Names

```python
def test_user_creation_with_valid_email_succeeds():
    ...

def test_user_creation_with_invalid_email_raises_error():
    ...
```

### 3. Follow AAA Pattern

```python
def test_something():
    # Arrange - set up test data
    service = MyService()
    
    # Act - perform the action
    result = service.do_something()
    
    # Assert - verify the result
    assert result == expected
```

### 4. Keep Tests Independent

```python
# Each test should work in isolation
# No dependencies between tests
# Clean up after yourself
```

## Test-Driven Development (TDD)

```
1. Red - Write a failing test
2. Green - Write minimal code to pass
3. Refactor - Improve code while keeping tests passing
```

## Continuous Testing

```yaml
# CI pipeline example
test:
  script:
    - pytest --cov --cov-report=xml
  coverage: '/Coverage: \d+%/'
```

## Anti-Patterns

### 1. Inverted Test Pyramid

**Bad:** More E2E tests than unit tests — heavy reliance on slow, brittle end-to-end tests
**Why it's bad:** The test suite takes forever to run, is flaky due to environmental dependencies, and debugging failures requires tracing through the entire stack
**Good:** Follow the testing pyramid — many fast unit tests at the base, fewer integration tests in the middle, minimal E2E tests at the top

### 2. Tests Not Run in CI

**Bad:** Tests only run locally on developer machines, with no automated enforcement in the CI pipeline
**Why it's bad:** Broken code gets merged to main — developers forget to run tests, skip them under time pressure, or have different test configurations
**Good:** Make test execution a blocking CI gate — code cannot merge until all tests pass, ensuring every change is verified automatically

### 3. Tests as Afterthought

**Bad:** Writing tests after the code is complete, designed specifically to pass rather than to verify behavior
**Why it's bad:** Tests are biased toward the happy path, edge cases are missed, and the code architecture is not driven by testability requirements
**Good:** Write tests first (TDD) or alongside code — tests that drive design produce more testable architectures and catch more bugs

### 4. Ignoring Test Maintenance Cost

**Bad:** Tests that require constant updates every time the implementation changes — tightly coupled to internal details
**Why it's bad:** The test suite becomes a liability — developers spend more time maintaining tests than writing code, and tests are deleted rather than fixed
**Good:** Write tests against stable interfaces and behavior, not implementation details — tests should survive refactoring as long as the observable behavior is unchanged

## Related Topics

- [[Testing MOC]]
- [[UnitTesting]]
- [[TDD]]
- [[CiCd]]
- [[CodeQuality]]

## Failure Modes

- **Testing implementation instead of behavior** → tests assert internal state or method calls → tests break on refactoring even when behavior is correct → test observable behavior and outputs, not internal workings
- **Test pyramid inverted** → more E2E tests than unit tests → slow test suite and flaky CI → follow testing pyramid: many unit tests, fewer integration tests, minimal E2E tests
- **Tests not run in CI** → tests only run locally → broken code merged to main → make test execution a blocking CI gate that must pass before merge
- **Shared test state between tests** → tests depend on each other or shared data → flaky tests that pass or fail based on execution order → each test must be independent with its own setup and teardown
- **No test for error paths** → only happy path tested → bugs in error handling and edge cases → test failure scenarios, invalid inputs, and boundary conditions alongside happy paths
- **Tests as afterthought** → tests written after code without TDD → tests designed to pass, not to verify behavior → write tests first to drive design and ensure testable architecture
- **Ignoring test maintenance cost** → tests require constant updates as code changes → test suite becomes liability → write tests against stable interfaces and behavior, not implementation details

## Examples

### Unit Test Example

```python
def test_calculate_total():
    items = [PriceItem(10), PriceItem(20), PriceItem(30)]
    assert calculate_total(items) == 60

def test_calculate_total_empty():
    assert calculate_total([]) == 0
```

### Integration Test Example

```python
def test_user_can_register():
    response = client.post('/register', {
        'email': 'test@example.com',
        'password': 'password123'
    })
    assert response.status_code == 201
    
    user = db.query(User).filter_by(email='test@example.com').first()
    assert user is not None
```

## Best Practices

1. **Follow the testing pyramid** - Many unit, fewer integration, few E2E
2. **Test behavior, not implementation** - Focus on what, not how
3. **Use meaningful test names** - Describe the scenario and expected outcome
4. **Keep tests independent** - No shared state between tests
5. **Run tests in CI** - Automatic feedback on every change
