---
title: Integration Testing
title_pt: Testes de Integração
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - IntegrationTesting
description: Testing how components work together.
description_pt: Testando como componentes funcionam juntos.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Integration Testing

## Description

Integration tests verify how components work together. Unlike unit tests, they:
- Test multiple components
- May use real databases
- Are slower than unit tests
- Test real scenarios

## Purpose

**When integration testing is valuable:**
- After unit tests pass
- For testing component interactions
- For catching integration bugs
- For verifying database interactions

**When integration tests may be skipped:**
- For simple systems with few components
- When unit tests are comprehensive
- When component boundaries are stable

**The key question:** Do these components work correctly together?

## Examples

```python
# Test API and database together
def test_create_user(api_client, db):
    # Make API call
    response = api_client.post("/users", {"name": "John"})
    
    # Check response
    assert response.status_code == 201
    
    # Check database
    user = db.query("SELECT * FROM users WHERE name = 'John'")
    assert user is not None
```

## Anti-Patterns

### 1. Tests Depending on Shared Database State

**Bad:** Tests that rely on data created by other tests or leave data behind for subsequent tests
**Why it's bad:** Tests pass or fail based on execution order — running the full suite fails but individual tests pass, and debugging requires understanding the entire test sequence
**Good:** Use transaction rollback or database reset between tests — each test should create its own data and clean up after itself

### 2. Real External Service Calls in Tests

**Bad:** Integration tests that hit production APIs, payment gateways, or third-party services
**Why it's bad:** Tests incur real costs, hit rate limits, produce non-deterministic results, and may trigger real-world side effects (actual charges, real emails sent)
**Good:** Use test doubles, sandbox environments, or recorded responses for external services — never call production APIs from tests

### 3. Not Testing Failure Scenarios

**Bad:** Integration tests that only verify the happy path — successful API calls, database writes, and service responses
**Why it's bad:** You do not know how the system behaves when the database is down, the API returns 500, or the network times out — these are the scenarios that cause production outages
**Good:** Test network failures, timeouts, service unavailability, and error responses — use fault injection or mock services to simulate failure conditions

### 4. Slow Integration Tests Blocking CI

**Bad:** Integration tests that take minutes each, resulting in a CI pipeline that runs for 30+ minutes
**Why it's bad:** Developers skip running tests locally, feedback loops are too slow for productive development, and the team loses trust in the test suite
**Good:** Optimize test setup, use in-memory databases, parallelize test execution, and categorize tests by speed — fast tests run on every commit, slow tests run on a schedule

## Best Practices

### 1. Use Test Database

```python
@pytest.fixture
def test_db():
    # Create test database
    db = create_test_db()
    yield db
    # Cleanup
    db.drop()
```

### 2. Isolate Tests

```python
# Each test should be independent
# Clean state between tests
```

### 3. Balance with Unit Tests

```python
# Unit tests for logic
# Integration tests for interaction
```

## Failure Modes

- **Tests depending on shared database state** → tests interfere with each other through database → flaky tests that pass or fail based on execution order → use transaction rollback or database reset between tests
- **Real external service calls in tests** → tests hit production APIs → rate limiting, costs, and non-deterministic results → use test doubles or sandbox environments for external services
- **Tests not isolated from each other** → test A creates data that test B depends on → test suite becomes order-dependent → each test should create its own data and clean up after itself
- **Slow integration tests blocking CI** → integration tests take minutes per run → developers skip running tests locally → optimize test setup, use in-memory databases, and parallelize test execution
- **Integration tests without assertions** → test runs but does not verify outcomes → false positives in test results → assert both response and side effects (database state, emitted events)
- **Not testing failure scenarios** → only happy path integration tested → system behavior on failures unknown → test network failures, timeouts, and service unavailability scenarios
- **Test environment drift from production** → integration tests pass but production fails → environment differences mask real issues → use containerized test environments that mirror production configuration

## Related Topics

- [[UnitTesting]]
- [[TestArchitecture]]
- [[E2ETesting]]
- [[ContractTesting]]
- [[Docker]]
- [[DatabaseOptimization]]
- [[APIDesign]]
- [[Mocks]]
