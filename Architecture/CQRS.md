---
title: CQRS
title_pt: CQRS (Command Query Responsibility Segregation)
layer: architecture
type: pattern
priority: high
version: 1.0.0
tags:
  - Architecture
  - CQRS
  - Pattern
  - Design
description: Architectural pattern that separates read and write operations into different models.
description_pt: Padrão arquitetural que separa operações de leitura e escrita em modelos diferentes.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# CQRS

## Description

[[CQRS]] (Command Query Responsibility Segregation) is an architectural pattern that separates read and write operations for a data store. The fundamental idea is that the way you read data shouldn't necessarily be the same as the way you write data. By segregating these responsibilities, you can optimize each operation independently, leading to better performance, scalability, and maintainability.

In traditional CRUD applications, the same model is used for both reading and writing. This approach works well for simple applications but becomes problematic as complexity increases. CQRS solves this by creating distinct models: one for handling commands (writes) and another for handling queries (reads).

The pattern became popular through the work of Greg Young and is particularly useful in:
- Systems with complex domain logic
- Applications with varying read/write loads
- Scenarios requiring different data representations for reads vs writes
- Event-driven architectures
- Systems that need to scale read and write independently

CQRS often goes hand-in-hand with Event Sourcing, where the write model is an event store and read models are built from those events. However, CQRS can also be implemented with a traditional database as the write store, with separate read models projecting from it.

## Purpose

**When CQRS is valuable:**
- When read and write workloads differ significantly
- For systems with complex business rules on writes
- When you need different representations for reading vs writing
- In event-driven architectures
- For systems requiring high read performance (read replicas)
- When team needs clear separation of read vs write concerns

**When to avoid CQRS:**
- Simple CRUD applications with balanced read/write
- When added complexity isn't justified
- Teams without experience with the pattern
- When eventual consistency is unacceptable

## Rules

1. **Separate models explicitly** - Don't share models between commands and queries
2. **Design commands around intent** - Focus on user intentions, not data
3. **Optimize reads for consumption** - Read models should match UI needs
4. **Consider eventual consistency** - Reads may be slightly stale
5. **Use events to synchronize** - If using event sourcing
6. **Start simple** - Don't over-engineer from the start
7. **Document the split** - Make the separation clear to the team

## Examples

### Basic CQRS Implementation

```python
# Traditional approach (NOT CQRS)
class UserService:
    def get_user(self, user_id):
        return self.db.query(User).filter(id=user_id).first()
    
    def create_user(self, name, email):
        user = User(name=name, email=email)
        self.db.add(user)
        self.db.commit()
        return user

# CQRS approach - SEPARATED models

# Commands (Writes)
class CreateUserCommand:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email

class UpdateUserCommand:
    def __init__(self, user_id: str, name: str = None, email: str = None):
        self.user_id = user_id
        self.name = name
        self.email = email

class DeleteUserCommand:
    def __init__(self, user_id: str):
        self.user_id = user_id

# Command Handlers
class UserCommandHandler:
    def handle_create(self, command: CreateUserCommand) -> str:
        user = User(
            id=str(uuid.uuid4()),
            name=command.name,
            email=command.email,
            created_at=datetime.utcnow()
        )
        self.event_store.save(user.to_events())  # Save events
        return user.id
    
    def handle_update(self, command: UpdateUserCommand):
        # Load aggregate and apply command
        aggregate = self.user_repository.get(command.user_id)
        aggregate.update_name(command.name)
        aggregate.update_email(command.email)
        self.event_store.save(aggregate.uncommitted_events())
    
    def handle_delete(self, command: DeleteUserCommand):
        aggregate = self.user_repository.get(command.user_id)
        aggregate.delete()
        self.event_store.save(aggregate.uncommitted_events())

# Queries (Reads)
class UserQuery:
    def get_user_summary(self, user_id: str) -> UserSummaryDTO:
        # Optimized for display - denormalized
        return self.read_db.query(UserSummaryView).filter(id=user_id).first()
    
    def get_user_list(self, page: int, size: int) -> List[UserListDTO]:
        return self.read_db.query(UserListView).limit(size).offset(page * size).all()
    
    def get_user_profile(self, user_id: str) -> UserProfileDTO:
        # Different view for profile page
        return self.read_db.query(UserProfileView).filter(id=user_id).first()
```

