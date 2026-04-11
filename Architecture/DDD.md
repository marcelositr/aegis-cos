---
title: DDD
title_pt: DDD (Domain-Driven Design)
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - DDD
  - Domain
  - Design
description: Software development approach focusing on complex domain modeling.
description_pt: Abordagem de desenvolvimento de software focada em modelagem de domínio complexa.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# DDD

## Description

Domain-Driven Design (DDD) is a software development methodology that emphasizes collaboration between technical and domain experts to create software that accurately represents a specific business domain. Founded by Eric Evans in his 2003 book "Domain-Driven Design: Tackling Complexity in the Heart of Software," DDD provides a framework for understanding business domains and translating that understanding into well-designed software.

DDD is particularly valuable when dealing with complex business domains where the logic and rules are intricate and constantly evolving. Rather than starting with technical considerations, DDD begins with understanding the domain - the business area being addressed - and building a shared model that both developers and domain experts can understand.

The core concepts of DDD include:
- **Ubiquitous Language**: A shared vocabulary between developers and domain experts
- **Bounded Contexts**: Clear boundaries around domain models
- **Aggregates**: Clusters of related objects treated as a unit
- **Domain Events**: Significant occurrences within the domain
- **Entities and Value Objects**: Different ways to represent domain concepts

DDD works particularly well with microservices architectures, where each service can have its own bounded context. It provides the conceptual foundation for breaking down complex systems into manageable, cohesive pieces that align with business capabilities.

## Purpose

**When DDD is valuable:**
- For complex business domains with intricate rules
- When domain expertise is critical to success
- In systems that will evolve over time
- For teams that need clear domain boundaries
- When building microservices

**When to avoid DDD:**
- Simple CRUD applications
- When domain is well-understood and stable
- When tight deadlines don't allow for modeling
- When team lacks domain expertise

## Rules

1. **Learn the domain** - Work with domain experts to understand the business
2. **Use Ubiquitous Language** - Create shared vocabulary
3. **Focus on Core Domain** - Identify and prioritize the most important parts
4. **Design Bounded Contexts** - Define clear boundaries
5. **Build Aggregates** - Group related entities
6. **Iterate on the model** - Continuously refine understanding
7. **Don't over-engineer** - Apply DDD where it adds value

## Examples

### Ubiquitous Language

```python
# BAD: Technical terminology in domain
class OrderRepository:
    def get_by_cust_id(self, customer_id):
        pass
    
    def save(self, order):
        pass

# GOOD: Using Ubiquitous Language
class OrderRepository:
    def find_pending_orders(self, customer):
        """Find all orders awaiting fulfillment for a customer"""
        pass
    
    def place_order(self, order):
        """Save a new order placed by customer"""
        pass
```

### Bounded Contexts

```python
# E-commerce bounded contexts

# Context: Order Management
class Order:
    def __init__(self, order_id, customer, items):
        self.id = order_id
        self.customer = customer
        self.items = items
        self.status = OrderStatus.DRAFT
    
    def submit(self):
        if not self.items:
            raise CannotSubmitEmptyOrderError()
        self.status = OrderStatus.SUBMITTED
    
    def fulfill(self):
        self.status = OrderStatus.FULFILLED

# Context: Shipping
class Shipment:
    def __init__(self, order_id, address):
        self.order_id = order_id
        self.address = address
        self.tracking_number = None
    
    def ship(self, carrier):
        self.tracking_number = carrier.generate_tracking()
    
    def deliver(self):
        self.status = DeliveryStatus.DELIVERED

# Different contexts, different models - but can communicate via events
```

### Aggregates

