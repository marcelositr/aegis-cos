---
title: Event Architecture
title_pt: Arquitetura Orientada a Eventos
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - EventArchitecture
  - EventDriven
description: Architectural pattern where components communicate through events rather than direct calls.
description_pt: Padrão arquitetural onde componentes se comunicam através de eventos ao invés de chamadas diretas.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Event Architecture

## Description

Event architecture (or event-driven architecture) is a pattern where components of a system communicate by emitting and reacting to events rather than making direct synchronous calls. Events are discrete occurrences—something happened—and interested parties can respond to those events without the emitter needing to know who or what will respond.

This decoupling is powerful: producers and consumers are independent. Producers don't need to know about consumers; they simply publish events. Consumers don't need to know about producers; they simply react to events they care about. This enables:
- **Temporal decoupling**: Producer and consumer don't need to be active at the same time
- **Space decoupling**: Producer and consumer don't need to know about each other
- **Speed scaling**: Different components can process at different rates via queues

Common implementations include event-driven microservices, CQRS (Command Query Responsibility Segregation), event sourcing, and saga patterns for distributed transactions.

## Purpose

**When to use event architecture:**
- When you need loose coupling between services
- When components have different scaling requirements
- When you need to add consumers without modifying producers
- When building real-time features
- When handling distributed transactions
- When you want to enable audit trails through event store
- When building systems that need to evolve independently

**When to avoid:**
- When you need immediate consistency (use synchronous calls instead)
- When debugging is difficult (events can be hard to trace)
- When ordering is critical and hard to guarantee
- When simplicity is more important than decoupling

## Rules

1. **Events are immutable** - Once published, events shouldn't change
2. **Idempotency is essential** - Consumers must handle duplicate events
3. **Design events for consumption** - Think about what consumers need
4. **Version events** - Plan for evolution
5. **Log everything** - You need to replay events in case of failure
6. **Handle failures gracefully** - Use dead letter queues
7. **Consider ordering** - Some events need strict ordering

## Examples

### Good Example: Event Publishing

```python
# events.py
from dataclasses import dataclass
from datetime import datetime
from typing import Any

@dataclass
class Event:
    event_id: str
    event_type: str
    occurred_at: datetime
    payload: dict

@dataclass
class OrderCreatedEvent(Event):
    def __init__(self, order_id: str, customer_id: str, items: list, total: float):
        super().__init__(
            event_id=f"order-created-{order_id}",
            event_type="OrderCreated",
            occurred_at=datetime.now(),
            payload={
                "order_id": order_id,
                "customer_id": customer_id,
                "items": items,
                "total": total
            }
        )

# producer.py
from kafka import KafkaProducer
import json

class OrderEventPublisher:
    def __init__(self, bootstrap_servers: list):
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            value_serializer=lambda v: json.dumps(v.__dict__).encode('utf-8')
        )
    
    def publish_order_created(self, event: OrderCreatedEvent):
        self.producer.send('orders.events', event)
        self.producer.flush()
    
    def close(self):
        self.producer.close()
```

### Bad Example: Tight Coupling via HTTP

```python
# BAD: Producer calling consumer directly
class OrderService:
    def create_order(self, order):
        # Save order
        self.db.save(order)
        
        # Directly call other services
        self.notification_service.send_email(order.customer_id, "Order created")
        self.inventory_service.reserve_items(order.items)
        self.payment_service.process_payment(order.payment)
        
        # All synchronous! Tightly coupled!
        # What if notification service is down?
        # What if we want to add more consumers later?
```

### Good Example: Event Consumer

```python
# consumer.py
from kafka import KafkaConsumer
import json

class InventoryEventHandler:
    def __init__(self):
        self.consumer = KafkaConsumer(
            'orders.events',
            bootstrap_servers=['localhost:9092'],
            group_id='inventory-service',
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            auto_offset_reset='earliest'
        )
    
    async def start(self):
        async for message in self.consumer:
            event = message.value
            event_type = event.get('event_type')
            
            if event_type == 'OrderCreated':
                await self.handle_order_created(event)
            elif event_type == 'OrderCancelled':
                await self.handle_order_cancelled(event)
    
    async def handle_order_created(self, event: dict):
        payload = event['payload']
        order_id = payload['order_id']
        items = payload['items']
        
        for item in items:
            await self.inventory.reserve(
                product_id=item['product_id'],
                quantity=item['quantity']
            )
        
        print(f"Reserved inventory for order {order_id}")
    
    async def handle_order_cancelled(self, event: dict):
        payload = event['payload']
        order_id = payload['order_id']
        
        await self.inventory.release_order(order_id)
```

