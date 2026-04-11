---
title: CAP Theorem
layer: architecture
type: concept
priority: high
version: 2.0.0
tags:
  - Architecture
  - CAP
  - DistributedSystems
  - Consistency
  - Databases
description: The CAP theorem constrains what distributed systems can guarantee during network partitions — you cannot simultaneously have Consistency, Availability, and Partition Tolerance.
---

# CAP Theorem

## Description

The CAP theorem (Brewer's Conjecture, proved by Gilbert and Lynch) states that in a distributed system with replicated state, when a **network partition** occurs (nodes cannot communicate), the system must choose between:

- **Consistency (C)** — Every read receives the most recent write or an error. All nodes see the same data at the same time. Linearizable consistency.
- **Availability (A)** — Every request receives a non-error response, without guarantee that it contains the most recent write. The system remains operational.
- **Partition Tolerance (P)** — The system continues to operate despite arbitrary message loss or delay between nodes.

The critical insight that most engineers miss: **P is not a choice**. In any system that communicates over a network (which is every distributed system), partitions *will* happen — switch failures, DNS outages, GC pauses, cloud AZ failures. Therefore, the real choice is **CP or AP** *during* a partition. When there is no partition (the normal case), you can have both C and A.

CAP is a property of the *entire system*, not individual components. Your API gateway might be AP while your database is CP. The system-level guarantee is determined by the weakest link.

## When to Use

- **Choosing a database for a new service** — CAP is the first filter in database selection. If you need strong consistency (financial ledger, inventory system), CP databases like PostgreSQL, etcd, or ZooKeeper are appropriate. If you need high availability (social feed, product catalog, session store), AP databases like DynamoDB, Cassandra, or CouchDB are better.
- **Designing multi-AZ or multi-region architectures** — when deploying across availability zones or regions, partition probability increases. CAP forces explicit decisions about behavior when cross-AZ links fail.
- **Evaluating tradeoffs in data replication** — synchronous replication (CP) vs. asynchronous replication (AP). Synchronous: writes wait for all replicas to acknowledge (consistent but slow, unavailable if a replica is down). Asynchronous: writes return immediately (fast, available) but replicas may diverge.
- **Incident planning for partition scenarios** — during a network partition, what should your system do? Return stale data (AP) or return errors (CP)? This decision must be made *before* the incident, not during it.

## When NOT to Use

- **As a standalone decision framework** — CAP describes behavior *only during partitions*. It says nothing about normal operation. Using CAP alone to choose a database ignores critical factors like query patterns, operational maturity, ecosystem, and total cost of ownership.
- **For single-node systems** — CAP only applies to distributed systems with replicated state. A single PostgreSQL instance has no CAP tradeoff (it is CA, but also not partition-tolerant — if it goes down, it's down).
- **To justify poor data modeling** — "we chose eventual consistency because CAP" is not a valid excuse for not modeling your data access patterns correctly. Many "eventual consistency" problems are actually data modeling problems.
- **As a binary classification** — real systems exist on a spectrum. Many databases offer tunable consistency (DynamoDB's `ConsistentRead`, Cassandra's quorum reads/writes, MongoDB's read/write concerns). The system can be configured to behave more CP or more AP based on the operation.

## Tradeoffs

### CP Systems (Consistency + Partition Tolerance)

**Examples**: PostgreSQL (synchronous replication), etcd, ZooKeeper, HBase, MongoDB (with `majority` write concern and `majority` read concern)

**Behavior during partition**: The system returns errors or times out on one side of the partition rather than serve stale data.

**Use cases**:
- Financial systems (payments, ledgers, account balances) — double-spending is unacceptable
- Inventory management — overselling stock causes customer harm
- Distributed locks and coordination — etcd/ZooKeeper used by Kubernetes for leader election
- Identity and access management — stale auth data creates security vulnerabilities

**Cost**: During a partition affecting N nodes, the unavailable partition handles 0% of requests. For a 3-node etcd cluster losing 1 node, the system remains available (2/3 quorum). For a 3-node cluster losing 2 nodes, the system is completely unavailable.

### AP Systems (Availability + Partition Tolerance)

**Examples**: DynamoDB (default), Cassandra, CouchDB, Riak, Redis (replicated)

**Behavior during partition**: Both sides of the partition continue accepting reads and writes. Data diverges and must be reconciled when the partition heals.

**Use cases**:
- Social media feeds — seeing a tweet 30 seconds late is acceptable
- Product catalogs and search indexes — stale catalog data causes minor UX issues
- Session stores — losing or having stale sessions is recoverable
- Telemetry and analytics — approximate data is acceptable

**Cost**: During a partition, clients may read stale data. After partition heals, conflicting writes must be resolved (last-write-wins, vector clocks, CRDTs, or application logic).

### The PACELC Extension

CAP is incomplete for normal (non-partitioned) operation. PACELC extends it:

> **P**artition occurs → choose **A**vailability or **C**onsistency.
> **E**lse (no partition) → choose **L**atency or **C**onsistency.

This reveals that even when the network is healthy, there is a consistency-vs-latency tradeoff. Synchronous replication across regions adds 50-200ms of latency per write. Asynchronous replication reduces latency but introduces replication lag.

| System | During Partition (P) | Else (E) | Implication |
|--------|---------------------|----------|-------------|
| DynamoDB (default) | AP | EL | Available during partition; async replication with configurable lag |
| Cassandra (QUORUM) | CP | CL | Quorum reads/writes are consistent even during partition; higher latency |
| MongoDB (majority) | CP | CL | Majority reads/writes are linearizable; replication lag on secondaries |
| etcd | CP | CL | Strongly consistent always; ~50-100ms write latency for 3-node cluster |

## Alternatives

- **Single-node with failover** — avoid CAP entirely by running on a single node with a hot standby. During failover, there is brief unavailability (seconds), but no partition dilemma. Appropriate for systems that can tolerate minutes of downtime.
- **Sharded single-consistency-domain** — shard data so that each shard is a single consistency domain (e.g., all data for user X lives on one shard). CAP applies *within* each shard, not across the system. This is how many large-scale systems operate.
- **Compensating transactions** — accept AP behavior during writes, then run compensating transactions to fix inconsistencies. Used in [[SagaPattern]] for distributed transactions.
- **CRDTs (Conflict-free Replicated Data Types)** — mathematical structures that converge automatically without conflict resolution. Used by Riak, Redis Enterprise, and collaborative editing systems. Avoids the reconciliation problem entirely.

## Failure Modes

1. **Assuming your database's default mode matches your requirements** — DynamoDB defaults to eventual consistency (AP), but if you're building a payment system, you need `ConsistentRead: true` (CP behavior). A real incident: an e-commerce platform used eventual consistency for inventory checks, causing overselling during traffic spikes because concurrent reads returned stale stock counts. Always verify consistency settings match your domain requirements.

2. **Partition lasts longer than reconciliation window** — AP systems reconcile data when the partition heals, but if the partition persists longer than your data's TTL or your reconciliation process's capacity, data is permanently lost. Example: Cassandra's hinted handoff has a default TTL of 3 hours. If a partition lasts 4 hours, hints expire and writes are lost. Mitigation: set hint TTL to exceed your maximum expected partition duration, or accept the data loss in your SLO.

3. **Split-brain in CP systems with even node counts** — a 2-node CP cluster cannot tolerate any partition (1 node is not a majority). A 4-node cluster also cannot tolerate a 2-vs-2 split (no majority). Always use odd node counts (3, 5, 7) for CP quorum-based systems. The rule: tolerate F failures requires 2F+1 nodes.

4. **Silent consistency degradation under load** — many databases degrade from strong to eventual consistency under high load without explicit indication. MongoDB secondaries fall behind during heavy writes, and reads directed to secondaries (for load balancing) return stale data. The application assumes strong consistency but gets eventual consistency under load. Mitigation: use explicit read/write concerns, monitor replication lag, and alert when lag exceeds your consistency tolerance.

5. **Client-side caching invalidates CAP guarantees** — even with a CP database, if your application caches data in Redis or an in-process LRU cache, you have introduced AP behavior at the application layer. The database is consistent, but the client reads stale cached data. This is the most common source of "CAP is wrong" complaints. Mitigation: treat cache consistency as a first-class design decision. Use cache invalidation strategies (TTL, write-through, pub/sub invalidation) that match your domain's consistency requirements.

6. **Cross-region partitions masked by BGP anycast or DNS** — a global DNS outage or BGP route leak can make one region unreachable from another, creating a partition that is invisible to your application (requests timeout rather than fail fast). Your CP database times out after 30s, causing cascading failures in upstream services. Mitigation: implement client-side timeouts that are shorter than your database timeout, use circuit breakers ([[CircuitBreaker]]) to fail fast, and test partition scenarios with chaos engineering ([[ChaosEngineering]]).

7. **Reconciliation conflicts produce business-invalid states** — after a partition heals, two nodes accepted conflicting writes for the same entity. Last-write-wins picks a winner, but the winning value may be business-invalid (e.g., both sides decremented inventory below zero). The system is technically consistent after reconciliation, but the data is wrong. Mitigation: implement application-level conflict resolution (not just timestamp-based), use version vectors for causal ordering, and design operations that are safe under concurrent execution (commutative, idempotent).

8. **CAP misapplied to non-replicated systems** — engineers invoke CAP to justify inconsistencies in systems that do not replicate data. If your service writes to a single PostgreSQL instance with no replicas, there is no CAP tradeoff. The inconsistency is a bug, not a theorem. CAP applies only when state is replicated across nodes that can be partitioned.

## Real-World Decision Framework

When designing a new service, answer these questions:

1. **What is the business impact of serving stale data?**
   - Financial harm (double-spend, oversell) → CP required
   - UX degradation (stale feed, old profile photo) → AP acceptable
   - Security risk (stale ACL, expired token) → CP required

2. **What is the business impact of returning errors?**
   - Lost revenue (checkout fails) → AP preferred
   - Data corruption prevented → CP preferred
   - Retryable operation (idempotent read) → CP acceptable

3. **What is your expected partition frequency and duration?**
   - Single AZ, rare partitions (< 1/year) → CAP matters less, optimize for normal operation
   - Multi-AZ, occasional partitions (monthly) → design for both modes explicitly
   - Multi-region, frequent partitions (weekly) → AP is the only viable choice

4. **Can different operations have different CAP choices?**
   - Yes. Reads can be AP (eventually consistent) while writes are CP (strongly consistent).
   - DynamoDB supports this via `ConsistentRead` parameter per operation.
   - Cassandra supports this via consistency level per query (`ONE`, `QUORUM`, `ALL`).

## Best Practices

1. **Decide per-operation, not per-system** — use your database's tunable consistency to choose CP or AP per operation. Read your user's profile with eventual consistency (AP). Process their payment with strong consistency (CP).
2. **Document your consistency model explicitly** — write it in the service's design doc. "This service uses eventual consistency for reads and strong consistency for writes." This prevents future engineers from assuming strong consistency and writing buggy code.
3. **Test partition scenarios in staging** — use network partition simulation (tc netem, AWS Fault Injection Simulator, toxiproxy) to verify your system behaves as designed when partitions occur. Do not wait for production to discover your assumptions were wrong.
4. **Monitor replication lag as a first-class SLO** — if you run AP, replication lag *is* your staleness metric. Track p99 replication lag and alert when it exceeds your business tolerance.
5. **Prefer causal consistency over eventual consistency when possible** — causal consistency (reads see causally related writes in order) is weaker than strong consistency but stronger than eventual consistency. It matches most application requirements better than either extreme.
6. **Understand your database's actual guarantees** — "eventual consistency" is a category, not a specification. What is the expected convergence time? What happens to writes during a partition? How are conflicts resolved? Read the database documentation, do not assume.
7. **Design for partition recovery, not just partition detection** — detecting a partition is easy. Recovering from it — reconciling divergent state, replaying missed writes, resolving conflicts — is where systems fail. Invest more engineering effort in recovery than in detection.

## Related Topics

- [[Consistency]] — deeper treatment of consistency models (linearizable, sequential, causal, eventual)
- [[DistributedSystems]] — foundational concepts for distributed architecture
- [[DistributedTransactions]] — handling transactions across consistency boundaries
- [[SagaPattern]] — compensating transactions for AP-style distributed operations
- [[EventualConsistency]] — the consistency model used by AP systems
- [[Resilience]] — designing systems that withstand partitions and failures
- [[CircuitBreaker]] — fail-fast mechanism to handle partitioned dependencies
- [[Replication]] — the mechanism that creates CAP tradeoffs
- [[ChaosEngineering]] — testing partition scenarios proactively
- [[Monitoring]] and [[Observability]] — detecting and measuring partition behavior
- [[Databases]] — database selection through the CAP lens
- [[Consensus]] — how CP systems achieve agreement (Raft, Paxos)
- [[Monoliths]] — single-node systems that avoid CAP tradeoffs (at the cost of scalability)
- [[Microservices]] — where CAP tradeoffs become unavoidable
