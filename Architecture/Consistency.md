---
title: Consistency
title_pt: Consistência
layer: architecture
type: concept
priority: critical
version: 1.0.0
tags:
  - Architecture
  - DistributedSystems
  - Consistency
description: Consistency models and tradeoffs in distributed systems.
description_pt: Modelos de consistência e tradeoffs em sistemas distribuídos.
prerequisites:
  - DistributedSystems
  - CAP
estimated_read_time: 15 min
difficulty: advanced
---

# Consistency

## Description

[[Consistency]] describes the guarantees a system provides about the order and visibility of operations. In distributed systems, consistency is fundamentally constrained by the CAP theorem: you can have at most two of Consistency, Availability, and Partition tolerance.

Understanding consistency models is essential for reasoning about:
- Data correctness in replicated systems
- Transaction boundaries
- Cache coherency
- Read-your-writes guarantees

## Consistency Models

### Strong Consistency

All reads see the most recent write. The system appears as if there is a single copy of data.

**When to use:**
- Financial transactions
- Inventory management
- Anything requiring linearizability

```python
# Strong consistency: reads block until write is visible
class StrongConsistencyStore:
    def write(self, key, value):
        # Synchronously replicate to quorum
        for node in quorum:
            node.write_sync(key, value)
        return "ok"
    
    def read(self, key):
        # Read from quorum
        return quorum_read(key)
```

### Eventual Consistency

Writes will eventually propagate to all nodes. Reads may see stale data temporarily.

**When to use:**
- Social media posts
- Analytics dashboards
- Cached content
- High-availability requirements

```python
# Eventual consistency: write returns immediately
class EventualConsistencyStore:
    def write(self, key, value):
        # Async replication
        async.replicate(key, value)
        return "ok"
    
    def read(self, key):
        # Read from any node (might be stale)
        return any_node.read(key)
```

### Causal Consistency

If operation A causes operation B, then B is seen after A. Otherwise, operations may be reordered.

**When to use:**
- Collaborative editing
- Comment threads
- Any scenario where causality matters

```python
# Causal consistency via version vectors
class CausalStore:
    def write(self, key, value, vector):
        # Ensure causality: vector must dominate
        if not vector.dominates(self.last_write_vector):
            raise ConcurrentModificationError()
        self.data[key] = (value, vector)
```

### Read-Your-Writes Consistency

After writing, subsequent reads see that write.

**When to use:**
- User profile updates
- Shopping cart
- Session data

```python
class ReadYourWritesStore:
    def write(self, key, value):
        self.pending_writes[key] = value
        return self.replicate(key, value)
    
    def read(self, key):
        if key in self.pending_writes:
            return self.pending_writes[key]
        return self.storage.read(key)
```

## Purpose

**When to choose strong consistency:**
- Data correctness is critical
- Regulatory requirements
- Financial operations
- Inventory/booking systems

**When eventual consistency is acceptable:**
- High availability is priority
- Stale reads are tolerable
- Conflict resolution is possible
- Last-write-wins is acceptable

**The key question:** Can your application tolerate stale reads, or must every read see the latest data?

## Failure Modes

- **Stale reads** → Eventual consistency allows reading outdated data → financial errors or inventory overselling → use strong consistency for critical data
- **Write conflicts** → Concurrent writes to same key → lost updates → implement conflict resolution or use versioning
- **Partition tolerance** → Network partition forces choice between consistency and availability → system stops accepting writes → prepare for graceful degradation
- **Split-brain** → Multiple leaders accept conflicting writes → data corruption → use majority quorums and term-based leadership
- **Causal violation** → Operations appear out of order → logical inconsistencies → use version vectors or causal timestamps
- **Read skew** → Transaction reads inconsistent snapshot → report generation errors → use snapshot isolation
- **Lost updates** → Last-write-wins discards earlier updates → user data loss → use optimistic locking or CRDTs

## Anti-Patterns

### 1. Inconsistent Consistency Choice

**Bad:** Using eventual consistency for financial data
```python
# Will lose money eventually
payment_processor.charge(user_id, amount)  # eventually consistent!
```

**Good:** Strong consistency for critical operations
```python
# Financial transactions need strong consistency
transaction = db.transaction()
try:
    account.debit(amount)
    audit_log.write(amount)
    transaction.commit()
except:
    transaction.rollback()
```

### 2. Mixing Consistency Models

**Bad:** Assuming eventual is same as strong
```python
# Read might return stale data
balance = user.read("balance")
if balance >= amount:
    user.write("balance", balance - amount)  # Race condition!
}
```

**Good:** Be explicit about consistency
```python
# Use single store with consistent reads
store = ConsistentStore()
balance = store.read(user_id, consistency=Strong)
if balance >= amount:
    store.write(user_id, balance - amount)
```

### 3. Ignoring Partition Behavior

**Bad:** Assuming network never fails
```python
# Will hang during partition
result = db.read(key)  # waiting...
```

**Good:** Design for partitions
```python
# Handle partition gracefully
try:
    result = db.read(key, timeout=2s)
except PartitionError:
    return cached_result(fallback=True)
```

## Best Practices

### 1. Choose Per-Operation

```python
# Different consistency for different operations
class DataStore:
    def read_balance(user_id):
        return self.read(user_id, Strong)  # Financial needs strong
    
    def read_notifications(user_id):
        return self.read(user_id, Eventual)  # Stale ok
    
    def write_profile(user_id, data):
        return self.write(user_id, data, ReadYourWrites)
```

### 2. Make Consistency Explicit

```python
# API declares consistency level
def get_balance(user_id, consistency: ConsistencyLevel = Strong):
    ...
    
def update_profile(user_id, profile, consistency: ConsistencyLevel = ReadYourWrites):
    ...
```

### 3. Monitor Staleness

```python
# Track how stale data might be
metrics.add_label("read_consistency", "stale_seconds", seconds)
metrics.add_label("write_replication", "lag_milliseconds", lag)
```

## Related Topics

- [[DistributedSystems]] — Where consistency matters
- [[Microservices]] — Distributed data management
- [[SQL]] — Consistency in relational databases
- [[NoSQL]] — Eventual consistency patterns
- [[EventSourcing]] — Eventual consistency in event stores

## Key Takeaways

- CAP theorem: pick 2 of Consistency, Availability, Partition tolerance
- Strong consistency: all reads see latest write, high latency during partitions
- Eventual consistency: writes propagate async, stale reads possible
- Choose consistency level per operation based on requirements
- Monitor replication lag and staleness metrics
- Design for graceful degradation during partitions
- Make consistency explicit in APIs, don't mix implicitly