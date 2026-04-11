---
title: Rate Limiting
title_pt: Limitação de Taxa
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - API
  - Performance
  - Protection
description: Controlling request rates to protect services from overload and abuse.
description_pt: Controlando taxas de requisições para proteger serviços de sobrecarga e abuso.
prerequisites:
  - DistributedSystems
  - PerformanceOptimization
estimated_read_time: 8 min
difficulty: intermediate
---

# Rate Limiting

## Description

Rate limiting is the practice of restricting how many requests a client can make within a time window. It protects services from being overwhelmed by traffic, prevents abuse, ensures fair resource allocation, and helps manage costs.

## Purpose

**When rate limiting is essential:**
- Public APIs with usage tiers
- Protecting against DDoS attacks
- Preventing resource exhaustion from runaway clients
- Managing costs by limiting expensive operations
- Ensuring fair access across clients

**When rate limiting adds unnecessary complexity:**
- Internal services with trusted clients
- Low-traffic applications
- When other protections (circuit breakers, auto-scaling) suffice

**The key question:** What happens when 10x your normal traffic hits your service?

## Rules

1. **Set limits based on real capacity** - Not arbitrary numbers
2. **Return clear headers** - X-RateLimit-* for client awareness
3. **Use progressive limits** - Allow bursts but throttle sustained high traffic
4. **Apply limits at edge** - Closer to client = less resource waste
5. **Include retry-after info** - Help clients know when to retry

## Examples

### Token Bucket Algorithm

```python
import time
from threading import Lock

class TokenBucket:
    def __init__(self, capacity: int, refill_rate: float):
        self.capacity = capacity
        self.refill_rate = refill_rate  # tokens per second
        self.tokens = capacity
        self.last_refill = time.time()
        self.lock = Lock()
    
    def allow_request(self, tokens: int = 1) -> bool:
        with self.lock:
            self._refill()
            if self.tokens >= tokens:
                self.tokens -= tokens
                return True
            return False
    
    def _refill(self):
        now = time.time()
        elapsed = now - self.last_refill
        new_tokens = elapsed * self.refill_rate
        self.tokens = min(self.capacity, self.tokens + new_tokens)
        self.last_refill = now

# Usage: 100 requests per second, burst up to 200
bucket = TokenBucket(capacity=200, refill_rate=100)

for request in requests:
    if bucket.allow_request():
        process(request)
    else:
        return 429, {"retry_after": 1}
```

### Sliding Window Counter

```python
import time
from collections import defaultdict

class SlidingWindow:
    def __init__(self, max_requests: int, window_seconds: int):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests = defaultdict(list)
    
    def allow_request(self, client_id: str) -> bool:
        now = time.time()
        window_start = now - self.window_seconds
        
        # Remove old requests outside window
        self.requests[client_id] = [
            t for t in self.requests[client_id] 
            if t > window_start
        ]
        
        if len(self.requests[client_id]) < self.max_requests:
            self.requests[client_id].append(now)
            return True
        return False

# Usage
limiter = SlidingWindow(max_requests=100, window_seconds=60)
```

### Distributed Rate Limiting with Redis

```python
import redis
import time

class RedisRateLimiter:
    def __init__(self, redis_client, key: str, limit: int, window: int):
        self.redis = redis_client
        self.key = f"ratelimit:{key}"
        self.limit = limit
        self.window = window
    
    def allow_request(self) -> tuple[bool, dict]:
        now = time.time()
        window_start = now - self.window
        
        pipe = self.redis.pipeline()
        # Remove old entries
        pipe.zremrangebyscore(self.key, 0, window_start)
        # Count current requests
        pipe.zcard(self.key)
        # Add current request
        pipe.zadd(self.key, {str(now): now})
        # Set expiry
        pipe.expire(self.key, self.window)
        
        results = pipe.execute()
        current_count = results[1]
        
        if current_count >= self.limit:
            return False, {"retry_after": self.window}
        
        remaining = self.limit - current_count - 1
        reset_time = int(now + self.window)
        
        return True, {
            "x_ratelimit_limit": self.limit,
            "x_ratelimit_remaining": remaining,
            "x_ratelimit_reset": reset_time
        }

# Usage
redis_client = redis.Redis(host='localhost', port=6379)
limiter = RedisRateLimiter(redis_client, "api:v1", limit=100, window=60)

allowed, headers = limiter.allow_request()
if not allowed:
    return 429, headers
```

