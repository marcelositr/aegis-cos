---
title: Test Doubles
aliases:
  - Test Doubles
  - TestDoubles
  - Mocks
  - Stubs
  - Fakes
  - Spies
  - Dummies
  - Test Doubles Pattern
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - Doubles
  - Mocking
  - UnitTesting
description: Test replacements for real dependencies: dummies, stubs, spies, fakes, and mocks. Understanding when to use each type and the tradeoffs involved.
prerequisites:
  - "[[UnitTest]]"
  - "[[TestArchitecture]]"
estimated_read_time: 8 min
difficulty: intermediate
---

# Test Doubles

## Description

Test replacements for real dependencies that make tests faster, more reliable, and more focused. The term "test double" is the testing equivalent of stunt doubles in filmmaking — each type serves a specific purpose.

## Purpose

**When to use:**
- Isolating unit under test from external dependencies (databases, APIs, file systems)
- Speeding up tests by replacing slow I/O with in-memory alternatives
- Testing edge cases and failure scenarios that are hard to trigger with real dependencies
- Breaking circular dependencies in test setup

**When to avoid:**
- When the real dependency is fast, reliable, and side-effect free (e.g., a simple utility)
- When the double would be more complex than the real implementation
- When testing integration behavior — use the real dependency for integration tests

## Types of Test Doubles

### Decision Tree

```
Do you need to verify HOW the dependency was called?
├── YES → Use a MOCK
└── NO → Do you need to PROVIDE SPECIFIC RETURN VALUES?
         ├── YES → Use a STUB
         └── NO → Do you need a WORKING IMPLEMENTATION?
                  ├── YES → Use a FAKE
                  └── NO → Do you need to RECORD CALLS?
                           ├── YES → Use a SPY
                           └── NO → Use a DUMMY
```

### Comparison Table

| Type | Purpose | Verifies | Implementation | Example |
|------|---------|----------|----------------|---------|
| **Dummy** | Fill parameter lists | Nothing | Empty or null | `new DummyUserService()` passed but never called |
| **Stub** | Provide canned responses | State (return values) | Hardcoded responses | Returns `{"user": "test"}` for any `getUser()` call |
| **Spy** | Record calls made | State + interaction history | Records call count, args | Verifies `sendEmail()` was called 3 times with specific args |
| **Fake** | Working simplified implementation | Behavior | In-memory working version | In-memory database instead of PostgreSQL |
| **Mock** | Verify interactions | Interactions (calls, order, args) | Pre-programmed expectations | Verifies `log()` was called exactly once with `"ERROR"` |

## Detailed Examples

### Stub — Canned Responses

```python
class UserDatabaseStub:
    """Stub that provides predetermined responses for user database queries."""

    def __init__(self):
        self._users = {
            "user-1": {"id": "user-1", "name": "Alice", "role": "admin"},
            "user-2": {"id": "user-2", "name": "Bob", "role": "viewer"},
        }

    def get_user(self, user_id: str) -> dict | None:
        return self._users.get(user_id)

    def get_users_by_role(self, role: str) -> list[dict]:
        return [u for u in self._users.values() if u["role"] == role]

    def save_user(self, user: dict) -> dict:
        # Stubs typically don't implement write behavior
        raise NotImplementedError("Stub does not support write operations")

# Usage
def test_admin_can_delete_user():
    db = UserDatabaseStub()
    service = UserService(db)
    result = service.delete_user("admin-1", "user-2")
    assert result.success is True
```

**When to choose:** Testing how the unit reacts to different inputs from dependencies.
**When NOT to choose:** When you need to verify that the unit called the dependency correctly.

### Fake — Working In-Memory Implementation

