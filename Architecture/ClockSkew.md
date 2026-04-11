---
title: Clock Skew
title_pt: Desvio de Relógio e Ordenação Distribuída
layer: architecture
type: concept
priority: critical
version: 1.0.0
id: core.arch.clockskew.v1
tags:
  - Architecture
  - ClockSkew
  - DistributedSystems
  - Consensus
  - Ordering
keywords:
  - clock skew
  - Lamport clock
  - vector clock
  - hybrid logical clock
  - NTP
  - clock drift
  - causal ordering
  - TrueTime
  - last writer wins
  - monotonic clock
description: The phenomenon where clocks on different machines in a distributed system diverge, making it impossible to determine the true ordering of events. Logical clocks (Lamport, Vector) provide ordering without physical time.
---

# Clock Skew

## Description

In a distributed system, **clock skew** is the difference between the clocks of two nodes. No two physical clocks are perfectly synchronized, and the divergence grows over time due to clock drift.

This matters because many distributed algorithms rely on ordering: "Did operation A happen before B?" With clock skew, comparing wall-clock timestamps across nodes is unreliable.

**Sources of clock divergence:**
- **Clock drift** — Crystal oscillators run at slightly different rates (±50 ppm typical)
- **NTP inaccuracy** — Network delay variance makes NTP correction imprecise (±1-10ms on LAN, ±100ms on WAN)
- **Leap seconds** — Clocks jump or repeat a second → non-monotonic time
- **Clock synchronization** — NTP daemon adjusts clock gradually; during adjustment, time is inconsistent

**Consequences:**
- "Last writer wins" with wall-clock timestamps → data loss when clocks diverge
- Lease expiration miscalculation → two nodes think they hold the same lease
- Certificate validity windows → cert appears "not yet valid" or "expired"
- Log correlation across services → incorrect debugging timeline

## Purpose

**When clock skew is a critical concern:**
- Distributed databases with "last writer wins" conflict resolution
- Lease-based leader election and distributed locks
- Certificate validation and token expiration
- Cross-service log correlation and tracing
- Any system using timestamps for ordering or causality

**When you can ignore clock skew:**
- Single-node systems
- Systems that don't use timestamps for ordering
- Systems using logical clocks instead of wall clocks

**The key question:** Am I using wall-clock timestamps to order events across nodes? If yes, clock skew will cause bugs.

## Logical Clocks

### Lamport Clocks

A Lamport clock is a monotonically increasing counter that establishes a **partial order** of events:

```
Rules:
1. Before each event, increment local counter
2. Include counter value in every message sent
3. On receiving message with counter T: local_counter = max(local_counter, T) + 1

Property: if A → B (A happens-before B), then clock(A) < clock(B)
Counter-property NOT true: clock(A) < clock(B) does NOT imply A → B
```

```python
class LamportClock:
    def __init__(self):
        self.counter = 0

    def tick(self) -> int:
        """Internal event."""
        self.counter += 1
        return self.counter

    def send(self) -> int:
        """Send a message — return timestamp to include."""
        self.counter += 1
        return self.counter

    def receive(self, remote_ts: int) -> int:
        """Receive a message with remote timestamp."""
        self.counter = max(self.counter, remote_ts) + 1
        return self.counter

# Example:
# Node A: tick → 1, send → 2 (message to B with ts=2)
# Node B: receive(ts=2) → max(0, 2) + 1 = 3, tick → 4
# We know A's send (ts=2) → B's receive (ts=3) — causal order preserved
```

### Vector Clocks

Vector clocks establish a **causal order** by maintaining a vector of counters — one per node:

```
Rules:
1. Each node maintains a vector of N counters (one per node)
2. Before internal event: increment own counter
3. On send: increment own counter, include full vector in message
4. On receive with vector V: element-wise max(local, V), then increment own

Comparison:
- VC(A) < VC(B) if all elements ≤ and at least one <  →  A → B (causally before)
- VC(A) || VC(B) (incomparable)  →  concurrent events
```