### Read Model Projections

```python
# Read models - specific to each use case

# View for user list (minimal data)
class UserListView:
    __tablename__ = 'user_list_view'
    
    id = Column(String, primary_key=True)
    name = Column(String)
    avatar_url = Column(String)
    status = Column(String)  # active, inactive

# View for user summary (dashboard)
class UserSummaryView:
    __tablename__ = 'user_summary_view'
    
    id = Column(String, primary_key=True)
    name = Column(String)
    email = Column(String)
    created_at = Column(DateTime)
    last_login = Column(DateTime)
    subscription_tier = Column(String)

# View for profile page (detailed)
class UserProfileView:
    __tablename__ = 'user_profile_view'
    
    id = Column(String, primary_key=True)
    name = Column(String)
    email = Column(String)
    phone = Column(String)
    bio = Column(String)
    settings = Column(JSON)  # Nested settings as JSON
    preferences = Column(JSON)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

# Projection from events to views
class UserProjection:
    def project(self, event):
        if isinstance(event, UserCreatedEvent):
            self.create_user_view(event)
        elif isinstance(event, UserUpdatedEvent):
            self.update_user_view(event)
        elif isinstance(event, UserDeletedEvent):
            self.delete_user_view(event)
    
    def create_user_view(self, event):
        # Create multiple read models from single event
        self.read_db.insert(UserListView(
            id=event.user_id,
            name=event.name,
            avatar_url=f"/avatars/{event.user_id}.jpg",
            status='active'
        ))
        self.read_db.insert(UserSummaryView(
            id=event.user_id,
            name=event.name,
            email=event.email,
            created_at=event.created_at,
            last_login=None,
            subscription_tier='free'
        ))
```

### API Layer with CQRS

```python
# FastAPI endpoints - SEPARATED commands and queries

# Command endpoints - POST, PUT, DELETE
@app.post("/users")
async def create_user(command: CreateUserCommand):
    handler = UserCommandHandler(user_repository, event_store)
    user_id = handler.handle_create(command)
    return {"user_id": user_id, "status": "created"}

@app.put("/users/{user_id}")
async def update_user(user_id: str, command: UpdateUserCommand):
    command.user_id = user_id
    handler = UserCommandHandler(user_repository, event_store)
    handler.handle_update(command)
    return {"status": "updated"}

@app.delete("/users/{user_id}")
async def delete_user(user_id: str):
    handler = UserCommandHandler(user_repository, event_store)
    handler.handle_delete(DeleteUserCommand(user_id))
    return {"status": "deleted"}

# Query endpoints - GET
@app.get("/users/{user_id}/summary")
async def get_user_summary(user_id: str):
    query = UserQuery(read_db)
    return query.get_user_summary(user_id)

@app.get("/users")
async def list_users(page: int = 0, size: int = 20):
    query = UserQuery(read_db)
    return query.get_user_list(page, size)

@app.get("/users/{user_id}/profile")
async def get_user_profile(user_id: str):
    query = UserQuery(read_db)
    return query.get_user_profile(user_id)
```

## Anti-Patterns

### 1. Over-Engineering CQRS

**Bad:**
- Creating too many read models
- Adding complexity where simple CRUD suffices
- Implementing Event Sourcing unnecessarily

**Solution:**
- Start with simple CQRS
- Only add complexity when needed
- Use single read model initially

### 2. Synchronous Read/Write Models

**Bad:**
- Expecting immediate consistency
- Blocking reads until writes complete
- Adding unnecessary complexity

**Solution:**
- Accept eventual consistency
- Use asynchronous updates
- Design for read replicas

### 3. Not Handling Failures

**Bad:**
- Not handling command failures
- Not retrying failed events
- Ignoring failed projections

**Solution:**
- Implement retry mechanisms
- Use outbox pattern for reliability
- Monitor projection health

## Best Practices

### 1. Start Simple

```python
# Simple CQRS - same DB, different models
# Use only when needed

class UserRepository:
    # Write model - normalized, validation
    def save(self, user):
        # Validate and save to master DB
        pass

class UserReadRepository:
    # Read model - denormalized, optimized
    def get_user_summary(self, user_id):
        # Query from read replica
        pass
```

