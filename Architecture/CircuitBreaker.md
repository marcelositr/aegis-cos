---
title: Circuit Breaker
title_pt: Circuit Breaker
layer: architecture
type: pattern
priority: high
version: 1.0.0
tags:
  - Architecture
  - Resilience
  - DistributedSystems
  - Pattern
description: Pattern for preventing cascading failures by stopping requests to failing services.
description_pt: Padrão para prevenir falhas em cascata parando requisições para serviços com falha.
prerequisites:
  - Distributed Systems
  - Microservices
estimated_read_time: 12 min
difficulty: advanced
---

# Circuit Breaker

## Description

The Circuit Breaker pattern prevents cascading failures by wrapping a protected function call in a circuit breaker object that monitors for failures. When failures exceed a threshold, the circuit "opens" and subsequent calls fail immediately without attempting the operation, giving the failing service time to recover.

States:
- **Closed** — Normal operation, requests pass through
- **Open** — Failure threshold exceeded, requests fail immediately (fast-fail)
- **Half-Open** — Testing if service recovered, limited requests allowed

Related resilience patterns:
- **Bulkhead** — Isolating resources so one failure doesn't consume all capacity
- **Retry** — Automatically retrying failed operations with backoff
- **Timeout** — Failing fast when operations take too long
- **Fallback** — Providing alternative response when primary fails

## Purpose

**When circuit breakers are essential:**
- Microservices calling other services
- External API dependencies
- Database connections under load
- Any synchronous dependency that can fail
- Systems where cascading failure is a risk

**When circuit breakers add unnecessary complexity:**
- Single-service applications
- Idempotent operations with instant retry
- When the dependency is guaranteed (same process)

**The key question:** If this dependency fails, will it take down my entire service?

## States and Transitions

```
                    Failure threshold
   CLOSED ──────────────────────────────► OPEN
     ▲                                      │
     │                                  Timeout expires
     │                                      │
     │                                      ▼
     │                                 HALF-OPEN
     │                                      │
     │                              ┌───────┴───────┐
     │                              │               │
     │                         Success          Failure
     │                              │               │
     └──────────────────────────────┘               │
                                                    ▼
                                                 OPEN (reset)
```

## Implementation

```python
import time
from enum import Enum
from typing import Callable, Any

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(
        self,
        failure_threshold: int = 5,
        recovery_timeout: float = 60.0,
        half_open_max_calls: int = 1
    ):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.half_open_max_calls = half_open_max_calls
        
        self.failure_count = 0
        self.state = CircuitState.CLOSED
        self.last_failure_time = 0
        self.half_open_calls = 0
    
    def call(self, func: Callable, *args, **kwargs) -> Any:
        if self.state == CircuitState.OPEN:
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = CircuitState.HALF_OPEN
                self.half_open_calls = 0
            else:
                raise CircuitBreakerOpenError("Circuit is open")
        
        if self.state == CircuitState.HALF_OPEN:
            if self.half_open_calls >= self.half_open_max_calls:
                raise CircuitBreakerOpenError("Circuit is half-open, max calls reached")
            self.half_open_calls += 1
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise
    
    def _on_success(self):
        self.failure_count = 0
        self.state = CircuitState.CLOSED
        self.half_open_calls = 0
    
    def _on_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN

class CircuitBreakerOpenError(Exception):
    pass

# Usage with fallback
breaker = CircuitBreaker(failure_threshold=3, recovery_timeout=30)

def get_user_from_service(user_id):
    return user_api.get(user_id)

def get_cached_user(user_id):
    return cache.get(f"user:{user_id}")

def get_user(user_id):
    try:
        return breaker.call(get_user_from_service, user_id)
    except CircuitBreakerOpenError:
        return get_cached_user(user_id)  # Fallback
    except Exception:
        return get_cached_user(user_id)  # Other errors → fallback
```

## Anti-Patterns

### 1. No Fallback

**Bad:** Circuit opens → requests fail → user sees error
**Solution:** Provide cached data, default response, or queue for later

### 2. Wrong Threshold

**Bad:** Threshold too low → circuit opens on transient failures
**Solution:** Base threshold on normal failure rate, not zero

### 3. No Monitoring

**Bad:** Circuit opens silently → no one knows → degraded service goes unnoticed
**Solution:** Emit metrics on state changes, alert on prolonged open state

### 4. Ignoring Half-Open

**Bad:** Half-open allows all traffic → service gets hammered again
**Solution:** Limit half-open calls, gradually increase

### 5. Circuit Breaker on Everything

**Bad:** Adding circuit breakers to local function calls
**Solution:** Only use for external/network dependencies

## Best Practices

1. **Always pair with fallback** — open circuit without fallback = failed requests
2. **Monitor state changes** — alert when circuit stays open too long
3. **Tune thresholds per dependency** — not one-size-fits-all
4. **Combine with retry + timeout** — circuit breaker alone isn't enough
5. **Test circuit behavior** — chaos engineering to verify resilience
6. **Log state transitions** — debugging requires visibility into circuit state

## Failure Modes

- **Circuit never opens** → threshold too high → cascading failure still happens
- **Circuit opens too easily** → threshold too low → unnecessary failures
- **Half-open storms** → multiple instances all try recovery simultaneously → stampede
- **No fallback** → circuit opens → all requests fail → user-facing outage
- **State not shared** → in distributed systems, each instance has own circuit → inconsistent behavior

## Related Topics

- [[DistributedSystems]] — Circuit breakers for distributed service communication
- [[Microservices]] — Essential pattern for service-to-service calls
- [[Idempotency]] — Retry patterns require idempotent operations
- [[RateLimiting]] — Complementary: rate limiting prevents overload, circuit breaker stops failures
- [[MessageQueues]] — Async alternative to sync calls that need circuit breakers
- [[Observability]] — Monitoring circuit state and transitions
- [[ChaosEngineering]] — Testing circuit breaker behavior
- [[BulkheadPattern]] — Isolating resources to limit blast radius
- [[RetryPattern]] — Combining retry with circuit breaker and backoff

## Key Takeaways

- The Circuit Breaker pattern prevents cascading failures by monitoring failures and fast-failing requests when a threshold is exceeded, giving the failing service time to recover.
- Use for microservices calling other services, external API dependencies, database connections under load, or any synchronous dependency that can fail.
- Do NOT use for single-service applications, idempotent operations with instant retry, or when the dependency is guaranteed within the same process.
- Key tradeoff: preventing cascading failures and improving resilience vs. added complexity in tuning thresholds and managing fallback logic.
- Main failure mode: circuit opens without a fallback, causing all requests to fail and creating a user-facing outage instead of graceful degradation.
- Best practice: always pair with a fallback (cached data, default response, or queued request), tune thresholds per dependency, and monitor state transitions.
- Related concepts: Bulkhead Pattern, Retry with Backoff, Timeout, Fallback, Microservices, Chaos Engineering, Rate Limiting.
