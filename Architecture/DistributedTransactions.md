---
title: DistributedTransactions
title_pt: Transações Distribuídas
layer: architecture
type: concept
priority: critical
version: 1.0.0
tags:
  - Architecture
  - DistributedSystems
  - Transactions
description: Managing transactions across multiple services or databases.
description_pt: Gerenciando transações através de múltiplos serviços ou bancos de dados.
prerequisites:
  - DistributedSystems
  - EventArchitecture
  - Microservices
estimated_read_time: 15 min
difficulty: advanced
---

# DistributedTransactions

## Description

[[DistributedTransactions]] coordinate operations across multiple services or databases that cannot use traditional ACID transactions. In microservices architectures, each service owns its data, so distributed transactions require new patterns.

The core challenge: distributed transactions span service boundaries where there's no shared database or transaction manager.

## Patterns

### Saga Pattern

Orchestrate distributed transactions as a sequence of local transactions. Each service performs its operation and publishes an event. If one fails, compensating transactions undo previous operations.

```python
# Saga Orchestrator
class OrderSaga:
    def execute(self, order_data):
        try:
            # Step 1: Create order
            order = self.order_service.create(order_data)
            
            # Step 2: Reserve inventory (publish event)
            self.event_bus.publish(InventoryReserved(order.id, order.items))
            
            # Step 3: Process payment
            self.payment_service.charge(order.customer_id, order.total)
            
            # Step 4: Confirm order
            self.order_service.confirm(order.id)
            
            return {"status": "completed", "order_id": order.id}
            
        except PaymentFailed:
            # Compensate: release inventory
            self.inventory_service.release(order.items)
            # Compensate: cancel order
            self.order_service.cancel(order.id)
            raise
```

### Choreography vs Orchestration

**Choreography:** Services emit and react to events without central coordinator.

```python
# Choreography - each service reacts to events
class InventoryService:
    def handle(self, event):
        if event.type == "OrderCreated":
            self.reserve(event.order_id, event.items)
            self.publish("InventoryReserved")
        elif event.type == "OrderCancelled":
            self.release(event.order_id)

class PaymentService:
    def handle(self, event):
        if event.type == "InventoryReserved":
            self.charge(event.customer_id, event.total)
            self.publish("PaymentProcessed")
```

**Orchestration:** Central coordinator directs the flow.

```python
# Orchestration - saga orchestrator controls
class OrderOrchestrator:
    def run(self, order):
        step1 = self.inventory.reserve(order.items)
        if not step1.success:
            return self.fail(order)
        
        step2 = self.payment.charge(order.total)
        if not step2.success:
            self.inventory.release(order.items)
            return self.fail(order)
        
        step3 = self.shipping.schedule(order)
        return self.success(order)
```

## Purpose

**When Saga is essential:**
- Microservices with separate databases
- Operations spanning multiple services
- Long-running business processes
- E-commerce order flows

**When simpler approaches work:**
- Single database with ACID transactions
- Operations within one service boundary
- Read-only operations
- Eventually consistent operations

**The key question:** Can you decompose your operation into independent local transactions with compensation?

## Failure Modes

- **Compensation failure** → Service fails to undo previous operation → inconsistent state → implement retry queues and manual intervention processes
- **Partial completion** → Some steps complete before failure → system in intermediate state → design for idempotency at each step
- **Infinite retries** → Compensating transaction keeps failing → dead letter queue and alerting → implement retry limits and escalation
- **Race conditions** → Concurrent sagas modify same data → conflicts → use optimistic locking or distributed locks
- **Timeout during saga** → Long-running operation times out → unclear if complete → use idempotency keys and status checking
- **Eventual consistency delay** → Compensation happens minutes later → user sees stale data → implement pending state UI
- **Cascading failures** → One service failure triggers many compensations → system overload → implement circuit breakers

## Anti-Patterns

### 1. Distributed Transactions Across Services

**Bad:** Using two-phase commit across service databases
```python
# 2PC across services - doesn't work!
distributed_transaction = BeginDistributed()
distributed_transaction.add(order_db)
distributed_transaction.add(payment_db)
distributed_transaction.commit()  # Not possible with separate DBs
```

**Good:** Saga pattern with compensation
```python
# Saga handles distributed operation
saga = OrderSaga()
result = saga.execute(order)
```

### 2. No Idempotency

**Bad:** Repeating operation causes duplicate
```python
# Will create duplicate orders on retry
def create_order(order_data):
    return db.insert(order_data)
```

**Good:** Idempotent operations
```python
# Idempotent - safe to retry
def create_order(order_data):
    existing = db.find_by_idempotency_key(order_data.idempotency_key)
    if existing:
        return existing
    return db.insert(order_data)
```

### 3. Missing Compensation Logic

**Bad:** Only forward operations
```python
# No way to undo
def place_order(order):
    inventory.reserve(order.items)
    payment.charge(order.total)
    return "ordered"
```

**Good:** Forward + compensation
```python
# Forward and undo
def place_order(order):
    try:
        inventory.reserve(order.items)
        payment.charge(order.total)
    except:
        inventory.release(order.items)  # Compensate!
        raise
```

## Best Practices

### 1. Design for Failure

```
Saga Design Checklist:
├── Identify each step that needs compensation
├── Define compensating actions for each step
├── Handle timeout gracefully
├── Implement idempotency at each step
├── Monitor saga state and progress
└── Alert on stuck or failed sagas
```

### 2. Use Orchestration for Complex Flows

```python
# Orchestrator for complex order flow
class OrderOrchestrator:
    STEPS = [
        ("validate_order", self.validate),
        ("reserve_inventory", self.inventory.reserve),
        ("charge_payment", self.payment.charge),
        ("create_shipment", self.shipping.create),
    ]
    
    def execute(self, order):
        executed = []
        for step_name, step_fn in self.STEPS:
            try:
                result = step_fn(order)
                executed.append((step_name, result))
            except:
                self.compensate(executed)
                raise
```

### 3. Monitor Saga Health

```python
# Track saga execution
def execute_saga(saga):
    with saga_tracker.track(saga.id) as tracker:
        tracker.record_start()
        try:
            result = saga.run()
            tracker.record_complete()
            return result
        except:
            tracker.record_failed()
            alert.on_call("Saga failed", saga.id)
            raise
```

## Related Topics

- [[Microservices]] — Distributed transaction context
- [[EventArchitecture]] — Event-driven communication
- [[EventSourcing]] — Event stores with sagas
- [[Idempotency]] — Safe retry of operations
- [[CircuitBreaker]] — Prevent cascading failures

## Key Takeaways

- Saga coordinates distributed transactions via local operations + compensation
- Choreography: event-driven; Orchestration: central coordinator
- Each step must be idempotent and have compensation logic
- Design for partial failure and eventual consistency
- Monitor saga health and alert on stuck executions
- Use orchestration for complex flows, choreography for simple