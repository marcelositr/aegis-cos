---
title: Event Sourcing
title_pt: Event Sourcing ( sourcing de Eventos)
layer: architecture
type: pattern
priority: high
version: 1.0.0
tags:
  - Architecture
  - EventSourcing
  - Pattern
  - Design
description: Pattern that stores state changes as a sequence of events instead of current state.
description_pt: Padrão que armazena mudanças de estado como uma sequência de eventos em vez do estado atual.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Event Sourcing

## Description

Event Sourcing is an architectural pattern where the state of an application is stored as a sequence of events rather than just the current state. Instead of storing the current state of an entity, you store all events that have occurred to that entity, and the current state is derived by replaying these events.

This approach provides several unique benefits:
- **Complete audit trail**: Every state change is captured as an event
- **Temporal queries**: You can query the state at any point in time
- **Event replay**: Rebuild state by replaying events from any point
- **Time travel**: Revert to previous states by reversing events

Event Sourcing works particularly well with Domain-Driven Design (DDD) and CQRS. In this pattern, each business operation generates one or more events that are persisted to an event store. These events are then used to update read models (projections) that optimize data for queries.

The event store acts as the source of truth, storing all events in the order they occurred. Unlike traditional databases that store current state, the event store maintains the full history, making it possible to reconstruct state at any moment or implement features like undo/redo.

Event Sourcing is particularly valuable in domains where:
- Audit trail is critical (banking, compliance)
- Business logic is complex and benefits from event modeling
- You need to track state changes over time
- Temporal queries are required

## Purpose

**When Event Sourcing is valuable:**
- When audit trail is required
- For complex business domains
- When you need temporal queries
- For systems requiring time travel
- In financial applications (ledger-style)
- For systems with complex state transitions

**When to avoid Event Sourcing:**
- Simple CRUD applications
- When eventual consistency is unacceptable
- Teams without domain modeling experience
- When storage costs are a concern

## Rules

1. **Events are immutable** - Once stored, events cannot be changed
2. **Append only** - Never modify or delete events
3. **Design events around domain** - Events represent meaningful business occurrences
4. **Include timestamps** - Every event should have creation time
5. **Version events** - Plan for event schema evolution
6. **Use event handlers** - Update read models through handlers
7. **Handle failures** - Implement retry for failed handlers
8. **Consider snapshots** - For performance with many events

## Examples

### Basic Event Sourcing

```python
# Event definitions - immutable facts
@dataclass
class Event:
    event_id: str
    occurred_at: datetime
    version: int = 1

@dataclass
class AccountCreated(Event):
    account_id: str
    owner_name: str
    initial_balance: decimal.Decimal

@dataclass
class MoneyDeposited(Event):
    account_id: str
    amount: decimal.Decimal
    deposit_id: str

@dataclass
class MoneyWithdrawn(Event):
    account_id: str
    amount: decimal.Decimal
    withdrawal_id: str

@dataclass
class MoneyTransferred(Event):
    from_account: str
    to_account: str
    amount: decimal.Decimal
    transfer_id: str

# Aggregate - reconstructs state from events
class BankAccount:
    def __init__(self, account_id: str = None):
        self.account_id = account_id
        self.balance = decimal.Decimal(0)
        self.owner_name = ""
        self.version = 0
        self._events = []
    
    @staticmethod
    def from_events(events: List[Event]) -> 'BankAccount':
        account = BankAccount()
        for event in events:
            account.apply(event)
        return account
    
    def apply(self, event: Event):
        if isinstance(event, AccountCreated):
            self.account_id = event.account_id
            self.owner_name = event.owner_name
            self.balance = event.initial_balance
        elif isinstance(event, MoneyDeposited):
            self.balance += event.amount
        elif isinstance(event, MoneyWithdrawn):
            self.balance -= event.amount
        elif isinstance(event, MoneyTransferred):
            if event.from_account == self.account_id:
                self.balance -= event.amount
            elif event.to_account == self.account_id:
                self.balance += event.amount
        self.version += 1
    
    def create(self, owner_name: str, initial_balance: decimal.Decimal):
        event = AccountCreated(
            event_id=str(uuid.uuid4()),
            occurred_at=datetime.utcnow(),
            account_id=str(uuid.uuid4()),
            owner_name=owner_name,
            initial_balance=initial_balance,
            version=self.version + 1
        )
        self.apply(event)
        self._events.append(event)
        return event
    
    def deposit(self, amount: decimal.Decimal):
        if amount <= 0:
            raise ValueError("Deposit amount must be positive")
        
        event = MoneyDeposited(
            event_id=str(uuid.uuid4()),
            occurred_at=datetime.utcnow(),
            account_id=self.account_id,
            amount=amount,
            deposit_id=str(uuid.uuid4()),
            version=self.version + 1
        )
        self.apply(event)
        self._events.append(event)
        return event
    
    def withdraw(self, amount: decimal.Decimal):
        if amount <= 0:
            raise ValueError("Withdrawal amount must be positive")
        if amount > self.balance:
            raise InsufficientFundsError(f"Insufficient funds: {self.balance}")
        
        event = MoneyWithdrawn(
            event_id=str(uuid.uuid4()),
            occurred_at=datetime.utcnow(),
            account_id=self.account_id,
            amount=amount,
            withdrawal_id=str(uuid.uuid4()),
            version=self.version + 1
        )
        self.apply(event)
        self._events.append(event)
        return event
    
    def uncommitted_events(self) -> List[Event]:
        return self._events
    
    def clear_events(self):
        self._events = []
```