## Anti-Patterns

### 1. Single Limiter for All Endpoints

```python
# BAD - Same limit for cheap and expensive endpoints
rate_limit = RateLimiter(1000)  # requests per second

# All these share the same limit
GET /users       # cheap
POST /process    # expensive (CPU intensive)
GET /export      # expensive (generates large files)

# GOOD - Endpoint-specific limits
limits = {
    "/users": 1000,     # cheap, higher limit
    "/process": 10,    # expensive, lower limit
    "/export": 1,      # very expensive
}
```

### 2. No Graceful Degradation

```python
# BAD - Completely block when limit hit
if not limiter.allow_request():
    return 403  # Hard block

# GOOD - Progressive limits
if not limiter.allow_request():
    # Downgrade to cached response
    return get_cached_response() or 429
```

### 3. Hardcoding Limits

```python
# BAD - Don't guess limits
LIMIT = 1000  # Where did this number come from?

# GOOD - Measure and adjust
# Start with reasonable default, auto-tune based on capacity
LIMIT = calculate_from_capacity() * 0.8
```

## Best Practices

### HTTP Headers

```
X-RateLimit-Limit: 1000    # Max requests allowed
X-RateLimit-Remaining: 423 # Requests left in window
X-RateLimit-Reset: 1640000000 # Unix timestamp when limit resets
Retry-After: 30           # Seconds to wait before retry
```

### Strategy Selection

| Strategy | Use Case | Pros | Cons |
|----------|----------|------|------|
| Token Bucket | API throttling | Allows bursts | Complex tuning |
| Leaky Bucket | Smooth traffic | Predictable | No bursts |
| Sliding Window | Precise limits | Accurate | Higher memory |
| Fixed Window | Simple | Low memory | Burst at boundaries |

### Layered Defense

```python
# Rate limiting is one layer of defense
layers = [
    "CDN-level rate limiting",  # Block massive attacks
    "API Gateway limits",      # Per-client limits
    "Application-level",       # Per-user per-endpoint
    "Database connection pool" # Final protection
]
```

## Failure Modes

- **Rate limiter state loss on restart** → in-memory counters reset → burst of requests overwhelms service → use distributed rate limiting with Redis for counter state
- **Legitimate users blocked by aggressive limits** → rate limit set below actual usage patterns → customer complaints → analyze traffic patterns, implement tiered limits, and provide clear rate limit headers
- **Rate limit bypass through IP rotation** → attacker uses multiple IPs to exceed per-IP limits → protection ineffective → combine IP-based limits with account-based limits and behavioral analysis
- **Clock drift in distributed rate limiters** → different servers have different time windows → inconsistent rate enforcement → use centralized time source or sliding window algorithms
- **Rate limiting expensive endpoints same as cheap** → single limit applied to all endpoints → expensive operations exhaust resources → implement per-endpoint rate limits weighted by resource cost
- **No graceful degradation when limit hit** → hard 429 response with no fallback → complete service denial → serve cached responses or queue requests when limit exceeded
- **DDoS amplification through rate limit responses** → rate limiter generates large error responses → bandwidth consumption → keep rate limit responses minimal and implement connection-level limiting at edge

## Related Topics

- [[Architecture MOC]]
- [[ApiGateway]]
- [[Microservices]]
- [[CircuitBreaker]]
- [[PerformanceOptimization]]

## Key Takeaways

- Rate limiting restricts client request rates within time windows to protect services from overload, abuse, and resource exhaustion
- Essential for public APIs, DDoS protection, preventing runaway clients, and managing costs of expensive operations
- Avoid for internal trusted services, low-traffic applications, or when circuit breakers and auto-scaling suffice
- Tradeoff: service protection and fair access versus legitimate user blocking risk and added infrastructure complexity
- Main failure mode: single limiter applied to all endpoints allows expensive operations to exhaust resources while cheap ones are underutilized
- Best practice: set limits based on measured capacity, use per-endpoint weighted limits, implement distributed state with Redis, return clear rate limit headers, and provide graceful degradation
- Related: API gateway, microservices, circuit breaker, performance optimization

## Additional Notes

**Common Limits:**
- Public API: 60-1000 requests/minute
- Auth endpoints: 5-10 requests/minute (prevent brute force)
- Internal services: Based on actual capacity

**Always include:**
- Clear error messages
- Retry headers
- Documentation for API consumers
- Monitoring of limit triggers