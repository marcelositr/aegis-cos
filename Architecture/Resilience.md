---
title: Resilience
aliases:
  - Resilience
  - Resilience Patterns
  - Fault Tolerance
  - FaultTolerance
  - ResiliencePatterns
layer: architecture
type: concept
priority: critical
version: 1.0.0
tags:
  - Architecture
  - Resilience
  - Patterns
  - FaultTolerance
  - DistributedSystems
description: The ability of a system to absorb shocks, adapt to changing conditions, and continue operating correctly when components fail. Encompasses resilience patterns, fault tolerance, and graceful degradation.
prerequisites:
  - "[[DistributedSystems]]"
  - "[[ErrorHandling]]"
estimated_read_time: 10 min
difficulty: advanced
---

# Resilience

## Description

The ability of a system to absorb shocks, adapt to changing conditions, and continue operating correctly when one or more components fail. Resilience goes beyond fault tolerance — it includes graceful degradation, adaptive capacity, and recovery.

## Purpose

**When to use:**
- Distributed systems where component failures are inevitable
- Systems with availability requirements (99.9%+ uptime SLA)
- When cascading failures would cause business-critical outages
- Systems serving external customers where downtime has revenue impact

**When to avoid:**
- Internal tools with tolerant users who can retry
- Prototyping or MVP where speed of delivery outweighs availability
- Systems where data consistency is more important than availability (choose strong consistency over resilience patterns)

## Core Concepts

### Fault Tolerance vs Resilience

| Aspect | Fault Tolerance | Resilience |
|--------|----------------|------------|
| Goal | Continue operating despite failures | Absorb shock, adapt, and recover |
| Scope | Component-level | System-level |
| Approach | Redundancy, failover | Redundancy + adaptation + degradation |
| Example | RAID disk mirroring | Load shedding + circuit breaker + retry |

### Failure Domains

A failure domain is a boundary within which a failure is contained. Good architecture minimizes the size of failure domains.

- **Process** — single process crash (mitigated by supervisor/restart)
- **Node** — single server failure (mitigated by replication)
- **Availability Zone** — datacenter failure (mitigated by multi-AZ deployment)
- **Region** — geographic region failure (mitigated by multi-region deployment)
- **Provider** — cloud provider outage (mitigated by multi-cloud, rare and expensive)

## Resilience Patterns

### Circuit Breaker

Prevents cascading failures by failing fast when a dependency is unhealthy.

```python
import time
from enum import Enum
from threading import Lock

class CircuitState(Enum):
    CLOSED = "closed"       # Normal operation
    OPEN = "open"           # Failing, reject requests
    HALF_OPEN = "half_open" # Testing recovery

class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, recovery_timeout: float = 30.0):
        self._failure_threshold = failure_threshold
        self._recovery_timeout = recovery_timeout
        self._failure_count = 0
        self._state = CircuitState.CLOSED
        self._last_failure_time = 0
        self._lock = Lock()

    def execute(self, func, *args, **kwargs):
        with self._lock:
            if self._state == CircuitState.OPEN:
                if time.time() - self._last_failure_time > self._recovery_timeout:
                    self._state = CircuitState.HALF_OPEN
                else:
                    raise CircuitBreakerOpen("Circuit breaker is open")

        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise

    def _on_success(self):
        with self._lock:
            self._failure_count = 0
            self._state = CircuitState.CLOSED

    def _on_failure(self):
        with self._lock:
            self._failure_count += 1
            self._last_failure_time = time.time()
            if self._failure_count >= self._failure_threshold:
                self._state = CircuitState.OPEN

class CircuitBreakerOpen(Exception):
    pass
```

**States:** Closed (normal) → Open (failing fast) → Half-Open (testing recovery) → Closed (recovered)

**When to use:** External service calls, database connections, shared infrastructure
**When NOT to use:** Idempotent local operations, when retry alone suffices

### Bulkhead

Isolates resources into separate pools so failures in one pool don't cascade.

```python
from concurrent.futures import ThreadPoolExecutor
from typing import Dict

class BulkheadService:
    def __init__(self, max_workers_per_partition: int = 10):
        self._pools: Dict[str, ThreadPoolExecutor] = {}
        self._max_workers = max_workers_per_partition

    def execute(self, partition_id: str, task, timeout: float = 30.0):
        pool = self._get_or_create_pool(partition_id)
        try:
            return pool.submit(task).result(timeout=timeout)
        except Exception:
            return self._fallback(partition_id)

    def _get_or_create_pool(self, partition_id: str) -> ThreadPoolExecutor:
        if partition_id not in self._pools:
            self._pools[partition_id] = ThreadPoolExecutor(max_workers=self._max_workers)
        return self._pools[partition_id]

    def _fallback(self, partition_id: str):
        return {"status": "degraded", "partition": partition_id}
```