```python
# Aggregate root - controls access to internal entities
class OrderAggregate:
    def __init__(self, order_id: str):
        self.id = order_id
        self._items = []
        self._status = OrderStatus.DRAFT
    
    @property
    def items(self):
        # Return copy to prevent external modification
        return list(self._items)
    
    @property
    def status(self):
        return self._status
    
    def add_item(self, product: Product, quantity: int):
        if self._status != OrderStatus.DRAFT:
            raise CannotModifyFulfilledOrderError()
        
        existing = next((i for i in self._items if i.product_id == product.id), None)
        if existing:
            existing.increase_quantity(quantity)
        else:
            self._items.append(OrderItem(product, quantity))
    
    def submit(self):
        if not self._items:
            raise CannotSubmitEmptyOrderError()
        
        self._status = OrderStatus.SUBMITTED
        # Domain events
        return [OrderSubmittedEvent(self.id, self._items)]
    
    def cancel(self):
        if self._status == OrderStatus.DELIVERED:
            raise CannotCancelDeliveredOrderError()
        
        self._status = OrderStatus.CANCELLED
        return [OrderCancelledEvent(self.id)]
```

### Value Objects

```python
# Value object - immutable, no identity
class Money:
    def __init__(self, amount: decimal.Decimal, currency: str):
        self._amount = amount
        self._currency = currency
    
    @property
    def amount(self):
        return self._amount
    
    @property
    def currency(self):
        return self._currency
    
    def add(self, other: 'Money') -> 'Money':
        if self.currency != other.currency:
            raise CurrencyMismatchError()
        return Money(self._amount + other._amount, self._currency)
    
    def __eq__(self, other):
        return self._amount == other._amount and self._currency == other._currency
    
    def __hash__(self):
        return hash((self._amount, self._currency))


class Address:
    def __init__(self, street: str, city: str, state: str, zip_code: str, country: str):
        self.street = street
        self.city = city
        self.state = state
        self.zip_code = zip_code
        self.country = country
    
    def __eq__(self, other):
        return (self.street == other.street and 
                self.city == other.city and
                self.state == other.state and
                self.zip_code == other.zip_code and
                self.country == other.country)
```

### Domain Events

```python
# Domain events - significant occurrences
from dataclasses import dataclass
from datetime import datetime

@dataclass
class DomainEvent:
    occurred_at: datetime
    event_id: str

@dataclass
class OrderSubmittedEvent(DomainEvent):
    order_id: str
    total: Money
    customer_id: str
    
    def __init__(self, order_id, items):
        super().__init__()
        self.order_id = order_id
        self.total = sum(item.price * item.quantity for item in items)
        self.customer_id = items[0].order.customer_id

@dataclass
class OrderFulfilledEvent(DomainEvent):
    order_id: str
    tracking_number: str

@dataclass
class PaymentProcessedEvent(DomainEvent):
    order_id: str
    amount: Money
    payment_method: str
```

## Anti-Patterns

### 1. Anemic Domain Model

**Bad:**
- Objects with only getters and setters
- No business logic in domain objects
- Logic in services/transaction scripts

```python
# BAD - Anemic
class Order:
    def __init__(self):
        self.items = []
        self.status = "draft"
    
    def add_item(self, item):
        self.items.append(item)
    
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

**Solution:**
- Move logic to domain objects
- Make domain objects responsible for their state

### 2. Generic Domain Model

**Bad:**
- Using generic terms like "Entity" or "Value"
- Not reflecting domain terminology
- All contexts in one model

**Solution:**
- Use domain-specific language
- Create models for specific contexts
- Let domain experts review models

### 3. Ignoring Bounded Contexts

**Bad:**
- One model for entire system
- Overlapping responsibilities
- Conflicting requirements

**Solution:**
- Identify bounded contexts
- Define clear boundaries
- Allow different models per context

## Best Practices

### 1. Strategic Design

```
# Bounded Context Map
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Catalog     │     │     Order       │     │    Shipping     │
│                 │     │                 │     │                 │
│ - Products      │     │ - Orders        │     │ - Shipments     │
│ - Categories    │     │ - Order Items   │     │ - Carriers      │
│ - Inventory    │     │ - Payments      │     │ - Tracking      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                      │                       │
         └──────────────────────┼───────────────────────┘
                                │
                         ┌─────────────────┐
                         │   Integration   │
                         │    Contexts     │
                         │                 │
                         │ - Customer      │
                         │ - Notifications │
                         └─────────────────┘
