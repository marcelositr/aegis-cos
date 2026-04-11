---
title: Partitioning
title_pt: Particionamento de Dados
layer: databases
type: concept
priority: critical
version: 1.0.0
id: core.db.partitioning.v1
tags:
  - Databases
  - Partitioning
  - Sharding
  - Scalability
  - DistributedSystems
keywords:
  - data partitioning
  - sharding
  - consistent hashing
  - range partitioning
  - hash partitioning
  - rebalancing
  - hot partition
  - scatter-gather
description: Horizontal data distribution strategy that splits a dataset across multiple nodes (shards) to achieve scale-out reads/writes, storage capacity, and fault isolation.
---

# Partitioning

## Description

**Partitioning** (also called **sharding**) is the horizontal split of a dataset across multiple storage nodes. Each partition (shard) holds a subset of the total data, and together they represent the complete dataset.

Unlike replication (which copies the same data to multiple nodes), partitioning **divides** the data — each node is responsible for a different slice.

**Key terminology:**
- **Partition/Shard** — A subset of data stored on one node
- **Partition key** — The attribute used to determine which partition holds a row
- **Routing** — The process of determining the correct partition for a given key
- **Rebalancing** — Redistributing data when partitions change (add/remove nodes, data growth)

## Purpose

**When partitioning is necessary:**
- Dataset exceeds single-node storage capacity
- Write throughput exceeds single-node capacity
- Read throughput requires parallel serving from multiple nodes
- Fault isolation needed (one partition failure shouldn't bring down entire dataset)
- Geographic distribution (data locality for compliance or latency)

**When partitioning is premature:**
- Single node can handle the load (start simple)
- Dataset fits comfortably in memory
- Complex cross-partition queries are the primary access pattern
- Team lacks operational experience with distributed data
- Transactional requirements demand strong consistency across rows

**The key question:** Is my bottleneck storage capacity, write throughput, or read parallelism that can't be solved with caching or vertical scaling?

## Tradeoffs

| Strategy | Description | Pros | Cons | Best For |
|----------|-------------|------|------|----------|
| **Range** | Key ranges assigned to partitions (A-F → node 1, G-M → node 2) | Range queries efficient | Hot spots on popular ranges | Time-series, alphabetical lookups |
| **Hash** | hash(key) % N → partition | Uniform distribution | Range queries impossible (scatter-gather) | Key-value, random access |
| **Directory-based** | Lookup table maps keys to partitions | Flexible rebalancing | Lookup table is SPOF | Multi-tenant, dynamic workloads |
| **Consistent hashing** | Hash ring, virtual nodes | Minimal data movement on rebalance | Complex implementation, hot spots with skew | Dynamo-style systems, CDNs |
| **Geographic** | Partition by region/location | Data locality, compliance | Cross-region queries slow | GDPR, multi-region apps |

## Partition Strategies in Detail

### Hash-Based Partitioning

```python
import hashlib

class HashPartitioner:
    """Consistent hash-based partitioning."""

    def __init__(self, num_partitions: int):
        self.num_partitions = num_partitions

    def partition_id(self, key: str) -> int:
        """Determine partition for a given key."""
        h = hashlib.sha256(key.encode()).hexdigest()
        return int(h, 16) % self.num_partitions

    def route(self, key: str, partitions: list) -> str:
        """Route a key to the correct partition endpoint."""
        pid = self.partition_id(key)
        return partitions[pid]

# Usage
partitioner = HashPartitioner(num_partitions=4)
partitions = ["shard-0:5432", "shard-1:5432", "shard-2:5432", "shard-3:5432"]

# Route user query
user_id = "user_12345"
target_shard = partitioner.route(user_id, partitions)
# → "shard-1:5432"
```

### Range Partitioning

```sql
-- PostgreSQL declarative partitioning by range
CREATE TABLE events (
    id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    event_type VARCHAR(50),
    payload JSONB
) PARTITION BY RANGE (event_time);

CREATE TABLE events_2024_q1 PARTITION OF events
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
CREATE TABLE events_2024_q2 PARTITION OF events
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
CREATE TABLE events_2024_q3 PARTITION OF events
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');
CREATE TABLE events_2024_q4 PARTITION OF events
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- Query automatically prunes partitions
SELECT * FROM events
WHERE event_time BETWEEN '2024-03-01' AND '2024-03-31';
-- → Only scans events_2024_q1
```

### Rebalancing with Consistent Hashing

```python
import hashlib
import bisect

class ConsistentHashRing:
    """Consistent hashing with virtual nodes."""

    def __init__(self, num_vnodes: int = 150):
        self.num_vnodes = num_vnodes
        self.ring = []  # sorted list of hash positions
        self.ring_to_node = {}  # hash position → node

    def add_node(self, node: str):
        """Add a node with virtual nodes for uniform distribution."""
        for i in range(self.num_vnodes):
            v_node = f"{node}#vnode{i}"
            h = int(hashlib.sha256(v_node.encode()).hexdigest(), 16)
            self.ring.append(h)
            self.ring_to_node[h] = node
        self.ring.sort()

    def remove_node(self, node: str):
        """Remove a node and all its virtual nodes."""
        for i in range(self.num_vnodes):
            v_node = f"{node}#vnode{i}"
            h = int(hashlib.sha256(v_node.encode()).hexdigest(), 16)
            self.ring.remove(h)
            del self.ring_to_node[h]

    def get_node(self, key: str) -> str:
        """Find the node responsible for a key."""
        h = int(hashlib.sha256(key.encode()).hexdigest(), 16)
        idx = bisect.bisect_right(self.ring, h) % len(self.ring)
        return self.ring_to_node[self.ring[idx]]

# Usage
ring = ConsistentHashRing(num_vnodes=100)
ring.add_node("shard-0")
ring.add_node("shard-1")
ring.add_node("shard-2")

print(ring.get_node("user:123"))  # → "shard-1"
print(ring.get_node("user:456"))  # → "shard-0"

# Adding shard-3 only moves ~25% of keys (not 100% like modulo hashing)
ring.add_node("shard-3")
```

## Failure Modes

- **Hot partition** → one partition handles 80% of traffic → single-node bottleneck → choose partition key that distributes load evenly, monitor per-partition metrics
- **Partition key skew** → time-based key causes all writes to one partition → add randomization/suffix, use composite keys
- **Cross-partition queries** (scatter-gather) → query touches all partitions → slow, inconsistent results → design queries around partition key, use materialized views for cross-partition aggregations
- **Cross-partition transactions** → can't atomically update two partitions → data inconsistency → use saga pattern, or co-locate related data
- **Rebalancing storms** → adding node triggers massive data movement → cluster overload → rebalance gradually with rate limiting, use consistent hashing to minimize movement
- **Partition key chosen poorly** → can't change without full data migration → analyze query patterns before choosing, prototype with production data distribution
- **Unbounded partition growth** → one partition becomes too large for single node → use sub-partitioning (range within hash), or change partition key
- **Routing table stale** → client routes to wrong partition after rebalance → stale read/write → use coordinator service (etcd, ZooKeeper) for routing, implement client-side cache with TTL
- **Schema changes across partitions** → migration must run on all shards → inconsistent schema during rollout → use schema evolution tools, coordinate with blue-green deployment
- **Partition failure** → one shard goes down → data unavailable → replicate within partition (leader + followers), implement automatic failover

## Anti-Patterns

### 1. Partitioning Before Understanding Access Patterns

**Bad:** Sharding a database before knowing the query workload
**Why it's bad:** Wrong partition key → every query is cross-partition → slower than unpartitioned, plus operational complexity
**Good:** Start with single node, add read replicas, then partition based on observed query patterns

### 2. Cross-Partition Joins in Application Code

**Bad:** Fetching data from 5 shards and joining in application memory
**Why it's bad:** O(n*m) complexity in application, inconsistent results if data changes during fetch
**Good:** Denormalize to avoid cross-partition joins, or use a distributed query engine (Presto, Trino)

### 3. Modulo Hashing for Partition Assignment

**Bad:** `partition = hash(key) % num_partitions` — changing num_partitions remaps 100% of keys
**Why it's bad:** Adding a node requires moving all data — downtime or complex migration
**Good:** Use consistent hashing — adding a node only moves ~1/N of keys

## Best Practices

1. **Choose partition key based on access patterns** — most queries should be single-partition
2. **Monitor per-partition metrics** — detect hot partitions before they become bottlenecks
3. **Use consistent hashing for dynamic clusters** — minimizes data movement during rebalancing
4. **Replicate within partitions** — each partition should have leader + followers for fault tolerance
5. **Co-locate related data** — same tenant, same user group → same partition
6. **Plan for rebalancing** — automated, rate-limited, observable
7. **Implement partition-aware routing** — clients should know which partition to query
8. **Design for cross-partition queries** — accept they'll be slow, optimize the common case
9. **Use sub-partitioning** — hash for distribution, range within partition for query efficiency
10. **Start unpartitioned** — only partition when single-node limits are reached

## Related Topics

- [[DatabaseOptimization]] — Query optimization within partitions
- [[Caching]] — Cache strategies for partitioned data
- [[DistributedSystems]] — Distributed data fundamentals
- [[Consistency]] — Consistency guarantees across partitions
- [[SchemaEvolution]] — Migrations across partitions
- [[DistributedTransactions]] — Cross-partition transaction patterns
- [[LoadBalancing]] — Load balancing across partitions
- [[CapacityPlanning]] — Capacity planning for partitioned systems