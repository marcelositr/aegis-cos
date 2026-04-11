---
title: Unit Testing
title_pt: Testes Unitários
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - UnitTesting
description: Testing individual functions and methods in isolation.
description_pt: Testando funções e métodos individuais isoladamente.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Unit Testing

## Description

Unit tests verify individual functions/methods in isolation. Good unit tests:
- Are fast
- Don't depend on external systems
- Test one thing
- Have clear names
- Are repeatable

## Purpose

**When unit testing is essential:**
- For test-driven development (TDD)
- For catching bugs early
- For regression prevention
- For documenting expected behavior

**When unit testing may not be enough:**
- For integration behavior
- For system-level testing
- For performance testing
- For UI behavior

**The key question:** Can this be tested in isolation without external dependencies?

## Examples

```python
import unittest

class TestMathOperations(unittest.TestCase):
    def test_add(self):
        self.assertEqual(add(2, 3), 5)
    
    def test_add_negative(self):
        self.assertEqual(add(-1, 1), 0)
    
    def test_divide_by_zero(self):
        with self.assertRaises(ZeroDivisionError):
            divide(10, 0)

# Using pytest
def test_add():
    assert add(2, 3) == 5

def test_add_negative():
    assert add(-1, 1) == 0

@pytest.mark.parametrize("input,expected", [
    (2, 3, 5),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_addParameterized(input_a, input_b, expected):
    assert add(input_a, input_b) == expected
```

## Anti-Patterns

### 1. Testing Implementation Instead of Behavior

**Bad:** Asserting internal state, private method calls, or specific implementation details
**Why it's bad:** Tests break on every refactoring even when the observable behavior is correct — the test suite becomes a barrier to improvement rather than a safety net
**Good:** Test observable behavior and outputs — if the function produces the right result for given inputs, the implementation should be free to change

### 2. Tests Depending on External Systems

**Bad:** Unit tests that hit real databases, APIs, or file systems
**Why it's bad:** Tests become slow, flaky, and non-deterministic — a network outage or database lock causes test failures that have nothing to do with the code under test
**Good:** Mock all external dependencies — unit tests should test logic in isolation, using fakes or stubs for anything outside the unit's boundary

### 3. Tests with Shared Mutable State

**Bad:** One test modifies global state or a shared object that another test depends on
**Why it's bad:** Tests pass or fail based on execution order — running the full suite fails but running individual tests passes, and the bug is nearly impossible to reproduce
**Good:** Ensure each test is independent with clean setup and teardown — no test should depend on the side effects of another test

### 4. Not Testing Edge Cases and Error Paths

**Bad:** Only testing the happy path — valid inputs, normal conditions, expected behavior
**Why it's bad:** Bugs live in the edge cases — empty inputs, null values, boundary conditions, and error handling are where most production defects originate
**Good:** Test empty inputs, null values, boundaries, and error conditions alongside happy paths — use parameterized tests to cover multiple scenarios efficiently

## Best Practices

### 1. Arrange-Act-Assert

```python
def test_something():
    # Arrange - set up
    service = MyService()
    
    # Act - do something
    result = service.do_something()
    
    # Assert - check result
    assert result == expected
```

### 2. Test One Thing

```python
# Bad - tests multiple things
def test_order():
    assert order.total() == 100
    assert order.status == "pending"
    send_email(order)  # Side effect!

# Good - one assertion per test
def test_order_total():
    assert order.total() == 100

def test_order_pending():
    assert order.status == "pending"
```

## Failure Modes

- **Tests depending on external systems** → unit tests hit database or network → tests become slow, flaky, and non-deterministic → mock all external dependencies and test logic in isolation
- **Testing implementation instead of behavior** → tests assert internal state or method calls → tests break on refactoring even when behavior is correct → test observable behavior and outputs, not internal workings
- **Tests with shared mutable state** → one test modifies state used by another → test order dependency and flaky failures → ensure each test is independent with clean setup and teardown
- **Assertions without messages** → test fails with unclear reason → debugging takes longer than writing the test → include descriptive assertion messages explaining expected vs actual
- **Test coverage without assertion quality** → high coverage percentage but tests assert nothing → false confidence in code quality → verify that tests actually check meaningful behavior and outcomes
- **Not testing edge cases and error paths** → only happy path tested → bugs in error handling and boundary conditions → test empty inputs, null values, boundaries, and error conditions
- **Tests that are harder to maintain than code** → complex test setup and fixtures → test suite becomes liability → keep tests simple, focused, and easy to understand

## Related Topics

- [[TestCoverage]]
- [[Mocks]]
- [[IntegrationTesting]]
- [[TDD]]
- [[Refactoring]]
- [[CodeQuality]]
- [[PropertyTesting]]
- [[MutationTesting]]
