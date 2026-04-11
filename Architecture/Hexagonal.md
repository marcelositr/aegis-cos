---
title: Hexagonal Architecture
title_pt: Arquitetura Hexagonal
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - Hexagonal
  - CleanArchitecture
description: Architectural pattern that separates application logic from external dependencies through ports and adapters.
description_pt: Padrão arquitetural que separa lógica de aplicação de dependências externas através de portas e adaptadores.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Hexagonal Architecture

## Description

Hexagonal Architecture, also known as Ports and Adapters, is an architectural pattern that isolates the core business logic of an application from external concerns. The central idea is to create boundaries that protect the domain from infrastructure details, making the application testable, maintainable, and independent of specific frameworks or technologies.

The architecture gets its name from the visual representation: a hexagon representing the core application, with ports on the sides connecting to adapters that handle external interactions. This metaphor emphasizes that the core is isolated and can have multiple interfaces without being affected by changes in external systems.

The core (or "application" in domain-driven design terms) contains:
- **Domain entities**: Business objects with identity and behavior
- **Domain services**: Operations that don't belong to a single entity
- **Value objects**: Immutable objects describing characteristics
- **Domain events**: Significant occurrences within the domain

The ports are interfaces that define how the core communicates with the outside world:
- **Driving ports** (primary): Interfaces for inbound communication (controllers, CLI)
- **Driven ports** (secondary): Interfaces for outbound communication (repositories, external services)

The adapters implement the ports:
- **Driving adapters**: UI, API controllers, CLI handlers
- **Driven adapters**: Database repositories, message queues, external API clients

## Purpose

**When to use Hexagonal Architecture:**
- When you need to isolate domain logic from infrastructure
- When tests should focus on business logic without database/API mocking
- When you want to swap implementations (e.g., different databases)
- When the application needs to be framework-agnostic
- When building applications with clear domain boundaries
- When you want to enable TDD (test-driven development)

**When to avoid:**
- Simple applications with minimal business logic
- When the overhead exceeds the benefit
- When team lacks understanding of the pattern
- Rapid prototypes where structure isn't important

## Rules

1. **Dependencies point inward** - Core knows nothing about adapters
2. **Ports define contracts** - Adapters implement port interfaces
3. **Keep domain pure** - No framework dependencies in domain
4. **Isolate external concerns** - Infrastructure code in adapters
5. **Test at boundaries** - Use adapters to test ports
6. **Single responsibility** - Each adapter handles one external concern
7. **Dependency injection** - Use DI to inject adapters into core

## Examples

### Good Example: Core Domain with Ports

```python
# core/domain/entities.py
class Order:
    def __init__(self, order_id: str, items: list):
        self.id = order_id
        self.items = items
        self.status = "pending"
    
    def total(self) -> decimal.Decimal:
        return sum(item.price * item.quantity for item in self.items)
    
    def confirm(self):
        self.status = "confirmed"

# core/domain/ports.py (Interfaces)
from abc import ABC, abstractmethod

class OrderRepository(ABC):
    @abstractmethod
    def save(self, order: Order) -> Order:
        pass
    
    @abstractmethod
    def find_by_id(self, order_id: str) -> Order:
        pass

class PaymentService(ABC):
    @abstractmethod
    def process_payment(self, order: Order) -> bool:
        pass

# core/application/services.py
class OrderService:
    def __init__(self, order_repo: OrderRepository, payment_svc: PaymentService):
        self.order_repo = order_repo
        self.payment_svc = payment_svc
    
    def create_order(self, order: Order) -> Order:
        if self.payment_svc.process_payment(order):
            order.confirm()
            return self.order_repo.save(order)
        raise PaymentFailedError()
```

### Bad Example: Domain Dependent on Infrastructure

```python
# BAD: Domain knows about database
class Order:
    def save(self):
        # Direct database call in entity
        db.session.add(self)
        db.session.commit()
    
    @classmethod
    def find_by_id(cls, order_id):
        # Query logic in entity
        return db.session.query(Order).filter_by(id=order_id).first()

# Problems:
# 1. Order cannot be tested without database
# 2. Changing database requires changes in entity
# 3. Domain logic is coupled to infrastructure
```

### Good Example: Driving Adapter (API Controller)

