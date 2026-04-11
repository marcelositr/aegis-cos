---
title: Mocking
title_pt: Mocking
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - Mocking
description: Replacing real dependencies with test doubles.
description_pt: Substituindo dependências reais por test doubles.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Mocking

## Description

Mocking replaces real dependencies with test doubles:
- **Dummy**: Fills parameter list
- **Fake**: Simplified implementation
- **Stub**: Provides canned responses
- **Mock**: Verifies interactions

## Purpose

**When mocking is valuable:**
- For unit testing in isolation
- For testing code that depends on slow/external systems
- For simulating edge cases

**When mocking may indicate problems:**
- When too many mocks are needed
- When testing implementation rather than behavior
- When mocking hides integration issues

**The key question:** Can we test this unit without real dependencies?

```python
# Using unittest.mock
from unittest.mock import Mock, patch, MagicMock

def test_order_processing():
    # Create mock
    payment_gateway = Mock()
    payment_gateway.charge.return_value = True
    
    # Use mock
    order_service = OrderService(payment=payment_gateway)
    result = order_service.process_order(order)
    
    # Verify
    assert result.status == "paid"
    payment_gateway.charge.assert_called_once()

# Patch external dependencies
@patch('mymodule.external_api')
def test_external_api(mock_api):
    mock_api.return_value = {"status": "ok"}
    # Test uses mock
```

## Best Practices

### 1. Mock at Boundaries

```python
# Mock external services, not internal logic
# Mock database, not business logic
```

### 2. Don't Over-Mock

```python
# Don't mock everything
# Real objects for simple cases
```

## Failure Modes

- **Over-mocking creating fragile tests** → every dependency mocked → tests verify mock setup, not real behavior → mock only external boundaries and use real objects for internal dependencies
- **Mocks drifting from real implementation** → mock behavior differs from real service → tests pass but production fails → regularly validate mocks against real implementations with contract tests
- **Mocking value types and simple functions** → mocking pure functions or data structures → unnecessary complexity and test fragility → only mock side-effecting operations and external dependencies
- **Tests that only verify mock interactions** → asserting that method was called without checking result → tests pass even when behavior is wrong → verify outcomes and state changes, not just interactions
- **Mock state not reset between tests** → mock retains state from previous test → test order dependency and flaky failures → reset or recreate mocks in test setup for each test
- **Hidden coupling through mock expectations** → test expects specific call order or count → refactoring breaks tests even when behavior is correct → use loose mock expectations that verify behavior, not implementation
- **Not testing with real dependencies periodically** → mocks hide integration issues → integration bugs discovered only in production → run integration tests with real dependencies alongside mocked unit tests

## Anti-Patterns

### 1. Over-Mocking Creating Fragile Tests

**Bad:** Mocking every dependency, including internal classes and simple utility functions
**Why it's bad:** Tests verify mock setup rather than real behavior — the test passes because the mocks are configured correctly, not because the code works
**Good:** Mock only external boundaries (databases, APIs, file systems) — use real objects for internal dependencies and simple functions

### 2. Mocks Drifting from Real Implementation

**Bad:** A mock returns simplified or outdated responses that do not match the real service's behavior
**Why it's bad:** Tests pass but production fails — the mock's behavior diverges from the real service over time, and the test suite gives false confidence
**Good:** Regularly validate mocks against real implementations with contract tests — ensure mock responses match the actual service's API and behavior

### 3. Tests That Only Verify Mock Interactions

**Bad:** Asserting that a method was called with specific arguments without checking the actual result or state change
**Why it's bad:** The test passes even when the behavior is wrong — a method can be called correctly but produce incorrect results, and the test would not catch it
**Good:** Verify outcomes and state changes, not just interactions — assert the return value, the database state, or the emitted event, not just that a method was called

### 4. Hidden Coupling Through Mock Expectations

**Bad:** Tests that expect a specific call order or exact call count for mocked methods
**Why it's bad:** Refactoring the implementation breaks tests even when the observable behavior is unchanged — the test is coupled to the implementation, not the contract
**Good:** Use loose mock expectations that verify behavior, not implementation — assert that the right thing happened, not that it happened in a specific order

## Related Topics

- [[UnitTesting]]
- [[IntegrationTesting]]
- [[TestArchitecture]]
- [[DependencyInjection]]
- [[TDD]]
- [[Fakes]]
- [[Stubs]]
- [[ContractTesting]]
