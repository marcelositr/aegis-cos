---
title: Layering
title_pt: Arquitetura em Camadas
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - Layering
description: Organizing code into distinct layers with specific responsibilities and dependency flow.
description_pt: Organizando código em camadas distintas com responsabilidades específicas e fluxo de dependência.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Layering

## Description

Layering is an architectural pattern that organizes code into horizontal layers, where each layer has a specific responsibility and can only depend on layers "below" it. This creates a structured approach to code organization that promotes separation of concerns, testability, and maintainability.

The most common layered architecture is the three-tier model:
- **Presentation layer**: Handles user interface and HTTP requests
- **Business logic layer**: Contains core application logic
- **Data access layer**: Manages database and external data sources

More sophisticated architectures add additional layers:
- **Application layer**: Orchestrates use cases
- **Domain layer**: Business entities and rules
- **Infrastructure layer**: External dependencies

The key principle is that dependencies flow in one direction only—from higher layers depending on lower layers, never the reverse. This ensures that business logic remains independent of infrastructure details.

## Purpose

**When to use layering:**
- When you need clear code organization
- When different developers work on different concerns
- When you want to test business logic without infrastructure
- When the application will grow in complexity
- When you need to swap data sources
- When maintainability is important

**When to avoid:**
- Simple applications with minimal logic
- When the overhead isn't worth the benefit
- When rapid prototyping is more important than structure
- When team is small and highly collaborative

## Rules

1. **Dependencies flow down** - Upper layers depend on lower, never reverse
2. **Layers are closed** - Each layer should be sealed
3. **Cross-layer communication via interfaces** - Don't expose implementation
4. **Domain layer is the core** - Business logic should be infrastructure-agnostic
5. **Each layer has single responsibility** - Don't mix concerns
6. **Data transformation at boundaries** - Convert between layer formats
7. **Test at appropriate layer** - Mock dependencies below

## Examples

### Good Example: Clean Layer Separation

```python
# presentation/api.py
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from application.order_service import OrderService
from domain.order import Order

router = APIRouter()

class CreateOrderRequest(BaseModel):
    items: list[dict]

@router.post("/orders")
def create_order(
    request: CreateOrderRequest,
    service: OrderService = Depends(get_order_service)
):
    # Presentation layer - only handles HTTP
    order = service.create_order_from_items(request.items)
    return {"order_id": order.id, "status": order.status}

# application/service.py
class OrderService:
    def __init__(self, order_repository: OrderRepository,
                 payment_gateway: PaymentGateway):
        self.order_repository = order_repository
        self.payment_gateway = payment_gateway
    
    def create_order_from_items(self, items: list[dict]) -> Order:
        # Application layer - orchestrates domain logic
        order = Order.from_items(items)
        
        total = order.calculate_total()
        if not self.payment_gateway.process(total):
            raise PaymentFailedError()
        
        self.order_repository.save(order)
        return order

# domain/order.py
class Order:
    def __init__(self, items: list[OrderItem], status: str = "pending"):
        self.items = items
        self.status = status
    
    def calculate_total(self) -> Decimal:
        # Domain layer - pure business logic
        return sum(item.price * item.quantity for item in self.items)
    
    @classmethod
    def from_items(cls, items: list[dict]) -> "Order":
        order_items = [OrderItem(i['product_id'], i['price'], i['quantity']) 
                       for i in items]
        return cls(items=order_items)

# infrastructure/persistence.py
class OrderRepository:
    def __init__(self, db: Database):
        self.db = db
    
    def save(self, order: Order):
        # Infrastructure layer - database details
        self.db.execute(
            "INSERT INTO orders (id, status) VALUES (?, ?)",
            [order.id, order.status]
        )
```

### Bad Example: Layer Violation

```python
# BAD: Presentation directly calling infrastructure
@router.post("/orders")
def create_order(request: dict):
    # Presentation layer doing everything!
    
    # Directly accessing database
    conn = sqlite3.connect("store.db")
    cursor = conn.cursor()
    cursor.execute("INSERT INTO orders ...")
    
    # Directly calling payment API
    response = requests.post("https://payment-gateway/charge", ...)
    
    # Business logic in presentation layer!
    if sum(item['price'] for item in request['items']) > 1000:
        discount = 0.1
    
    return {"status": "created"}
```

### Good Example: Layer Abstraction