```python
# adapters/driving/rest_api.py
from fastapi import FastAPI, HTTPException
from core.application.services import OrderService
from core.domain.ports import OrderRepository, PaymentService

app = FastAPI()

class SqlAlchemyOrderRepository(OrderRepository):
    def __init__(self, session):
        self.session = session
    
    def save(self, order: Order) -> Order:
        self.session.add(order)
        self.session.commit()
        return order
    
    def find_by_id(self, order_id: str) -> Order:
        return self.session.query(Order).filter_by(id=order_id).first()

class StripePaymentService(PaymentService):
    def process_payment(self, order: Order) -> bool:
        # Stripe API call
        return True

# Dependency injection
order_service = OrderService(
    order_repo=SqlAlchemyOrderRepository(session),
    payment_svc=StripePaymentService()
)

@app.post("/orders")
def create_order(request: OrderRequest):
    order = Order(order_id=request.id, items=request.items)
    return order_service.create_order(order)
```

### Bad Example: No Port Abstraction

```python
# BAD: Direct dependency on concrete class
class OrderService:
    def __init__(self):
        self.repository = SqlAlchemyOrderRepository()  # Concrete!
        self.payment = StripePayment()  # Concrete!
    
    def create_order(self, order_data):
        # Direct calls to specific implementations
        order = Order(order_data)
        self.repository.save(order)
        self.payment.charge(order.total)
```

### Good Example: Driven Adapter (Repository Implementation)

```python
# adapters/driven/database/sqlalchemy_repository.py
from sqlalchemy import Column, String, Numeric
from sqlalchemy.dialects.postgresql import UUID
import uuid

class OrderModel(Base):
    __tablename__ = "orders"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    status = Column(String(50), nullable=False)
    total = Column(Numeric(10, 2), nullable=False)

class SqlAlchemyOrderRepository(OrderRepository):
    def __init__(self, session_factory):
        self.session_factory = session_factory
    
    def save(self, order: Order) -> Order:
        with self.session_factory() as session:
            model = OrderModel(
                id=uuid.UUID(order.id),
                status=order.status,
                total=order.total()
            )
            session.add(model)
            session.commit()
            return order
    
    def find_by_id(self, order_id: str) -> Order:
        with self.session_factory() as session:
            model = session.query(OrderModel).filter_by(id=uuid.UUID(order_id)).first()
            if not model:
                raise OrderNotFoundError(order_id)
            return Order(order_id=str(model.id), items=[], status=model.status)
```

## Anti-Patterns

### 1. Anemic Domain Model

**Bad:**
- Entities are just data containers with no behavior
- Business logic lives in services only
- No encapsulation of business rules

**Why it's bad:**
- Violates OOP principles
- Business rules scattered
- Hard to enforce invariants

**Good:**
- Rich domain models with behavior
- Business logic in entities
- Invariants enforced by entities

### 2. Leaky Abstraction

**Bad:**
- Domain depends on infrastructure
- Ports reference framework types
- Database models in domain layer

**Why it's bad:**
- Core is not isolated
- Hard to test
- Changes in infrastructure affect core

**Good:**
- Ports are pure interfaces
- Domain has no external dependencies
- Adapters handle infrastructure

### 3. God Object

**Bad:**
- Single service handling everything
- No separation of concerns
- Monolithic domain

**Why it's bad:**
- Hard to maintain
- Difficult to test
- No clear boundaries

**Good:**
- Multiple services with single responsibility
- Clear separation between use cases
- Modular domain

### 4. Missing Ports

**Bad:**
- Direct dependencies on adapters
- No abstraction layer
- Tight coupling throughout

**Why it's bad:**
- Cannot swap implementations
- Hard to test
- Violates hexagonal principles

**Good:**
- Define ports for all external dependencies
- Code to interfaces
- Inject implementations

### 5. Circular Dependencies

**Bad:**
- Adapters depend on each other
- Domain references adapters
- Ports depend on adapters

**Why it's bad:**
- Violates dependency rule
- Creates tight coupling
- Breaks testability

**Good:**
- All dependencies point inward
- Clear layer boundaries
- No circular references

## Best Practices

### 1. Project Structure

```
src/
├── core/
│   ├── domain/
│   │   ├── entities/
│   │   ├── value_objects/
│   │   ├── events/
│   │   └── exceptions/
│   ├── application/
│   │   ├── services/
│   │   ├── use_cases/
│   │   └── dto/
│   └── ports/
│       ├── driven/
│       └── driving/
├── adapters/
│   ├── driven/
│   │   ├── database/
│   │   ├── message_queue/
│   │   └── external_api/
│   └── driving/
│       ├── rest_api/
│       ├── graphql/
│       └── cli/
└── main.py
```

### 2. Dependency Injection Container

