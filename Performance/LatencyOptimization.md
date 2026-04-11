---
title: LatencyOptimization
title_pt: Otimização de Latência
layer: performance
type: concept
priority: high
version: 1.0.0
tags:
  - Performance
  - Latency
  - Optimization
description: Reducing response time and tail latency.
description_pt: Reduzindo tempo de resposta e latência de cauda.
prerequisites:
  - PerformanceOptimization
  - PerformanceProfiling
estimated_read_time: 10 min
difficulty: intermediate
---

# Latency Optimization

## Description

[[LatencyOptimization]] focuses on reducing response times, especially at percentile levels (P50, P95, P99). While throughput matters, latency affects user experience directly.

Key concepts:
- **P50 (Median)** — Typical request time
- **P95** — 5% of requests slower than this
- **P99** — 1% of requests slowest (tail latency)
- **Tail latency** — Worst-case responses

## Purpose

**When latency optimization matters:**
- User-facing applications
- Real-time systems
- API services with SLAs
- Any latency-sensitive operation

**When to focus elsewhere:**
- Batch processing
- Background jobs
- When throughput is the bottleneck

**The key question:** How fast does your 99th percentile request complete?

## Latency Sources

### Network Latency

```python
# Bad: Sequential requests
def get_user_data(user_id):
    user = http.get(f"/users/{user_id}")      # 100ms
    orders = http.get(f"/users/{user_id}/orders")  # 150ms
    posts = http.get(f"/users/{user_id}/posts")    # 120ms
    return {"user": user, "orders": orders, "posts": posts}  # Total: 370ms

# Good: Concurrent requests
import asyncio

async def get_user_data(user_id):
    user, orders, posts = await asyncio.gather(
        http.get(f"/users/{user_id}"),
        http.get(f"/users/{user_id}/orders"),
        http.get(f"/users/{user_id}/posts")
    )
    return {"user": user, "orders": orders, "posts": posts}  # Total: ~150ms
```

### Database Latency

```python
# Bad: N+1 queries
for user in users:
    orders = db.query(f"SELECT * FROM orders WHERE user_id = {user.id}")  # N+1!

# Good: JOIN or batch
orders = db.query("SELECT * FROM orders WHERE user_id IN (?)", [u.id for u in users])
```

## Failure Modes

- **Tail latency** → Slow requests degrade experience → use timeouts and graceful degradation
- **Latency spikes** → Occasional slow requests → identify and optimize bottlenecks
- **Connection pool starvation** → Waiting for connections → increase pool or reduce concurrency
- **Database lock contention** → Slow queries block others → optimize queries and isolation levels

## Anti-Patterns

### 1. Ignoring Percentiles

**Bad:** Only optimize average
```python
# Only looking at mean
avg = sum(latencies) / len(latencies)
# Misses P99 problems!
```

**Good:** Monitor percentiles
```python
# Track P50, P95, P99
latencies.sort()
p50 = latencies[int(len(latencies) * 0.50)]
p95 = latencies[int(len(latencies) * 0.95)]
p99 = latencies[int(len(latencies) * 0.99)]
```

### 2. Synchronous Everything

**Bad:** Blocking calls throughout
```python
def process(request):
    user = get_user_sync(request.user_id)      # Blocks
    items = get_items_sync(user.items)        # Blocks more
    notify = send_notification_sync(user)     # Blocks more
    return {"user": user, "items": items}
```

**Good:** Async where beneficial
```python
async def process(request):
    user, items, _ = await asyncio.gather(
        get_user(request.user_id),
        get_items(user.items),
        send_notification(user)  # Fire and forget
    )
    return {"user": user, "items": items}
```

### 3. No Timeouts

**Bad:** Infinite waits
```python
# Will wait forever on slow service
result = http.get(url)  # No timeout!
```

**Good:** Set timeouts
```python
# Fail fast
try:
    result = await asyncio.wait_for(http.get(url), timeout=5)
except asyncio.TimeoutError:
    return fallback()
```

## Best Practices

### 1. Set Latency Targets

```
Latency SLAs:
├── P50 < 100ms: Fast interactions
├── P95 < 500ms: Acceptable for most
├── P99 < 1s: Rare slow requests OK
└── P99 > 2s: Unacceptable, investigate
```

### 2. Use Timeouts at Every Layer

```python
# Timeout chain
http_client = TimeoutClient(total=5, connect=2)
database = Pool(timeout=3)
cache = Cache(timeout=1)

# Each layer has deadline
```

### 3. Degrade Gracefully

```python
# If slow, return cached or partial
async def get_dashboard():
    try:
        user = await asyncio.wait_for(get_user(), timeout=1)
    except asyncio.TimeoutError:
        user = cache.get("user")  # Stale is better than nothing
    
    try:
        orders = await asyncio.wait_for(get_orders(), timeout=1)
    except asyncio.TimeoutError:
        orders = []  # Partial is OK
    
    return {"user": user, "orders": orders}
```

## Related Topics

- [[PerformanceOptimization]] — Overall performance
- [[PerformanceProfiling]] — Finding latency sources
- [[ConnectionPooling]] — Database connection latency
- [[Caching]] — Reduce latency with cache
- [[AsyncIO]] — Concurrent operations

## Key Takeaways

- Focus on P99 (tail latency), not just averages
- Identify latency contributors: network, DB, computation
- Use concurrent requests to reduce total latency
- Set timeouts at every layer to prevent blocking
- Monitor percentiles in production
- Degrade gracefully when latency targets can't be met