```python
# domain/ports.py - Interfaces for infrastructure
from abc import ABC, abstractmethod

class OrderRepository(ABC):
    @abstractmethod
    def save(self, order: Order) -> Order:
        pass
    
    @abstractmethod
    def find_by_id(self, order_id: str) -> Order:
        pass

class PaymentGateway(ABC):
    @abstractmethod
    def process_payment(self, amount: Decimal, currency: str) -> bool:
        pass

# application/service.py - Uses abstractions
class OrderService:
    def __init__(self, repository: OrderRepository, 
                 payment: PaymentGateway):
        # Depends on abstractions, not concretions
        self.repository = repository
        self.payment = payment
```

### Bad Example: Domain Depends on Infrastructure

```python
# BAD: Domain entity knows about database
class Order:
    def save(self):
        from database import get_connection
        conn = get_connection()
        conn.execute("INSERT INTO orders ...")
    
    @classmethod
    def find(cls, order_id):
        from database import get_connection
        # Domain knows database structure!
```

### Good Example: Data Transformation

```python
# domain/entity.py
class User:
    def __init__(self, user_id: str, email: str, name: str):
        self.user_id = user_id
        self.email = email
        self.name = name

# infrastructure/database_model.py
class UserModel:
    def __init__(self, id: int, user_email: str, full_name: str, created: datetime):
        self.id = id
        self.user_email = user_email
        self.full_name = full_name
        self.created = created

# infrastructure/mapper.py
class UserMapper:
    @staticmethod
    def to_domain(model: UserModel) -> User:
        return User(
            user_id=str(model.id),
            email=model.user_email,
            name=model.full_name
        )
    
    @staticmethod
    def to_model(user: User) -> UserModel:
        return UserModel(
            id=int(user.user_id),
            user_email=user.email,
            full_name=user.name,
            created=datetime.now()
        )

# application/service.py uses mapper
class UserService:
    def get_user(self, user_id: str) -> User:
        model = self.repository.find(user_id)
        return UserMapper.to_domain(model)  # Transform at boundary
```

## Anti-Patterns

### 1. Anemic Domain

**Bad:**
- Entities are just data containers (getters/setters)
- All logic in services
- No behavior in domain

**Why it's bad:**
- Violates OOP
- Business rules scattered
- Hard to enforce invariants

**Good:**
- Rich domain models with behavior
- Services only orchestrate
- Entities encapsulate business rules

### 2. Leaky Layers

**Bad:**
- Domain layer imports HTTP libraries
- Application layer knows about database
- Infrastructure leaks into upper layers

**Why it's bad:**
- Can't test without infrastructure
- Hard to swap implementations
- Violates layer isolation

**Good:**
- Pure domain in domain layer
- Use interfaces/ports
- All infrastructure in infrastructure layer

### 3. Skip Layers

**Bad:**
- Presentation directly accesses database
- Domain calls external APIs directly
- Bypassing layers

**Why it's bad:**
- Loses layer benefits
- Hard to test
- Violates separation

**Good:**
- Go through proper layers
- Each layer handles its responsibility
- Clear data flow

### 4. God Service

**Bad:**
- One service with too many responsibilities
- All business logic in one place
- No separation between use cases

**Why it's bad:**
- Hard to maintain
- Difficult to test
- No clear boundaries

**Good:**
- Services with single responsibility
- Separate use cases
- Clear orchestration

### 5. Not Using Closed Layers

**Bad:**
- Creating new layers between existing ones
- Making exceptions to layer rules
- Allowing "one-off" access

**Why it's bad:**
- Inconsistent structure
- Precedent for more violations
- Hard to maintain

**Good:**
- Follow layer rules consistently
- Only create new layers when needed
- Document exceptions

## Best Practices

### 1. Standard Layer Structure

```
src/
├── presentation/
│   ├── api/
│   ├── cli/
│   └── consumers/
├── application/
│   ├── services/
│   ├── use_cases/
│   └── dtos/
├── domain/
│   ├── entities/
│   ├── value_objects/
│   ├── services/
│   └── events/
├── infrastructure/
│   ├── persistence/
│   ├── external/
│   └── messaging/
└── main.py
```

### 2. Dependency Injection

```python
# container.py
from dependency_injector import containers, providers

class Container(containers.DeclarativeContainer):
    # Infrastructure
    database = providers.Singleton(Database)
    http_client = providers.Singleton(HTTPClient)
    
    # Repositories (implement domain ports)
    user_repository = providers.Factory(
        SqlAlchemyUserRepository,
        session=database.session
    )
    order_repository = providers.Factory(
        SqlAlchemyOrderRepository,
        session=database.session
    )
    
    # Application services
    user_service = providers.Factory(
        UserService,
        repository=user_repository
    )
    order_service = providers.Factory(
        OrderService,
        repository=order_repository
    )
```

### 3. Testing at Different Layers

