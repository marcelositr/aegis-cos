---
title: Caching
title_pt: Cache
layer: databases
type: concept
priority: medium
version: 1.0.0
tags:
  - Databases
  - Caching
  - Performance
  - Concept
description: Caching strategies to improve application performance.
description_pt: Estratégias de cache para melhorar o desempenho da aplicação.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Caching

## Description

Caching is the practice of storing frequently accessed data in a faster storage layer to reduce latency and decrease load on primary data sources. Effective caching can dramatically improve application performance by serving data from memory rather than executing expensive database queries or API calls.

Caching strategies vary based on:
- **Cache location** - Client, CDN, server, database
- **Cache invalidation** - When to remove stale data
- **Cache scope** - Per-request, per-user, global
- **Consistency requirements** - Staleness tolerance

Common caching layers:
- **Browser cache** - Client-side
- **CDN** - Edge caching for static assets
- **Application cache** - In-memory (Redis, Memcached)
- **Database cache** - Query result caching

Key metrics:
- **Hit rate** - Percentage of requests served from cache
- **Latency** - Time to serve from cache vs source
- **Memory usage** - Cache size and eviction

## Purpose

**When caching is valuable:**
- For frequently accessed data
- For expensive computations
- For static content
- For read-heavy workloads

**What to cache:**
- User profiles
- Configurations
- Aggregated data
- API responses
- Session data

## Rules

1. **Cache appropriately** - Not everything needs caching
2. **Set TTL** - Define expiration times
3. **Handle misses** - What to do when not cached
4. **Invalidate correctly** - Remove when data changes
5. **Monitor hit rates** - Track cache effectiveness

## Examples

### Redis Cache Pattern

```python
# Python with Redis
import json
import redis
from functools import wraps

redis_client = redis.Redis(host='localhost', port=6379, db=0)

def cache_result(prefix, ttl=300):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Generate cache key
            cache_key = f"{prefix}:{args}:{kwargs}"
            
            # Try to get from cache
            cached = redis_client.get(cache_key)
            if cached:
                return json.loads(cached)
            
            # If not cached, compute and store
            result = func(*args, **kwargs)
            redis_client.setex(
                cache_key,
                ttl,
                json.dumps(result)
            )
            return result
        return wrapper
    return decorator

@cache_result('user_profile', ttl=600)
def get_user_profile(user_id):
    # Database query
    return db.query('SELECT * FROM users WHERE id = ?', user_id)

# Invalidate cache when data changes
def update_user(user_id, data):
    db.update('UPDATE users SET ... WHERE id = ?', user_id)
    redis_client.delete(f'user_profile:({user_id}):{{}}')
```

### Cache-Aside Pattern

```python
# Cache-Aside (Lazy Loading)
def get_product(product_id):
    # 1. Check cache first
    cache_key = f"product:{product_id}"
    product = redis.get(cache_key)
    
    if product:
        return json.loads(product)
    
    # 2. Cache miss - get from database
    product = db.get_product(product_id)
    
    if product:
        # 3. Store in cache
        redis.setex(cache_key, 3600, json.dumps(product))
    
    return product

def update_product(product_id, data):
    # 1. Update database
    db.update_product(product_id, data)
    
    # 2. Invalidate cache
    redis.delete(f"product:{product_id}")
```

### Write-Through Pattern

```python
# Write-Through - write to both cache and DB
def save_order(order):
    # 1. Write to cache first
    cache_key = f"order:{order.id}"
    redis.set(cache_key, json.dumps(order))
    
    # 2. Also write to database
    db.save_order(order)
    
    return order

def get_order(order_id):
    # Read from cache
    cache_key = f"order:{order_id}"
    cached = redis.get(cache_key)
    
    if cached:
        return json.loads(cached)
    
    # Fall back to database
    return db.get_order(order_id)
```

### Distributed Cache with Fallback

```python
# Multi-layer cache
class CacheService:
    def __init__(self):
        self.local_cache = {}  # In-process LRU
        self.redis = redis.Redis()
        self.max_local = 1000
    
    def get(self, key):
        # 1. Check local cache
        if key in self.local_cache:
            return self.local_cache[key]
        
        # 2. Check Redis
        value = self.redis.get(key)
        if value:
            # Populate local cache
            self.local_cache[key] = value
            # Check size and evict if needed
            if len(self.local_cache) > self.max_local:
                self.local_cache.pop(next(iter(self.local_cache)))
        
        return value
    
    def set(self, key, value, ttl=3600):
        self.local_cache[key] = value
        self.redis.setex(key, ttl, value)
    
    def invalidate(self, key):
        self.local_cache.pop(key, None)
        self.redis.delete(key)
```

