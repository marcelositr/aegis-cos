---
title: Abstraction
title_pt: Abstração
layer: foundations
type: concept
priority: high
version: 1.0.0
tags:
  - Foundations
  - Abstraction
description: Hiding complexity behind simple interfaces, enabling focus on essential details.
description_pt: Escondendo complexidade atrás de interfaces simples, permitindo foco em detalhes essenciais.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Abstraction

## Description

Abstraction is the process of hiding implementation details behind a simple interface. It allows you to work with complex systems without understanding every detail. Good abstraction enables:
- Simpler mental model
- Easier change management
- Reusability
- Independent development

## Purpose

**When abstraction is valuable:**
- When dealing with complex systems
- When building reusable components
- When multiple teams work on system parts
- When implementation may change
- For creating clean APIs

**When abstraction may be overkill:**
- For simple, one-off operations
- When overhead exceeds benefit
- For performance-critical code (abstraction has cost)
- When domain is simple and well-understood

**The key question:** Does this abstraction hide complexity usefully, or just add unnecessary indirection?

## Types:
- **Procedural abstraction**: Hiding code logic
- **Data abstraction**: Hiding data structure
- **Object abstraction**: Hiding object state
- **Interface abstraction**: Hiding implementation

## Examples

### Data Abstraction

```python
# Hide internal implementation
class UserRepository:
    def __init__(self):
        self._cache = {}  # Internal detail hidden
    
    def get_user(self, user_id):
        # User doesn't know about caching
        # Just calls get_user()
        if user_id in self._cache:
            return self._cache[user_id]
        return self._fetch_from_db(user_id)
    
    def _fetch_from_db(self, user_id):
        # Database implementation hidden
        pass
```

### Interface Abstraction

```python
from abc import ABC, abstractmethod

class PaymentProcessor(ABC):
    @abstractmethod
    def charge(self, amount: float) -> bool:
        """Process payment. Implementation hidden."""
        pass

class StripeProcessor(PaymentProcessor):
    def charge(self, amount: float) -> bool:
        # Stripe-specific implementation
        pass

class PayPalProcessor(PaymentProcessor):
    def charge(self, amount: float) -> bool:
        # PayPal-specific implementation
        pass
```

### Function Abstraction

```python
# Complex logic hidden in function
def calculate_order_total(order):
    """
    Calculate total with discounts, taxes, shipping.
    Caller doesn't see complexity.
    """
    subtotal = sum(item.price for item in order.items)
    discount = apply_discount(subtotal, order.coupon)
    tax = calculate_tax(discount)
    shipping = calculate_shipping(order)
    return subtotal - discount + tax + shipping
```

## Best Practices

### 1. Hide Implementation

```python
# Expose interface, hide details
class Stack:
    def __init__(self):
        self._items = []  # Hidden
    
    def push(self, item):
        self._items.append(item)
    
    def pop(self):
        return self._items.pop()
    
    # User doesn't need to know it's a list
```

### 2. Single Responsibility

```python
# Each abstraction has one job
class UserValidator:
    def validate(self, user): ...

class UserRepository:
    def save(self, user): ...

class UserNotifier:
    def notify(self, user): ...
```

### 3. Minimal Interface

```python
class Calculator:
    # Just what's needed
    def add(self, a, b): return a + b
    def subtract(self, a, b): return a - b
    # Hide multiply, divide unless needed
```

## Anti-Patterns

### 1. Over-Abstraction

**Bad:** 5 layers of indirection for simple operation → impossible to debug → abstraction should simplify, not complicate
**Solution:** Only abstract when it genuinely reduces complexity

### 2. Leaky Abstraction

**Bad:** Abstraction claims to hide database but leaks SQL errors → caller needs to know implementation → fix the leak
**Solution:** Abstraction boundaries must be complete

## Failure Modes

- **Too many abstraction layers** → following code requires jumping through 5 files → developer gives up → limit layers
- **Wrong level of abstraction** → too high (useless) or too low (no benefit) → match abstraction to use case
- **Abstraction without contract** → interface doesn't specify behavior → implementations diverge → define clear contracts
- **Performance cost ignored** → virtual dispatch, allocations, indirection → latency increase → measure abstraction overhead
- **Abstraction locks you in** → hard to change when requirements shift → prefer composable abstractions
- **Premature abstraction** → abstracting before understanding the problem → wrong abstraction → wait for patterns to emerge

## Decision Framework

```
Is the code used in 3+ places? → Consider abstraction
Does the implementation change frequently? → Consider abstraction
Is the complexity hiding useful information? → Consider abstraction
Is it used once and unlikely to change? → Don't abstract yet
Does the abstraction make code harder to understand? → Remove it
```

## Related Topics

- [[Foundations MOC]]
- [[Coupling]]
- [[InterfaceDesign]]
- [[Hexagonal]]
- [[Modularity]]

## Key Takeaways

- Abstraction hides implementation details behind simple interfaces, enabling focus on essential details without understanding every component
- Valuable when dealing with complex systems, building reusable components, or when implementations may change over time
- Avoid for simple one-off operations, performance-critical code where overhead matters, or when the domain is simple and well-understood
- Tradeoff: simpler mental models and easier change management versus added indirection and potential performance costs
- Main failure mode: premature abstraction before understanding the problem creates wrong abstractions that are harder to change than no abstraction at all
- Best practice: wait for patterns to emerge before abstracting, expose minimal interfaces, hide implementation completely, and remove abstractions that make code harder to understand
- Related: coupling, interface design, hexagonal architecture, modularity
