---
title: Leader Election
title_pt: Eleição de Líder
layer: architecture
type: concept
priority: critical
version: 1.0.0
id: core.arch.leaderelection.v1
tags:
  - Architecture
  - LeaderElection
  - Consensus
  - DistributedSystems
  - Resilience
keywords:
  - leader election
  - primary selection
  - raft
  - bully algorithm
  - lease
  - fencing token
  - split-brain
  - distributed coordination
description: Algorithm by which a group of nodes in a distributed system selects one node as coordinator/leader to manage shared resources, coordinate writes, or act as primary.
---

# Leader Election

## Description

In a distributed system, **leader election** is the process of selecting a single node from a group to act as the coordinator. The leader is responsible for tasks that require coordination: serializing writes, managing leases, scheduling jobs, or acting as the primary replica.

**Why it matters:** Without a leader, nodes may make conflicting decisions (split-brain), waste resources duplicating work, or deadlock waiting for coordination that never happens.

**Key properties:**
- **Safety:** At most one leader exists at any time
- **Liveness:** Eventually, a leader is elected (if a quorum is alive)
- **Fault tolerance:** If the leader fails, a new leader is elected

## Purpose

**When leader election is required:**
- Primary-replica databases (single writer, multiple readers)
- Distributed job schedulers (exactly-one execution)
- Distributed locks and leases
- Configuration management (single source of truth)
- Message queue brokers (single active broker per partition)
- Any system where "only one should write at a time"

**When leader election is NOT needed:**
- Fully peer-to-peer systems (gossip protocols, DHTs)
- Stateless services (any node handles any request)
- Multi-primary/active-active systems with conflict resolution
- Single-node systems (trivially the leader)

**The key question:** Does this system require a single decision-maker, or can all nodes act independently?

## Tradeoffs

| Algorithm | Nodes Required | Fault Tolerance | Complexity | Best For |
|-----------|---------------|-----------------|------------|----------|
| **Bully** | Any | N-1 failures | Simple | Small clusters, teaching |
| **Raft** | 2f+1 (majority) | f failures | Medium | Production systems (etcd, Consul, TiKV) |
| **Paxos** | 2f+1 (majority) | f failures | High | Theoretical foundation, Google Chubby |
| **ZAB** (ZooKeeper) | 2f+1 | f failures | Medium | ZooKeeper ecosystems |
| **Lease-based** | Coordinator + storage | Coordinator failure | Simple | Cloud environments (DynamoDB, Redis) |
| **Ring-based** | Any ring subset | Ring-dependent | Medium | Consistent hashing with primaries |

## Alternatives

- **Gossip protocols** — eventual consistency without a leader (Cassandra, Riak)
- **Distributed consensus without explicit leader** — Multi-Paxos variant with rotating leaders
- **External coordination service** — offload to etcd, ZooKeeper, Consul instead of implementing
- **Lease from cloud provider** — DynamoDB conditional writes, Redis SET NX, GCP Spanner leader election

## How Leader Election Works (Raft)

```
1. All nodes start as FOLLOWERS
2. If follower receives no heartbeat within election timeout → becomes CANDIDATE
3. CANDIDATE increments term, votes for self, sends RequestVote to all nodes
4. If CANDIDATE receives majority of votes → becomes LEADER
5. LEADER sends heartbeats (AppendEntries) to all followers
6. If LEADER receives heartbeat from higher-term leader → steps down to FOLLOWER
7. If no candidate wins majority → new election with randomized timeout
```

### Lease-Based Leader Election (Simple Cloud Pattern)

```python
import redis
import time
import threading

class LeaseBasedLeader:
    """Simple leader election using Redis leases."""

    def __init__(self, redis_client: redis.Redis, lease_key: str, node_id: str, ttl: int = 10):
        self.redis = redis_client
        self.lease_key = lease_key
        self.node_id = node_id
        self.ttl = ttl
        self.is_leader = False

    def try_acquire_lease(self) -> bool:
        """Try to become leader using SET NX (set if not exists)."""
        # SET NX: only set if key doesn't exist (no current leader)
        acquired = self.redis.set(self.lease_key, self.node_id, nx=True, ex=self.ttl)
        if acquired:
            self.is_leader = True
            return True

        # Key exists — check if current leader is this node (renewal)
        current_leader = self.redis.get(self.lease_key)
        if current_leader and current_leader.decode() == self.node_id:
            self.redis.expire(self.lease_key, self.ttl)  # Renew
            self.is_leader = True
            return True

        self.is_leader = False
        return False

    def run_leader_loop(self):
        """Continuously try to acquire/renew leadership."""
        while True:
            if self.try_acquire_lease():
                if self.is_leader:
                    self._do_leader_work()
            else:
                self._do_follower_work()
            time.sleep(self.ttl / 3)  # Check 3x per TTL

    def _do_leader_work(self):
        print(f"[{self.node_id}] I am the leader")
        # Perform leader-exclusive work here

    def _do_follower_work(self):
        print(f"[{self.node_id}] I am a follower, leader is {self.redis.get(self.lease_key)}")
```

