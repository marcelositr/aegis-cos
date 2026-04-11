---
title: LoadBalancing
title_pt: Balanceamento de Carga
layer: network
type: concept
priority: high
version: 1.0.0
tags:
  - Network
  - LoadBalancing
  - Infrastructure
description: Distributing traffic across multiple servers for scalability.
description_pt: Distribuindo tráfego entre múltiplos servidores para escalabilidade.
prerequisites:
  - Network
  - DistributedSystems
estimated_read_time: 10 min
difficulty: intermediate
---

# Load Balancing

## Description

[[LoadBalancing]] distributes incoming traffic across multiple servers to ensure no single server becomes overwhelmed, improving reliability and scalability.

Key concepts:
- **Algorithms** — How traffic is distributed
- **Health checks** — Monitoring server availability
- **Session affinity** — Directing same user to same server
- **Layer 4 vs Layer 7** — Network vs Application level

## Algorithms

### Round Robin

```python
# Simple rotation
class RoundRobin:
    def __init__(self, servers):
        self.servers = servers
        self.index = 0
    
    def get_server(self):
        server = self.servers[self.index]
        self.index = (self.index + 1) % len(self.servers)
        return server
```

### Least Connections

```python
# Send to server with fewest active connections
class LeastConnections:
    def __init__(self, servers):
        self.servers = {s: 0 for s in servers}
    
    def get_server(self):
        server = min(self.servers, key=self.servers.get)
        self.servers[server] += 1
        return server
    
    def release(self, server):
        self.servers[server] -= 1
```

### Weighted

```python
# More requests to powerful servers
class Weighted:
    def __init__(self, servers_with_weights):
        self.servers = []
        for server, weight in servers_with_weights:
            self.servers.extend([server] * weight)
    
    def get_server(self):
        return random.choice(self.servers)
```

## Purpose

**When load balancing is essential:**
- High-traffic applications
- Achieving high availability
- Scaling horizontally
- Handling failures gracefully

**When simpler approaches work:**
- Low-traffic applications
- Single server deployments
- When cost is primary concern

**The key question:** Can your single server handle peak traffic, or do you need distribution?

## Failure Modes

- **Server overload** → All requests sent to one server → service degraded → use weighted least connections
- **Health check failure** → Dead server stays in pool → failed requests → improve health check sensitivity
- **Session loss** → User sent to different server → lost session state → use session affinity or external session store
- **Load balancer failure** → Single point of failure → entire system down → use multiple load balancers

## Anti-Patterns

### 1. No Health Checks

**Bad:** Sending traffic to dead servers
```python
# Always round robin regardless of health
def get_server():
    return servers[current_index % len(servers)]
```

**Good:** Check server health
```python
def get_server():
    for _ in servers:
        server = next_server()
        if is_healthy(server):
            return server
    return None  # No healthy server
```

### 2. Sticky Sessions Everywhere

**Bad:** All traffic to one server
```python
# User always goes to same server
def get_server(user_id):
    return hash(user_id) % len(servers)
```

**Good:** Balance with affinity
```python
# Most requests balanced, some affinity
def get_server(request):
    if needs_affinity(request):
        return get_sticky_server(request)
    return least_connected_server()
```

## Best Practices

### 1. Use Layer 7 for App Awareness

```
Layer 4 (TCP): Fast, simple
└── Use for: Non-HTTP traffic, raw performance

Layer 7 (HTTP): Smart routing
└── Use for: HTTP traffic, path-based routing, headers
```

### 2. Monitor and Alert

```python
# Track health
metrics.gauge("active_servers", healthy_count)
metrics.gauge("requests_per_second", rps)
metrics.gauge("latency_ms", avg_latency)
```

## Related Topics

- [[DistributedSystems]] — Scale and reliability
- [[Kubernetes]] — K8s load balancing
- [[CircuitBreaker]] — Handle failures
- [[AutoScaling]] — Scale based on load

## Key Takeaways

- Distributes traffic across multiple servers
- Algorithms: Round Robin, Least Connections, Weighted
- Health checks prevent sending to dead servers
- Layer 4 for speed, Layer 7 for smart routing
- Use multiple load balancers for HA