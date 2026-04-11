---
title: DRY Principle
title_pt: Princípio DRY
layer: principles
type: concept
priority: high
version: 1.0.0
tags:
  - Principles
  - DRY
description: Don't Repeat Yourself - avoid duplicating code and knowledge in a system.
description_pt: Não Repita Você Mesmo - evitar duplicar código e conhecimento em um sistema.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# DRY Principle

## Description

DRY (Don't Repeat Yourself) states that every piece of knowledge should have a single, unambiguous representation in the system. Duplication:
- Increases maintenance burden
- Creates inconsistency
- Leads to bugs when updates miss one copy
- Makes refactoring harder

## Purpose

**When DRY is valuable:**
- When same logic appears in multiple places
- When changes need to propagate across copies
- For building maintainable systems
- When consistency matters

**When duplication is acceptable:**
- When pieces serve different purposes
- When abstraction cost exceeds duplication cost
- For test code vs production code
- When solving different problems

**The key question:** Is this duplication of knowledge or just similar solutions to different problems?

## Examples

### Bad - Code Duplication

```python
# Duplicated code
def calculate_user_discount(user):
    if user.subscription == 'premium':
        return 0.20
    elif user.subscription == 'gold':
        return 0.15
    elif user.subscription == 'silver':
        return 0.10
    return 0

def calculate_order_discount(order):
    if order.user.subscription == 'premium':
        return 0.20
    elif order.user.subscription == 'gold':
        return 0.15
    elif order.user.subscription == 'silver':
        return 0.10
    return 0
```

### Good - Single Source

```python
# Define discount rules once
DISCOUNT_RATES = {
    'premium': 0.20,
    'gold': 0.15,
    'silver': 0.10,
    None: 0
}

def get_discount_rate(subscription):
    return DISCOUNT_RATES.get(subscription, 0)

def calculate_user_discount(user):
    return get_discount_rate(user.subscription)

def calculate_order_discount(order):
    return get_discount_rate(order.user.subscription)
```

### Bad - Knowledge Duplication

```python
# Same validation in multiple places
# Form validation
def validate_email_form(email):
    if '@' not in email or '.' not in email.split('@')[1]:
        raise ValueError("Invalid email")

# API validation
def validate_email_api(email):
    if '@' not in email or '.' not in email.split('@')[1]:
        raise ValueError("Invalid email")

# Database validation
def validate_email_db(email):
    if '@' not in email or '.' not in email.split('@')[1]:
        raise ValueError("Invalid email")
```

### Good - Single Validator

```python
# Single validation rule
def validate_email(email: str) -> bool:
    """Validate email format."""
    if not email or '@' not in email:
        return False
    local, domain = email.split('@')
    return bool(local and '.' in domain)

# Use everywhere
def validate_email_form(email):
    if not validate_email(email):
        raise ValueError("Invalid email")

def validate_email_api(email):
    if not validate_email(email):
        raise ValueError("Invalid email")

def validate_email_db(email):
    if not validate_email(email):
        raise ValueError("Invalid email")
```

## Anti-Patterns

### 1. Premature Abstraction

**Bad:** Extracting shared code into a common function after seeing duplication only twice, before understanding if the two cases serve different purposes
**Why it's bad:** The abstraction is likely wrong — when a third use case arrives, it doesn't fit, and the abstraction becomes riddled with conditionals
**Good:** Wait for the rule of three — abstract only after seeing the same knowledge duplicated at least three times with the same underlying reason

### 2. False DRY Coupling

**Bad:** Two code blocks look similar but serve different business purposes — you merge them into one function to "be DRY"
**Why it's bad:** A change to one use case breaks the other — the coupling was accidental, not intentional, and now both features are held hostage
**Good:** Distinguish accidental similarity from true knowledge duplication — if the code would change for different reasons, keep it separate

### 3. DRY Violating Single Responsibility

**Bad:** Extracting shared code into a utility class that accumulates unrelated helper methods over time
**Why it's bad:** The utility class becomes a god class with no coherent purpose — every team member adds their "helpers" and it becomes unmaintainable
**Good:** Ensure extracted abstractions have a single clear purpose — if a utility class handles both string formatting and database queries, split it

### 4. Readability Sacrificed for DRY

**Bad:** Creating a clever, deeply abstracted solution that eliminates all duplication but is incomprehensible to readers
**Why it's bad:** Developers spend more time tracing through abstraction layers than understanding the logic — the maintenance cost exceeds the duplication cost
**Good:** Prefer readable duplication over clever abstraction when clarity suffers — code is read far more often than it is written

## Best Practices

### 1. Extract Common Logic

```python
# Before
def process_user(): ...
def process_admin(): ...
def process_guest(): ...

# After
def process(role):
    if role == 'user': ...
    elif role == 'admin': ...
    elif role == 'guest': ...
```

### 2. Use Constants

```python
# Instead of magic numbers
if status == 200: ...  # What is 200?
if status == HTTP_OK: ...  # Clearer
```

### 3. Centralize Configuration

```python
# config.py
CONFIG = {
    'timeout': 30,
    'retries': 3,
    'cache_ttl': 300
}

# Use throughout
def fetch_data():
    timeout = CONFIG['timeout']
    ...
```

## Failure Modes

- **Premature abstraction to eliminate duplication** → creating abstractions before understanding if code serves same purpose → wrong abstraction that fits neither use case → wait for three occurrences before abstracting
- **False DRY coupling unrelated code** → two similar code blocks serve different purposes but share implementation → change to one breaks the other → distinguish accidental similarity from true knowledge duplication
- **Over-abstracting configuration** → creating complex config systems for simple settings → configuration becomes harder than the code it configures → keep configuration simple and only abstract when patterns emerge
- **DRY violating single responsibility** → extracting shared code creates class with multiple responsibilities → class becomes god class → ensure extracted abstraction has single clear purpose
- **Hidden coupling through DRY** → shared constant or utility used in unrelated contexts → changing shared code affects unrelated features → evaluate whether shared code truly represents single knowledge or coincidence
- **DRY making code harder to understand** → abstraction adds indirection that obscures intent → developers spend time tracing abstractions → prefer readable duplication over clever abstraction when clarity suffers
- **Not DRY-ing knowledge duplication** → same business rule encoded in multiple places → rule changes miss some locations → identify and centralize business rules, validation logic, and calculation formulas

## Related Topics

- [[KISS]]
- [[YAGNI]]
- [[Modularity]]
- [[Refactoring]]
- [[CodeQuality]]
- [[TechnicalDebt]]
- [[SeparationOfConcerns]]
- [[SOLID]]

## Key Takeaways

- DRY states every piece of knowledge should have a single, unambiguous representation in the system to avoid maintenance burden and inconsistency
- Valuable when same logic appears in multiple places, changes need to propagate, or consistency matters across the system
- Accept duplication when pieces serve different purposes, abstraction cost exceeds duplication cost, or code solves genuinely different problems
- Tradeoff: single source of truth and easier maintenance versus risk of false coupling and premature abstraction
- Main failure mode: premature abstraction after seeing duplication only twice creates wrong abstractions that fit neither use case when a third arrives
- Best practice: wait for the rule of three before abstracting, distinguish accidental similarity from true knowledge duplication, and prefer readable duplication over clever abstraction when clarity suffers
- Related: KISS, YAGNI, modularity, refactoring, code quality, technical debt, separation of concerns