### Bad Example: No Idempotency

```python
# BAD: Not handling duplicate events
class PaymentHandler:
    async def handle_payment_event(self, event: dict):
        # Every time this event is processed, payment is charged!
        payment_info = event['payload']['payment']
        
        await self.payment_gateway.charge(
            amount=payment_info['amount'],
            card=payment_info['card']
        )  # No checking if already charged!
        
        # If Kafka retries, customer gets charged multiple times!
```

### Good Example: Idempotency with Event Store

```python
# idempotent_consumer.py
class IdempotentPaymentHandler:
    def __init__(self, event_store: EventStore, payment_gateway: PaymentGateway):
        self.event_store = event_store
        self.payment_gateway = payment_gateway
    
    async def handle_payment_event(self, event: dict):
        event_id = event['event_id']
        
        # Check if already processed
        if await self.event_store.is_processed(event_id):
            return  # Already processed, skip
        
        payload = event['payload']
        payment = payload['payment']
        
        # Process payment
        result = await self.payment_gateway.charge(
            amount=payment['amount'],
            card=payment['card']
        )
        
        if result.success:
            # Mark as processed
            await self.event_store.mark_processed(event_id)
        else:
            # Handle failure
            await self.event_store.mark_failed(event_id, result.error)
```

## Anti-Patterns

### 1. Events Carrying Too Much Data

**Bad:**
- Including entire objects in events
- Embedding deeply nested structures
- Making events huge

**Why it's bad:**
- Large messages slow down processing
- Versioning becomes hard
- Hard to evolve

**Good:**
- Include only IDs and necessary data
- Use "eventual" lookups for full objects
- Keep events small and focused

### 2. Events Carrying Too Little Data

**Bad:**
- Only sending event type, no payload
- Consumers need to query producer for data
- Creates unnecessary coupling

**Why it's bad:**
- Defeats purpose of decoupling
- Consumers need to know producer's API
- More network calls

**Good:**
- Include all data consumer needs
- Self-contained events
- Think about consumer requirements

### 3. No Error Handling

**Bad:**
- Failed events are lost
- No dead letter queue
- No retry mechanism

**Why it's bad:**
- Data inconsistency
- Silent failures
- Hard to debug

**Good:**
- Implement dead letter queues
- Retry with backoff
- Log failures for investigation

### 4. Synchronous Events (Pseudo-Events)

**Bad:**
- Using events but waiting for response
- Blocking until consumer processes
- Losing async benefits

**Why it's bad:**
- Same problems as direct calls
- Complexity of both sync and async
- No real decoupling

**Good:**
- Fire and forget
- Use correlation IDs for tracking
- Accept eventual consistency

### 5. Not Versioning Events

**Bad:**
- Changing event structure without versioning
- Breaking consumers
- No migration path

**Why it's bad:**
- New producer version breaks consumers
- Forced coordinated releases
- Hard to maintain

**Good:**
- Version events (e.g., OrderCreatedV1, OrderCreatedV2)
- Support multiple versions during transition
- Document migration path

## Best Practices

### 1. Event Schema Design

```json
{
  "event_id": "evt-123-456",
  "event_type": "OrderCreated",
  "event_version": "1.0",
  "occurred_at": "2024-01-15T10:30:00Z",
  "producer": "orders-service",
  "correlation_id": "corr-789",
  "causation_id": "cmd-001",
  "payload": {
    "order_id": "ord-123",
    "customer_id": "cust-456",
    "items": [...],
    "total": 99.99
  }
}
```

### 2. Event Store for Audit

```python
class EventStore:
    def __init__(self, db):
        self.db = db
    
    async def append(self, event: Event):
        await self.db.execute(
            """
            INSERT INTO event_store 
            (event_id, event_type, occurred_at, payload)
            VALUES (?, ?, ?, ?)
            """,
            [event.event_id, event.event_type, 
             event.occurred_at, json.dumps(event.payload)]
        )
    
    async def get_events(self, aggregate_id: str) -> list:
        # For replay/debugging
        return await self.db.query(
            "SELECT * FROM event_store WHERE aggregate_id = ?",
            [aggregate_id]
        )
```

### 3. CQRS Implementation

