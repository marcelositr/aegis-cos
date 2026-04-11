---
title: Determinism Principle
title_pt: Princípio de Determinismo
layer: principles
type: concept
priority: high
version: 1.0.0
tags:
  - Principles
  - Determinism
description: Operations that produce the same output for the same input every time.
description_pt: Operações que produzem a mesma saída para a mesma entrada todas as vezes.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Determinism Principle

## Description

A deterministic function/processing always produces the same output for the same input. Non-deterministic behavior:
- Makes testing difficult
- Causes hard-to-reproduce bugs
- Creates unpredictable systems
- Makes debugging harder

## Purpose

**When determinism is valuable:**
- For reproducible testing
- For debugging and troubleshooting
- For financial/calculation systems
- For deterministic builds

**When non-determinism is acceptable:**
- For randomization (games, ML)
- For unique ID generation
- For timestamps
- For load balancing

**The key question:** Should same inputs always produce same outputs?

## Examples

### Deterministic

```python
def calculate_tax(subtotal, rate):
    return subtotal * rate

def sort_list(items):
    return sorted(items)

# Testable
assert calculate_tax(100, 0.1) == 10
```
```

### Bad - Non-Deterministic

```python
import random

def random_discount():
    # Different result each time!
    return random.random() * 0.2  # Non-deterministic!

def get_current_time():
    # Different result each time!
    return datetime.now()  # Non-deterministic!

def get_user_from_db(user_id):
    # Could get different result if data changes
    return db.query(f"SELECT * FROM users WHERE id = {user_id}")
```

### Good - Deterministic Alternative

```python
# Separate deterministic from non-deterministic
class DiscountCalculator:
    def __init__(self, random_source=None):
        self.random_source = random_source or random
    
    def calculate(self, subtotal):
        # Deterministic part
        base_discount = subtotal * 0.1
        
        # Non-deterministic part injected
        random_discount = self.random_source.random() * 0.05
        
        return base_discount + random_discount
```

### Good - Pure Functions

```python
# Pure functions - deterministic
def add(a, b):
    return a + b

def calculate_total(items):
    return sum(item.price for item in items)

# Impure functions - non-deterministic
def save_to_db(data):
    return db.insert(data)  # Side effect

def send_email(to, subject):
    smtp.send(to, subject)  # Side effect

# Keep business logic pure for testability
def calculate_order_total(items):
    """Pure - deterministic"""
    return sum(item.price for item in items)

def process_order(order):
    """Impure - handles side effects"""
    total = calculate_order_total(order.items)  # Pure
    db.save(order)  # Impure
    send_confirmation(order.email)  # Impure
```

## Anti-Patterns

### 1. Hidden Non-Determinism in Business Logic

**Bad:** A pricing function that uses `datetime.now()` to calculate discounts without exposing the time dependency
**Why it's bad:** The same order produces different totals at different times of day — bugs are irreproducible because you cannot recreate the exact conditions
**Good:** Inject time, random sources, and external dependencies — make non-determinism explicit at the function signature level

### 2. Non-Deterministic Tests

**Bad:** Tests that depend on system time, random values, or live external APIs
**Why it's bad:** Tests pass or fail randomly — developers lose trust in the test suite and start ignoring failures, letting real bugs through
**Good:** Use fixed test fixtures, injected clocks, and mocked external services — every test should produce the same result every run

### 3. Non-Deterministic Ordering in Collections

**Bad:** Iterating over hash sets, dictionaries, or database queries without ORDER BY and expecting consistent output
**Why it's bad:** The same code produces different output on different runs, different machines, or different Python versions — breaking downstream consumers
**Good:** Use ordered collections when output order matters — sort explicitly before serialization or comparison

### 4. Non-Deterministic Builds

**Bad:** Builds that embed timestamps, use unpinned dependencies, or depend on file system ordering
**Why it's bad:** Two builds from the same source produce different binaries — you cannot verify that a deployed artifact matches the source, and debugging becomes impossible
**Good:** Pin all dependencies, use reproducible build tools, and strip timestamps from build artifacts

## Best Practices

### 1. Separate Pure and Impure

```python
# Pure logic separate from side effects
def calculate_discount(subtotal, customer_type):
    """Pure - deterministic"""
    rates = {'gold': 0.2, 'silver': 0.1, 'bronze': 0.05}
    return subtotal * rates.get(customer_type, 0)

def apply_discount(order, customer):
    """Impure - calls pure function"""
    discount = calculate_discount(order.subtotal, customer.type)
    order.total = order.subtotal - discount
    return order
```

### 2. Inject Non-Determinism

```python
# Inject time, random, etc.
class OrderService:
    def __init__(self, clock=None):
        self.clock = clock or SystemClock()
    
    def create_order(self, data):
        # Use injected clock for determinism in tests
        data['created_at'] = self.clock.now()
        return OrderService.save(data)
```

### 3. Make Operations Predictable

```python
# Predictable over random
# Instead of random selection
def select_user(users):
    return users[0]  # Deterministic

# Instead of time-based
def generate_id():
    return str(uuid.uuid4())  # Unique but not time-based
```

## Failure Modes

- **Non-deterministic tests causing flaky CI** → tests pass or fail randomly based on timing → developers lose trust in test suite → inject clock, random source, and external dependencies for deterministic tests
- **Hidden non-determinism in business logic** → calculation depends on system time or random values → irreproducible bugs in production → separate deterministic business logic from non-deterministic input sources
- **Non-deterministic builds** → build output varies between machines → deployment inconsistencies and debugging nightmares → use pinned dependencies, deterministic build tools, and reproducible build configurations
- **Race conditions creating non-deterministic behavior** → concurrent access to shared state produces different results → intermittent production bugs → use synchronization, immutable data, or actor model
- **Time-dependent logic without abstraction** → code directly calls system clock → cannot test time-based behavior → inject clock abstraction to control time in tests
- **Non-deterministic ordering in collections** → iterating over hash sets or maps in undefined order → different output on different runs → use ordered collections when output order matters
- **External API responses affecting determinism** → test depends on live API data → tests fail when API changes → mock external API responses with fixed test fixtures

## Related Topics

- [[Testing]]
- [[FailFast]]
- [[Abstraction]]
- [[Idempotency]]
- [[PropertyTesting]]
- [[Algorithms]]
- [[DataStructures]]
- [[CiCd]]

## Key Takeaways

- Deterministic operations always produce the same output for the same input, enabling reproducible testing, debugging, and reliable systems
- Valuable for reproducible testing, debugging, financial/calculation systems, and deterministic builds
- Non-determinism is acceptable for randomization (games, ML), unique ID generation, timestamps, and load balancing
- Tradeoff: reproducibility and testability versus the need to explicitly manage sources of non-determinism like time and randomness
- Main failure mode: hidden non-determinism in business logic creates irreproducible bugs that cannot be recreated for debugging
- Best practice: separate pure deterministic logic from impure side effects, inject non-deterministic sources as dependencies, use ordered collections when output order matters, and pin dependencies for reproducible builds
- Related: testing, fail fast, abstraction, idempotency, property testing, algorithms, data structures