```python
from typing import Dict

class VectorClock:
    def __init__(self, node_id: str, all_nodes: list[str]):
        self.node_id = node_id
        self.clock = {n: 0 for n in all_nodes}

    def tick(self):
        self.clock[self.node_id] += 1

    def send(self) -> Dict[str, int]:
        self.tick()
        return dict(self.clock)

    def receive(self, remote_vc: Dict[str, int]):
        for node, ts in remote_vc.items():
            self.clock[node] = max(self.clock.get(node, 0), ts)
        self.tick()

    @staticmethod
    def happens_before(vc1: Dict[str, int], vc2: Dict[str, int]) -> str:
        """Returns 'before', 'after', 'concurrent', or 'equal'."""
        all_nodes = set(vc1.keys()) | set(vc2.keys())
        leq = all(vc1.get(n, 0) <= vc2.get(n, 0) for n in all_nodes)
        geq = all(vc1.get(n, 0) >= vc2.get(n, 0) for n in all_nodes)
        if leq and geq: return 'equal'
        if leq: return 'before'
        if geq: return 'after'
        return 'concurrent'

# Example:
# Node A sends to B, then independently B sends to C
# A's vc: {A:1, B:0, C:0}
# B receives from A: {A:1, B:1, C:0}, then B sends: {A:1, B:2, C:0}
# C's event (independent): {A:0, B:0, C:1}
# Compare B's send vs C's event: concurrent (neither happened-before the other)
```

### Hybrid Logical Clocks (HLC)

HLCs combine physical time with logical ordering — useful when you want timestamps close to wall-clock time but with causal ordering guarantees:

```
HLC = (physical_time, logical_counter, node_id)

On event:
  pt = current physical time
  if pt > last.pt:
      last.pt = pt; last.lc = 0
  else:
      last.lc += 1
  return (last.pt, last.lc, node_id)

Comparison: primarily by physical time, then by logical counter, then by node ID
→ Provides total order that's "close to" wall-clock time
```

## Tradeoffs

| Approach | Ordering Strength | Physical Time Proximity | Message Overhead | Best For |
|----------|------------------|------------------------|------------------|----------|
| **Wall clock (NTP-synced)** | None (unreliable) | Exact | None | Logging, monitoring |
| **Lamport clock** | Partial order | No relationship | Counter in every message | Causal ordering without vector overhead |
| **Vector clock** | Causal order | No relationship | N counters per message (N = nodes) | Conflict detection, CRDTs |
| **Hybrid logical clock** | Total order | Close to physical | Counter in every message | Distributed databases, last-writer-wins |
| **TrueTime (Google Spanner)** | Total order with bounded uncertainty | Bounded window (±7ms) | Hardware (GPS + atomic clocks) | Externally consistent transactions |

## Alternatives

- **Lease-based ordering** — Use a consensus service (etcd, ZooKeeper) for ordering instead of clocks
- **Sequence numbers from coordinator** — Single source of monotonically increasing IDs
- **Version vectors** — Extension of vector clocks for multi-value keys (Dynamo-style)
- **TrueTime API** — Google Spanner's hardware-assisted clock (not available externally)

## Mitigating Clock Skew

### NTP Best Practices

```bash
# Use multiple NTP servers (at least 3-4)
# Prefer local stratum-1 servers for lower latency
# Monitor offset continuously

# Check current offset
ntpq -p
chronyc tracking

# Alert if offset exceeds threshold (typically 100ms)
# In production, use chrony (better than ntpd for VMs)

# Linux: prevent non-monotonic time
# Don't use step adjustment in production (causes time jumps)
# Use slew mode (gradual adjustment)
```

### Clock Skew Detection

