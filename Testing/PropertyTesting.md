---
title: Property-Based Testing
title_pt: Testes Baseados em Propriedades
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - PropertyTesting
description: Testing by specifying properties that should hold for all inputs.
description_pt: Testando especificando propriedades que devem ser válidas para todas as entradas.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Property-Based Testing

## Description

Property-based testing verifies properties that should hold for any valid input. Instead of testing specific cases, you test invariants.

## Purpose

**When property-based testing is valuable:**
- For mathematical/property-based functions
- For testing serialization/deserialization
- For finding edge cases automatically
- When many test cases would be needed

**When example-based testing suffices:**
- For simple, obvious cases
- For UI testing
- When properties are hard to define

**The key question:** Can we define properties that should always hold?

## Examples

```python
# Using hypothesis
from hypothesis import given, strategies as st

def reverse_twice(s):
    return s[::-1][::-1]

def test_reverse_twice(s):
    result = reverse_twice(s)
    assert result == s

# Test for any string
@given(st.text())
def test_reverse_twice_property(s):
    assert reverse_twice(s) == s

@given(st.lists(st.integers()))
def test_sort_idempotent(lst):
    sorted_lst = sorted(lst)
    assert sorted(sorted_lst) == sorted_lst
```

## Anti-Patterns

### 1. Poor Property Selection

**Bad:** Defining properties that are trivially true (e.g., `len(sort(x)) == len(x)`) or always false
**Why it's bad:** Tests pass without catching any bugs — the property does not capture a meaningful invariant of the system, giving false confidence
**Good:** Choose properties that capture meaningful invariants — round-trip equality, idempotency, commutativity, and boundary preservation

### 2. Non-Deterministic Properties

**Bad:** Properties that depend on system time, random values, or external state
**Why it's bad:** Tests are flaky — they sometimes fail for reasons unrelated to the code, and developers lose trust in the test suite
**Good:** Isolate non-deterministic sources and inject them as parameters — the property should depend only on its inputs, not on the environment

### 3. Not Combining with Example-Based Tests

**Bad:** Relying solely on property-based tests without any example-based tests
**Why it's bad:** Obvious bugs are not caught during development — property tests find edge cases, but example tests document expected behavior and catch regressions quickly
**Good:** Use example-based tests for documentation and common cases, property tests for edge cases and invariants — they complement each other

### 4. Ignoring Shrinking Failures

**Bad:** A property test fails and the shrunk minimal failing case is not examined
**Why it's bad:** The root cause is harder to identify — the shrunk case is the simplest reproduction of the bug, and ignoring it means debugging the complex original input instead
**Good:** Always examine the shrunk failing case — it is the most direct path to understanding and fixing the bug

## Best Practices

### 1. Find Good Properties

```python
# Example properties:
# - round(trip) = original (serialization)
# - sort after sort = sort (idempotent)
# - f(g(x)) = x if f and g are inverses
```

### 2. Use Shrinking

```python
# Hypothesis shrinks failing examples
# Automatically finds minimal failing case
```

## Failure Modes

- **Poor property selection** → properties that are trivially true or always false → tests pass without catching bugs or always fail → choose properties that capture meaningful invariants of the system
- **Insufficient input generation** → generator does not cover edge cases → bugs in boundary conditions missed → use combinators to generate edge cases explicitly alongside random inputs
- **Non-deterministic properties** → property depends on time, random, or external state → flaky tests that sometimes fail → isolate non-deterministic sources and inject them as parameters
- **Property testing performance-sensitive code** → property testing generates thousands of inputs → performance degradation in test suite → limit test iterations for slow functions and use targeted generators
- **Ignoring shrinking failures** → minimal failing case not examined → root cause harder to identify → always examine the shrunk failing case to understand the bug
- **Properties that are too broad** → single property tries to verify everything → unclear what aspect failed when test fails → write focused properties that verify one invariant each
- **Not combining with example-based tests** → relying solely on property tests → obvious bugs not caught during development → use example-based tests for documentation and property tests for edge cases

## Related Topics

- [[Fuzzing]]
- [[UnitTesting]]
- [[MutationTesting]]
- [[Algorithms]]
- [[DataStructures]]
- [[Determinism]]
- [[Idempotency]]
- [[TestCoverage]]
