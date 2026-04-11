---
title: Monoliths
title_pt: Monólitos
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - Monoliths
description: Single-deployment architectural style where all components are part of one unified application.
description_pt: Estilo arquitetural de implantação única onde todos os componentes fazem parte de uma aplicação unificada.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Monoliths

## Description

A monolith is an application where all components—user interface, business logic, data access, and database—are packaged and deployed as a single unit. Despite the recent popularity of microservices, monoliths remain the right choice for many applications and can often outperform distributed architectures for certain use cases.

The key advantage of monoliths is simplicity. A single codebase, single deployment, unified debugging, and transactions that "just work" provide significant operational benefits. Many successful applications—including Shopify, Spotify (early), and Basecamp—started as monoliths and thrived.

Monoliths aren't inherently bad; they're a different trade-off. They optimize for development simplicity and operational efficiency at the cost of deployment flexibility and independent scaling. The decision between monolith and microservices should be based on your specific requirements, team structure, and scaling needs—not on architectural trends.

## Purpose

**When a monolith makes sense:**
- Small to medium applications with bounded scope
- Teams without distributed systems expertise
- Applications where all components have similar scaling needs
- When deployment simplicity is critical
- When transactions span multiple components
- Early-stage startups iterating on product-market fit
- When you need fast local development

**When to avoid:**
- When different parts need different scaling characteristics
- When teams need to deploy independently
- When application is becoming too complex
- When you need different technology stacks
- When fault isolation is critical

## Rules

1. **Start simple** - Don't microservices until you have a reason to
2. **Keep it modular** - Even in a monolith, separate concerns
3. **Maintain boundaries** - Define clear module interfaces
4. **Avoid shared state** - Minimize global variables and singletons
5. **Use dependency injection** - Enables testing and future extraction
6. **Document module contracts** - Makes future extraction easier
7. **Refactor incrementally** - Don't wait for big bang rewrites

## Examples

### Good Example: Modular Monolith Structure

```
src/
├── main.py
├── config/
│   └── settings.py
├── modules/
│   ├── users/
│   │   ├── __init__.py
│   │   ├── models.py          # User entity
│   │   ├── services.py       # User business logic
│   │   ├── repositories.py   # Data access
│   │   └── api.py             # API endpoints
│   ├── orders/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── services.py
│   │   ├── repositories.py
│   │   └── api.py
│   └── payments/
│       ├── __init__.py
│       ├── models.py
│       ├── services.py
│       ├── repositories.py
│       └── api.py
├── shared/
│   ├── database.py
│   ├── exceptions.py
│   └── utils.py
└── tests/
    ├── users/
    ├── orders/
    └── payments/
```

### Bad Example: Spaghetti Monolith

```
# BAD: Everything in one file or tightly coupled
# models.py - 5000 lines with everything
class User: ...
class Order: ...
class Product: ...
class Payment: ...
# And all mixed with services!

# services.py - business logic mixed
def do_something(user_id, order_id, product_id):
    # SQL queries, API calls, business rules all mixed
```

### Good Example: Clean Module Boundaries

```python
# modules/users/services.py
class UserService:
    def __init__(self, user_repository: UserRepository,
                 email_service: EmailService):
        self.user_repository = user_repository
        self.email_service = email_service
    
    def create_user(self, email: str, name: str) -> User:
        # Business logic isolated here
        if self.user_repository.find_by_email(email):
            raise UserAlreadyExistsError(email)
        
        user = User(email=email, name=name)
        self.user_repository.save(user)
        self.email_service.send_welcome_email(user)
        
        return user

# modules/users/api.py
from fastapi import APIRouter, Depends

router = APIRouter()

def get_user_service() -> UserService:
    return UserService(
        user_repository=UserRepository(),
        email_service=EmailService()
    )

@router.post("/users")
def create_user(
    request: CreateUserRequest,
    service: UserService = Depends(get_user_service)
):
    return service.create_user(request.email, request.name)
```

### Bad Example: Tight Coupling

```python
# BAD: Modules directly depend on each other's internals
class OrderService:
    def __init__(self):
        self.user_model = User  # Directly using another module's model!
        self.payment_model = Payment  # And another!
    
    def create_order(self, user_id, items):
        # Querying another module's data directly
        user = self.user_model.get(user_id)
        # No clear boundaries
        for item in items:
            Product.inventory[item.id] -= 1
```

### Good Example: Event-Driven Module Communication

```python
# modules/users/events.py
from dataclasses import dataclass
from datetime import datetime

@dataclass
class UserCreatedEvent:
    user_id: str
    email: str
    timestamp: datetime = datetime.now()

@dataclass
class UserDeletedEvent:
    user_id: str
    timestamp: datetime = datetime.now()

# Event publisher in users module
class UserEventPublisher:
    def __init__(self, event_bus: EventBus):
        self.event_bus = event_bus
    
    def publish_user_created(self, user: User):
        self.event_bus.publish(UserCreatedEvent(
            user_id=user.id,
            email=user.email
        ))

# Event handler in orders module
class OrderEventHandler:
    def __init__(self, event_bus: EventBus):
        event_bus.subscribe(UserDeletedEvent, self.handle_user_deleted)
    
    def handle_user_deleted(self, event: UserDeletedEvent):
        # Orders module reacts to users module events
        self.order_repository.cancel_user_orders(event.user_id)
```

## Anti-Patterns

### 1. Spaghetti Code

**Bad:**
- No clear module structure
- Everything in one file
- Global state everywhere

**Why it's bad:**
- Impossible to understand
- Hard to test
- Difficult to modify

