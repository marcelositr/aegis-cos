---
title: Refactoring
title_pt: Refatoração
layer: design
type: concept
priority: high
version: 1.0.0
tags:
  - Design
  - Refactoring
description: Improving code structure without changing external behavior.
description_pt: Melhorando estrutura de código sem alterar comportamento externo.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Refactoring

## Description

Refactoring is the process of improving code structure without changing its external behavior. It makes code more readable, maintainable, and extensible without introducing new features or fixing bugs.

Key principles:
- **Behavior preservation** - Same inputs → same outputs
- **Incremental changes** - Small, safe steps
- **Test coverage** - Ensure nothing breaks
- **Purpose-driven** - Every change has clear reason

## Purpose

**When refactoring is valuable:**
- When code is hard to understand
- Before adding new features
- When fixing bugs (code likely needs improvement)
- During code reviews when issues found
- When technical debt accumulates

**When to avoid refactoring:**
- When deadline is critical
- When code will be replaced soon
- Without tests to verify behavior
- When change cost exceeds benefit

**The key question:** Will this refactoring make the code easier to work with, and do we have tests to verify nothing broke?

## Common refactorings:
- Extract function/method
- Rename variables
- Inline code
- Move method to better class
- Replace conditional with polymorphism
- Introduce parameter object

## Examples

### Extract Method

```python
# Before
def print_invoice(order):
    print("INVOICE")
    print(f"Customer: {order.customer_name}")
    print(f"Date: {order.date}")
    print("Items:")
    for item in order.items:
        print(f"  {item.name}: {item.price}")
    print(f"Subtotal: {order.subtotal}")
    print(f"Tax: {order.tax}")
    print(f"Total: {order.total}")

# After - extract logical pieces
def print_invoice(order):
    print_header(order)
    print_items(order)
    print_totals(order)

def print_header(order):
    print("INVOICE")
    print(f"Customer: {order.customer_name}")
    print(f"Date: {order.date}")

def print_items(order):
    print("Items:")
    for item in order.items:
        print(f"  {item.name}: {item.price}")

def print_totals(order):
    print(f"Subtotal: {order.subtotal}")
    print(f"Tax: {order.tax}")
    print(f"Total: {order.total}")
```

### Replace Conditional with Polymorphism

```python
# Before
class NotificationService:
    def send(self, notification):
        if notification.type == "email":
            self.send_email(notification)
        elif notification.type == "sms":
            self.send_sms(notification)
        elif notification.type == "push":
            self.send_push(notification)

# After - polymorphism
class NotificationService(ABC):
    @abstractmethod
    def send(self, notification):
        pass

class EmailNotification(NotificationService):
    def send(self, notification):
        # Email-specific logic
        pass

class SMSNotification(NotificationService):
    def send(self, notification):
        # SMS-specific logic
        pass

class PushNotification(NotificationService):
    def send(self, notification):
        # Push-specific logic
        pass
```

## Failure Modes

- **Refactoring without tests** → behavior changes undetected → silent bugs → ensure comprehensive test coverage before refactoring
- **Large refactoring commits** → hard to isolate failures → difficult rollback → make small, incremental changes with individual commits
- **Changing behavior during refactoring** → bugs introduced → regression → preserve external behavior, change only internal structure
- **Refactoring under deadline pressure** → rushed changes → new defects → avoid refactoring during critical delivery periods
- **No clear purpose** → unnecessary complexity → wasted effort → every refactoring should have a documented reason and goal
- **Ignoring code review feedback** → poor refactoring decisions → technical debt → review refactoring changes for correctness and clarity
- **Not running tests after each change** → accumulated errors → broken functionality → run full test suite after every refactoring step

## Anti-Patterns

### 1. Big Bang Refactoring

**Bad:** Rewriting an entire module or system in one massive refactoring effort
**Why it's bad:** High risk of introducing bugs, impossible to review, difficult to rollback, and often takes far longer than estimated
**Good:** Refactor incrementally — small, testable changes that preserve behavior at each step

### 2. Refactoring Without Tests

**Bad:** Restructuring code without a comprehensive test suite to verify behavior preservation
**Why it's bad:** You have no safety net to catch regressions — what looks like a refactor may silently change behavior
**Good:** Write characterization tests that capture current behavior before refactoring legacy code

### 3. Refactoring Under Deadline Pressure

**Bad:** Attempting large refactoring efforts when a delivery deadline is imminent
**Why it's bad:** Rushed refactoring introduces defects, and the time pressure prevents proper testing and review
**Good:** Schedule refactoring as part of regular development or dedicate specific time for it outside of crunch periods

### 4. Refactoring for Aesthetics Only

**Bad:** Renaming variables and reorganizing code purely to match personal style preferences without improving readability or maintainability
**Why it's bad:** Creates churn in version history, causes unnecessary merge conflicts, and doesn't deliver real value
**Good:** Refactor with a purpose — reduce complexity, improve testability, or prepare for a specific feature

### 5. Changing Behavior During Refactoring

**Bad:** "While I'm here, let me also fix this bug and add this small feature" during a refactoring session
**Why it's bad:** Makes it impossible to isolate whether a new bug came from the refactor or the behavior change
**Good:** Separate refactoring (structure change, same behavior) from feature work (behavior change) into distinct commits

## Best Practices

### 1. Test First

```python
# Ensure tests pass before and after
def test_refactoring():
    # Given
    original_result = original_function(input)
    
    # When
    refactored_result = refactored_function(input)
    
    # Then
    assert refactored_result == original_result
```

### 2. Small Steps

```python
# Make one change at a time
# Commit after each successful change
# Run tests after each change
```

### 3. Name Things Clearly

```python
# Rename for clarity
# Before: def calc(o): ...
# After: def calculate_order_total(order): ...
```

## Related Topics

- [[DesignPatterns]]
- [[CodeQuality]]
- [[TechnicalDebt]]
- [[CyclomaticComplexity]]
- [[UnitTesting]]
- [[Metrics]]
- [[Cohesion]]
- [[Coupling]]

## Key Takeaways

- Refactoring improves code structure without changing external behavior, making code more readable, maintainable, and extensible
- Valuable when code is hard to understand, before adding new features, during bug fixes, or when technical debt accumulates
- Avoid when deadlines are critical, code will be replaced soon, or there are no tests to verify behavior preservation
- Tradeoff: improved maintainability and reduced future development cost versus time investment and risk of introducing bugs
- Main failure mode: refactoring without tests leads to undetected behavior changes and silent bugs in production
- Best practice: write characterization tests first, make small incremental changes with individual commits, run tests after every step, and never mix refactoring with behavior changes
- Related: design patterns, code quality, technical debt, cyclomatic complexity, unit testing, cohesion, coupling

## Additional Notes
