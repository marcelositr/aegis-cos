---
title: UML Basics
title_pt: UML Básico (Unified Modeling Language)
layer: design
type: tool
priority: medium
version: 1.0.0
tags:
  - Design
  - UML
  - Modeling
  - Tool
description: Fundamental UML diagrams for software design and documentation.
description_pt: Diagramas UML fundamentais para design e documentação de software.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# UML Basics

## Description

The Unified Modeling Language (UML) is a standardized visual modeling language used in software engineering to specify, visualize, construct, and document software system artifacts. UML provides a common vocabulary and notation for describing system structure and behavior, making it easier for teams to communicate and understand designs.

UML was created in the 1990s by merging three competing modeling notations (Booch, OMT, and OOSE) and is now managed by Object Management Group (OMG). The language includes various diagram types organized into two main categories:

1. **Structural Diagrams** - Show static structure of the system
   - Class Diagram, Object Diagram, Component Diagram, Deployment Diagram
   - Package Diagram, Composite Structure Diagram

2. **Behavioral Diagrams** - Show dynamic behavior
   - Use Case Diagram, Activity Diagram, State Machine Diagram
   - Sequence Diagram, Communication Diagram

UML is particularly valuable during the design phase, where it helps visualize architecture before implementation. It also serves as documentation for existing systems and facilitates communication between technical and non-technical stakeholders.

## Purpose

**When UML is valuable:**
- During system design to visualize architecture
- For communicating designs to stakeholders
- As documentation for existing systems
- In team environments where visual communication helps
- For planning refactoring efforts

**When to avoid UML:**
- For simple, well-understood systems
- When rapid prototyping is more important
- When team doesn't know UML
- In fast-paced iterations where documentation lags

## Rules

1. **Use the right diagram** - Choose based on what you need to communicate
2. **Keep diagrams simple** - Don't show everything, focus on what's relevant
3. **Follow UML conventions** - Use standard notation
4. **Update diagrams** - Keep them in sync with code
5. **Don't over-document** - Diagram what's needed, not everything
6. **Use tools** - Use diagramming tools rather than hand-drawing
7. **Focus on intent** - Diagrams should communicate, not just describe

## Examples

### Class Diagram

```uml
@startuml
skinparam classAttributeIconSize 0

class User {
  -id: UUID
  -name: String
  -email: String
  -passwordHash: String
  -createdAt: DateTime
  
  +create(name, email, password): User
  +updateProfile(name): void
  +verifyPassword(password): Boolean
}

class Order {
  -id: UUID
  -userId: UUID
  -status: OrderStatus
  -total: Money
  
  +place(): void
  +cancel(): void
  +fulfill(): void
}

class OrderItem {
  -quantity: Integer
  -price: Money
}

enum OrderStatus {
  DRAFT
  PENDING
  CONFIRMED
  SHIPPED
  DELIVERED
  CANCELLED
}

User "1" -- "*" Order : places
Order "1" -- "*" OrderItem : contains
OrderItem "*" -- "1" Product : for
@enduml
```

### Sequence Diagram

```uml
@startuml
actor Client
participant "API Gateway" as Gateway
participant "Auth Service" as Auth
participant "User Service" as UserSVC
database Database

Client -> Gateway: POST /users
Gateway -> Auth: Validate token
alt token valid
    Auth -> Gateway: Valid
    Gateway -> UserSVC: Create user
    UserSVC -> Database: INSERT user
    Database -> UserSVC: User created
    UserSVC -> Gateway: User response
    Gateway -> Client: 201 Created
else token invalid
    Auth -> Gateway: Invalid
    Gateway -> Client: 401 Unauthorized
end
@enduml
```

### Use Case Diagram

```uml
@startuml
left to right direction

actor Customer
actor "Support Agent" as Agent
actor Admin

rectangle "E-commerce System" {
    usecase "Search Products" as UC1
    usecase "Add to Cart" as UC2
    usecase "Checkout" as UC3
    usecase "View Orders" as UC4
    usecase "Track Order" as UC5
    usecase "Manage Products" as UC6
    usecase "Process Refund" as UC7
}

Customer -- UC1
Customer -- UC2
Customer -- UC3
Customer -- UC4
Customer -- UC5

Agent -- UC7
UC7 ..> UC4 : includes

Admin -- UC6
@enduml
```

### Activity Diagram

```uml
@startuml
start
:User enters checkout;
if (Cart empty?) then (yes)
    :Show empty cart message;
    stop
else (no)
    :Display order summary;
endif

if (Address saved?) then (yes)
    :Use saved address;
else (no)
    :Collect shipping address;
endif

if (Payment method saved?) then (yes)
    :Use saved payment;
else (no)
    :Collect payment details;
endif

:Review order;
:Place order;
:Send confirmation;
stop
@enduml
```

### State Machine Diagram

```uml
@startuml
[*] --> Draft

Draft --> Pending: Submit
Pending --> Confirmed: Confirm
Confirmed --> Shipped: Ship
Shipped --> Delivered: Deliver

Shipped --> Cancelled: Cancel
Confirmed --> Cancelled: Cancel

Delivered --> [*]
Cancelled --> [*]

note right of Draft
  Can edit items
end note

note right of Cancelled
  Refund triggered
end note
@enduml
```

