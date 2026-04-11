---
title: Fail Fast Principle
title_pt: Princípio Fail Fast
layer: principles
type: concept
priority: high
version: 1.0.0
tags:
  - Principles
  - FailFast
description: Detect and report errors as early as possible in development and execution.
description_pt: Detectar e reportar erros o mais cedo possível em desenvolvimento e execução.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Fail Fast Principle

## Description

Fail fast means detecting and reporting errors as early as possible. When something is wrong:
- Fail immediately rather than proceeding with invalid state
- Make the failure obvious and visible
- This makes bugs easier to find and fix

## Purpose

**When fail fast is valuable:**
- During development to catch bugs early
- For invalid inputs that can't be handled
- When continuing would cause worse problems
- For configuration and setup validation

**When fail fast may not be appropriate:**
- When failure can be gracefully handled
- For optional features that can be skipped
- In systems that must always stay running

**The key question:** Would continuing with invalid state make debugging harder?

## Examples

### Good - Fail Fast

```python
def divide(a, b):
    if b == 0:
        raise ValueError("Division by zero")  # Fail immediately!
    return a / b

def create_user(name, email):
    if not name:
        raise ValueError("Name is required")  # Fail immediately!
    if not email:
        raise ValueError("Email is required")  # Fail immediately!
    return User(name=name, email=email)
```

### Bad - Fail Late

```python
def divide(a, b):
    # Returns None or wrong value instead of raising error
    if b == 0:
        return None  # Silent failure - fails late!
    return a / b

# Caller doesn't know division failed!
result = divide(10, 0)  # Returns None
result + 5  # Fails later with confusing error
```

### Good - Input Validation

```python
class UserService:
    def __init__(self, repository):
        if repository is None:
            raise ValueError("repository is required")
        self.repository = repository
    
    def create_user(self, user_data):
        # Validate at boundary
        if not user_data.get('email'):
            raise ValueError("email is required")
        if '@' not in user_data['email']:
            raise ValueError("invalid email format")
        
        return self.repository.save(user_data)
```

### Bad - Deferred Validation

```python
# Validates too late - after data is used
def create_user(user_data):
    user = User()
    user.name = user_data.get('name')  # Used before validation
    # ... lots of code ...
    # Then validation happens somewhere else
    # Failure happens far from the source
```

## Anti-Patterns

### 1. Silent Failure Masking

**Bad:** Catching exceptions and returning `None`, empty results, or default values without logging
**Why it's bad:** The error is hidden and the system continues with invalid state — the real bug surfaces much later in an unrelated place, making it nearly impossible to trace
**Good:** Fail loudly — log the error with full context and either handle it explicitly or re-throw a meaningful exception

### 2. Failing Fast in Production Without Degradation

**Bad:** Crashing the entire service when a single request has invalid input
**Why it's bad:** One bad request takes down the service for all users — the cure is worse than the disease
**Good:** Fail fast in development, degrade gracefully in production — reject the bad request but keep serving others

### 3. Assertion-Only Validation

**Bad:** Relying on `assert` statements for critical validation that gets disabled in production builds
**Why it's bad:** When assertions are disabled (e.g., Python with `-O` flag), all validation disappears and invalid data flows through the system
**Good:** Use explicit validation for critical invariants — assertions are for developer sanity checks, not production safety

### 4. Fail-Fast Without Useful Context

**Bad:** Throwing a generic "invalid input" error without specifying which field, what value was received, or what was expected
**Why it's bad:** Developers cannot diagnose the problem — they must reproduce it, add logging, and try again
**Good:** Include relevant context in failure messages — the field name, the received value, and the expected constraints

## Best Practices

### 1. Validate at Boundaries

```python
# Validate input at system boundary
def process_order(order_data):
    # Validate immediately
    if not order_data.get('items'):
        raise ValueError("order must have items")
    if not order_data.get('customer_id'):
        raise ValueError("customer_id required")
    
    # After validation, proceed with confidence
    return OrderService().create(order_data)
```

### 2. Use Assertions

```python
def process(data):
    # Fail fast on unexpected state
    assert data is not None, "data must not be None"
    assert len(data) > 0, "data must not be empty"
    
    # Proceed with confidence
    return transform(data)
```

### 3. Fail Loudly

```python
# Don't hide errors
def bad_example():
    try:
        # Some operation
        return result
    except Exception:
        return None  # Silent failure!

def good_example():
    try:
        return result
    except SpecificException as e:
        raise ProcessingError(f"Failed to process: {e}") from e
```

## Failure Modes

- **Failing fast in production without graceful degradation** → immediate crash on invalid input → complete service outage for users → fail fast in development, degrade gracefully in production with fallbacks
- **Silent failures masking root causes** → catching exceptions and continuing with invalid state → corrupted data propagates through system → never swallow exceptions; always log and either handle or re-throw
- **Fail-fast checks too expensive for production** → comprehensive validation on every operation → performance degradation → use sampled or probabilistic fail-fast checks in production, full checks in development
- **Missing fail-fast at system boundaries** → invalid input accepted deep into processing → debugging far from source of problem → validate all input at entry points before any processing begins
- **Assertion-only validation** → relying on assertions that are disabled in production → no validation in deployed code → use explicit validation, not just assertions, for critical invariants
- **Fail-fast without useful error messages** → immediate failure with no context → developers cannot diagnose the problem → include relevant context in failure messages
- **Inconsistent fail-fast behavior** → some paths fail fast, others fail late → unpredictable system behavior → establish and enforce consistent fail-fast policy across all code paths

## Related Topics

- [[InputValidation]]
- [[Determinism]]
- [[Testing]]
- [[Monitoring]]
- [[Alerting]]
- [[ErrorHandling]]
- [[CiCd]]
- [[QualityGates]]

## Key Takeaways

- Fail Fast detects and reports errors as early as possible, failing immediately rather than proceeding with invalid state that corrupts downstream systems
- Valuable during development to catch bugs early, for invalid inputs that cannot be handled, and for configuration validation
- Not appropriate when failure can be gracefully handled, for optional features that can be skipped, or in systems that must always stay running
- Tradeoff: immediate obvious failures easy to debug versus risk of taking down entire services on single bad requests
- Main failure mode: silent failures mask root causes and let corrupted data propagate through the system, surfacing bugs in unrelated places that are nearly impossible to trace
- Best practice: validate all input at system boundaries, fail loudly with useful context, use explicit validation not just assertions for critical invariants, and degrade gracefully in production while failing fast in development
- Related: input validation, determinism, testing, monitoring, alerting, error handling, CI/CD, quality gates