```python
class InMemoryDatabase:
    """Fake: a working database implementation backed by a dict."""

    def __init__(self):
        self._tables: dict[str, list[dict]] = {}
        self._next_id: dict[str, int] = {}

    def create_table(self, name: str, schema: dict):
        self._tables[name] = []
        self._next_id[name] = 1

    def insert(self, table: str, row: dict) -> int:
        row_id = self._next_id[table]
        self._tables[table].append({"id": row_id, **row})
        self._next_id[table] += 1
        return row_id

    def query(self, table: str, **filters) -> list[dict]:
        results = self._tables.get(table, [])
        if filters:
            results = [
                r for r in results
                if all(r.get(k) == v for k, v in filters.items())
            ]
        return results

    def delete(self, table: str, **filters) -> int:
        original_count = len(self._tables.get(table, []))
        self._tables[table] = [
            r for r in self._tables.get(table, [])
            if not all(r.get(k) == v for k, v in filters.items())
        ]
        return original_count - len(self._tables[table])
```

**When to choose:** Testing behavior that requires a working implementation (CRUD operations, complex queries).
**When NOT to choose:** When the fake would need to replicate complex behavior (concurrency, transactions, persistence).

### Mock — Interaction Verification

```python
from unittest.mock import MagicMock, call

def test_order_service_sends_confirmation_email():
    # Arrange
    email_service = MagicMock()
    order_repo = MagicMock()
    order_repo.get_order.return_value = {
        "id": "order-1",
        "user_id": "user-1",
        "user_email": "alice@example.com",
        "total": 99.99,
    }

    service = OrderService(order_repo, email_service)

    # Act
    service.confirm_order("order-1")

    # Assert — verify interactions
    email_service.send.assert_called_once_with(
        to="alice@example.com",
        subject="Order Confirmed",
        body="Your order order-1 has been confirmed. Total: $99.99"
    )
```

**When to choose:** Verifying that the unit sends the right messages/calls to dependencies.
**When NOT to choose:** When you only care about outcomes, not how they're achieved (prefer stubs/fakes).

### Spy — Call Recording

```python
class NotificationSpy:
    """Records all notifications sent without actually sending them."""

    def __init__(self):
        self.sent_notifications: list[dict] = []

    def send(self, user_id: str, message: str, channel: str = "email"):
        self.sent_notifications.append({
            "user_id": user_id,
            "message": message,
            "channel": channel,
        })

def test_system_alerts_on_critical_failure():
    spy = NotificationSpy()
    monitor = SystemMonitor(notification_service=spy, threshold=90)

    # Simulate CPU at 95%
    monitor.check_system(cpu_usage=95, memory_usage=70)

    assert len(spy.sent_notifications) == 1
    assert "CPU" in spy.sent_notifications[0]["message"]
    assert spy.sent_notifications[0]["channel"] == "pager"
```

**When to choose:** Need to verify multiple calls or complex interaction patterns.
**When NOT to choose:** When a simple mock assertion would suffice.

### Dummy — Placeholder

```python
def test_user_creation_ignores_logger():
    # Logger is a dummy — we don't care what it does
    dummy_logger = NullLogger()
    service = UserService(database=InMemoryDatabase(), logger=dummy_logger)

    user = service.create_user("alice", "alice@example.com")
    assert user.name == "alice"
```

**When to choose:** Dependency is required by constructor but not used in the test scenario.
**When NOT to choose:** When the dependency's behavior affects the test outcome.

## Rules

1. **Prefer fakes over mocks** — fakes test behavior, mocks test implementation details
2. **Keep doubles simple** — if the double is more complex than the real thing, rethink your design
3. **Sync doubles with contracts** — stale doubles pass tests while production breaks
4. **Isolate double state** — reset doubles between tests to prevent cross-test pollution
5. **Doubles are code** — version them, review them, test them

## Examples

### Good Example — Fake + Stub Combination

```python
class OrderServiceTest:
    def test_complete_order_sends_email_and_updates_status(self):
        # Fake for behavior verification
        db = InMemoryDatabase()
        db.create_table("orders", {"user_id": str, "status": str, "total": float})

        # Stub for input data
        email_service = NotificationSpy()

        service = OrderService(db, email_service)

        order_id = db.insert("orders", {
            "user_id": "user-1",
            "status": "pending",
            "total": 50.0,
            "user_email": "user1@test.com",
        })

        service.complete_order(order_id)

        # Verify state change (via fake)
        orders = db.query("orders", id=order_id)
        assert orders[0]["status"] == "completed"

        # Verify notification sent (via spy)
        assert len(email_service.sent_notifications) == 1
```

