---
title: Invariants
title_pt: Invariantes
layer: design
type: concept
priority: high
version: 1.0.0
tags:
  - Design
  - Invariants
description: Conditions that must always be true during the lifecycle of a system or component.
description_pt: Condições que devem ser verdadeiras sempre durante o ciclo de vida de um sistema ou componente.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Invariants

## Description

An invariant is a condition that must always be true during the execution of a program. It's a constraint that the system guarantees will hold, and if it doesn't, there's a bug in the system.

Invariants help:
- **Define correctness** - What "right" looks like
- **Guide implementation** - What code must maintain
- **Testing** - What to verify
- **Documentation** - What the system guarantees

## Purpose

**When invariants are critical:**
- Financial systems where balance must always balance
- Database systems with ACID properties
- Concurrent code where race conditions must be prevented
- Data validation that must always hold

**When invariants may be overkill:**
- Rapid prototypes with evolving requirements
- Experimental code where constraints change frequently
- Simple utility scripts

**The key question:** What conditions MUST always be true, no matter what?

## Types of invariants:
- **Class invariants** - Conditions on object's state
- **Loop invariants** - Conditions that hold before/after loop iteration
- **System invariants** - Cross-component guarantees
- **Business invariants** - Domain rules

## Examples

### Class Invariant

```python
class BankAccount:
    def __init__(self, balance: Decimal):
        self._balance = balance
    
    @property
    def balance(self) -> Decimal:
        return self._balance
    
    def deposit(self, amount: Decimal):
        if amount <= 0:
            raise ValueError("Deposit must be positive")
        self._balance += amount
    
    def withdraw(self, amount: Decimal):
        if amount <= 0:
            raise ValueError("Withdrawal must be positive")
        if amount > self._balance:
            raise InsufficientFundsError()
        self._balance -= amount
    
    # INVARIANT: balance is always non-negative
    # This is guaranteed by validation in withdraw()
```

### Business Invariant

```python
class Order:
    def __init__(self):
        self.items: list[OrderItem] = []
        self.status = OrderStatus.DRAFT
    
    def confirm(self):
        # INVARIANT: Can't confirm empty order
        if not self.items:
            raise CannotConfirmEmptyOrderError()
        
        # INVARIANT: Can't confirm with pending items
        for item in self.items:
            if not item.is_available:
                raise CannotConfirmWithUnavailableItemsError()
        
        self.status = OrderStatus.CONFIRMED
```

## Anti-Patterns

### 1. Silent Invariant Violations

**Bad:** An invariant check fails but the error is silently swallowed or logged without stopping execution
**Why it's bad:** Corrupted state propagates through the system, making the root cause nearly impossible to trace later
**Good:** Fail fast and loudly when an invariant is violated — throw an exception or halt execution immediately

### 2. Invariant Checks Only in Tests

**Bad:** Invariants are verified in unit tests but not enforced in production code
**Why it's bad:** Integration scenarios, edge cases, and production data patterns that tests don't cover can violate invariants undetected
**Good:** Enforce invariants at runtime in production, especially at public boundaries and after state mutations

### 3. Invariant Bloat

**Bad:** Declaring every business rule and validation check as an "invariant"
**Why it's bad:** Dilutes the meaning of invariants — if everything is an invariant, nothing is. Makes it hard to prioritize which checks are truly critical
**Good:** Reserve "invariant" for conditions that must ALWAYS be true — distinguish from validations that apply only in specific contexts

### 4. Mutating State Without Re-Checking Invariants

**Bad:** A method modifies multiple fields but only validates the invariant at the end, leaving the object in a temporarily inconsistent state visible to other threads
**Why it's bad:** In concurrent systems, other threads can observe the intermediate broken state and act on corrupted data
**Good:** Use synchronization, immutable data structures, or transactional updates to ensure invariants are never visibly violated

### 5. Assuming Invariants Survive Refactoring

**Bad:** Refactoring code that depends on an invariant without verifying the invariant still holds after the change
**Why it's bad:** Subtle changes in control flow or data flow can break previously valid assumptions, introducing silent corruption
**Good:** Document invariants explicitly in code comments and add invariant assertions that run automatically after refactoring

## Best Practices

### 1. Document Invariants

```python
class Stack:
    """
    A last-in-first-out (LIFO) stack.
    
    Invariants:
    - is_empty() returns (size() == 0)
    - pop() returns most recently pushed item
    - size() is always >= 0
    - After push(x): size() == old_size() + 1
    - After pop(): size() == old_size() - 1
    """
    pass
```

### 2. Enforce at Boundaries

```python
class Account:
    def __init__(self, initial_balance: Decimal):
        # Enforce invariant at construction
        if initial_balance < 0:
            raise ValueError("Initial balance cannot be negative")
        self._balance = initial_balance
    
    @property
    def balance(self) -> Decimal:
        return self._balance
```

### 3. Test Invariants

```python
import hypothesis
from hypothesis import given, strategies

@given(strategies.lists(strategies.integers(min_value=1)))
def test_stack_invariant(operations):
    stack = Stack()
    
    for op in operations:
        if op > 0:
            stack.push(op)
        
        # INVARIANT: size >= 0
        assert stack.size() >= 0
        
        # INVARIANT: empty => size == 0
        if stack.is_empty():
            assert stack.size() == 0
```

## Failure Modes

- **Invariant violation in production** → code path bypasses invariant check → corrupted state propagates → always validate invariants at public boundaries and after state mutations
- **Over-constraining invariants** → too many invariants prevent legitimate operations → system becomes inflexible → distinguish between hard invariants and soft constraints
- **Invariant checks impacting performance** → expensive invariant validation on every operation → latency degradation → use defensive checks in development, sampled checks in production
- **Missing invariants for business rules** → no enforcement of domain constraints → invalid business states accepted → identify and encode all business rules as invariants in domain model
- **Invariant drift during refactoring** → code changes break previously valid invariants → silent corruption → document invariants explicitly and add invariant checks to test suite
- **Concurrent invariant violations** → race condition allows temporary invariant breach → inconsistent state visible to other threads → use synchronization or immutable data to maintain invariants
- **Testing invariants only in unit tests** → integration scenarios violate invariants not covered by unit tests → production failures → add invariant property tests and integration-level checks

## Related Topics

- [[Design MOC]]
- [[Contracts]]
- [[SOLID]]
- [[DomainModeling]]
- [[TDD]]

## Key Takeaways

- Invariants are conditions that must always be true during program execution; if violated, there's a bug
- Critical in financial systems, database systems with ACID properties, concurrent code, and data validation
- Overkill for rapid prototypes, experimental code with frequently changing constraints, or simple utility scripts
- Tradeoff: correctness guarantees and self-documenting code versus runtime validation overhead and implementation discipline
- Main failure mode: silent invariant violations let corrupted state propagate through the system, making root causes nearly impossible to trace
- Best practice: document invariants explicitly in code, enforce them at public boundaries and after state mutations, fail fast and loudly on violation, and test with property-based testing
- Related: contracts, SOLID, domain modeling, test-driven development