### HTTP Cache Headers

```python
# Django response with cache headers
from django.http import JsonResponse

def user_profile(request, user_id):
    user = get_user(user_id)
    
    response = JsonResponse(user)
    
    # Cache for 5 minutes
    response['Cache-Control'] = 'public, max-age=300'
    
    # Conditional get support
    response['ETag'] = f'"{hash(user)}"'
    response['Last-Modified'] = user.updated_at
    
    return response

# Browser/CDN check
def conditional_get(request, data):
    etag = f'"{hash(data)}"'
    
    if request.headers.get('If-None-Match') == etag:
        return HttpResponse(status=304)
    
    response = JsonResponse(data)
    response['ETag'] = etag
    return response
```

## Anti-Patterns

### 1. No Invalidation Strategy

```python
# BAD - Data becomes stale
redis.set('product:123', product_data)  # Set once, never updated

# GOOD - Proper invalidation
def update_product(product_id, data):
    db.update(product_id, data)
    redis.delete(f'product:{product_id}')
```

### 2. Caching Too Much

```python
# BAD - Cache everything including sensitive data
redis.set('user:password:123', user_password)  # Never cache secrets!

# GOOD - Cache appropriately
redis.set('user_profile:123', {
    'name': user.name,
    'bio': user.bio
    # Don't include password or sensitive data
})
```

### 3. No TTL

```python
# BAD - No expiration - memory grows forever
redis.set('key', 'value')

# GOOD - Set appropriate TTL
redis.setex('key', 3600, 'value')  # 1 hour TTL
```

## Best Practices

### Cache Key Design

```python
# Good cache key patterns
cache_keys = {
    'user': 'user:{user_id}',
    'product': 'product:{product_id}',
    'list': 'products:list:{sort}:{page}',
    'session': 'session:{session_id}',
}

# Include version for easy invalidation
cache_key = f"user:{user_id}:v{schema_version}"
```

### Monitoring

```python
# Track cache metrics
def track_cache_access(operation, key, hit):
    metrics.increment(f'cache.{operation}.{"hit" if hit else "miss"}')
    metrics.gauge('cache.size', redis.dbsize())
```

## Failure Modes

- **No cache invalidation strategy** → cached data never updated → users see stale data indefinitely → implement TTL expiration and event-based invalidation for data changes
- **Caching sensitive data** → passwords, tokens, or PII stored in cache → data exposure if cache is compromised → never cache secrets or sensitive data; encrypt cached data if unavoidable
- **No TTL on cache entries** → cache entries persist forever → memory grows unbounded and stale data served → always set appropriate TTL based on data freshness requirements
- **Cache stampede on expiration** → many requests hit expired key simultaneously → database overload from concurrent misses → implement cache-aside with lock or probabilistic early expiration
- **Cache key collisions** → different data shares same cache key → wrong data returned to users → use structured cache keys with version prefixes and namespace separation
- **Inconsistent cache and database** → cache updated but database write fails → data inconsistency between layers → use write-through or write-behind patterns with proper error handling
- **Cache becoming single point of failure** → application depends entirely on cache → cache outage causes complete service failure → implement graceful degradation with database fallback when cache unavailable

## Technology Stack

| Tool | Use Case |
|------|----------|
| Redis | In-memory cache |
| Memcached | Simple key-value cache |
| Varnish | HTTP cache |
| CloudFront | CDN |
| local cache | In-process |

## Related Topics

- [[DatabaseOptimization]]
- [[PerformanceOptimization]]
- [[SQL]]
- [[NoSQL]]
- [[Redis]]
- [[LoadTesting]]
- [[Monitoring]]
- [[DataStructures]]

## Additional Notes

**Cache Strategies:**
- Cache-aside: Lazy loading
- Write-through: Synchronous
- Write-back: Async write

**Invalidation Methods:**
- TTL expiration
- Event-based
- Manual

**Key Metrics:**
- Hit rate (target > 90%)
- Latency reduction
- Memory usage