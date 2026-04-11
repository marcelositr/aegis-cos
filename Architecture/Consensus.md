---
title: Consensus
title_pt: Consenso
layer: architecture
type: concept
priority: critical
version: 1.0.0
tags:
  - Architecture
  - DistributedSystems
  - Consensus
description: Algorithms for reaching agreement in distributed systems.
description_pt: Algoritmos para alcançar consenso em sistemas distribuídos.
prerequisites:
  - DistributedSystems
  - Concurrency
estimated_read_time: 15 min
difficulty: advanced
---

# Consensus

## Description

[[Consensus]] is the fundamental problem of getting multiple nodes in a distributed system to agree on a single value or state. Without consensus, systems cannot reliably coordinate, replicate data, or make coordinated decisions.

The consensus problem requires:
- **Agreement**: All non-faulty nodes decide on the same value
- **Validity**: The decided value must have been proposed by some node
- **Termination**: Every non-faulty node eventually decides

## Purpose

**When consensus is essential:**
- Distributed databases replicating data across nodes
- Leadership election (picking a coordinator)
- Distributed locking systems
- State machine replication
- Blockchain and cryptocurrencies

**When simpler approaches work:**
- Single-node systems
- Eventually consistent systems (AP)
- Systems that can tolerate inconsistency
- Read-heavy workloads with conflict resolution

**The key question:** Can your system tolerate divergent state, or must all nodes agree exactly?

## Algorithms

### Raft

Raft is a consensus algorithm designed to be understandable. It uses:
- **Leader**: One node leads the consensus process
- **Term**: Logical time periods to detect stale leaders
- **Log**: Append-only replicated command log

```go
// Raft Leader Election
type RaftNode struct {
    term        int
    votedFor    int
    state       State // Follower, Candidate, Leader
    log         []LogEntry
}

func (n *RaftNode) RequestVote(candidateId, candidateTerm, lastLogIndex, lastLogTerm int) VoteResponse {
    if candidateTerm > n.term {
        n.becomeFollower(candidateTerm)
    }
    
    if n.votedFor == -1 || n.votedFor == candidateId {
        if lastLogTerm >= n.lastLogTerm && lastLogIndex >= n.lastLogIndex {
            n.votedFor = candidateId
            return VoteResponse{n.term, true}
        }
    }
    return VoteResponse{n.term, false}
}

func (n *RaftNode) becomeLeader() {
    n.state = Leader
    n.term++
    // Send AppendEntries to all followers
    for _, peer := range n.peers {
        go n.sendAppendEntries(peer)
    }
}
```

### Paxos

Paxos is the original consensus algorithm. More complex but equally correct:

```python
# Paxos Proposer
class Proposer:
    def __init__(self):
        self.proposal_id = None
        self.value = None
        
    def prepare(self):
        self.proposal_id = (time.time(), self.node_id)
        for acceptor in acceptors:
            promise = acceptor.promise(self.proposal_id)
            if promise.accepted_value:
                # Choose value with highest proposal_id
                self.value = max(promise.accepted_value, key=lambda x: x.id)
    
    def accept(self):
        for acceptor in acceptors:
            if not acceptor.accept(self.proposal_id, self.value):
                # Retry with higher proposal_id
                self.prepare()
                break
```

## Failure Modes

- **Split-brain** → Network partition separates nodes into groups → each group elects its own leader → conflicting state → prevent with majority quorums
- **Stale leader** → Network partition isolates leader → followers elect new leader → two leaders → use term/version to detect and reject stale
- **Log inconsistency** → Leader crashes before replicating → followers have divergent logs → use log matching property
- **Byzantine failures** → Node behaves arbitrarily (malicious or buggy) → incorrect decisions → use PBFT or other Byzantine-tolerant algorithms
- **Majority failure** → More than half nodes fail → consensus impossible → design for appropriate failure threshold
- **Long election** → Leader crash with many candidates → election timeout delays → use randomized timeouts
- **Disk failure** → Consensus log corruption → cannot recover state → use replicated logs or Raft with snapshots

## Anti-Patterns

### 1. Ignoring Quorum

**Bad:** Writing to single node
```python
# Single point of failure
db.write(key, value)
```

**Good:** Majority quorum
```python
# Requires majority to confirm
for node in majority_nodes:
    node.write(key, value)
```

### 2. Not Handling Partitions

**Bad:** Assuming network always works
```python
# Will hang during partition
result = wait_for(all_nodes)
```

**Good:** Timeout and fallback
```python
try:
    result = wait_for(majority, timeout=5s)
except TimeoutError:
    return fallback()
```

### 3. Using Consensus for Everything

**Bad:** Consensus for high-frequency operations
```python
# Too slow for every request
for each_user_action:
    consensus_vote(action)
```

**Good:** Consensus only for critical state
```
- Leader election: consensus
- Configuration changes: consensus
- Regular requests: direct to leader
```

## Best Practices

### 1. Use Proven Implementations

```go
// Use etcd, Consul, or similar
// Don't implement your own consensus
client, _ := etcd.New(etcd.Config{
    Endpoints: []string{"localhost:2379"},
})
```

### 2. Monitor Leadership

```go
// Alert on leadership changes
func (n *RaftNode) becomeLeader() {
    metrics.Inc("leadership_changes_total")
    alert.PagerDuty("New leader elected")
}
```

### 3. Snapshot State

```go
// Prevent unbounded log growth
if n.log.len() > 10000 {
    snapshot := n.writeSnapshot()
    n.log = n.log[snapshot.index:]
    n.saveSnapshot(snapshot)
}
```

### 4. Plan for Failures

```
Consensus Design Decisions:
├── Failure tolerance: How many nodes can fail?
├── Recovery time: How long to recover?
├── Consistency level: Strong vs eventual
└── Performance: Latency vs safety
```

## Technology Stack

| Implementation | Language | Use Case |
|----------------|----------|----------|
| etcd | Go | Kubernetes, Service Discovery |
| Consul | Go | Service Mesh, Key-Value |
| CockroachDB | Go | Distributed SQL |
| TiKV | Rust | Distributed KV Store |
| ZooKeeper | Java | Legacy coordination |

## Related Topics

- [[DistributedSystems]] — Systems requiring consensus
- [[Microservices]] — Service coordination
- [[EventSourcing]] — Replicated event logs
- [[CircuitBreaker]] — Failover patterns
- [[MessageQueues]] — Async communication

## Key Takeaways

- Consensus ensures all nodes agree on state despite failures
- Raft is understandable; Paxos is correct but complex
- Use majority quorums to prevent split-brain
- Implementations like etcd solve the hard problems
- Don't over-use consensus; reserve for critical state
- Monitor leadership changes and respond to partitions
- Consider CAP tradeoffs: consensus = strong consistency