**When to use:** Multi-tenant systems, multiple external dependencies with different criticality
**When NOT to use:** Single-purpose systems, when resource overhead is prohibitive

### Retry with Backoff

Retries transient failures with increasing delays between attempts.

```python
import time
import random
from functools import wraps

def retry_with_backoff(max_retries: int = 3, base_delay: float = 1.0, max_delay: float = 60.0):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(max_retries + 1):
                try:
                    return func(*args, **kwargs)
                except (ConnectionError, TimeoutError) as e:
                    last_exception = e
                    if attempt == max_retries:
                        raise
                    # Exponential backoff with jitter
                    delay = min(base_delay * (2 ** attempt) + random.uniform(0, 1), max_delay)
                    time.sleep(delay)
            raise last_exception
        return wrapper
    return decorator
```

**Key rules:**
- Only retry **transient** failures (network timeouts, 503 errors)
- Never retry **non-transient** failures (400 errors, validation failures)
- Always use **exponential backoff with jitter** to prevent thundering herd
- Set a **maximum delay cap** to prevent indefinite waits

**When to use:** Network calls, database connections, external APIs
**When NOT to use:** Non-idempotent operations (unless deduplication is implemented), local function calls

### Timeout

Sets a maximum wait time for operations to complete, preventing resource exhaustion from hanging calls.

```python
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FuturesTimeout

def execute_with_timeout(func, timeout_seconds: float = 30.0, *args, **kwargs):
    with ThreadPoolExecutor(max_workers=1) as executor:
        future = executor.submit(func, *args, **kwargs)
        try:
            return future.result(timeout=timeout_seconds)
        except FuturesTimeout:
            future.cancel()
            raise TimeoutError(f"Operation exceeded {timeout_seconds}s timeout")
```

**When to use:** All external calls, database queries, network requests
**When NOT to use:** Long-running batch jobs (use async progress tracking instead)

### Graceful Degradation

When a dependency fails, provide a reduced but functional response rather than a complete failure.

```python
class ProductService:
    def get_product_with_fallback(self, product_id: str) -> dict:
        try:
            return self._fetch_from_cache(product_id)
        except CacheError:
            try:
                return self._fetch_from_database(product_id)
            except DatabaseError:
                # Graceful degradation: return stale data if available
                return self._fetch_stale_data(product_id) or {
                    "id": product_id,
                    "status": "unavailable",
                    "message": "Product information temporarily unavailable"
                }
```

**Degradation levels:**
1. Full functionality (normal)
2. Cached/stale data (slightly stale but usable)
3. Default values (reduced functionality)
4. Error message with retry guidance (minimal functionality)

**When to use:** User-facing features, non-critical data, recommendation systems
**When NOT to use:** Financial transactions, security checks, compliance-critical operations

## Rules

1. **Design for failure** — assume every dependency will fail eventually
2. **Minimize failure domains** — isolate components so one failure doesn't cascade
3. **Test failure paths** — chaos engineering, fault injection, game days
4. **Monitor leading indicators** — latency percentiles, error rates, saturation levels
5. **Implement defense in depth** — combine multiple patterns (circuit breaker + bulkhead + retry + timeout)

## Examples

### Good Example — Layered Resilience

```python
class ResilientExternalService:
    def __init__(self):
        self._circuit_breaker = CircuitBreaker(failure_threshold=5, recovery_timeout=30)
        self._bulkhead = BulkheadService(max_workers_per_partition=20)
        self._cache = LocalCache(ttl=300)

    def call_external_api(self, request: dict) -> dict:
        return self._bulkhead.execute(
            partition_id=request.get("tenant_id", "default"),
            task=lambda: self._execute_with_resilience(request)
        )

    def _execute_with_resilience(self, request: dict) -> dict:
        # Try cache first
        cache_key = self._build_cache_key(request)
        cached = self._cache.get(cache_key)
        if cached:
            return cached

        # Try circuit breaker + retry
        @retry_with_backoff(max_retries=3, base_delay=0.5)
        def api_call():
            return self._circuit_breaker.execute(
                self._make_api_request, request
            )

        try:
            result = api_call()
            self._cache.put(cache_key, result)
            return result
        except CircuitBreakerOpen:
            # Return stale cache if available
            stale = self._cache.get_stale(cache_key)
            if stale:
                return stale
            raise ServiceDegraded("Service temporarily unavailable")
        except Exception:
            raise

class ServiceDegraded(Exception):
    pass
```

