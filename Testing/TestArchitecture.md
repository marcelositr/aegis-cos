---
title: Test Architecture
title_pt: Arquitetura de Testes
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - TestArchitecture
description: Organizing and structuring tests for maintainability and scalability.
description_pt: Organizando e estruturando testes para manutenibilidade e escalabilidade.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Test Architecture

## Description

Test architecture structures tests for maintainability:
- Test organization
- Test data management
- Test fixtures
- Test execution strategy

## Purpose

**When test architecture matters:**
- For large test suites
- For multiple test types
- For team collaboration
- For maintainability at scale

**When simple structure suffices:**
- For small projects
- For single test type
- For temporary tests

**The key question:** How should we organize tests for maintainability?

## Structure

```
tests/
├── __init__.py
├── conftest.py           # Shared fixtures
├── unit/
│   ├── __init__.py
│   ├── test_models.py
│   └── test_services.py
├── integration/
│   ├── __init__.py
│   └── test_api.py
├── e2e/
│   ├── __init__.py
│   └── test_flows.py
└── fixtures/
    ├── __init__.py
    └── sample_data.py
```

## Fixtures

```python
# conftest.py
import pytest
from database import TestDatabase

@pytest.fixture
def db():
    with TestDatabase() as db:
        yield db

@pytest.fixture
def sample_user():
    return {"name": "Test User", "email": "test@example.com"}
```

## Test Organization

```python
# Test naming: test_<method>_<expected_behavior>
def test_user_create_success():
    ...

def test_user_create_duplicate_email():
    ...
```

## Failure Modes

- **No test organization** → hard to find and run tests → slow development → structure tests by type (unit, integration, e2e)
- **Duplicated test fixtures** → inconsistent test data → flaky tests → centralize fixtures in conftest.py or shared modules
- **Shared mutable state between tests** → order-dependent failures → non-deterministic results → isolate test state and clean up
- **No test data management** → stale test data → false failures → use factories and fixtures for reproducible test data
- **Mixing test types** → slow unit tests → delayed feedback → separate fast unit tests from slow integration/E2E tests
- **Missing test categorization** → cannot run subsets → inefficient CI → tag tests by speed, feature, and priority
- **No conftest sharing** → fixture duplication → maintenance burden → use hierarchical conftest.py files for fixture inheritance

## Anti-Patterns

### 1. No Test Organization

**Bad:** All tests in a single flat directory with no structure — unit, integration, and E2E tests mixed together
**Why it's bad:** Running a specific test type is impossible — you cannot run just the fast tests for quick feedback, and the CI pipeline cannot categorize tests by speed
**Good:** Structure tests by type (unit, integration, e2e) and by feature — use separate directories and configure CI to run each type independently

### 2. Duplicated Test Fixtures

**Bad:** Each test file creates its own test data, fixtures, and setup code independently
**Why it's bad:** Test data is inconsistent across files — one test creates a user with email "test@test.com" and another with "user@example.com", and when the schema changes, every file must be updated
**Good:** Centralize fixtures in `conftest.py` or shared modules — one source of truth for test data, updated in one place when the schema changes

### 3. Mixing Test Types

**Bad:** Slow integration tests mixed with fast unit tests in the same test suite, all running together
**Why it's bad:** Developers cannot get quick feedback — running the test suite takes 10 minutes because it includes database tests, network calls, and file I/O
**Good:** Separate fast unit tests from slow integration/E2E tests — run unit tests on every commit, integration tests on PR, and E2E tests on a schedule

### 4. Shared Mutable State Between Tests

**Bad:** Tests that modify global state, shared databases, or singleton objects without cleanup
**Why it's bad:** Test results depend on execution order — running tests individually passes, but running the full suite fails with mysterious errors
**Good:** Isolate test state — each test should create its own data, use transaction rollback, and clean up after itself regardless of pass or fail

## Best Practices

### 1. Use conftest.py

```python
# Share fixtures across tests
# Avoid duplication
```

### 2. Test Organization

```python
# Group by type: unit, integration, e2e
# Group by feature: users, orders, payments
```

### 3. Test Data

```python
# Create reusable test data
# Use factories
```

## Related Topics

- [[UnitTesting]]
- [[IntegrationTesting]]
- [[E2ETesting]]
- [[TestCoverage]]
- [[Mocks]]
- [[CiCd]]
- [[CodeQuality]]
- [[BDD]]