### Bad Example — Over-Mocked Tests

```python
def test_process_order_bad():
    # Over-specified: every interaction is mocked
    db = MagicMock()
    email = MagicMock()
    payment = MagicMock()
    inventory = MagicMock()
    analytics = MagicMock()
    notification = MagicMock()
    cache = MagicMock()

    db.get_order.return_value = {"id": 1, "status": "pending"}
    payment.charge.return_value = {"success": True}
    inventory.reserve.return_value = True

    service = OrderService(db, email, payment, inventory, analytics, notification, cache)
    service.process_order(1)

    # Verifying implementation details, not behavior
    db.get_order.assert_called_once_with(1)
    payment.charge.assert_called_once_with(...)
    inventory.reserve.assert_called_once_with(...)
    email.send.assert_called_once_with(...)
    analytics.track.assert_called_once_with(...)
```

**Why it's bad:** This test is coupled to the implementation. If `process_order` changes to call `payment.charge` twice or in a different order, the test fails even though the outcome is correct. Use fakes for state verification, reserve mocks for interaction-critical paths (email, notifications).

## Anti-Patterns

### Mock Overuse (Brittle Tests)

Mocking every dependency and verifying every interaction.

**Why it's bad:** Tests become coupled to implementation details. Any refactoring breaks tests even when behavior is correct. Prefer fakes for state-based testing.

### The Double That Lies

A test double whose behavior diverges from the real dependency.

**Why it's bad:** Tests pass but production fails. The double returns `{"success": True}` while the real API returns `{"error": "rate limited"}`. Keep doubles simple, contract-test them against real implementations.

### Shared Mutable Doubles

Test doubles that maintain state across test runs.

**Why it's bad:** Test order dependency, flaky tests, "works on my machine." Reset doubles in `setUp`/`beforeEach`, or create fresh instances per test.

## Failure Modes

- **Mock overuse** → brittle tests when too many interactions verified → use mocks sparingly, prefer fakes and stubs for state-based testing
- **Behavioral differences** → production bugs when fake behavior diverges from real implementation → keep fakes simple, document assumptions, contract-test fakes against real implementations
- **Stale doubles** → passing tests with broken production code when doubles don't reflect actual API → sync doubles with contracts, use contract testing, generate doubles from interfaces
- **Shared mutable state** → flaky tests when doubles maintain state across tests → reset doubles between tests, use fresh instances, avoid global double state
- **Over-complex fakes** → maintenance burden when fakes replicate too much production logic → prefer simple fakes that cover only the behavior needed by tests
- **Incorrect double type** → test confusion when wrong double used for purpose → understand the spectrum: dummy → stub → spy → fake → mock, choose based on what you need to verify
- **Leaking production concerns** → tests fail when doubles don't isolate from infrastructure → design doubles for test isolation, never call real network/disk from unit tests

## Best Practices

- **Follow the test double pyramid**: many fakes/stubs at the base, fewer mocks at the top
- **Keep doubles under version control** — they are production code for tests
- **Generate doubles from interfaces** — use code generation or type checking to ensure doubles match real APIs
- **Use dependency injection** — makes it easy to swap real for doubles without changing test code
- **Test your fakes** — include tests that verify the fake behaves correctly for the scenarios your unit tests depend on
- **Prefer state-based over interaction-based testing** — verify outcomes, not the steps taken to achieve them
- **Document double assumptions** — what behavior does the fake simplify? What edge cases does it not cover?

## Related Topics

- [[UnitTest]]
- [[TestArchitecture]]
- [[IntegrationTesting]]
- [[ContractTesting]]
- [[Mocks]]

## Key Takeaways

- Test doubles replace real dependencies: dummy, stub, spy, fake, mock
- Choose based on what you need to verify: state (stub/fake) vs interaction (mock/spy)
- Prefer fakes over mocks — they test behavior, not implementation details
- Primary failure mode: double behavior diverges from real dependency
- Keep doubles simple, version them, and contract-test against real implementations
- Reset doubles between tests to prevent cross-test pollution
- Follow the double pyramid: many fakes/stubs, fewer mocks
