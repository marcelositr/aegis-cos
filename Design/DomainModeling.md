---
title: Domain Modeling
title_pt: Modelagem de Domínio
layer: design
type: concept
priority: medium
version: 1.0.0
tags:
  - Design
  - Domain
  - Modeling
description: Techniques for modeling business domains in software.
description_pt: Técnicas para modelar domínios de negócio em software.
prerequisites: []
estimated_read_time: 15 min
difficulty: intermediate
---

# Domain Modeling

## Description

Domain modeling is the process of creating a conceptual representation of a business domain that can be understood by both technical and non-technical stakeholders. It bridges the gap between the real-world business problems and the software solutions that address them.

A good domain model captures:
- **Entities** - Objects with identity (Order, User, Product)
- **Value Objects** - Objects without identity (Money, Address, Color)
- **Aggregates** - Clusters of related objects with one root
- **Services** - Operations that don't belong to entities
- **Events** - Something significant happened in the domain
- **Repositories** - Access to domain objects

## Purpose

**When domain modeling is valuable:**
- When building complex business applications
- When there is a need to communicate with domain experts
- When the domain has complex rules and relationships
- When implementing DDD (Domain-Driven Design)
- When designing APIs that reflect business concepts

**When domain modeling may be overkill:**
- Simple CRUD applications with minimal business logic
- Prototype/MVP with evolving requirements
- Data transformation pipelines (ETL, reporting)
- Utility scripts and automation
- When domain is well-understood and simple

**The key question:** Does the business domain have complexity that warrants explicit modeling, or can we treat data as simple records?

## Rules

1. **Model the domain, not the database** - Focus on business concepts, not tables
2. **Use ubiquitous language** - Same terms for technical and business people
3. **Capture business rules in the model** - Don't delegate to services alone
4. **Distinguish entities from value objects** - Identity vs. attribute equality
5. **Keep aggregates cohesive** - Group related objects, control access through root

## Examples

### Entity with Identity

```python
# Entity - has distinct identity
class Order:
    def __init__(self, order_id: str):
        self._id = order_id  # Identity matters
        self._items = []
        self._status = 'pending'
    
    @property
    def id(self):
        return self._id
    
    def add_item(self, product, quantity):
        if self._status != 'pending':
            raise ValueError("Cannot modify submitted order")
        self._items.append(OrderItem(product, quantity))
    
    def submit(self):
        if not self._items:
            raise ValueError("Cannot submit empty order")
        self._status = 'submitted'
        return OrderSubmittedEvent(self)
```

### Value Object without Identity

```python
# Value Object - defined by attributes, no identity
class Money:
    def __init__(self, amount: Decimal, currency: str):
        self._amount = amount
        self._currency = currency
    
    def __eq__(self, other):
        return self._amount == other._amount and self._currency == other._currency
    
    def __hash__(self):
        return hash((self._amount, self._currency))
    
    def add(self, other: 'Money') -> 'Money':
        if self._currency != other._currency:
            raise ValueError("Cannot add different currencies")
        return Money(self._amount + other._amount, self._currency)
    
    def multiply(self, factor: Decimal) -> 'Money':
        return Money(self._amount * factor, self._currency)
```

### Aggregate Root

```python
# Aggregate - cluster controlled by root
class OrderAggregate:
    def __init__(self, order_id: str):
        self.id = order_id
        self._items = []
        self._status = 'draft'
    
    # External code can only access through root
    def add_item(self, product, quantity):
        if self._status != 'draft':
            raise ValueError("Cannot modify submitted order")
        
        # Check for existing item
        existing = next((i for i in self._items if i.product_id == product.id), None)
        if existing:
            existing.increase_quantity(quantity)
        else:
            self._items.append(OrderItem(product, quantity))
    
    # Get items via copy to prevent external modification
    @property
    def items(self):
        return list(self._items)
    
    def submit(self):
        if not self._items:
            raise ValueError("Cannot submit empty order")
        
        events = [OrderSubmittedEvent(self.id)]
        self._status = 'submitted'
        return events
```

### Domain Service

```python
# Domain Service - operation that doesn't fit in entity
class PricingService:
    def calculate_total(self, items: List[OrderItem], customer: Customer) -> Money:
        subtotal = sum(item.price * item.quantity for item in items)
        
        # Apply business rules
        discount = self._calculate_discount(customer, subtotal)
        tax = self._calculate_tax(subtotal - discount)
        
        return Money(subtotal - discount + tax, 'USD')
    
    def _calculate_discount(self, customer, subtotal):
        if customer.tier == 'premium' and subtotal > 1000:
            return subtotal * Decimal('0.10')
        return Decimal('0')
```

### Domain Events

```python
# Domain Events - significant occurrences
from dataclasses import dataclass
from datetime import datetime

@dataclass
class DomainEvent:
    occurred_at: datetime
    event_id: str

@dataclass
class OrderSubmittedEvent(DomainEvent):
    order_id: str
    customer_id: str
    total: Money

@dataclass
class OrderShippedEvent(DomainEvent):
    order_id: str
    tracking_number: str

@dataclass
class PaymentReceivedEvent(DomainEvent):
    order_id: str
    amount: Money
    payment_method: str
```