## Anti-Patterns

### 1. UML as Documentation Only

**Bad:**
- Creating UML after code is written
- Never updating diagrams
- Diagrams don't match code

**Solution:**
- Use UML during design, before coding
- Keep diagrams updated with code changes
- Use round-trip tools

### 2. Over-detailed Diagrams

**Bad:**
- Showing every attribute and method
- Diagrams become unreadable
- Too much detail obscures meaning

**Solution:**
- Focus on what's important
- Hide unnecessary details
- Use different levels of detail

### 3. Wrong Diagram for Purpose

**Bad:**
- Using class diagrams for behavior
- Showing flow in structural diagrams

**Solution:**
- Choose diagram based on what to communicate
- Use multiple diagrams for different views

## Best Practices

### 1. Level of Detail

```uml
# High-level (just classes and relationships)
class Order
class Customer
Order "*" -- "1" Customer

# Medium-level (key attributes)
class Order {
  id: UUID
  status: OrderStatus
  total: Money
}

# Detailed (all attributes and methods)
class Order {
  -id: UUID
  -customerId: UUID
  -items: List<OrderItem>
  -status: OrderStatus
  -createdAt: DateTime
  -updatedAt: DateTime
  
  +place(): void
  +cancel(): void
  +addItem(product, quantity): void
  +removeItem(itemId): void
  +getTotal(): Money
}
```

### 2. Naming Conventions

```python
# Classes: Capitalized, noun (User, OrderService)
# Interfaces: Capitalized with I prefix orable (IShape, Drawable)
# Methods: camelCase (getUser, calculateTotal)
# Attributes: camelCase or underscore (userName, _internal)
# Constants: UPPER_CASE (MAX_RETRY, DEFAULT_TIMEOUT)

# Good examples
class ShoppingCart:
    def add_item(self, product, quantity): ...
    def calculate_total(self): ...

# Bad examples
class cart: ...  # Should be Cart
def AddItem(): ...  # Should be addItem
```

### 3. Using Tools

| Tool | Best For |
|------|----------|
| PlantUML | Text-based, version control friendly |
| Mermaid | Simple diagrams in markdown |
| Lucidchart | Collaborative visual |
| Visual Paradigm | Enterprise modeling |
| draw.io | General purpose |

## Failure Modes

- **Diagrams diverging from code** → UML not updated after code changes → diagrams become misleading documentation → generate diagrams from code or update as part of development workflow
- **Over-detailed diagrams obscuring intent** → showing every attribute and method → diagram becomes unreadable → focus on relevant elements for the audience and purpose
- **Wrong diagram type for communication goal** → using class diagram to show behavior → audience misunderstands the message → match diagram type to what you need to communicate
- **UML as after-the-fact documentation** → diagrams created after code is written → diagrams reflect implementation, not design intent → create diagrams during design phase before coding
- **Tool lock-in for diagram formats** → proprietary diagram files not version-controllable → lost diagrams when tool changes → use text-based formats like PlantUML or Mermaid
- **Ignoring diagram audience** → technical diagrams shown to stakeholders → confusion and wasted time → create different abstraction levels for different audiences
- **Stale sequence diagrams** → interaction flows change but diagrams do not → debugging using wrong mental model → update behavioral diagrams when interaction patterns change

## Technology Stack

| Tool | Type | Use Case |
|------|------|----------|
| PlantUML | Text-based | Code-friendly diagrams |
| Mermaid | Text-based | Markdown integration |
| StarUML | GUI | Visual modeling |
| Lucidchart | Cloud | Collaboration |
| Visual Paradigm | Enterprise | Full UML support |

## Related Topics

- [[Design MOC]]
- [[DomainModeling]]
- [[DDD]]
- [[OOP]]
- [[DistributedSystems]]

## Key Takeaways

- UML is a standardized visual modeling language for specifying, visualizing, and documenting software system structure and behavior
- Valuable during system design, communicating with stakeholders, documenting existing systems, and planning refactoring
- Avoid for simple well-understood systems, rapid prototyping, or when the team doesn't know UML notation
- Tradeoff: shared visual understanding and design-before-code discipline versus documentation maintenance overhead and potential for stale diagrams
- Main failure mode: diagrams diverging from code after changes turn UML into misleading documentation that creates wrong mental models
- Best practice: use text-based formats like PlantUML for version control, create diagrams during design phase before coding, keep appropriate detail levels for the audience, and update as part of development workflow
- Related: domain modeling, DDD, object-oriented design, architecture

## Additional Notes

**Most Used Diagrams:**
1. Class Diagram - Structure
2. Sequence Diagram - Behavior
3. Use Case Diagram - Requirements

**UML Versions:**
- UML 1.x (1997)
- UML 2.x (2005-present)
- UML 2.5.1 (2017) - current

**When to Create UML:**
- Before coding complex systems
- To explain design to team
- For documentation
- For planning refactoring

**Tool Selection:**
- Text-based for version control
- Visual for quick sketching
- Enterprise tools for formal specs