### 2. Use Commands for Intent

```python
# GOOD: Command describes intent
class PlaceOrderCommand:
    def __init__(self, customer_id: str, items: List[OrderItem], shipping_address: str):
        self.customer_id = customer_id
        self.items = items
        self.shipping_address = shipping_address

# NOT GOOD: Command describes data
class UpdateOrderCommand:
    def __init__(self, order_id: str, items: List[OrderItem] = None, address: str = None):
        # Too generic - doesn't capture intent
        pass
```

### 3. Async Projection for Scalability

```python
# Kafka-based projection
class EventProcessor:
    def __init__(self):
        self.consumer = KafkaConsumer('user-events', bootstrap_servers=['localhost:9092'])
    
    def process(self):
        for message in self.consumer:
            event = json.loads(message.value)
            
            if event['type'] == 'USER_CREATED':
                self.create_user_projection(event)
            elif event['type'] == 'USER_UPDATED':
                self.update_user_projection(event)
```

## Technology Stack

| Tool | Use Case |
|------|----------|
| EventStoreDB | Event sourcing database |
| Kafka | Event streaming |
| RabbitMQ | Message queuing |
| Redis | Read cache |
| PostgreSQL | Read/Write DB |
| Elasticsearch | Read model search |

## Failure Modes

- **Read model lag causing stale data** → projections fall behind write model → users see outdated information → monitor projection lag and implement read-your-writes consistency where needed
- **Eventual consistency confusing users** → user creates data but cannot immediately see it → poor user experience → design UI to handle eventual consistency with loading states and optimistic updates
- **Projection failures silently dropping events** → event handler crashes and does not retry → read model permanently inconsistent → implement dead letter queues and retry mechanisms
- **Over-engineering with too many read models** → separate model for every query pattern → maintenance nightmare → start with single read model, split only when performance demands it
- **Command handler not validating business rules** → invalid commands accepted into write model → corrupted state → enforce invariants and validation before accepting commands
- **Event schema evolution breaking projections** → new event version incompatible with existing handlers → projection crashes on replay → version events explicitly and support multiple versions during migration
- **Write model becoming bottleneck** → all writes go through single command handler → throughput ceiling → partition command handlers by aggregate and use event sourcing for scalability

## Related Topics

- [[EventSourcing]] — Store events instead of state, often paired with CQRS
- [[DDD]] — Domain-Driven Design, bounded contexts
- [[Microservices]] — CQRS per service boundary
- [[Hexagonal]] — Ports and adapters for command/query separation
- [[EventArchitecture]] — Event-driven CQRS projections
- [[SQL]] — Read/write database separation
- [[NoSQL]] — Read-optimized stores
- [[Caching]] — Read model caching strategies
- [[APIDesign]] — Separate command and query endpoints
- [[Idempotency]] — Making commands safe to retry
- [[RateLimiting]] — Protecting write models
- [[DistributedSystems]] — CQRS in distributed environments
- [[PerformanceOptimization]] — Read model optimization

## Additional Notes

**CQRS Benefits:**
- Independent scaling of reads/writes
- Optimized read models per use case
- Clear separation of concerns
- Better performance for read-heavy systems

**CQRS Challenges:**
- Added complexity
- Eventual consistency
- Learning curve for teams
- Testing complexity

**Eventual Consistency:**
- Accept that reads may be slightly behind
- Design UI to handle this
- Use timestamps to show data freshness

**When to use Event Sourcing with CQRS:**
- Audit trail requirements
- Complex business logic
- Need full state history
- Rebuild state from events

## Key Takeaways

- CQRS separates read and write operations into distinct models, allowing independent optimization of each.
- Use when read and write workloads differ significantly, complex business rules exist on writes, or independent scaling is needed.
- Do NOT use for simple CRUD applications, when eventual consistency is unacceptable, or when added complexity isn't justified.
- Key tradeoff: independent optimization and scalability of reads vs. added architectural complexity and eventual consistency.
- Main failure mode: over-engineering with too many read models or expecting immediate consistency between write and read models.
- Best practice: start simple with same-database different-models CQRS, design commands around user intent, and accept eventual consistency.
- Related concepts: Event Sourcing, DDD, Hexagonal Architecture, Event Architecture, Read Replicas, Outbox Pattern.