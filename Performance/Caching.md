---
title: Caching
title_pt: Cache
layer: performance
type: concept
priority: high
version: 1.0.0
tags:
  - Performance
  - Caching
  - Storage
description: Techniques for storing frequently accessed data to reduce latency.
description_pt: Técnicas para armazenar dados frequentemente acessados para reduzir latência.
prerequisites:
  - PerformanceOptimization
  - DatabaseOptimization
estimated_read_time: 10 min
difficulty: intermediate
---

# Caching

## Description

[[Caching]] stores frequently accessed data in fast storage to avoid recomputation or repeated database queries. A cache acts as a layer between your application and the data source.

Key concepts:
- **Hit rate** — Percentage of requests served from cache
- **TTL (Time to Live)** — How long cached data is valid
- **Invalidation** — Removing stale data from cache
- **Eviction** — Removing data when cache is full

## Cache Types

### In-Memory Cache

```python
from functools import lru_cache
import time

# In-memory with TTL
class TTLCache:
    def __init__(self, ttl_seconds=60):
        self.cache = {}
        self.ttl = ttl_seconds
    
    def get(self, key):
        if key in self.cache:
            value, timestamp = self.cache[key]
            if time.time() - timestamp < self.ttl:
                return value
            del self.cache[key]
        return None
    
    def set(self, key, value):
        self.cache[key] = (value, time.time())

# Using LRU cache
@lru_cache(maxsize=1000)
def get_user(user_id):
    return database.query(f"SELECT * FROM users WHERE id = {user_id}")
```

### Distributed Cache

```python
import redis

# Redis cache
redis_client = redis.Redis(host='localhost', port=6379, db=0)

def get_user_cached(user_id):
    # Try cache first
    cached = redis_client.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)
    
    # Fetch from database
    user = database.query("SELECT * FROM users WHERE id = ?", user_id)
    
    # Store in cache
    redis_client.setex(
        f"user:{user_id}",
        300,  # 5 minute TTL
        json.dumps(user)
    )
    return user
```

## Purpose

**When caching is essential:**
- Repeated database queries
- Expensive computations
- Static or slowly changing data
- API responses that don't change often

**When caching adds unnecessary complexity:**
- Data that changes frequently
- Unique per-request data
- Small datasets that fit in memory
- When consistency is critical

**The key question:** Can you tolerate stale data, and is the performance gain worth the complexity?

## Failure Modes

- **Stale data served** → Cache has old data → users see outdated information → use appropriate TTL and invalidation
- **Cache miss storm** → All requests miss cache → database overwhelmed → use cache warming and gradual expiration
- **Cache invalidation failure** → Stale data persists → system shows wrong state → implement reliable invalidation
- **Memory exhaustion** → Cache grows unbounded → OOM crash → set size limits and eviction policies
- **Hot keys** → Single key accessed excessively → single point of contention → distribute keys, replicate hot data
- **Cache penetration** → Non-existent keys queried → database hit every request → use bloom filters or negative caching

## Anti-Patterns

### 1. No Invalidation Strategy

**Bad:** Cache never expires
```python
# Data becomes permanently stale
cache.set(key, value)  # No TTL!
```

**Good:** TTL with invalidation
```python
# Time-based expiration
cache.setex(key, 300, value)  # 5 minute TTL
```

### 2. Caching Everything

**Bad:** Cache unique data
```python
# Cache user-specific data
cache.set(f"user_{user_id}_dashboard", data)  # Almost every user unique!
```

**Good:** Cache shared data
```python
# Cache shared data
cache.set("featured_products", products)  # Same for all users
```

### 3. Not Handling Cache Miss

**Bad:** Synchronous wait on miss
```python
# All requests wait for same expensive computation
def get_data():
    cached = cache.get("key")
    if cached:
        return cached
    return expensive_compute()
```

**Good:** Prevent cache stampede
```python
import threading

# Only one computation per key
def get_data():
    if key in computing:
        return wait_for_completion(key)
    
    cached = cache.get("key")
    if cached:
        return cached
    
    computing.add(key)
    try:
        result = expensive_compute()
        cache.set("key", result)
        return result
    finally:
        computing.remove(key)
```

## Best Practices

### 1. Choose Cache Level

```
Cache Hierarchy:
├── L1: In-process (fastest, limited size)
├── L2: Redis/Memcached (network, larger)
└── L3: CDN (edge, static content)
```

### 2. Measure Effectiveness

```python
# Track cache metrics
cache_hits = 0
cache_misses = 0

def get_cached(key):
    global cache_hits, cache_misses
    result = cache.get(key)
    if result:
        cache_hits += 1
    else:
        cache_misses += 1
    
    hit_rate = cache_hits / (cache_hits + cache_misses)
    print(f"Cache hit rate: {hit_rate:.2%}")
    return result
```

### 3. Use Appropriate Strategy

| Data Type | Strategy | TTL |
|-----------|----------|-----|
| User profiles | Write-through | 5-15 min |
| Product catalog | Lazy loading | 30-60 min |
| Session data | LRU | 1-24 hours |
| Static config | Write-once | 1-24 hours |
| Counters | Write-behind | 1-5 min |

## Related Topics

- [[DatabaseOptimization]] — Where caching applies
- [[Databases/Caching]] — Database-level caching (query cache, buffer pool)
- [[Redis]] — Common cache implementation
- [[NoSQL]] — Cache-aside pattern
- [[LoadTesting]] — Testing cache behavior
- [[PerformanceOptimization]] — Overall performance

## Key Takeaways

- Caching reduces latency by storing frequently accessed data
- Choose TTL based on how often data changes
- Implement cache invalidation for data updates
- Prevent cache stampede with locking or gradual expiration
- Monitor hit rate to validate cache effectiveness
- Use multi-level caching: L1 in-memory, L2 Redis, L3 CDN