### Bad Example — No Resilience

```python
class FragileService:
    def call_external_api(self, request: dict) -> dict:
        # No timeout — can hang indefinitely
        # No retry — single failure = complete failure
        # No circuit breaker — cascading failures
        # No bulkhead — one tenant can exhaust all resources
        # No fallback — no graceful degradation
        response = requests.post("https://api.external.com", json=request)
        return response.json()
```

**Why it's bad:** A single network timeout causes a complete failure. No retry for transient failures, no circuit breaker to prevent cascading failures, no bulkhead to isolate tenants, no fallback for graceful degradation.

## Anti-Patterns

### Untested Failure Paths

Implementing resilience patterns but never testing them against actual failures.

**Why it's bad:** Failure paths are the most complex and least tested code. They often have bugs that only manifest during real outages. Test with chaos engineering and fault injection.

### Pattern Conflicts

Applying resilience patterns without understanding interactions (e.g., retry + circuit breaker with wrong timeout causes retry storms).

**Why it's bad:** Retry before circuit breaker check wastes resources. Circuit breaker before bulkhead isolates nothing. Understand the order: bulkhead → timeout → retry → circuit breaker → fallback.

### Over-Engineering

Applying all resilience patterns to every component regardless of criticality.

**Why it's bad:** Complexity burden, maintenance cost, and debugging difficulty outweigh the reliability benefit for non-critical paths. Apply patterns based on failure impact analysis.

## Failure Modes

- **Single point of failure** → system outage when critical component fails without redundancy → implement redundancy at all layers, eliminate SPOFs during architecture review
- **Untested failure paths** → outages when failures occur in production only → chaos engineering, fault injection, game days, test failure scenarios in staging
- **Circuit breaker misconfiguration** → circuits open too frequently (false positives) or never open (defeated purpose) → tune thresholds based on actual failure rates, monitor circuit state transitions
- **Retry storms** → cascading retries overwhelm recovering services → use exponential backoff with jitter, implement retry budgets, add jitter to prevent synchronization
- **Bulkhead resource waste** → too many isolated pools exhaust available resources → balance isolation with resource availability, use dynamic pool sizing
- **Failover delays** → extended downtime during failover → test failover times regularly, use automatic failover, implement health checks
- **Split-brain scenarios** → data inconsistency when both sides of a partition think they're primary → use quorum-based decision making, implement fencing tokens
- **Silent failures** → undetected outages when errors swallowed → implement comprehensive monitoring, alert on error rate increases, use structured logging
- **Graceful degradation bypass** → complete outages when degradation modes untested → implement and test degradation modes, document degradation paths
- **Health check blind spots** → false health when checks miss critical dependencies → test health checks against actual failure modes, include dependency health in checks

## Best Practices

- **Combine patterns** — use circuit breaker + bulkhead + retry + timeout together for critical external dependencies
- **Test with chaos** — Netflix Simian Army, AWS Fault Injection Simulator, Gremlin
- **Monitor leading indicators** — latency (P50/P95/P99), error rate, saturation, traffic (USE/RED methods)
- **Document resilience topology** — architecture decision records, failure mode analysis diagrams
- **Implement progressive resilience** — start with timeouts (simplest), add retry, then circuit breaker, then bulkhead based on observed failure patterns
- **Design for degradation** — identify which features can degrade and how, implement fallbacks before they're needed
- **Conduct game days** — regularly test failure scenarios with the team, document learnings, update runbooks

## Related Topics

- [[DistributedSystems]]
- [[BulkheadPattern]]
- [[CircuitBreaker]]
- [[ErrorHandling]]
- [[RetryPattern]]
- [[ChaosEngineering]]
- [[DisasterRecovery]]
- [[Monitoring]]
- [[IncidentManagement]]

## Key Takeaways

- Resilience = absorb shock + adapt + recover, not just tolerate faults
- Design for failure as the normal case in distributed systems
- Combine patterns: bulkhead → timeout → retry → circuit breaker → fallback
- Test failure paths with chaos engineering — untested failure paths will fail in production
- Primary failure mode: single points of failure and cascading failures
- Monitor leading indicators (latency, error rate, saturation) not just availability
- Implement progressive resilience — add patterns based on observed failure impact