## Anti-Patterns

### 1. Anemic Domain Model

**Bad:** Objects with only getters and setters, no behavior

```python
class Order:
    def __init__(self):
        self.items = []
        self.status = "draft"
    
    def get_total(self):
        return sum(i.price * i.quantity for i in self.items)

# All logic in service
class OrderService:
    def submit_order(self, order):
        if not order.items:
            raise Error("Empty")
        if order.status != "draft":
            raise Error("Already submitted")
        order.status = "submitted"
        self.notify_customer(order)
```

**Solution:** Move business logic into domain objects

### 2. God Object

**Bad:** One model trying to represent everything

```python
# Trying to model everything in one class
class SystemObject:
    # Orders, customers, products, invoices...
    # Everything!
```

**Solution:** Separate bounded contexts, use distinct models

### 3. Anemic Value Objects

**Bad:** Using primitives instead of meaningful types

```python
# BAD - What does "100" mean?
def calculate_price(price, tax, discount):
    return (price + tax - discount) * 1.1

# GOOD - Explicit value objects
def calculate_price(price: Money, tax: Money, discount: Money):
    return price.add(tax).subtract(discount).multiply(Decimal('1.1'))
```

## Failure Modes

- **Anemic domain model** → logic in services → business rules scattered → embed behavior in domain objects, not anemic data holders
- **God object** → single model represents everything → unmaintainable → separate bounded contexts with distinct models
- **Primitive obsession** → raw types instead of value objects → semantic errors → use explicit value objects (Money, Email, etc.)
- **Modeling database instead of domain** → technical structure leaks → business concepts obscured → model business concepts, not tables
- **Missing invariants** → invalid state possible → data corruption → enforce business rules as domain object invariants
- **Inconsistent ubiquitous language** → miscommunication between teams → wrong implementation → document and enforce shared terminology
- **Aggregate boundary violations** → external code modifies internals → inconsistent state → control access through aggregate root only

## Best Practices

### 1. Start with Ubiquitous Language

```python
# Establish shared vocabulary with domain experts
# Customer = "anyone who has purchased or shown interest"
# Client = "business entity we have contract with"
# Lead = "potential customer in sales pipeline"

# Document these terms and use consistently
GLOSSARY = {
    "Order": "Customer commitment to purchase",
    "Quote": "Price proposal valid for limited time",
    "Invoice": "Request for payment for delivered goods"
}
```

### 2. Test the Model

```python
# Domain model should be testable in isolation
def test_order_submission():
    order = Order("order-1")
    order.add_item(Product("p1"), 2)
    
    events = order.submit()
    
    assert order.status == 'submitted'
    assert len(events) == 1
    assert isinstance(events[0], OrderSubmittedEvent)

def test_cannot_add_to_submitted_order():
    order = Order("order-1")
    order.add_item(Product("p1"), 1)
    order.submit()
    
    with pytest.raises(ValueError):
        order.add_item(Product("p2"), 1)
```

### 3. Validate Invariants

```python
# Ensure business rules are always maintained
class BankAccount:
    def __init__(self, balance: Money):
        self._balance = balance
    
    def withdraw(self, amount: Money):
        if amount > self._balance:
            raise InsufficientFundsError("Cannot withdraw more than balance")
        self._balance = self._balance.subtract(amount)
    
    def deposit(self, amount: Money):
        self._balance = self._balance.add(amount)
        # Invariant: balance should never be negative
```

## Related Topics

- [[DDD]]
- [[GRASP]]
- [[DesignPatterns]]
- [[Cohesion]]
- [[Modularity]]
- [[DataStructures]]
- [[APIDesign]]
- [[SQL]]

## Key Takeaways

- Domain modeling creates conceptual representations of business domains using entities, value objects, aggregates, services, events, and repositories
- Valuable for complex business applications, communicating with domain experts, implementing DDD, and designing APIs that reflect business concepts
- Overkill for simple CRUD apps, prototypes with evolving requirements, ETL pipelines, or utility scripts
- Tradeoff: rich business-aligned models that encode rules versus modeling effort and the discipline to resist database-driven design
- Main failure mode: anemic domain models with logic scattered in services instead of embedded in domain objects, making business rules hard to find and maintain
- Best practice: model the domain not the database, use ubiquitous language shared with domain experts, distinguish entities from value objects, enforce invariants in domain objects, and control access through aggregate roots
- Related: DDD, GRASP, design patterns, cohesion, modularity, API design

## Additional Notes

**Domain Model vs Data Model:**
- Data model: How data is stored (tables, columns)
- Domain model: How business concepts relate

**Modeling Techniques:**
- Event storming (Ubiquitous Language)
- Domain storytelling
- Example mapping
- CRC cards (Class-Responsibility-Collaboration)

**When to Evolve:**
- When business requirements change
- When domain expert provides new insights
- When model doesn't support new use cases