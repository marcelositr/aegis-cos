---
title: Cohesion
title_pt: Coesão
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - Cohesion
description: The degree to which elements inside a module belong together; goal is high cohesion.
description_pt: O grau em que elementos dentro de um módulo pertencem juntos; objetivo é alta coesão.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Cohesion

## Description

Cohesion measures how strongly related and focused the responsibilities of a single module are. A highly cohesive module contains elements that are closely related to each other and work together to accomplish a single purpose. Low cohesion means a module has multiple, unrelated responsibilities.

High cohesion is desirable because it:
- Makes modules easier to maintain
- Increases reusability
- Reduces the impact of changes
- Improves readability and understandability
- Simplifies testing

While coupling measures inter-module relationships, cohesion measures intra-module relationships. The ideal is loose coupling between modules and high cohesion within modules.

Levels of cohesion (from worst to best):
- **Coincidental**: Random, unrelated elements (worst)
- **Logical**: Elements in same category but different purposes
- **Temporal**: Elements used at same time
- **Procedural**: Elements in same execution order
- **Communicational**: Elements operate on same data
- **Sequential**: Output of one is input of another
- **Functional**: All elements contribute to single purpose (best)

## Purpose

**When high cohesion matters:**
- When modules need to be maintained
- When you want reusability
- When understanding code quickly is important
- When testing needs to be focused
- When multiple people work on codebase
- When system will evolve over time

**When to accept lower cohesion:**
- Very small modules
- When separating would increase complexity more than help
- Performance-critical code where grouping matters

## Rules

1. **Single Responsibility** - One reason to change
2. **Related things together** - Keep related functionality close
3. **Separate concerns** - Different responsibilities = different modules
4. **Complete functionality** - Module does one complete thing
5. **Minimize module size** - Small, focused modules
6. **Name reflects purpose** - Name should clearly indicate responsibility

## Examples

### Good Example: High Cohesion

```python
# Highly cohesive module - single responsibility
# modules/email/__init__.py
from .service import EmailService
from .templates import EmailTemplate
from .queue import EmailQueue

__all__ = ["EmailService", "EmailTemplate", "EmailQueue"]

# modules/email/service.py
class EmailService:
    """Handles email sending - single responsibility"""
    
    def __init__(self, smtp_client: SMTPClient, queue: EmailQueue):
        self.smtp = smtp_client
        self.queue = queue
    
    def send(self, to: str, subject: str, body: str) -> bool:
        # All code here is for sending email
        message = self.build_message(to, subject, body)
        return self.smtp.send(message)
    
    def send_async(self, to: str, subject: str, body: str):
        # Async email sending
        self.queue.enqueue(to, subject, body)
    
    def build_message(self, to: str, subject: str, body: str) -> Message:
        # Message building logic
        return Message(to=to, subject=subject, body=body)
    
    def validate_email(self, email: str) -> bool:
        # Email validation logic
        return "@" in email and "." in email.split("@")[1]
```

### Bad Example: Low Cohesion

```python
# BAD: Disorganized, unfocused module
# utils.py - 2000 lines of random functions
def send_email(...): ...
def calculate_tax(...): ...
def parse_json(...): ...
def format_date(...): ...
def validate_password(...): ...
def encrypt_password(...): ...
def generate_pdf(...): ...
def zip_files(...): ...

# Nothing related!
# Can't find anything
# Hard to maintain
# No clear purpose
```

### Good Example: Grouping by Responsibility

```python
# Better organization - cohesive modules
# modules/email/
#   service.py - Email sending
#   templates.py - Template management
#   validation.py - Email validation

# modules/taxes/
#   calculator.py - Tax calculations
#   rates.py - Tax rates
#   exemptions.py - Exemption logic

# modules/crypto/
#   encryption.py - Encryption utilities
#   hashing.py - Password hashing
#   keys.py - Key management
```

### Bad Example: Feature Envy (Low Cohesion)

```python
# BAD: Class that should be elsewhere
class Order:
    def __init__(self, items: list):
        self.items = items
    
    def calculate_total(self):
        return sum(item.price for item in self.items)

class OrderPrinter:
    def print_order(self, order: Order):
        # Envying Order's data!
        for item in order.items:  # Should be in Order
            print(f"{item.name}: {item.price}")
        total = sum(item.price for item in order.items)  # Should be in Order
        print(f"Total: {total}")
```

### Good Example: Moving Related Code Together

```python
# Highly cohesive Order class
class Order:
    def __init__(self, order_id: str, items: list):
        self.order_id = order_id
        self.items = items
        self.status = "pending"
    
    # Related operations on Order
    def calculate_total(self) -> Decimal:
        return sum(item.price * item.quantity for item in self.items)
    
    def add_item(self, item: OrderItem):
        self.items.append(item)
    
    def remove_item(self, item_id: str):
        self.items = [i for i in self.items if i.id != item_id]
    
    def confirm(self):
        self.status = "confirmed"
    
    def cancel(self):
        self.status = "cancelled"
        for item in self.items:
            item.quantity = 0
    
    def is_empty(self) -> bool:
        return len(self.items) == 0
    
    def __repr__(self):
        return f"Order({self.order_id}, {self.status})"
```

## Anti-Patterns

### 1. God Class/Module