```

### 2. Application Services

```python
# Application service - orchestration, not business logic
class OrderApplicationService:
    def __init__(self, order_repository, event_bus):
        self.order_repository = order_repository
        self.event_bus = event_bus
    
    def place_order(self, command: PlaceOrderCommand):
        # 1. Create aggregate
        order = OrderAggregate(str(uuid.uuid4()))
        
        # 2. Add items (domain logic)
        for item in command.items:
            product = self.product_service.get(item.product_id)
            order.add_item(product, item.quantity)
        
        # 3. Submit (domain logic)
        events = order.submit()
        
        # 4. Persist
        self.order_repository.save(order)
        
        # 5. Publish events
        for event in events:
            self.event_bus.publish(event)
        
        return order.id
```

### 3. Repository Pattern

```python
# Repository - abstracts data access
class OrderRepository:
    def __init__(self, event_store):
        self.event_store = event_store
    
    def get(self, order_id: str) -> OrderAggregate:
        events = self.event_store.get_events_for_aggregate(order_id)
        return OrderAggregate.from_events(events)
    
    def save(self, order: OrderAggregate):
        self.event_store.append(order.id, order.uncommitted_events())
```

## Failure Modes

- **Over-engineering** → applying DDD to simple CRUD → unnecessary complexity → slow delivery
- **Anemic domain** → entities as data bags → business logic in services → defeats DDD purpose
- **Wrong bounded contexts** → boundaries don't match business → teams step on each other → rework
- **Ubiquitous language drift** → terms mean different things to different people → miscommunication → bugs
- **Ignoring context mapping** → contexts integrated incorrectly → data inconsistency → integration failures
- **No domain expert involvement** → developers guess domain rules → wrong model → software doesn't match business needs
- **Aggregate too large** → too many entities in one aggregate → concurrency conflicts → poor performance

## Technology Stack

| Tool | Use Case |
|------|----------|
| Axon Framework | Java DDD framework |
| Akka | Actor-based DDD |
| Propel | PHP DDD |
| Laravel | PHP with DDD patterns |
| .NET Orleans | DDD with actors |

## Related Topics

- [[EventSourcing]]
- [[Hexagonal]]
- [[Modularity]]
- [[Cohesion]]
- [[DomainModeling]]
- [[EventArchitecture]]
- [[SeparationOfConcerns]]
- [[Monoliths]]

## Additional Notes

**DDD Patterns:**
- Aggregate, Entity, Value Object
- Domain Events
- Ubiquitous Language
- Bounded Context
- Anti-Corruption Layer
- Repository, Factory

**When DDD Works Best:**
- Complex domains
- Evolving business rules
- Team collaboration
- Long-term projects

**Common Mistakes:**
- Applying DDD everywhere
- Ignoring domain experts
- Over-engineering simple domains
- Not maintaining ubiquitous language

## Key Takeaways

- DDD is a development approach that emphasizes collaboration between technical and domain experts to create software accurately representing complex business domains.
- Use for complex business domains with intricate rules, when domain expertise is critical, or when building microservices that need clear boundaries.
- Do NOT use for simple CRUD applications, stable/well-understood domains, or when tight deadlines don't allow for modeling sessions.
- Key tradeoff: software that closely matches business reality and evolves with it vs. significant upfront modeling effort and learning curve.
- Main failure mode: anemic domain models where entities are data bags with business logic scattered in services, defeating DDD's purpose.
- Best practice: work closely with domain experts, establish a ubiquitous language, define clear bounded contexts, and keep aggregates small.
- Related concepts: Bounded Contexts, Aggregates, Event Sourcing, Hexagonal Architecture, Microservices, Ubiquitous Language, Context Mapping.