### Event Store

```python
# Event Store - append-only storage
class EventStore:
    def __init__(self, connection):
        self.db = connection
    
    def append(self, aggregate_id: str, events: List[Event]):
        for event in events:
            self.db.execute("""
                INSERT INTO events (aggregate_id, event_type, data, occurred_at, version)
                VALUES (?, ?, ?, ?, ?)
            """, (
                aggregate_id,
                event.__class__.__name__,
                json.dumps(event, default=str),
                event.occurred_at,
                event.version
            ))
    
    def get_events_for_aggregate(self, aggregate_id: str, from_version: int = 0) -> List[Event]:
        rows = self.db.execute("""
            SELECT event_type, data FROM events
            WHERE aggregate_id = ? AND version > ?
            ORDER BY occurred_at
        """, (aggregate_id, from_version)).fetchall()
        
        events = []
        for row in rows:
            event_type = row['event_type']
            data = json.loads(row['data'])
            event = self.deserialize_event(event_type, data)
            events.append(event)
        return events
    
    def deserialize_event(self, event_type: str, data: dict) -> Event:
        event_classes = {
            'AccountCreated': AccountCreated,
            'MoneyDeposited': MoneyDeposited,
            'MoneyWithdrawn': MoneyWithdrawn,
            'MoneyTransferred': MoneyTransferred,
        }
        return event_classes[event_type](**data)
```

### Projections

```python
# Read models / Projections
class AccountSummaryProjection:
    def __init__(self, db):
        self.db = db
    
    def project(self, event: Event):
        if isinstance(event, AccountCreated):
            self.db.execute("""
                INSERT INTO account_summary (account_id, owner_name, balance, created_at)
                VALUES (?, ?, ?, ?)
            """, (event.account_id, event.owner_name, event.initial_balance, event.occurred_at))
        
        elif isinstance(event, MoneyDeposited):
            self.db.execute("""
                UPDATE account_summary 
                SET balance = balance + ?
                WHERE account_id = ?
            """, (event.amount, event.account_id))
        
        elif isinstance(event, MoneyWithdrawn):
            self.db.execute("""
                UPDATE account_summary 
                SET balance = balance - ?
                WHERE account_id = ?
            """, (event.amount, event.account_id))
    
    def get_summary(self, account_id: str) -> dict:
        return self.db.execute("""
            SELECT * FROM account_summary WHERE account_id = ?
        """, (account_id,)).fetchone()

# Event Handler - processes events to update projections
class EventHandler:
    def __init__(self, event_store: EventStore, projections: List):
        self.event_store = event_store
        self.projections = projections
    
    def handle(self, event: Event):
        for projection in self.projections:
            projection.project(event)
```

### Temporal Queries

```python
# Query state at a point in time
class TemporalQuery:
    def __init__(self, event_store: EventStore):
        self.event_store = event_store
    
    def get_balance_at(self, account_id: str, at_time: datetime) -> decimal.Decimal:
        events = self.db.execute("""
            SELECT data FROM events
            WHERE aggregate_id = ? AND occurred_at <= ?
            ORDER BY occurred_at
        """, (account_id, at_time)).fetchall()
        
        balance = decimal.Decimal(0)
        for row in events:
            event_data = json.loads(row['data'])
            if 'initial_balance' in event_data:
                balance = decimal.Decimal(event_data['initial_balance'])
            elif 'amount' in event_data:
                balance += decimal.Decimal(event_data['amount'])
        
        return balance
    
    def get_state_at(self, account_id: str, at_time: datetime) -> dict:
        events = self.event_store.get_events_for_aggregate(
            account_id, 
            from_version=0
        )
        # Filter events by time
        events_before = [e for e in events if e.occurred_at <= at_time]
        
        # Reconstruct state
        account = BankAccount.from_events(events_before)
        return {
            'account_id': account.account_id,
            'balance': account.balance,
            'owner': account.owner_name,
            'at_time': at_time
        }
```

## Anti-Patterns

### 1. Storing Sensitive Data in Events

**Bad:**
- Storing passwords, credit cards, or PII in events
- Events visible in logs or monitoring

**Solution:**
- Don't store sensitive data in events
- Store references to sensitive data
- Encrypt event data if necessary

### 2. Large Events

**Bad:**
- Storing entire objects in events
- Including unnecessary data