**Bad:**
- Everything in one place
- Too many responsibilities
- Hard to understand

**Solution:**
- Split by responsibility
- Extract related groups
- Follow SRP

### 2. Feature Envy

**Bad:**
- Class uses data from another class more than its own
- Function in wrong place

**Solution:**
- Move function to where it belongs
- Put data and behavior together

### 3.，散布操作 (Shotgun Surgery)

**Bad:**
- Making changes requires touching many modules
- Related functionality scattered

**Solution:**
- Move related operations together
- Create cohesive modules

### 4. Duplicated Code

**Bad:**
- Same logic in multiple places
- Related code not shared

**Solution:**
- Extract to single location
- Use inheritance or composition

### 5. Naming Too Generic

**Bad:**
- "Utils", "Helpers", "Common" modules
- Dumping ground for everything

**Solution:**
- Descriptive names
- Group by domain/feature

## Best Practices

### 1. SRP Application

```python
# Single Responsibility per module
# modules/user/
#   creation - creating users
#   authentication - login/logout
#   profile - user profiles
#   preferences - user settings

# modules/notification/
#   email - email sending
#   sms - SMS sending
#   push - push notifications
#   webhook - webhook triggering
```

### 2. Keep Related Things Together

```python
# Related data and behavior together
class User:
    def __init__(self, email: str, name: str):
        self.email = email
        self.name = name
    
    def validate(self) -> bool:
        # Validation is here with the data
        return "@" in self.email
    
    def to_dict(self) -> dict:
        # Serialization is here
        return {"email": self.email, "name": self.name}
```

### 3. Cohesion vs Coupling Balance

```
High cohesion + Low coupling = GOOD
High cohesion + High coupling = NECESSARY (sometimes)
Low cohesion + Low coupling = TRY TO AVOID
Low cohesion + High coupling = BAD (avoid)
```

### 4. Measuring Cohesion

```python
# LCOM (Lack of Cohesion of Methods)
# Count pairs of methods that don't share instance variables
# Higher LCOM = lower cohesion

# Example - if User class has methods:
# - set_email() uses email
# - set_name() uses name
# - get_email() uses email
# - get_name() uses name

# Methods using email: set_email, get_email (2)
# Methods using name: set_name, get_name (2)
# They don't share - LCOM is high!
```

### 5. Module Size Guidelines

```
Module size recommendations:
- Too small: Can't see the forest for the trees
- Too large: Hard to understand
- Just right: 1-3 files, single responsibility
- Focus: Easy to describe what it does
```

## Failure Modes

- **God class/module accumulation** → unrelated responsibilities cluster in one place → code becomes impossible to understand or test → split by single responsibility and reject additions outside module purpose
- **Feature envy indicating misplaced code** → methods use more data from other classes than their own → low cohesion and tight coupling → move methods to the class whose data they primarily use
- **Shotgun surgery from scattered concerns** → single change requires modifications across many modules → high risk of incomplete updates → consolidate related operations into cohesive modules
- **Utility module becoming dumping ground** → "utils" and "helpers" accumulate unrelated functions → no discoverability and growing complexity → create domain-specific modules with clear naming
- **Temporal cohesion masquerading as functional** → functions grouped because they run at the same time, not because they're related → maintenance confusion when timing changes → group by business concept, not execution timing
- **Logical cohesion hiding unrelated operations** → module handles all "input validation" for different domains → no real cohesion between validation rules → split validation by domain entity
- **Cohesion degradation over time** → incremental additions slowly erode module focus → module gradually becomes unfocused → periodic module boundary reviews and refactoring

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| SonarQube | Cohesion metrics |
| CodeScene | Cohesion analysis |
| Understand | Code metrics |

## Related Topics

- [[Coupling]]
- [[Modularity]]
- [[Layering]]
- [[SOLID]]
- [[Refactoring]]
- [[SeparationOfConcerns]]
- [[Metrics]]
- [[CyclomaticComplexity]]

## Key Takeaways

- Cohesion measures how strongly related elements within a module are; high cohesion means all elements contribute to a single focused purpose
- Matters when modules need maintenance, reusability, quick understanding, or when multiple developers work on the codebase
- Accept lower cohesion in very small modules, performance-critical code, or when splitting would increase complexity more than it helps
- Tradeoff: high cohesion improves maintainability and testability but may require more modules to manage
- Main failure mode: god classes/modules accumulate unrelated responsibilities, becoming impossible to understand, test, or refactor
- Best practice: apply single responsibility principle, keep related data and behavior together, avoid generic "utils" modules, and periodically review module boundaries
- Related: coupling, modularity, SOLID, separation of concerns, refactoring

## Additional Notes

**Cohesion vs Coupling:**
- Cohesion: Within a module
- Coupling: Between modules
- Both matter for maintainability
- Best practice: high cohesion, low coupling

**When Cohesion Breaks:**
- Adding unrelated features
- "It might be useful here" mentality
- Not refactoring over time
- No clear ownership

**Improving Cohesion:**
1. Identify single responsibility
2. Move related code together
3. Extract unrelated code
4. Name modules accurately
5. Review module boundaries

**Testing Benefits:**
- High cohesion = easier to test
- Focus on single responsibility
- Clear inputs/outputs
- Less mocking needed
