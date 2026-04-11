---
title: Coupling
title_pt: Acoplamento
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - Coupling
description: The degree of interdependence between software modules; goal is loose coupling.
description_pt: O grau de interdependência entre módulos de software; objetivo é baixo acoplamento.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Coupling

## Description

Coupling measures the degree of interdependence between software modules. Tight coupling means modules are heavily dependent on each other—changes in one module often require changes in others. Loose coupling means modules are independent and communicate through well-defined interfaces.

High coupling is a primary source of software complexity and maintenance problems. When modules are tightly coupled:
- Changes propagate through the system
- Testing becomes difficult
- Reuse is challenging
- Parallel development is limited

The goal is loose coupling: modules should know as little as possible about each other, communicate through abstractions, and be able to change independently.

Types of coupling (from worst to best):
- **Content coupling**: One module modifies another's internal data
- **Common coupling**: Modules share global data
- **Stamp coupling**: Modules share composite data structures
- **Control coupling**: One module controls another via flags/parameters
- **Data coupling**: Modules share only necessary data (best)

## Purpose

**When to focus on reducing coupling:**
- When changes in one area affect many others
- When testing is difficult due to dependencies
- When different teams work on different parts
- When you need to reuse modules
- When the system needs to evolve
- When you want independent deployability

**When some coupling is acceptable:**
- Very small systems
- Performance-critical paths
- When abstraction would harm performance

## Rules

1. **Program to interfaces** - Depend on abstractions, not concretions
2. **Use dependency injection** - Invert dependencies
3. **Avoid shared state** - Pass data instead of sharing
4. **Minimize method signatures** - Only what's needed
5. **Hide implementation details** - Information hiding
6. **Use events for communication** - Decouple producers/consumers
7. **Law of Demeter** - Only talk to immediate neighbors

## Examples

### Good Example: Interface-Based Coupling

```python
# interfaces.py
from abc import ABC, abstractmethod

class PaymentGateway(ABC):
    @abstractmethod
    def charge(self, amount: float, currency: str) -> "PaymentResult":
        pass
    
    @abstractmethod
    def refund(self, charge_id: str) -> "RefundResult":
        pass

# implementation.py
class StripePaymentGateway(PaymentGateway):
    def __init__(self, api_key: str):
        self.api_key = api_key
    
    def charge(self, amount: float, currency: str) -> PaymentResult:
        # Stripe API call
        ...
    
    def refund(self, charge_id: str) -> RefundResult:
        # Stripe API call
        ...

# user of interface
class OrderService:
    def __init__(self, payment_gateway: PaymentGateway):
        # Depends on abstraction, not concrete class
        self.payment_gateway = payment_gateway
```

### Bad Example: Direct Dependency

```python
# BAD: Direct coupling to concrete class
class OrderService:
    def __init__(self):
        # Direct dependency - can't swap implementations
        self.stripe = StripePaymentGateway("sk_live_...")
    
    def process_payment(self, order: Order):
        # Knows about specific implementation
        result = self.stripe.charge(order.total, "USD")
        if result.success:
            order.status = "paid"
```

### Good Example: Dependency Injection

```python
# main.py - Configure dependencies
def create_order_service() -> OrderService:
    gateway = StripePaymentGateway(config.stripe_key)
    repo = PostgresOrderRepository(config.db)
    return OrderService(payment_gateway=gateway, repository=repo)

# Container-based approach
from dependency_injector import containers, providers

class Container(containers.DeclarativeContainer):
    payment_gateway = providers.Factory(StripePaymentGateway)
    order_service = providers.Factory(
        OrderService,
        payment_gateway=payment_gateway
    )

# Test can easily inject mock
def test_order_service():
    mock_gateway = MockPaymentGateway()
    service = OrderService(payment_gateway=mock_gateway)
```

### Bad Example: Shared State

```python
# BAD: Global shared state
class GlobalState:
    current_user = None
    current_tenant = None

class UserService:
    def create_user(self, name: str):
        # Depends on global state!
        tenant_id = GlobalState.current_tenant
        # ...
```

### Good Example: Passed Dependencies

```python
# GOOD: Dependencies passed as parameters
class OrderService:
    def __init__(self, repository: OrderRepository,
                 event_publisher: EventPublisher):
        self.repository = repository
        self.event_publisher = event_publisher
    
    def create_order(self, user_id: str, items: list) -> Order:
        # All dependencies explicitly provided
        order = Order(user_id=user_id, items=items)
        self.repository.save(order)
        self.event_publisher.publish(OrderCreatedEvent(order))
        return order
```

## Anti-Patterns

### 1. Circular Dependencies

**Bad:**
- A depends on B, B depends on A
- Can't initialize independently
- Changes propagate

**Solution:**
- Break cycle with interface
- Use events
- Extract to third module

### 2. God Classes

**Bad:**
- One class knows everything
- Everything depends on it
- Can't change without breaking

