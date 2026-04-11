---
title: Saga Pattern
title_pt: Padrão Saga
layer: architecture
type: pattern
priority: high
version: 1.0.0
tags:
  - Architecture
  - DistributedSystems
  - Pattern
  - Transactions
description: Pattern for managing distributed transactions across multiple services using compensating actions.
description_pt: Padrão para gerenciar transações distribuídas entre múltiplos serviços usando ações compensatórias.
prerequisites:
  - Distributed Systems
  - Microservices
  - Message Queues
estimated_read_time: 15 min
difficulty: advanced
---

# Saga Pattern

## Description

The Saga pattern manages distributed transactions across multiple services by breaking them into a sequence of local transactions, each with a compensating action that undoes it if a later step fails. Unlike traditional 2-phase commit (2PC), sagas don't require distributed locks, making them suitable for microservices.

Key concepts:
- **Local Transaction** — Each step is a transaction within a single service
- **Compensating Transaction** — Action that undoes a previous step
- **Saga Coordinator** — Orchestrates the sequence of steps
- **Forward Recovery** — Retry the failed step
- **Backward Recovery** — Execute compensating transactions to undo

## Purpose

**When the Saga pattern is essential:**
- Microservices that need cross-service data consistency
- Operations spanning multiple services (order → payment → shipping)
- When 2PC is too expensive or unavailable
- Event-driven architectures with eventual consistency

**When Saga adds unnecessary complexity:**
- Single database transactions (use ACID)
- When strong consistency is required (use 2PC)
- Simple operations within one service boundary

**The key question:** Do I need to coordinate changes across multiple services atomically?

## Approaches

### Choreography (Event-Driven)

Services communicate via events. Each service knows its role.

```python
# Order Service emits OrderCreated
class OrderService:
    def create_order(self, order):
        self.db.save(order)
        self.event_bus.publish(OrderCreatedEvent(order_id=order.id))

# Payment Service listens, processes, emits
class PaymentService:
    def on_order_created(self, event: OrderCreatedEvent):
        try:
            payment = self.process_payment(event.order_id)
            self.event_bus.publish(PaymentCompletedEvent(order_id=event.order_id))
        except PaymentFailed as e:
            self.event_bus.publish(PaymentFailedEvent(
                order_id=event.order_id,
                reason=str(e)
            ))

# Shipping Service listens for payment completion
class ShippingService:
    def on_payment_completed(self, event: PaymentCompletedEvent):
        self.create_shipment(event.order_id)
        self.event_bus.publish(ShippingCreatedEvent(order_id=event.order_id))

# Compensation: if shipping fails, payment is refunded
class PaymentService:
    def on_shipping_failed(self, event: ShippingFailedEvent):
        self.refund_payment(event.order_id)
        self.event_bus.publish(PaymentRefundedEvent(order_id=event.order_id))
```

### Orchestration (Central Coordinator)

A central saga orchestrator directs each step.

```python
class OrderSaga:
    def __init__(self):
        self.steps = [
            Step(
                action=self.reserve_inventory,
                compensation=self.release_inventory,
                name="reserve_inventory"
            ),
            Step(
                action=self.process_payment,
                compensation=self.refund_payment,
                name="process_payment"
            ),
            Step(
                action=self.create_shipment,
                compensation=self.cancel_shipment,
                name="create_shipment"
            ),
            Step(
                action=self.notify_customer,
                compensation=self.notify_cancellation,
                name="notify_customer"
            ),
        ]
    
    def execute(self, order_id: str) -> SagaResult:
        completed = []
        
        for step in self.steps:
            try:
                step.action(order_id)
                completed.append(step)
            except StepFailed as e:
                # Backward recovery: compensate in reverse order
                for completed_step in reversed(completed):
                    try:
                        completed_step.compensation(order_id)
                    except CompensationFailed:
                        # Log and alert - manual intervention needed
                        self.alert(f"Compensation failed: {completed_step.name}")
                
                return SagaResult(success=False, failed_step=step.name)
        
        return SagaResult(success=True)
```

## Anti-Patterns

### 1. No Compensation

**Bad:** Step fails → no undo → data inconsistency
**Solution:** Every step MUST have a compensating action

### 2. Non-Idempotent Steps

**Bad:** Retry causes duplicate operations
**Solution:** All steps and compensations must be idempotent

### 3. Circular Dependencies

**Bad:** Service A triggers saga → Service B fails → compensates → triggers another saga
**Solution:** Design sagas as directed acyclic graphs

### 4. Long-Running Sagas

**Bad:** Saga takes minutes → resources locked → timeout
**Solution:** Set saga timeout, use async steps, consider alternative patterns

### 5. Lost Saga State

**Bad:** Orchestrator crashes mid-saga → unknown state
**Solution:** Persist saga state after each step, use event sourcing

## Best Practices

1. **Design compensations carefully** — they're not always exact inverses
2. **Make everything idempotent** — retries and replays must be safe
3. **Persist saga state** — recover from crashes
4. **Set timeouts** — don't let sagas run forever
5. **Monitor saga execution** — track success rate, duration, failures
6. **Handle compensation failures** — they need manual intervention paths
7. **Start with orchestration** — easier to understand and debug than choreography

## Failure Modes

- **Compensation fails** → partial state → manual intervention required
- **Saga timeout** → incomplete transaction → need cleanup process
- **Duplicate events** → idempotency prevents double execution
- **Orchestrator crash** → persisted state enables recovery
- **Service down during compensation** → retry with backoff, alert if persistent
- **Eventual inconsistency window** — between step and compensation, system is inconsistent

## Related Topics

- [[DistributedSystems]] — Sagas solve distributed transaction problem
- [[Microservices]] — Cross-service data consistency
- [[Idempotency]] — Required for safe saga retries
- [[MessageQueues]] — Event transport for choreography sagas
- [[EventArchitecture]] — Event-driven saga coordination
- [[EventSourcing]] — Persisting saga state as events
- [[CQRS]] — Sagas often bridge command and query models
- [[CircuitBreaker]] — Protecting saga step calls from failing services

## Key Takeaways

- The Saga pattern manages distributed transactions across multiple services by breaking them into local transactions with compensating actions for rollback.
- Use for microservices needing cross-service data consistency, operations spanning multiple services, or when 2PC is too expensive or unavailable.
- Do NOT use for single-database transactions (use ACID), when strong consistency is required (use 2PC), or simple operations within one service boundary.
- Key tradeoff: avoiding distributed locks and enabling microservice autonomy vs. complexity of designing compensating transactions and handling partial failures.
- Main failure mode: compensation itself fails, leaving the system in a partially inconsistent state requiring manual intervention.
- Best practice: make every step and compensation idempotent, persist saga state after each step, set timeouts, and start with orchestration over choreography.
- Related concepts: Distributed Transactions, Idempotency, Event-Driven Architecture, Message Queues, Event Sourcing, Circuit Breaker, Two-Phase Commit.