**Good:**
- Clear module boundaries
- Single responsibility per module
- Dependency injection

### 2. God Module

**Bad:**
- One module contains everything
- No separation of concerns
- Impossible to extract

**Why it's bad:**
- Hard to maintain
- Single point of failure
- Can't scale parts independently

**Good:**
- Well-defined modules
- Clear interfaces
- Single responsibility

### 3. Database as Integration

**Bad:**
- Modules share database tables
- Direct SQL joins across modules
- No clear ownership

**Why it's bad:**
- Tight coupling
- Changes affect multiple modules
- Hard to extract later

**Good:**
- Each module owns its tables
- Use API or events for communication
- Clear data ownership

### 4. No Testing Strategy

**Bad:**
- Only manual testing
- No unit tests
- Integration tests are fragile

**Why it's bad:**
- Bugs reach production
- Fear of refactoring
- Slow development

**Good:**
- Unit tests per module
- Integration tests for module boundaries
- CI/CD pipeline

### 5. Avoiding Refactoring

**Bad:**
- "We'll rewrite it later"
- No investment in code quality
- Technical debt accumulates

**Why it's bad:**
- Rewrites rarely succeed
- Productivity suffers
- Bug count increases

**Good:**
- Incremental refactoring
- Good tests first
- Regular attention to quality

## Best Practices

### 1. Modular Monolith Design

```python
# Use dependency injection for testability
# main.py

from fastapi import FastAPI
from modules.users.api import router as users_router
from modules.orders.api import router as orders_router
from modules.payments.api import router as payments_router

app = FastAPI()

app.include_router(users_router, prefix="/users", tags=["users"])
app.include_router(orders_router, prefix="/orders", tags=["orders"])
app.include_router(payments_router, prefix="/payments", tags=["payments"])
```

### 2. Database Schema Per Module

```python
# migrations/versions/001_create_users.py
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

# migrations/versions/002_create_orders.py
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),  -- Reference, not join
    status VARCHAR(50) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

# Orders module should NOT query users directly
# Use API or event-driven communication
```

### 3. Extractable Modules

```python
# modules/users/__init__.py
# Define public API clearly
from .models import User
from .services import UserService
from .api import router

__all__ = ["User", "UserService", "router"]

# Internal implementations are private
# modules/users/internal.py is not exported
# This makes future extraction to microservice easier
```

### 4. Shared Kernel Strategy

```python
# sharedkernel/
# Code shared across modules, but keep minimal

# sharedkernel/exceptions.py
class DomainError(Exception):
    pass

class UserNotFoundError(DomainError):
    pass

class OrderNotFoundError(DomainError):
    pass

# sharedkernel/events.py
from dataclasses import dataclass
from datetime import datetime
from typing import Any

@dataclass
class Event:
    occurred_at: datetime = datetime.now()
    
# Use events for cross-module communication
# Keep shared kernel small!
```

## Failure Modes

- **Spaghetti monolith** → no module boundaries → impossible to understand → team velocity drops to zero
- **Database coupling** → modules share tables → can't extract services → stuck forever
- **Long build times** → monolith grows → CI takes 30+ minutes → developers skip tests → quality drops
- **Single point of failure** → one bug crashes entire app → all features down → need circuit breakers at module level
- **Team conflicts** → multiple teams editing same code → merge hell → slow delivery
- **Deployment risk** → one change deploys everything → any bug affects all features → need feature flags
- **Scaling inefficiency** → one module needs 10x resources → entire monolith scaled → wasted money

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| FastAPI/Flask/Django | Web framework |
| Spring Boot | Java monolith |
| Rails | Ruby monolith |
| Laravel | PHP monolith |
| PostgreSQL/MySQL | Single database |
| Docker | Containerization |
| CI/CD | Deployment automation |

## Related Topics

- [[Hexagonal]]
- [[Layering]]
- [[Modularity]]
- [[Coupling]]
- [[Cohesion]]
- [[DDD]]
- [[Docker]]
- [[CiCd]]

## Additional Notes

**Monolith Advantages:**
- Simple development workflow
- Easy debugging (single process)
- ACID transactions work
- Simple deployment
- Fast local development
- Easy refactoring

**When to Extract from Monolith:**
1. Different components have different scaling needs
2. Teams need independent deployments
3. Components have different technology requirements
4. Fault isolation becomes critical
5. Deployment times are too long

**Extraction Patterns:**
1. Strangler fig pattern - gradually replace
2. Branch by abstraction - create abstraction
3. Feature flags - toggle between old/new
4. Database decoupling - separate tables first

**The Modular Monolith:**
- Best of both worlds
- Structure of microservices
- Simplicity of monolith
- Can extract when needed
- Great starting point

## Key Takeaways

- A monolith packages all components (UI, business logic, data access) into a single deployable unit, optimizing for simplicity and operational efficiency.
- Use for small to medium applications, teams without distributed systems expertise, when transactions span multiple components, or early-stage startups.
- Do NOT use when different parts need different scaling, teams need independent deployments, or fault isolation is critical.
- Key tradeoff: development simplicity, ACID transactions, and easy debugging vs. inability to scale parts independently and single point of failure.
- Main failure mode: spaghetti monolith with no module boundaries leading to impossible-to-understand code and team velocity dropping to zero.
- Best practice: start as a modular monolith with clear module boundaries, use dependency injection, and design modules to be extractable later.
- Related concepts: Modular Monolith, Strangler Fig Pattern, Microservices, DDD, Hexagonal Architecture, CI/CD, Feature Flags.