**Solution:**
- Split responsibilities
- Use Law of Demeter
- Depend on abstractions

### 3. Feature Envy

**Bad:**
- Class that uses data from another class too much
- More interest in other's data than its own

**Solution:**
- Move method to the class it envy's
- Extract the behavior

### 4. Inappropriate Intimacy

**Bad:**
- Classes that know too much about each other's internals
- Directly accessing private members
- Relying on implementation details

**Solution:**
- Use interfaces
- Don't access private members
- Keep boundaries clean

### 5. Message Chains

**Bad:**
- a.getB().getC().getD().doSomething()
- Too many hops to get data
- Brittle

**Solution:**
- Use delegation
- Ask, don't navigate
- Provide direct access

## Best Practices

### 1. Interface Segregation

```python
# Instead of one big interface
class UserService(ABC):
    @abstractmethod
    def create(self): ...
    @abstractmethod
    def update(self): ...
    @abstractmethod
    def delete(self): ...
    @abstractmethod
    def get_orders(self): ...  # Doesn't belong!

# Use small, focused interfaces
class UserCreator(ABC):
    @abstractmethod
    def create(self, data): ...

class UserReader(ABC):
    @abstractmethod
    def get(self, user_id): ...

class UserDeleter(ABC):
    @abstractmethod
    def delete(self, user_id): ...
```

### 2. Dependency Inversion

```
# Traditional: High-level depends on low-level
HighLevelModule -> LowLevelModule

# Inverted: Both depend on abstraction
HighLevelModule -> Interface <- LowLevelModule
```

### 3. Event-Driven Decoupling

```python
# Instead of direct call
class OrderService:
    def __init__(self, notification_service: NotificationService):
        self.notification = notification_service
    
    def create_order(self, order):
        self.notification.send(order.user_email, "Order created")

# Use events - producer doesn't know consumer
class OrderService:
    def __init__(self, event_bus: EventBus):
        self.event_bus = event_bus
    
    def create_order(self, order):
        self.event_bus.publish(OrderCreatedEvent(order))

class NotificationHandler:
    def __init__(self, event_bus: EventBus):
        event_bus.subscribe(OrderCreatedEvent, self.handle)
    
    def handle(self, event):
        send_email(event.user_email, "Order created")
```

### 4. Law of Demeter

```python
# BAD - Law of Demeter violation
class Order:
    @property
    def user(self):
        return User(...)

class User:
    @property
    def address(self):
        return Address(...)

# Calling code:
city = order.user.address.city  # Too many dots!

# GOOD - Provide method on Order
class Order:
    @property
    def user(self):
        return User(...)
    
    def get_user_city(self):
        return self.user.address.city

# Calling code:
city = order.get_user_city()
```

## Failure Modes

- **Circular dependencies between modules** → modules cannot be initialized or tested independently → deployment and testing failures → break cycles using interfaces, events, or extracting shared abstractions
- **Direct dependency on concrete implementations** → cannot swap implementations for testing or alternatives → vendor lock-in and untestable code → depend on abstractions and inject concretions at composition root
- **Shared global state** → hidden dependencies between modules that appear independent → non-deterministic behavior and race conditions → pass dependencies explicitly and avoid mutable globals
- **Feature envy across module boundaries** → one module extensively uses another's data → tight coupling and fragile changes → move behavior to the module that owns the data
- **Message chains (a.getB().getC().doX())** → code navigates deep object graphs → brittle code that breaks on any intermediate change → use delegation and ask objects to perform work directly
- **Inappropriate intimacy** → modules accessing each other's private internals → implementation details become public contracts → enforce encapsulation and communicate through well-defined interfaces only
- **Implicit coupling through configuration** → modules share config files or environment variables → changing one module's config breaks another → isolate configuration per module with explicit contracts

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| Dependency Injector | Python DI container |
| Spring IoC | Java DI |
| Dagger/Hilt | Android/Java DI |
| Inversify | TypeScript DI |

## Related Topics

- [[Modularity]]
- [[Cohesion]]
- [[Hexagonal]]
- [[EventArchitecture]]
- [[Layering]]
- [[SOLID]]
- [[Refactoring]]
- [[DesignPatterns]]

## Key Takeaways

- Coupling measures inter-module interdependence; the goal is loose coupling where modules communicate through abstractions and change independently
- Focus on reducing coupling when changes cascade across the system, testing is hard due to dependencies, or teams need parallel development
- Accept some coupling in very small systems, performance-critical paths, or when abstraction overhead harms performance
- Tradeoff: loose coupling increases flexibility and testability but adds indirection and initial design complexity
- Main failure mode: circular dependencies prevent independent initialization, testing, and deployment of modules
- Best practice: program to interfaces, use dependency injection, avoid shared state, apply Law of Demeter, and use events for producer/consumer decoupling
- Related: cohesion, modularity, SOLID, event-driven architecture, refactoring
