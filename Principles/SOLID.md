---
title: SOLID Principles
title_pt: Princípios SOLID
layer: principles
type: concept
priority: high
version: 1.0.0
tags:
  - Principles
  - SOLID
description: Five principles for object-oriented design: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.
description_pt: Cinco princípios para design orientado a objetos: Responsabilidade Única, Aberto/Fechado, Substituição de Liskov, Segregação de Interface, Inversão de Dependência.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# SOLID Principles

## Description

SOLID is an acronym for five design principles that make software designs more understandable, flexible, and maintainable:

1. **S**ingle Responsibility Principle (SRP)
2. **O**pen/Closed Principle (OCP)
3. **L**iskov Substitution Principle (LSP)
4. **I**nterface Segregation Principle (ISP)
5. **D**ependency Inversion Principle (DIP)

These principles guide object-oriented design and help create robust, scalable systems.

## Purpose

**When SOLID is valuable:**
- When building large, maintainable systems
- When working with teams on shared codebases
- When code needs to evolve over time
- For creating testable architectures

**When SOLID may be overkill:**
- For simple scripts and utilities
- When requirements are stable and limited
- For prototypes where speed matters

**The key question:** Will these principles help the code evolve, or add unnecessary overhead?

## 1. Single Responsibility Principle (SRP)

**A class should have one, and only one, reason to change.**

```python
# Bad - Multiple responsibilities
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email
    
    def save(self, db):
        # Responsibility 1: Database persistence
        db.save_user(self)
    
    def send_email(self, subject, body):
        # Responsibility 2: Email sending
        # Violates SRP!
        smtp.send(self.email, subject, body)
    
    def validate(self):
        # Responsibility 3: Validation
        # Also violates SRP!
        if '@' not in self.email:
            raise ValueError("Invalid email")
```

```python
# Good - Separate responsibilities
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email

class UserValidator:
    def validate(self, user: User):
        if '@' not in user.email:
            raise ValueError("Invalid email")

class UserRepository:
    def save(self, user: User, db):
        db.save_user(user)

class EmailService:
    def send_email(self, to, subject, body):
        smtp.send(to, subject, body)
```

## 2. Open/Closed Principle (OCP)

**Software entities should be open for extension but closed for modification.**

```python
# Bad - Must modify to add new shapes
class AreaCalculator:
    def calculate(self, shape):
        if shape.type == 'circle':
            return 3.14 * shape.radius ** 2
        elif shape.type == 'rectangle':
            return shape.width * shape.height
        # Must add new condition for new shapes!
```

```python
# Good - Extend without modifying
class Shape(ABC):
    @abstractmethod
    def area(self) -> float:
        pass

class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius
    
    def area(self) -> float:
        return 3.14 * self.radius ** 2

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def area(self) -> float:
        return self.width * self.height

class AreaCalculator:
    def calculate(self, shape: Shape) -> float:
        return shape.area()  # No modification needed for new shapes!
```

## 3. Liskov Substitution Principle (LSP)

**Objects of a superclass should be replaceable with objects of a subclass without breaking the application.**

```python
# Bad - Violates LSP
class Rectangle:
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def set_width(self, width):
        self.width = width
    
    def set_height(self, height):
        self.height = height

class Square(Rectangle):
    def __init__(self, size):
        super().__init__(size, size)
    
    def set_width(self, width):
        # Square breaks Rectangle's contract!
        self.width = width
        self.height = width
    
    def set_height(self, height):
        self.width = height
        self.height = height

# Usage breaks when using Square as Rectangle
def resize_rectangle(rect, new_width, new_height):
    rect.set_width(new_width)
    rect.set_height(new_height)
    # Square will have wrong dimensions!

resize_rectangle(Square(5), 10, 20)  # Results: 20x20 instead of 10x20
```

```python
# Good - Proper inheritance
class Shape(ABC):
    @abstractmethod
    def area(self) -> float:
        pass

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def area(self) -> float:
        return self.width * self.height

class Square(Shape):
    def __init__(self, size):
        self.size = size
    
    def area(self) -> float:
        return self.size ** 2

# Both can be used interchangeably
def calculate_area(shape: Shape) -> float:
    return shape.area()
```

## 4. Interface Segregation Principle (ISP)

**Clients should not be forced to depend on interfaces they do not use.**

```python
# Bad - Fat interface
class Machine(ABC):
    @abstractmethod
    def print(self, document):
        pass
    
    @abstractmethod
    def scan(self, document):
        pass
    
    @abstractmethod
    def fax(self, document):
        pass

class AllInOnePrinter(Machine):
    def print(self, document):
        # Implementation
        pass
    
    def scan(self, document):
        # Implementation
        pass
    
    def fax(self, document):
        # Implementation
        pass

class SimplePrinter(Machine):
    def print(self, document):
        # Implementation
        pass
    
    def scan(self, document):
        # Must implement even though not needed!
        raise NotImplementedError("Can't scan")
    
    def fax(self, document):
        raise NotImplementedError("Can't fax")
```

```python
# Good - Segregated interfaces
class Printer(ABC):
    @abstractmethod
    def print(self, document):
        pass

class Scanner(ABC):
    @abstractmethod
    def scan(self, document):
        pass

class FaxMachine(ABC):
    @abstractmethod
    def fax(self, document):
        pass

class AllInOne(Printer, Scanner, FaxMachine):
    def print(self, document): pass
    def scan(self, document): pass
    def fax(self, document): pass

class SimplePrinter(Printer):
    def print(self, document): pass
    # Only implements what it needs!
```

## 5. Dependency Inversion Principle (DIP)

**High-level modules should not depend on low-level modules. Both should depend on abstractions.**