```python
import time
import requests

def detect_clock_skew(servers: list[str], threshold_ms: float = 500) -> dict:
    """Detect clock skew by comparing round-trip-adjusted timestamps."""
    local_time = time.time()
    results = {}

    for server in servers:
        start = time.time()
        resp = requests.get(f"https://{server}/api/time", timeout=5)
        end = time.time()
        rtt = (end - start) * 1000  # Round-trip time in ms
        remote_time = resp.json()['timestamp']

        # Estimated server time at midpoint of RTT
        estimated_remote_at_midpoint = remote_time + (rtt / 2)
        local_at_midpoint = (start + end) / 2
        skew_ms = (estimated_remote_at_midpoint - local_at_midpoint) * 1000

        results[server] = {
            'skew_ms': skew_ms,
            'rtt_ms': rtt,
            'alert': abs(skew_ms) > threshold_ms
        }

    return results
```

## Failure Modes

- **Last-writer-wins with wall clocks** → node with fast clock overwrites data from node with slow clock → silent data loss → use vector clocks or HLCs for conflict resolution
- **Lease expiration with skewed clock** → node thinks lease expired, acquires it → two leaders → use fencing tokens from consensus service, not timestamps
- **Certificate validity window** → cert appears "not yet valid" because node clock is behind → use NTP with multiple sources, monitor offset
- **Token expiration miscalculation** → JWT issued with `exp` based on skewed clock → token rejected or accepted too long → use server clock for validation, not client clock
- **Log correlation impossible** → events across services appear in wrong order → can't debug distributed failures → use distributed tracing with span IDs, not timestamps
- **NTP step adjustment** → clock jumps backward → time-based algorithms break → use slew mode, not step mode, in production
- **Leap second** → 61st second repeats → event processing duplicates or stalls → smear leap seconds (Google's approach), or use clock that handles leap seconds
- **VM clock drift** — suspended/resumed VM has stale clock → large offset from reality → use hypervisor clock sync, monitor offset aggressively
- **Assuming monotonic time** — `time.time()` can go backward on some systems → use monotonic clock (`time.monotonic()` in Python, `System.nanoTime()` in Java) for measuring durations
- **Cross-datacenter clock skew** — DCs in different regions have different NTP paths → inter-DC skew of 100ms+ → don't use wall clocks for cross-DC ordering

## Anti-Patterns

### 1. Using Wall Clock for Causal Ordering

**Bad:** "Event A has timestamp 10:00:01, event B has 10:00:02, so A happened before B"
**Why it's bad:** Clock skew means the timestamps are on different clocks — B could have happened first on a node with a slower clock
**Good:** Use Lamport clocks, vector clocks, or a coordinator for ordering

### 2. time.time() for Timeout Calculation

**Bad:** `deadline = time.time() + 30; while time.time() < deadline: ...`
**Why it's bad:** If clock jumps backward (NTP adjustment), the loop runs longer than expected; if forward, shorter
**Good:** Use monotonic clock: `deadline = time.monotonic() + 30`

## Best Practices

1. **Never use wall clocks for ordering** — use logical clocks (Lamport, vector, HLC)
2. **Use monotonic clocks for durations** — `time.monotonic()`, `System.nanoTime()`, `std::chrono::steady_clock`
3. **Monitor clock offset continuously** — alert if offset exceeds 100ms
4. **Use multiple NTP sources** — at least 3-4 servers for redundancy
5. **Prefer chrony over ntpd** — better for VMs, faster convergence
6. **Use fencing tokens from consensus** — not timestamps, for distributed locks
7. **Include node ID with timestamps** — enables debugging when skew occurs
8. **Design for clock skew** — assume up to 500ms skew between datacenters
9. **Use HLCs for databases** — close to wall-clock time with causal guarantees
10. **Test with simulated skew** — inject clock offsets in CI to verify resilience

## Related Topics

- [[DistributedSystems]] — Distributed system fundamentals
- [[Consensus]] — Ordering through consensus
- [[StateMachines]] — Replicated state machines and ordering
- [[LeaderElection]] — Leader election affected by clock skew
- [[Tracing]] — Distributed tracing as alternative to timestamp-based correlation
- [[Consistency]] — Consistency guarantees requiring ordering
- [[Partitioning]] — Partition-level ordering challenges