**Solution:**
- Keep events small and focused
- Store only what changed
- Use references for related data

### 3. Not Handling Schema Evolution

**Bad:**
- Events can't be deserialized after schema changes
- Breaking changes without version handling

**Solution:**
- Version events explicitly
- Use event upcasters
- Document event schemas

## Best Practices

### 1. Snapshots for Performance

```python
# Snapshot strategy
class SnapshotStore:
    def save_snapshot(self, aggregate_id: str, snapshot: dict, version: int):
        self.db.execute("""
            INSERT OR REPLACE INTO snapshots (aggregate_id, snapshot_data, version)
            VALUES (?, ?, ?)
        """, (aggregate_id, json.dumps(snapshot), version))
    
    def get_latest_snapshot(self, aggregate_id: str) -> (dict, int):
        row = self.db.execute("""
            SELECT snapshot_data, version FROM snapshots
            WHERE aggregate_id = ?
            ORDER BY version DESC LIMIT 1
        """, (aggregate_id,)).fetchone()
        
        if row:
            return json.loads(row['snapshot_data']), row['version']
        return None, 0
```

### 2. Idempotent Handlers

```python
# Handle duplicate events idempotently
class IdempotentHandler:
    def __init__(self, event_store: EventStore):
        self.processed_events = set()
    
    def handle(self, event: Event):
        if event.event_id in self.processed_events:
            return  # Already processed
        
        self.process_event(event)
        self.processed_events.add(event.event_id)
```

### 3. Outbox Pattern for Reliability

```python
# Outbox pattern - ensures events are published
class OutboxRepository:
    def save_events(self, events: List[Event]):
        with self.db.transaction():
            # Save events
            for event in events:
                self.db.execute("""
                    INSERT INTO events (aggregate_id, event_type, data)
                    VALUES (?, ?, ?)
                """, (event.aggregate_id, event.type, json.dumps(event)))
            
            # Save to outbox for reliable publishing
            for event in events:
                self.db.execute("""
                    INSERT INTO outbox (event_id, event_data, created_at)
                    VALUES (?, ?, ?)
                """, (event.event_id, json.dumps(event), datetime.utcnow()))
```

## Technology Stack

| Tool | Use Case |
|------|----------|
| EventStoreDB | Event sourcing database |
| Kafka | Event streaming |
| Axon Framework | Java CQRS/ES framework |
| EventFlow | .NET event sourcing |
| Marten | PostgreSQL event store for .NET |
| Orleans | Actor-based ES |

## Failure Modes

- **Event schema evolution breaking replay** → old events cannot be deserialized after code changes → cannot rebuild state from history → version events explicitly and implement upcasters for schema migration
- **Unbounded event stream growth** → aggregate with millions of events takes minutes to replay → system startup too slow → implement snapshots at regular intervals to limit replay scope
- **Sensitive data stored in immutable events** → PII or credentials embedded in events that cannot be deleted → GDPR compliance violations → never store sensitive data in events; use references to encrypted stores
- **Projection lag causing stale reads** → event handlers fall behind event store → CQRS read models show outdated data → monitor projection lag and implement health checks
- **Non-idempotent event handlers** → replaying events produces different state → corrupted projections after recovery → design all event handlers to be idempotent using event IDs for deduplication
- **Large events with unnecessary data** → events carry entire object graphs → storage costs explode → store only the delta in each event, not full state
- **Missing event handlers for new event types** → new events added but projections not updated → silent data gaps → implement handler registry validation and test coverage for all event types

## Related Topics

- [[EventArchitecture]]
- [[DDD]]
- [[Idempotency]]
- [[Caching]]
- [[DatabaseOptimization]]
- [[Monitoring]]
- [[DataStructures]]

## Key Takeaways

- Event Sourcing stores state changes as an immutable sequence of events rather than current state, deriving state by replaying the event log
- Valuable when audit trails are required, temporal queries are needed, or complex state transitions must be tracked (banking, compliance)
- Avoid for simple CRUD applications, when eventual consistency is unacceptable, or teams lack domain modeling experience
- Tradeoff: complete history and time-travel queries versus storage growth, schema evolution complexity, and replay performance costs
- Main failure mode: event schema evolution breaking deserialization of old events prevents state reconstruction from history
- Best practice: version events explicitly, use snapshots for performance, design idempotent handlers, and never store sensitive data in immutable events
- Related: event-driven architecture, CQRS, idempotency, DDD, database optimization

## Additional Notes

**Event Sourcing Benefits:**
- Complete audit trail
- Temporal queries
- Easy debugging (event replay)
- Complex business logic modeling

**Event Sourcing Challenges:**
- Learning curve
- Storage costs
- Event schema evolution
- Performance with many events

**When to use:**
- Financial systems
- Audit-critical applications
- Complex domain models
- Systems needing temporal queries

**Snapshot Strategy:**
- Save state periodically
- Reduces replay time
- Balance between snapshot frequency and replay cost