---
title: GRASP
title_pt: GRASP (General Responsibility Assignment Software Patterns)
layer: design
type: pattern
priority: medium
version: 1.0.0
tags:
  - Design
  - GRASP
  - Pattern
  - OOP
description: Patterns for assigning responsibilities in object-oriented design.
description_pt: Padrões para atribuir responsabilidades no design orientado a objetos.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# GRASP

## Description

GRASP (General Responsibility Assignment Software Patterns) is a set of patterns that guide object-oriented designers in assigning responsibilities to classes and objects. Created by Craig Larman, GRASP provides a systematic approach to designing software by breaking down complex design decisions into manageable patterns.

The nine GRASP patterns help answer fundamental questions in object-oriented design:
- Who should be responsible for doing this?
- Who should know about this?
- Who should create this object?

These patterns are based on principles like low coupling, high cohesion, and the Law of Demeter. They provide a vocabulary for discussing design decisions and help developers make consistent, maintainable choices.

GRASP patterns are particularly valuable during the analysis and design phases of software development, helping teams collaborate on design decisions and providing a framework for evaluating design quality.

The nine GRASP patterns are:
1. **Information Expert** - Where to assign responsibility
2. **Creator** - Who should create objects
3. **Controller** - Who handles system operations
4. **Low Coupling** - How to minimize dependencies
5. **High Cohesion** - How to keep objects focused
6. **Indirection** - How to introduce intermediaries
7. **Polymorphism** - How to handle variations
8. **Pure Fabrication** - Who does what doesn't fit elsewhere
9. **Protected Variations** - How to handle changing aspects

## Purpose

**When GRASP is valuable:**
- During object-oriented design
- When assigning responsibilities to classes
- For evaluating design quality
- In team discussions about design
- For learning object-oriented principles

**When to avoid:**
- For simple CRUD applications
- When using functional paradigms
- In rapid prototyping

## Rules

1. **Start with Information Expert** - Assign to class with most knowledge
2. **Minimize coupling** - Reduce dependencies between classes
3. **Maintain high cohesion** - Keep classes focused
4. **Use controller appropriately** - Don't make God objects
5. **Apply polymorphism** - Handle variations cleanly
6. **Protect against variations** - Encapsulate changing parts

## Examples

### 1. Information Expert

```python
# PROBLEM: Who calculates order total?

# BAD: Controller does everything
class OrderController:
    def create_order(self, items):
        order = Order()
        for item in items:
            total = 0
            for i in item:
                total += i.price * i.quantity
        # Logic in controller!

# GOOD: Expert does it - Order knows its total
class Order:
    def __init__(self):
        self.items = []
    
    def add_item(self, product, quantity):
        self.items.append(OrderItem(product, quantity))
    
    def calculate_total(self):  # Information Expert
        return sum(item.subtotal() for item in self.items)

class OrderItem:
    def __init__(self, product, quantity):
        self.product = product
        self.quantity = quantity
    
    def subtotal(self):
        return self.product.price * self.quantity

# Usage
order = Order()
order.add_item(product_a, 2)
order.add_item(product_b, 1)
total = order.calculate_total()  # Order is the expert
```

### 2. Creator

```python
# PROBLEM: Who creates OrderItem?

# GOOD: Order creates its items
class Order:
    def create_item(self, product, quantity):
        return OrderItem(product, quantity, self)

# Order is the Creator because:
# - Order contains OrderItems
# - Order is responsible for managing OrderItems

# Alternative: Factory for complex creation
class OrderFactory:
    def create_order(self, customer, items):
        order = Order(customer)
        for item_data in items:
            order.add_item(
                product=item_data.product,
                quantity=item_data.quantity
            )
        return order
```

### 3. Controller

```python
# PROBLEM: Who handles user request?

# BAD: Too much in one controller
class GodController:
    def handle_login(self, request): ...
    def handle_logout(self): ...
    def handle_order(self, request): ...
    def handle_payment(self, request): ...
    def handle_shipping(self, request): ...
    # Too many responsibilities!

# GOOD: Multiple specialized controllers
class AuthenticationController:
    def handle_login(self, credentials): ...
    def handle_logout(self, user): ...

class OrderController:
    def handle_create_order(self, order_data): ...
    def handle_cancel_order(self, order_id): ...

class PaymentController:
    def handle_process_payment(self, payment_data): ...

# Use-case controller - orchestrates use case
class PlaceOrderController:
    def __init__(self, order_service, payment_service, notification_service):
        self.order_service = order_service
        self.payment_service = payment_service
        self.notification_service = notification_service
    
    def execute(self, order_request):
        # Orchestrate the use case
        order = self.order_service.create(order_request)
        payment = self.payment_service.process(order)
        self.notification_service.send_confirmation(order)
        return order
```