```python
# Commands (Write)
class CreateOrderCommand:
    def __init__(self, customer_id: str, items: list):
        self.customer_id = customer_id
        self.items = items

# Command Handler
class CommandHandler:
    def __init__(self, event_store: EventStore):
        self.event_store = event_store
    
    async def handle(self, command: CreateOrderCommand):
        order_id = generate_id()
        event = OrderCreatedEvent(order_id, command.customer_id, 
                                  command.items, calculate_total(command.items))
        await self.event_store.append(event)
        return order_id

# Queries (Read) - separate read model
class QueryHandler:
    def __init__(self, read_db: Database):
        self.read_db = read_db
    
    async def get_order_summary(self, order_id: str) -> dict:
        # Optimized for reading
        return await self.read_db.query(
            "SELECT * FROM order_summaries WHERE order_id = ?",
            [order_id]
        )
```

### 4. Saga Pattern for Distributed Transactions

```python
# saga.py
class OrderSaga:
    def __init__(self, steps: list[SagaStep]):
        self.steps = steps
    
    async def execute(self, order: Order):
        completed = []
        
        for step in self.steps:
            try:
                await step.execute(order)
                completed.append(step)
            except StepFailed as e:
                # Compensate in reverse
                for s in reversed(completed):
                    await s.compensate(order)
                raise SagaFailed(e)

class ReserveInventoryStep(SagaStep):
    async def execute(self, order: Order):
        for item in order.items:
            await self.inventory.reserve(item)
    
    async def compensate(self, order: Order):
        for item in order.items:
            await self.inventory.release(item)
```

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| Apache Kafka | High-throughput event streaming |
| RabbitMQ | General-purpose message broker |
| AWS EventBridge | Serverless event bus |
| Google Cloud Pub/Sub | Managed event streaming |
| NATS | Lightweight messaging |
| EventStoreDB | Event sourcing database |

## Failure Modes

- **Lost events with no dead letter queue** → failed event processing silently drops messages → data inconsistency → implement dead letter queues with alerting and manual replay capability
- **Non-idempotent event consumers** → duplicate event delivery causes double processing → duplicate charges or corrupted state → design all consumers to be idempotent using event IDs
- **Event ordering violations** → events processed out of order due to partitioning → incorrect aggregate state → use partition keys to ensure ordering within aggregates
- **Event schema evolution without versioning** → producer changes event format → consumer deserialization fails → version events explicitly and support backward-compatible changes
- **Synchronous event processing blocking producers** → consumer slowness backs up to producer → producer throughput degrades → use async message brokers with buffering
- **Events carrying too much or too little data** → oversized events slow processing or events require callback to producer → performance issues or tight coupling → design events with exactly the data consumers need
- **No event replay capability** → cannot rebuild state after consumer bug → permanent data loss → persist all events in append-only store and design consumers to be replayable

## Related Topics

- [[Coupling]]
- [[Modularity]]
- [[EventSourcing]]
- [[Idempotency]]
- [[Monitoring]]
- [[Cohesion]]
- [[Kubernetes]]
- [[CiCd]]

## Key Takeaways

- Event-driven architecture decouples components by having them emit and react to immutable events rather than making direct synchronous calls
- Use when loose coupling is needed, components have different scaling requirements, or you need to add consumers without modifying producers
- Avoid when immediate consistency is required, debugging distributed flows is too difficult, or event ordering is critical and hard to guarantee
- Tradeoff: temporal and spatial decoupling with independent scaling versus eventual consistency, harder debugging, and schema evolution complexity
- Main failure mode: non-idempotent consumers processing duplicate events cause double charges or corrupted state
- Best practice: design idempotent consumers, version events, use dead letter queues for failures, keep events self-contained with exactly the data consumers need, and persist events for replay capability
- Related: coupling, modularity, event sourcing, idempotency, monitoring, CQRS, saga pattern

## Additional Notes

**Event-Driven Patterns:**

1. **Mediator** - Central mediator coordinates events
2. **Broker** - Light broker, peer-to-peer
3. **CQRS** - Separate read/write models
4. **Event Sourcing** - Store events instead of state
5. **Saga** - Distributed transactions via events

**Challenges:**
- Eventual consistency
- Debugging distributed flows
- Event ordering
- Idempotency
- Schema evolution

**When to Use Event Sourcing:**
- Need complete audit trail
- Need to replay to recreate state
- Complex business rules based on history
- Temporal queries (state at any point in time)

**When NOT to Use:**
- Simple CRUD operations
- Strong consistency required
- Team unfamiliar with pattern
- Debugging overhead too high
