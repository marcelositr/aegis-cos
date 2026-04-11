---
title: KISS Principle
title_pt: Princípio KISS
layer: principles
type: concept
priority: high
version: 1.0.0
tags:
  - Principles
  - KISS
description: Keep It Simple, Stupid - prefer simple solutions over complex ones.
description_pt: Mantenha Simples, Estúpido - prefira soluções simples sobre complexas.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# KISS Principle

## Description

KISS (Keep It Simple, Stupid) states that most systems work best if they're kept simple rather than made complex. Simplicity:
- Makes code easier to understand
- Reduces bugs
- Easier to maintain
- Faster to develop

## Purpose

**When KISS is valuable:**
- When solving straightforward problems
- When team has varying skill levels
- For maintainable codebases
- For rapid prototyping

**When more complex solutions may be needed:**
- When problem genuinely requires complexity
- When performance demands it
- When simplicity hides important details

**The key question:** Does this solution solve the problem with minimum complexity?

## Examples

### Bad - Over-Engineering

```python
# Unnecessarily complex
class AdvancedUserManager:
    def __init__(self, config=None, logger=None, validator=None,
                 cache_manager=None, event_bus=None, metrics=None):
        # Complex initialization
        # Many dependencies
        # Too flexible
    
    def create_user(self, user_data):
        # Complex validation chain
        # Multiple abstraction layers
        # Way more complex than needed
        pass

# Simple is better:
def create_user(email, name):
    if not email or not name:
        raise ValueError("Email and name required")
    return User(email=email, name=name)
```

### Good - Simple Solution

```python
# Find maximum - simple approach
def find_max(numbers):
    if not numbers:
        return None
    max_val = numbers[0]
    for num in numbers:
        if num > max_val:
            max_val = num
    return max_val

# Clear, simple, works
# Don't use quicksort to find max!
```

### Bad - Premature Optimization

```python
# Optimized before needed
class DataProcessor:
    def __init__(self):
        self.cache = LRUCache(1000)
        self.pool = ThreadPoolExecutor(max_workers=100)
        self.queue = PriorityQueue()
        self.bloom_filter = BloomFilter(100000)
    
    def process(self, item):
        # All this complexity for processing a list
        pass
```

### Good - Start Simple

```python
# Start simple
def process_data(items):
    return [transform(item) for item in items]

# Optimize when needed
def process_data_optimized(items):
    # Only add complexity when profiling shows it's needed
    with ProcessPoolExecutor() as executor:
        return list(executor.map(transform, items))
```

## Anti-Patterns

### 1. Oversimplifying Complex Problems

**Bad:** Ignoring genuine complexity in a problem domain to achieve a "simple" solution that doesn't handle edge cases
**Why it's bad:** The solution works for the happy path but fails catastrophically on real-world inputs — simplicity became negligence
**Good:** Distinguish simple solutions from oversimplified ones — address the real complexity, but express the solution as clearly as possible

### 2. KISS as an Excuse for No Design

**Bad:** Skipping architecture discussions, design reviews, and planning in the name of "keeping it simple"
**Why it's bad:** The system grows into accidental complexity — without any design, the simplest path leads to a big ball of mud
**Good:** Simple does not mean unplanned — invest in lightweight design before coding to prevent accidental complexity

### 3. Reinventing the Wheel for Simplicity

**Bad:** Writing a custom sorting algorithm, HTTP client, or JSON parser because the library "seems too complex"
**Why it's bad:** Custom implementations have bugs, lack edge case handling, and become a maintenance burden that the team owns forever
**Good:** Prefer well-tested libraries over custom implementations — the library's complexity is someone else's problem, and it's been battle-tested

### 4. Clever Code Disguised as Simple

**Bad:** Using language tricks, one-liners, and golf-style code that is short but incomprehensible
**Why it's bad:** Short code is not simple code — if the next developer needs 10 minutes to understand a one-liner, it is not simple
**Good:** Favor explicit, readable code over clever tricks — clarity is the true measure of simplicity, not line count

## Best Practices

### 1. Write Readable Code

```python
# Clear over clever
# Bad
result = (x := 5) and (y := 10) and x + y

# Good
x = 5
y = 10
result = x + y
```

### 2. Solve the Problem First

```python
# Don't add abstraction layers upfront
# Solve the problem
def calculate_total(items):
    return sum(item.price for item in items)

# Refactor later if needed
def calculate_total(items, tax_rate=0):
    subtotal = sum(item.price for item in items)
    return subtotal * (1 + tax_rate)
```

### 3. Prefer Explicit

```python
# Explicit over implicit
# Bad
def process(data):
    # What does this do?
    return [x * 2 for x in data]

# Good
def double_prices(prices):
    """Double all prices in the list."""
    return [price * 2 for price in prices]
```

## Failure Modes

- **Over-simplifying complex problems** → ignoring real complexity to achieve simplicity → solution does not handle edge cases → distinguish simple solutions from oversimplified ones
- **KISS used as excuse for no design** → skipping architecture discussions in name of simplicity → system grows into accidental complexity → simple does not mean unplanned; design before coding
- **Simplicity hiding important details** → abstraction layer hides critical behavior → debugging becomes impossible when internals are opaque → ensure simplicity does not sacrifice transparency for critical operations
- **Reinventing the wheel for simplicity** → writing custom implementation instead of using proven library → bugs and maintenance burden → prefer well-tested libraries over custom implementations
- **KISS conflicting with extensibility needs** → simplest solution cannot accommodate future requirements → complete rewrite needed when requirements change → balance simplicity with reasonable extensibility
- **Simplistic error handling** → ignoring error cases to keep code simple → silent failures and data corruption → handle errors explicitly; simplicity in structure does not mean skipping error paths
- **Under-documenting simple code** → assuming simple code is self-documenting → future developers miss important context → document the why, not the what, even for simple code

## Related Topics

- [[DRY]]
- [[YAGNI]]
- [[Abstraction]]
- [[Refactoring]]
- [[CodeQuality]]
- [[SOLID]]
- [[Modularity]]
- [[TechnicalDebt]]

## Key Takeaways

- KISS states systems work best when kept simple rather than made complex, prioritizing readability and maintainability
- Valuable for straightforward problems, teams with varying skill levels, maintainable codebases, and rapid prototyping
- More complex solutions needed when problems genuinely require complexity or performance demands it
- Tradeoff: faster development and fewer bugs versus risk of oversimplifying genuinely complex problems
- Main failure mode: over-simplifying complex problems ignores real edge cases and fails catastrophically on real-world inputs
- Best practice: distinguish simple solutions from oversimplified ones, prefer well-tested libraries over custom implementations, favor explicit readable code over clever tricks, and solve the problem first before adding abstraction
- Related: DRY, YAGNI, abstraction, refactoring, code quality, SOLID, modularity