```python
# Bad - Direct dependency
class OrderService:
    def __init__(self):
        self.database = MySQLDatabase()  # Direct dependency!
        self.email = SendGridEmail()     # Direct dependency!
    
    def create_order(self, order):
        self.database.save(order)
        self.email.send(order.customer_email, "Order created")
```

```python
# Good - Depend on abstractions
class Database(ABC):
    @abstractmethod
    def save(self, data): pass

class EmailService(ABC):
    @abstractmethod
    def send(self, to, message): pass

class OrderService:
    def __init__(self, database: Database, email: EmailService):
        self.database = database  # Depend on abstraction
        self.email = email        # Depend on abstraction
    
    def create_order(self, order):
        self.database.save(order)
        self.email.send(order.customer_email, "Order created")

# Concrete implementations
class MySQLDatabase(Database):
    def save(self, data): pass

class SendGridEmail(EmailService):
    def send(self, to, message): pass

# Easy to swap implementations
# Easy to test with mocks
```

## Anti-Patterns

### 1. SOLID Abstraction Hell

**Bad:** Creating interfaces for every class, layers for every concern, and factories for every object "to follow SOLID"
**Why it's bad:** The complexity of the abstraction layer overwhelms the actual business logic — navigating the codebase requires jumping through 5 files to understand one feature
**Good:** Apply SOLID principles proportionally to system complexity — a simple script does not need five layers of abstraction

### 2. SRP Taken to Extremes

**Bad:** Splitting every class into micro-classes with single methods, creating hundreds of tiny files for a simple feature
**Why it's bad:** Navigation overhead and cognitive load exceed the benefit — understanding a feature requires assembling a puzzle of micro-classes
**Good:** SRP means one reason to change, not one method per class — group cohesive operations that change together

### 3. LSP Violations Through Convenience Inheritance

**Bad:** Using inheritance for code reuse when the subclass does not truly satisfy the parent's contract (e.g., Square extends Rectangle)
**Why it's bad:** Code that works with the parent type breaks when given the subclass — the inheritance relationship is a lie
**Good:** Use inheritance only when the subclass is a true subtype — prefer composition over inheritance when the relationship is "uses" not "is-a"

### 4. DIP Over-Engineering

**Bad:** Creating abstract factories, service locators, and dependency injection containers for a simple application with two classes
**Why it's bad:** The DI infrastructure becomes more complex than the application itself — you are solving a problem you do not have
**Good:** Use simple constructor injection for small applications — reserve DI containers and service locators for large systems with many interchangeable components

## Best Practices

### 1. Keep Classes Small

```python
# Each class has one responsibility
# One reason to change
# Easy to test
```

### 2. Program to Interfaces

```python
# Use ABC or Protocol
# Depend on abstractions
# Easy to swap implementations
```

### 3. Inject Dependencies

```python
# Constructor injection
# Don't create dependencies inside class
# Makes testing easier
```

## Related Topics

- [[Coupling]]
- [[Cohesion]]
- [[DesignPatterns]]
- [[Refactoring]]
- [[GRASP]]
- [[Modularity]]
- [[CodeQuality]]
- [[SeparationOfConcerns]]

## Failure Modes

- **SRP violation creating god classes** → class has multiple reasons to change → every modification risks breaking unrelated functionality → split classes by responsibility and ensure single reason to change
- **OCP violation requiring code modification** → adding new behavior requires changing existing tested code → regression risk in stable code → use polymorphism and strategy patterns to extend without modifying
- **LSP violation breaking substitutability** → subclass changes behavior expected from parent type → code using parent interface fails with subclass → ensure subclasses honor parent contracts and invariants
- **ISP violation forcing unused implementations** → clients depend on methods they do not use → unnecessary coupling and implementation burden → split fat interfaces into smaller client-specific interfaces
- **DIP violation creating tight coupling** → high-level modules depend on concrete low-level classes → cannot test or swap implementations → depend on abstractions and inject concretions at composition root
- **Over-applying SOLID creating abstraction hell** → interfaces for everything, layers for everything → complexity overwhelms benefit → apply SOLID principles proportionally to system complexity
- **SOLID principles conflicting with each other** → SRP suggests splitting but DIP suggests abstraction → analysis paralysis → balance principles; no single principle should dominate design decisions

## Examples

### SRP - One Reason to Change

```python
# BAD - Multiple responsibilities
class User:
    def save(self): ...      # Database
    def send_email(self): ...  # Email
    def generate_report(self): ...  # Reporting

# GOOD - Separate classes
class UserRepository: ...
class EmailService: ...
class ReportGenerator: ...
```

### DIP - Depend on Abstractions

```python
# BAD - Concrete dependency
class MySQLUserRepository:
    def get_user(self): ...

# GOOD - Abstract dependency
class UserRepository(ABC):
    @abstractmethod
    def get_user(self): ...

class MySQLUserRepository(UserRepository): ...
class PostgresUserRepository(UserRepository): ...
```

## Key Takeaways

- SOLID comprises five principles (SRP, OCP, LSP, ISP, DIP) that make object-oriented designs more understandable, flexible, and maintainable
- Valuable for large maintainable systems, team-shared codebases, code that needs to evolve, and creating testable architectures
- Overkill for simple scripts, stable limited requirements, or prototypes where speed matters more than structure
- Tradeoff: flexible testable designs that evolve gracefully versus abstraction overhead that can overwhelm simple systems
- Main failure mode: over-applying SOLID creates abstraction hell with interfaces for everything, making navigation require jumping through 5 files to understand one feature
- Best practice: apply SOLID proportionally to system complexity, program to interfaces, use constructor injection, ensure subclasses honor parent contracts, and split fat interfaces into client-specific ones
- Related: coupling, cohesion, design patterns, refactoring, GRASP, modularity, separation of concerns

## Additional Notes