### etcd-Based Leader Election (Production)

```python
import etcd3
import time

class EtcdLeaderElection:
    """Production leader election using etcd leases and transactions."""

    def __init__(self, etcd: etcd3.Etcd3Client, election_key: str, node_id: str):
        self.etcd = etcd
        self.election_key = election_key
        self.node_id = node_id
        self.lease = None

    def campaign(self) -> bool:
        """Attempt to become leader. Returns True if elected."""
        # Create a short-lived lease
        self.lease = self.etcd.lease(ttl=10)

        # Transaction: set key only if it doesn't exist (Compare version == 0)
        success, _ = self.etcd.transaction(
            compare=[self.etcd.transactions.version(self.election_key) == 0],
            success=[self.etcd.transactions.put(self.election_key, self.node_id, lease=self.lease)],
            failure=[]
        )

        if success:
            # Start automatic lease refresh
            self.lease.refresh()
            return True

        return False

    def resign(self):
        """Voluntarily give up leadership."""
        if self.lease:
            self.etcd.delete(self.election_key)
            self.lease.revoke()
```

## Failure Modes

- **Split-brain (two leaders)** → conflicting writes, data corruption → requires quorum-based election (Raft, Paxos), never use simple "first to write wins" without fencing
- **Leader not detected** → old leader's lease not expired → new leader elected but old leader still thinks it's leader → use fencing tokens, reject requests with old term
- **Election livelock** → two nodes repeatedly tie in election → randomized election timeouts (Raft uses 150-300ms random), break symmetry
- **Lease too short** → leader spends all time renewing, not working → balance TTL with work interval (3-5x work duration)
- **Lease too long** → dead leader holds lock for extended period → slow failover → use short TTL with frequent refresh
- **Network partition isolates leader** → followers elect new leader, old leader still accepting writes → use fencing: new leader increments term, old leader's writes rejected by storage
- **Clock skew affecting leases** → leader's clock faster than followers → lease expires prematurely → use monotonically increasing terms, not wall clocks
- **Storage layer accepts old leader writes** → no fencing → data corruption → storage must reject writes with term < current term
- **All nodes crash simultaneously** → no leader, system stalled → require quorum to recover, manual intervention if < quorum survive
- **Byzantine leader** → leader sends conflicting messages to different nodes → Raft/Paxos don't handle Byzantine faults → need PBFT or blockchain-style consensus for adversarial environments

## Anti-Patterns

### 1. File-Based "Lock" as Leadership

**Bad:** Leader creates a file `/tmp/leader.lock`, followers check if it exists
**Why it's bad:** No atomicity, no lease, no detection of dead leader → two nodes can both think they're leader
**Good:** Use atomic compare-and-swap (Redis SET NX, etcd transaction, ZooKeeper ephemeral nodes)

### 2. No Fencing Token

**Bad:** New leader elected but old leader still writes to storage
**Why it's bad:** Data corruption — old and new leader both write, last-write-wins arbitrarily
**Good:** Every write includes the leader's term/fencing token — storage rejects writes with stale tokens

### 3. Hardcoded Primary

**Bad:** Node 1 is always the leader, others are standby
**Why it's bad:** Node 1 failure = total leader failure → no automatic recovery
**Good:** Dynamic election — any node can become leader if the current one fails

## Best Practices

1. **Use existing libraries** — etcd, Consul, ZooKeeper — don't implement leader election from scratch
2. **Always use fencing tokens** — leader's term must be included in every write, storage rejects stale terms
3. **Randomize election timeouts** — prevent livelock from simultaneous elections
4. **Require quorum** — majority-based election tolerates f failures with 2f+1 nodes
5. **Monitor leadership changes** — alert on frequent leadership changes (indicates instability)
6. **Log leadership transitions** — include old leader, new leader, term, timestamp
7. **Test leader failover** — kill leader during writes, verify no data loss, no split-brain
8. **Use ephemeral nodes/leases** — automatically released when leader crashes (not explicit delete)
9. **Validate term monotonicity** — terms must only increase, never decrease
10. **Design for leadership absence** — system should be safe (not necessarily available) without a leader

## Related Topics

- [[Consensus]] — Raft, Paxos algorithms
- [[DistributedSystems]] — Distributed system fundamentals
- [[CAPTheorem]] — Consistency vs availability during partitions
- [[Resilience]] — Fault tolerance patterns
- [[StateMachines]] — Replicated state machines
- [[CircuitBreaker]] — Handling leader unavailability