### 4. Low Coupling

```python
# PROBLEM: Tight coupling makes changes hard

# BAD: Tight coupling
class OrderService:
    def __init__(self):
        self.email = EmailService()  # Direct dependency
        self.payment = StripePayment()  # Direct dependency
        self.shipping = UPSShipping()  # Direct dependency
    
    def process(self, order):
        self.payment.charge(order)
        self.shipping.ship(order)
        self.email.send(order.customer, "Shipped")

# GOOD: Low coupling via interfaces
class PaymentGateway(ABC):
    @abstractmethod
    def charge(self, amount): pass

class NotificationGateway(ABC):
    @abstractmethod
    def send(self, to, message): pass

class OrderService:
    def __init__(self, payment: PaymentGateway, notification: NotificationGateway):
        self.payment = payment  # Depends on abstraction
        self.notification = notification
    
    def process(self, order):
        self.payment.charge(order.total)
        self.notification.send(order.customer, "Shipped")

# Easy to swap implementations
class StripePayment(PaymentGateway):
    def charge(self, amount): ...

class EmailNotification(NotificationGateway):
    def send(self, to, message): ...
```

### 5. High Cohesion

```python
# PROBLEM: Low cohesion leads to confusion

# BAD: Low cohesion - unrelated responsibilities
class UserManager:
    def create_user(self, data): ...        # User creation
    def calculate_salary(self, user): ...   # Payroll
    def generate_report(self): ...          # Reporting
    def send_email(self, user, msg): ...    # Email
    def back_up_database(self): ...        # Backup

# GOOD: High cohesion - focused classes
class UserService:
    def create_user(self, data): ...
    def update_user(self, user_id, data): ...
    def deactivate_user(self, user_id): ...

class PayrollService:
    def calculate_salary(self, employee): ...
    def process_payment(self, payroll): ...

class ReportService:
    def generate_user_report(self): ...
    def generate_sales_report(self): ...

class EmailService:
    def send(self, to, message): ...
```

### 6. Indirection

```python
# PROBLEM: Direct coupling between components

# BAD: A knows about B directly
class Client:
    def __init__(self):
        self.service = ExternalService()

# GOOD: Introduce intermediary
class ServiceProxy:
    def __init__(self):
        self.service = ExternalService()
    
    def call(self, method, params):
        # Can add caching, logging, etc.
        return self.service.call(method, params)

class Client:
    def __init__(self):
        self.proxy = ServiceProxy()
```

### 7. Polymorphism

```python
# PROBLEM: Different behaviors with if/else

# BAD: Switch on type
class PaymentProcessor:
    def process(self, payment):
        if payment.type == 'credit':
            self.process_credit(payment)
        elif payment.type == 'debit':
            self.process_debit(payment)
        elif payment.type == 'crypto':
            self.process_crypto(payment)

# GOOD: Polymorphism
class Payment(ABC):
    @abstractmethod
    def process(self): pass

class CreditCardPayment(Payment):
    def process(self): ...

class DebitCardPayment(Payment):
    def process(self): ...

class CryptoPayment(Payment):
    def process(self): ...

# Client uses polymorphic interface
class OrderService:
    def __init__(self):
        self.payments = []
    
    def add_payment(self, payment: Payment):
        self.payments.append(payment)
    
    def checkout(self):
        for payment in self.payments:
            payment.process()  # Polymorphic call
```

### 8. Pure Fabrication

```python
# PROBLEM: Domain object shouldn't have persistence

# BAD: Mixing domain with persistence
class User:
    def save(self): ...
    def load(self, id): ...
    # User shouldn't know about database!

# GOOD: Pure fabrication - separate class
class User:  # Pure domain
    def __init__(self, name, email):
        self.name = name
        self.email = email

class UserRepository:  # Pure fabrication - persistence
    def save(self, user):
        # Database logic
        pass
    
    def find_by_id(self, id):
        # Database logic
        pass

class UserService:
    def __init__(self, repository: UserRepository):
        self.repository = repository
    
    def create(self, name, email):
        user = User(name, email)
        self.repository.save(user)
        return user
```

### 9. Protected Variations