```python
# Test domain (no dependencies)
def test_order_calculate_total():
    order = Order(items=[
        OrderItem("p1", Decimal("10.00"), 2),
        OrderItem("p2", Decimal("5.00"), 1)
    ])
    assert order.calculate_total() == Decimal("25.00")

# Test application (mock infrastructure)
def test_order_service_create():
    mock_repo = Mock(spec=OrderRepository)
    mock_payment = Mock(spec=PaymentGateway)
    mock_payment.process.return_value = True
    
    service = OrderService(mock_repo, mock_payment)
    result = service.create_order([{"product_id": "p1", "price": 10, "quantity": 1}])
    
    assert result.status == "pending"
    mock_repo.save.assert_called_once()

# Test presentation (integration test)
def test_api_create_order(client, test_db):
    response = client.post("/orders", json={"items": [...]})
    assert response.status_code == 201
```

### 4. Layer Configuration

```python
# Each layer has its own settings
# config/presentation.py
class PresentationConfig:
    CORS_ORIGINS: list = ["*"]
    RATE_LIMIT: int = 100

# config/application.py
class ApplicationConfig:
    MAX_ITEMS_PER_ORDER: int = 100
    DEFAULT_CURRENCY: str = "USD"

# config/domain.py
class DomainConfig:
    ORDER_MIN_AMOUNT: Decimal = Decimal("0.01")
    ORDER_MAX_AMOUNT: Decimal = Decimal("999999.99")

# config/infrastructure.py
class InfrastructureConfig:
    DB_POOL_SIZE: int = 10
    DB_TIMEOUT: int = 30
    PAYMENT_RETRY_COUNT: int = 3
```

## Failure Modes

- **Domain layer depending on infrastructure** → business rules become coupled to database or external APIs → cannot test domain logic in isolation or swap infrastructure → enforce dependency inversion with ports/interfaces in domain layer
- **Presentation layer bypassing business logic** → controllers directly query databases → business rules scattered across presentation → enforce layer boundaries with architectural fitness functions in CI
- **Leaky abstractions between layers** → infrastructure details (SQL queries, HTTP clients) leak into upper layers → cannot change infrastructure without touching business logic → use mappers and DTOs at layer boundaries
- **Anemic domain models** → entities are just data containers with no behavior → business logic scattered in services → enrich domain entities with behavior and invariants
- **God service layer** → single service orchestrates all use cases → service becomes untestable and unmaintainable → create focused use-case-specific services
- **Cross-layer data format coupling** → database models used directly in API responses → database schema changes break API contracts → transform data at each layer boundary
- **Skipping layers for convenience** → presentation calls infrastructure directly → layer structure becomes meaningless → enforce layer traversal rules consistently

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| FastAPI | Presentation layer |
| SQLAlchemy | Infrastructure layer |
| Pydantic | DTOs and validation |
| Dependency Injector | DI container |
| pytest | Testing layers |

## Related Topics

- [[Hexagonal]]
- [[Modularity]]
- [[Coupling]]
- [[Cohesion]]
- [[DDD]]
- [[SeparationOfConcerns]]
- [[UnitTesting]]
- [[IntegrationTesting]]

## Key Takeaways

- Layering organizes code into horizontal layers with specific responsibilities where dependencies flow only downward from presentation to infrastructure
- Use when clear code organization is needed, different developers work on different concerns, or business logic must stay infrastructure-agnostic
- Avoid for simple applications, rapid prototyping, or when layer overhead exceeds structural benefits
- Tradeoff: clean separation and testability versus added indirection, boilerplate, and potential over-engineering for simple use cases
- Main failure mode: domain layer depending on infrastructure couples business rules to database/APIs, making unit testing and infrastructure swaps impossible
- Best practice: enforce unidirectional dependency flow, use ports/interfaces in the domain layer, transform data at layer boundaries, and test each layer at its appropriate level
- Related: hexagonal architecture, modularity, DDD, separation of concerns, dependency injection

## Additional Notes

**Layer vs Hexagonal:**
- Layering is simpler, hierarchical structure
- Hexagonal is about ports/adapters
- Can combine both approaches
- Choose based on complexity

**Common Layer Mistakes:**
- Not using dependency injection
- Domain depending on infrastructure
- Mixing layer responsibilities
- Skipping layers for "simplicity"

**When to Add Layers:**
- Application layer for use case orchestration
- Domain layer for business rules
- Infrastructure for external concerns
- Don't over-engineer with too many layers

**Testing Strategy:**
- Unit test domain
- Integration test application
- E2E test presentation
- Mock infrastructure at each level
