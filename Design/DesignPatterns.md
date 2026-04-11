---
title: Design Patterns
title_pt: Padrões de Design
layer: design
type: concept
priority: high
version: 1.0.0
tags:
  - Design
  - DesignPatterns
description: Reusable solutions to commonly occurring problems in software design.
description_pt: Soluções reutilizáveis para problemas comuns em design de software.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Design Patterns

## Description

Design patterns are reusable solutions to commonly occurring problems in software design. They are not finished designs that can be transformed directly into code, but rather templates for how to solve a problem that can be adapted to different situations.

Patterns are categorized into three main groups:

1. **Creational**: Object creation mechanisms
   - Singleton, Factory, Abstract Factory, Builder, Prototype

2. **Structural**: Object composition
   - Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy

3. **Behavioral**: Object communication
   - Chain of Responsibility, Command, Iterator, Mediator, Memento, Observer, State, Strategy, Template Method, Visitor

Understanding patterns helps you:
- Communicate using common vocabulary
- Apply proven solutions
- Avoid reinventing the wheel
- Recognize patterns in existing code

## Purpose

**When to use design patterns:**
- When you encounter recurring design problems
- When you need proven solutions
- When communicating with other developers
- When building flexible, maintainable systems
- When you need standard solutions

**When to avoid:**
- When simpler solutions work
- When pattern adds unnecessary complexity
- When misused or forced
- When you don't understand the pattern fully

## Rules

1. **Know the problem first** - Patterns solve specific problems
2. **Don't force patterns** - Use when appropriate
3. **Prefer composition over inheritance** - More flexible
4. **Program to interfaces** - More flexible, testable
5. **Consider the trade-offs** - Patterns have costs
6. **Keep it simple** - Don't over-engineer

## Examples

### Creational: Factory Method

```python
# Factory Method - create objects without specifying exact class
class Document:
    def render(self):
        raise NotImplementedError

class PDFDocument(Document):
    def render(self):
        return "Rendering PDF..."

class WordDocument(Document):
    def render(self):
        return "Rendering Word..."

class DocumentFactory:
    def create_document(self, doc_type: str) -> Document:
        if doc_type == "pdf":
            return PDFDocument()
        elif doc_type == "word":
            return WordDocument()
        raise ValueError(f"Unknown type: {doc_type}")

# Usage
factory = DocumentFactory()
doc = factory.create_document("pdf")
```

### Creational: Builder

```python
# Builder - construct complex objects step by step
class User:
    def __init__(self):
        self.name = None
        self.email = None
        self.age = None
        self.address = None

class UserBuilder:
    def __init__(self):
        self.user = User()
    
    def with_name(self, name: str):
        self.user.name = name
        return self
    
    def with_email(self, email: str):
        self.user.email = email
        return self
    
    def with_age(self, age: int):
        self.user.age = age
        return self
    
    def build(self) -> User:
        return self.user

# Usage
user = (UserBuilder()
    .with_name("John")
    .with_email("john@example.com")
    .with_age(30)
    .build())
```

### Structural: Adapter

```python
# Adapter - convert interface of a class to another
class OldPaymentSystem:
    def make_payment(self, amount: int):
        # Amount in cents
        print(f"Processing ${amount/100:.2f}")

class NewPaymentAPI:
    def pay(self, amount: float):
        print(f"Processing ${amount:.2f}")

class PaymentAdapter:
    def __init__(self, api: NewPaymentAPI):
        self.api = api
    
    def make_payment(self, amount: int):
        # Convert cents to dollars
        self.api.pay(amount / 100)

# Usage
adapter = PaymentAdapter(NewPaymentAPI())
adapter.make_payment(1999)  # $19.99
```

### Structural: Decorator

```python
# Decorator - add behavior dynamically
class Coffee:
    def cost(self):
        return 5

class CoffeeDecorator:
    def __init__(self, coffee: Coffee):
        self.coffee = coffee
    
    def cost(self):
        return self.coffee.cost()

class Milk(CoffeeDecorator):
    def cost(self):
        return self.coffee.cost() + 1.5

class Sugar(CoffeeDecorator):
    def cost(self):
        return self.coffee.cost() + 0.5

# Usage
coffee = Coffee()
coffee = Milk(coffee)
coffee = Sugar(coffee)
print(coffee.cost())  # 7.0
```

### Behavioral: Observer

```python
# Observer - define one-to-many dependency
from abc import ABC, abstractmethod

class Observer(ABC):
    @abstractmethod
    def update(self, message: str):
        pass

class Subject:
    def __init__(self):
        self.observers = []
    
    def attach(self, observer: Observer):
        self.observers.append(observer)
    
    def detach(self, observer: Observer):
        self.observers.remove(observer)
    
    def notify(self, message: str):
        for observer in self.observers:
            observer.update(message)

class UserObserver(Observer):
    def update(self, message: str):
        print(f"User notified: {message}")

# Usage
subject = Subject()
subject.attach(UserObserver())
subject.notify("New message!")
```

### Behavioral: Strategy