```python
# PROBLEM: Changes ripple through system

# BAD: Expose internal details
class Order:
    def __init__(self):
        self.items = []
        self.status = "pending"
    
    def get_items(self):
        return self.items  # Exposes internal structure

# GOOD: Encapsulate variation
class Order:
    def __init__(self):
        self._items = []
        self._status = OrderStatus.PENDING
    
    def get_items(self):
        return list(self._items)  # Returns copy
    
    def add_item(self, item):
        self._items.append(item)
    
    def get_total(self):
        return sum(i.price for i in self._items)
    
    def get_status(self):
        return self._status.value
```

## Anti-Patterns

### 1. Ignoring GRASP

**Bad:**
- No systematic approach to responsibility assignment
- Random placement of methods
- God classes

**Solution:**
- Apply GRASP patterns consciously
- Discuss design decisions in terms of patterns
- Review designs for pattern application

### 2. Over-Applying Patterns

**Bad:**
- Creating interfaces for everything
- Too many abstractions
- Complexity without benefit

**Solution:**
- Apply patterns when they add value
- Don't over-engineer simple cases
- Consider YAGNI

## Best Practices

### Design Process with GRASP

```
1. Identify requirements and use cases
2. Identify classes and responsibilities
3. Apply Information Expert first
4. Apply Creator for object creation
5. Apply Low Coupling throughout
6. Apply High Cohesion to keep classes focused
7. Use Controller for system operations
8. Apply other patterns as needed
9. Review for coupling and cohesion
10. Refactor as needed
```

### Evaluating Design

```python
# Checklist for design review
checklist = {
    "information_expert": "Is responsibility on class with most info?",
    "creator": "Is creator class closely related to created object?",
    "controller": "Is there a controller for each use case?",
    "low_coupling": "Are dependencies minimized?",
    "high_cohesion": "Are classes focused on single purpose?",
    "indirection": "Is indirection used to reduce coupling?",
    "polymorphism": "Are variations handled with polymorphism?",
    "pure_fabrication": "Are non-domain responsibilities separated?",
    "protected_variations": "Are stable interfaces created?"
}
```

## Failure Modes

- **Ignoring GRASP leads to random responsibility assignment** → no systematic approach to class design → god classes and anemic models → apply GRASP patterns consciously during design discussions
- **Over-applying Indirection pattern** → adding proxy layers everywhere → unnecessary complexity and performance overhead → introduce indirection only when it reduces coupling
- **Information Expert creating god classes** → all related knowledge concentrated in one class → class becomes too large → balance information expertise with single responsibility
- **Pure Fabrication over-engineering** → creating artificial classes for simple operations → more classes to maintain → use pure fabrication only when domain classes would gain inappropriate responsibilities
- **Controller becoming god controller** → single controller handles all use cases → controller becomes unmaintainable → create use-case-specific controllers with focused responsibilities
- **Polymorphism abuse for simple conditionals** → creating class hierarchy for two-case switch → complexity without benefit → use polymorphism when variations are likely to grow
- **Protected Variations creating unnecessary abstractions** → interfaces for things that never vary → abstraction overhead without payoff → apply protected variations only to genuinely volatile aspects

## Technology Stack

| Concept | Application |
|---------|-------------|
| SOLID | Complementary to GRASP |
| Design Patterns | Build on GRASP principles |
| TDD | Guide test design with GRASP |

## Related Topics

- [[SOLID]]
- [[DesignPatterns]]
- [[Coupling]]
- [[Cohesion]]
- [[DomainModeling]]
- [[Refactoring]]
- [[SeparationOfConcerns]]
- [[CodeQuality]]

## Key Takeaways

- GRASP provides nine systematic patterns for assigning responsibilities to classes in object-oriented design, answering who should do, know, or create what
- Valuable during object-oriented design, when assigning responsibilities, evaluating design quality, and in team design discussions
- Avoid for simple CRUD applications, functional paradigms, or rapid prototyping where design overhead isn't justified
- Tradeoff: systematic responsibility assignment and design vocabulary versus risk of over-engineering with unnecessary abstractions
- Main failure mode: ignoring GRASP leads to random responsibility assignment producing god classes and anemic models
- Best practice: start with Information Expert, apply Low Coupling and High Cohesion throughout, use Controller per use-case (not god controllers), and balance pattern application with YAGNI
- Related: SOLID, design patterns, coupling, cohesion, domain modeling, refactoring, separation of concerns

## Additional Notes

**GRASP vs SOLID:**
- GRASP: Focus on responsibility assignment
- SOLID: Focus on class design principles
- Both complement each other

**Learning GRASP:**
1. Start with Information Expert
2. Then Low Coupling and High Cohesion
3. Add other patterns as needed

**Design Heuristics:**
- Start simple
- Refactor when patterns emerge
- Discuss designs in pattern terms