```python
# container.py
from dependency_injector import containers, providers

class Container(containers.DeclarativeContainer):
    config = providers.Configuration()
    
    # Adapters
    database_session = providers.Factory(DatabaseSession)
    
    # Driven adapters
    order_repository = providers.Factory(
        SqlAlchemyOrderRepository,
        session_factory=database_session
    )
    payment_service = providers.Factory(StripePaymentService)
    
    # Application services
    order_service = providers.Factory(
        OrderService,
        order_repo=order_repository,
        payment_svc=payment_service
    )
```

### 3. Testing Strategy

```python
# test_application_service.py
class MockOrderRepository(OrderRepository):
    def __init__(self):
        self.saved_orders = []
    
    def save(self, order: Order) -> Order:
        self.saved_orders.append(order)
        return order
    
    def find_by_id(self, order_id: str) -> Order:
        return None

class MockPaymentService(PaymentService):
    def __init__(self, should_succeed: bool = True):
        self.should_succeed = should_succeed
    
    def process_payment(self, order: Order) -> bool:
        return self.should_succeed

def test_create_order_success():
    # Arrange
    repo = MockOrderRepository()
    payment = MockPaymentService(should_succeed=True)
    service = OrderService(order_repo=repo, payment_svc=payment)
    
    # Act
    order = Order("123", [Item("1", 10.0)])
    result = service.create_order(order)
    
    # Assert
    assert result.status == "confirmed"
    assert len(repo.saved_orders) == 1
```

### 4. Mapping Between Layers

Use separate mappers to convert between layers:
- **DTO**: Data transfer from adapters to application
- **Domain objects**: Pure business objects
- **Persistence models**: Database-specific structures

```python
# mappers/order_mapper.py
class OrderMapper:
    @staticmethod
    def to_domain(model: OrderModel) -> Order:
        return Order(
            order_id=str(model.id),
            items=[],  # Load items separately
            status=model.status
        )
    
    @staticmethod
    def to_persistence(order: Order) -> OrderModel:
        return OrderModel(
            id=uuid.UUID(order.id),
            status=order.status
        )
```

## Failure Modes

- **Too many ports** → over-abstraction → code becomes hard to follow → developers bypass ports
- **Leaky domain** → domain depends on infrastructure → can't test without database → defeats purpose
- **Wrong DI configuration** → wrong adapter injected → runtime errors hard to trace
- **Circular dependency** → adapter A needs adapter B needs adapter A → startup failure
- **Mapping overhead** → too many conversions between layers → performance degradation
- **Anemic domain** → entities are data bags → business logic scattered in services → hard to maintain

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| FastAPI | Driving adapter (REST API) |
| SQLAlchemy | Driven adapter (Database) |
| Dependency Injector | DI container |
| Pydantic | DTO validation |
| RabbitMQ/Kafka | Message-driven adapters |
| httpx | External API adapters |

## Related Topics

- [[Layering]]
- [[Modularity]]
- [[Coupling]]
- [[DDD]]
- [[Cohesion]]
- [[SeparationOfConcerns]]
- [[UnitTesting]]
- [[APIDesign]]

## Additional Notes

**Comparison with Clean Architecture:**
Hexagonal Architecture and Clean Architecture share similar principles:
- Both isolate domain from infrastructure
- Both use dependency injection
- Both enable testability

Differences:
- Hexagonal focuses on ports/adapters metaphor
- Clean Architecture adds use cases layer
- Clean Architecture has more formal layer definitions

**When to Extract to Hexagonal:**
1. Business logic is complex
2. Multiple interfaces needed (API, CLI, etc.)
3. Database might change
4. Testing domain logic is difficult
5. Framework coupling is a concern

**Common Mistakes:**
- Creating ports for everything (over-abstraction)
- Not using dependency injection
- Leaking infrastructure into domain
- Testing through adapters instead of directly

## Key Takeaways

- Hexagonal Architecture isolates core business logic from external dependencies through ports (interfaces) and adapters (implementations).
- Use when domain logic needs isolation from infrastructure, when swapping implementations (databases, APIs) is important, or when enabling TDD.
- Do NOT use for simple applications with minimal business logic, rapid prototypes, or when the team lacks understanding of the pattern.
- Key tradeoff: testability and framework independence vs. added abstraction layers and mapping overhead between layers.
- Main failure mode: leaky abstractions where the domain depends on infrastructure types, defeating the isolation purpose.
- Best practice: ensure all dependencies point inward, keep the domain pure with no framework dependencies, and use dependency injection to wire adapters.
- Related concepts: DDD, Clean Architecture, Dependency Injection, Ports and Adapters, Layering, Modularity, SOLID.