```python
# Strategy - define family of algorithms, select at runtime
class PaymentStrategy(ABC):
    @abstractmethod
    def pay(self, amount: float):
        pass

class CreditCardPayment(PaymentStrategy):
    def __init__(self, card_number: str):
        self.card = card_number
    
    def pay(self, amount: float):
        print(f"Paid {amount} with credit card {self.card[-4:]}")

class PayPalPayment(PaymentStrategy):
    def __init__(self, email: str):
        self.email = email
    
    def pay(self, amount: float):
        print(f"Paid {amount} with PayPal {self.email}")

class ShoppingCart:
    def __init__(self):
        self.items = []
        self.payment_strategy = None
    
    def set_payment(self, strategy: PaymentStrategy):
        self.payment_strategy = strategy
    
    def checkout(self):
        total = sum(item.price for item in self.items)
        self.payment_strategy.pay(total)

# Usage
cart = ShoppingCart()
cart.set_payment(CreditCardPayment("4111111111111111"))
cart.checkout()
```

## Anti-Patterns

### 1. Applying Wrong Pattern

**Bad:**
- Force-fitting pattern where not needed
- Using pattern that doesn't fit problem
- Adding complexity without benefit

**Solution:**
- Understand the problem first
- Choose simplest solution
- Don't over-engineer

### 2. Pattern Overdose

**Bad:**
- Using pattern for everything
- Creating unnecessary layers
- Complexity for complexity's sake

**Solution:**
- Keep it simple
- Use when appropriate
- YAGNI

### 3. Not Understanding Pattern Fully

**Bad:**
- Incomplete implementation
- Wrong usage
- Missing parts

**Solution:**
- Study pattern thoroughly
- Understand trade-offs
- Practice before using

### 4. Ignoring Context

**Bad:**
- Using pattern without considering environment
- Not adapting to specific needs
- One-size-fits-all approach

**Solution:**
- Consider context
- Adapt pattern
- Don't copy blindly

## Failure Modes

- **Forcing pattern where not needed** → unnecessary complexity → harder to maintain → use simplest solution that solves the problem
- **Pattern overdose** → excessive abstraction layers → debugging nightmare → apply patterns only where they provide clear benefit
- **Incomplete pattern implementation** → broken pattern contract → subtle bugs → study and implement full pattern, not partial
- **Ignoring context** → pattern mismatch → wrong solution for problem → adapt patterns to specific domain requirements
- **Misidentifying the problem** → wrong pattern selected → no real improvement → understand the problem deeply before choosing a pattern
- **Copy-paste without understanding** → pattern misuse → architectural debt → learn pattern intent and trade-offs before applying
- **Not considering alternatives** → suboptimal design → missed better solutions → evaluate multiple patterns and simple alternatives

## Best Practices

### 1. Pattern Selection Guide

| Problem | Pattern |
|---------|---------|
| Object creation varies | Factory, Builder |
| Need single instance | Singleton |
| Interface mismatch | Adapter |
| Add behavior dynamically | Decorator |
| Hide complexity | Facade |
| One-to-many dependency | Observer |
| Multiple algorithms | Strategy |
| Complex construction | Builder |
| Define algorithm skeleton | Template Method |

### 2. Implementation Checklist

```
Before using pattern:
- Understand the problem
- Know all pattern options
- Consider trade-offs
- Check if pattern fits
- Plan implementation

After using pattern:
- Code is clear?
- Tests still work?
- Maintenance easier?
- Pattern justified?
```

### 3. Patterns and Principles

- **SOLID**: Complementary to patterns
- **SRP**: Each pattern has single responsibility
- **OCP**: Patterns enable extension
- **DIP**: Patterns often use interfaces
- **ISP**: Patterns should have focused interfaces

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| OOP languages | Pattern implementations |
| Python abc | Abstract classes |
| Java interfaces | Pattern contracts |
| Go interfaces | Duck typing for patterns |

## Related Topics

- [[Refactoring]]
- [[SOLID]]
- [[Coupling]]
- [[Cohesion]]
- [[GRASP]]
- [[Modularity]]
- [[CodeQuality]]
- [[SeparationOfConcerns]]

## Key Takeaways

- Design patterns are reusable solution templates for recurring software design problems, categorized as creational, structural, or behavioral
- Use when you encounter proven recurring problems, need a shared vocabulary with the team, or are building flexible maintainable systems
- Avoid when simpler solutions work, the pattern adds unnecessary complexity, or you don't fully understand the pattern's trade-offs
- Tradeoff: proven solutions and shared vocabulary versus added abstraction layers and potential over-engineering
- Main failure mode: forcing patterns where they don't fit creates unnecessary complexity that's harder to maintain than the original problem
- Best practice: understand the problem deeply first, choose the simplest solution, prefer composition over inheritance, and program to interfaces
- Related: refactoring, SOLID principles, coupling, cohesion, GRASP, modularity

## Additional Notes

**When to Learn Patterns:**
- After understanding OOP basics
- When reading existing code
- When solving recurring problems
- When discussing with other developers

**Pattern vs Algorithm:**
- Pattern: General solution template
- Algorithm: Specific steps to solve problem
- Pattern is higher-level

**Common Misconceptions:**
- Patterns are not rules
- Not all problems need patterns
- Patterns can be combined
- Context matters
