---
title: Object-Oriented Design
title_pt: Design Orientado a Objetos
layer: design
type: concept
priority: medium
version: 1.0.0
tags:
  - Design
  - OOP
  - Object-Oriented
description: Object-oriented design principles and patterns.
description_pt: Princípios e padrões de design orientado a objetos.
prerequisites: []
estimated_read_time: 15 min
difficulty: intermediate
---

# Object-Oriented Design

## Description

Object-oriented design (OOD) organizes software as a collection of objects that contain both data and behavior. This approach promotes modularity, reusability, and maintainability.

Key OOP concepts:
- **Classes** - Blueprints for objects
- **Inheritance** - Is-a relationships
- **Composition** - Has-a relationships
- **Polymorphism** - Different behaviors for same interface
- **Encapsulation** - Hiding internal details

## Purpose

**When OOP is valuable:**
- When modeling real-world entities with behavior
- When building large applications with complex state
- When team understands OOP concepts
- When using OOP languages (Java, C#, Python, etc.)

**When OOP may not be the best fit:**
- When functional approach is more natural (data transformation pipelines)
- For simple scripts with minimal state
- When performance is critical and overhead matters
- For systems better modeled as transformations than entities

**The key question:** Does the domain naturally fit as objects with state and behavior, or is it better modeled as functions?

## Rules

1. **Favor composition over inheritance** - More flexible, less coupling
2. **Encapsulate what varies** - Hide implementation details
3. **Program to interfaces, not implementations** - Depend on abstractions
4. **Single Responsibility** - Each class has one reason to change
5. **Open for extension, closed for modification** - Don't change existing code

## Examples

### Encapsulation

```python
# GOOD - Encapsulated
class BankAccount:
    def __init__(self, initial_balance=0):
        self._balance = initial_balance  # Private
    
    def deposit(self, amount):
        if amount <= 0:
            raise ValueError("Amount must be positive")
        self._balance += amount
    
    def withdraw(self, amount):
        if amount > self._balance:
            raise ValueError("Insufficient funds")
        self._balance -= amount
    
    @property
    def balance(self):
        return self._balance  # Controlled access

# BAD - Exposed internals
class BankAccount:
    def __init__(self):
        self.balance = 0  # Anyone can modify!
```

### Composition

```python
# GOOD - Composition over inheritance
class Car:
    def __init__(self):
        self.engine = Engine()
        self.wheels = [Wheel() for _ in range(4)]
        self.transmission = Transmission()
    
    def drive(self):
        self.engine.start()
        self.transmission.engage()
        # ...

# BAD - Deep inheritance hierarchy
class Vehicle: pass
class Car(Vehicle): pass
class SportsCar(Car): pass
class ElectricSportsCar(SportsCar): pass  # Fragile!
```

### Polymorphism

```python
# GOOD - Polymorphic behavior
from abc import ABC, abstractmethod

class PaymentProcessor(ABC):
    @abstractmethod
    def process(self, amount: float) -> bool:
        pass

class CreditCardProcessor(PaymentProcessor):
    def process(self, amount):
        # Credit card logic
        return True

class PayPalProcessor(PaymentProcessor):
    def process(self, amount):
        # PayPal logic
        return True

class CryptoProcessor(PaymentProcessor):
    def process(self, amount):
        # Crypto logic
        return True

# Use interchangeably
def checkout(processor: PaymentProcessor, amount):
    return processor.process(amount)
```

### Interface Segregation

```python
# GOOD - Small, focused interfaces
class Printer(ABC):
    @abstractmethod
    def print(self, document): pass

class Scanner(ABC):
    @abstractmethod
    def scan(self): pass

class Fax(ABC):
    @abstractmethod
    def fax(self, number): pass

class AllInOne(Printer, Scanner, Fax):
    def print(self, document): pass
    def scan(self): pass
    def fax(self, number): pass

# BAD - Fat interface
class IMachine(ABC):
    def print(self): pass
    def scan(self): pass
    def fax(self): pass
    def copy(self): pass
    
# A simple printer must implement all these!
```

## Anti-Patterns

### 1. Anemic Domain Model

```python
# BAD - Just data, no behavior
class Order:
    def __init__(self):
        self.items = []
        self.total = 0

# Logic scattered everywhere
class OrderService:
    def calculate_total(self, order):
        order.total = sum(i.price * i.quantity for i in order.items)
    
    def validate(self, order):
        if not order.items:
            return False
        # Validation logic outside
```

**Solution:** Put behavior in objects

### 2. God Object

```python
# BAD - Too much responsibility
class System:
    def __init__(self):
        self.db = Database()
        self.cache = Cache()
        self.auth = Auth()
        self.email = Email()
        self.logging = Logging()
        # ... 100 more things!
```

**Solution:** Split into smaller, focused classes

### 3. Deep Inheritance

```python
# BAD - Complex hierarchy
class Animal: pass
class Vertebrate(Animal): pass
class Mammal(Vertebrate): pass
class Primate(Mammal): pass
class Human(Primate): pass

# Changes ripple through entire tree
```

**Solution:** Use composition instead

## Best Practices

### 1. SOLID Principles

```
S - Single Responsibility: One class, one job
O - Open/Closed: Open for extension, closed for modification
L - Liskov Substitution: Subtypes must be substitutable
I - Interface Segregation: Many small interfaces > one big
D - Dependency Inversion: Depend on abstractions, not concretes
```

### 2. Tell, Don't Ask

```python
# BAD - Asking for data, then doing work
if user.balance > 100:
    user.discount = 0.1

# GOOD - Tell the object to do it
user.apply_discount_if_eligible()

class User:
    def apply_discount_if_eligible(self):
        if self.balance > 100:
            self.discount = 0.1
```

### 3. Law of Demeter

```python
# BAD - Long chain of calls
order.customer.address.city.save()

# GOOD - Ask the object to do it
order.save_customer_city()

class Order:
    def save_customer_city(self):
        self.customer.save_city()
```

## Failure Modes

- **Deep inheritance hierarchies** → changes in base class ripple through entire tree → fragile base class problem → prefer composition over inheritance for code reuse
- **Anemic domain models** → entities are data containers with no behavior → business logic scattered across services → enrich entities with behavior and keep services as orchestrators only
- **God object accumulating responsibilities** → single class knows and does everything → untestable and unmaintainable → apply single responsibility principle and extract focused classes
- **Violating Liskov Substitution** → subclass breaks parent contract → code using parent type fails with subclass → ensure subclasses honor all parent invariants and behavioral contracts
- **Tight coupling through inheritance** → subclass depends on parent implementation details → cannot change parent without breaking children → depend on abstractions and use composition for reuse
- **Over-engineering with patterns** → applying design patterns where simple code suffices → unnecessary complexity → apply patterns only when they solve a real problem
- **Ignoring encapsulation** → exposing internal state through getters and setters → external code depends on internal representation → hide implementation details and expose behavior, not data

## Related Topics

- [[Design MOC]]
- [[SOLID]]
- [[DesignPatterns]]
- [[DomainModeling]]
- [[Abstraction]]

## Key Takeaways

- Object-oriented design organizes software as objects combining data and behavior, promoting modularity, reusability, and maintainability
- Valuable when modeling real-world entities with behavior, building large stateful applications, or using OOP languages
- Consider alternatives (functional, procedural) for data transformation pipelines, simple scripts, or performance-critical systems
- Tradeoff: natural modeling of entities with encapsulated state versus inheritance complexity, coupling risks, and potential over-engineering
- Main failure mode: deep inheritance hierarchies create fragile base class problems where changes ripple unpredictably through the tree
- Best practice: favor composition over inheritance, program to interfaces, apply SOLID principles, use "tell don't ask" to keep behavior with data, and follow Law of Demeter
- Related: SOLID, design patterns, domain modeling, abstraction

## Additional Notes

**OOP Languages:**
- Java, C#, C++ - Traditional OOP
- Python, Ruby - Multi-paradigm with OOP
- Kotlin, Swift - Modern OOP with modern features

**Alternatives:**
- Functional programming (data transformation)
- Procedural (simple scripts)
- Component-based (UI frameworks)