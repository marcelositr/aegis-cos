---
title: Retry Pattern
layer: architecture
type: concept
priority: high
version: 2.0.0
tags:
  - Architecture
  - Resilience
  - Patterns
  - Reliability
  - DistributedSystems
description: Automatically retrying failed operations to handle transient faults, with exponential backoff, jitter, and proper idempotency guarantees.
---

# Retry Pattern

## Description

The retry pattern automatically re-executes failed operations when the failure is likely transient. It is the most commonly implemented — and most commonly misimplemented — resilience pattern in distributed systems.

A correct retry implementation requires three components:

1. **Transient fault detection** — distinguishing failures worth retrying (timeout, 503, connection reset) from failures that will never succeed with retry (400, 403, constraint violation)
2. **Backoff strategy** — controlling *when* to retry (immediate, fixed delay, exponential backoff, exponential backoff + jitter)
3. **Termination condition** — deciding *when to stop* retrying (max attempts, deadline exceeded, non-retryable error, circuit breaker open)

The critical insight: **retry is amplification**. Every retry multiplies load on the failing service. A naive retry policy during an outage turns a 1% failure rate into a 100% overload. Getting retry wrong does not just fail your service — it takes down the dependency you are trying to reach.

## When to Use

- **Network communication between services** — TCP connections reset, DNS resolution fails, TLS handshakes timeout. These are transient by nature. Retry with backoff is appropriate.
- **Database operations that encounter transient failures** — connection pool exhaustion, database failover (primary-replica switchover takes 1-3 seconds), lock timeouts. These resolve on their own within seconds.
- **External API calls returning 5xx errors** — 502 Bad Gateway, 503 Service Unavailable, 504 Gateway Timeout indicate the server is temporarily unable, not that the request is invalid.
- **Message publishing with at-least-once delivery** — message brokers (SQS, Kafka, RabbitMQ) may fail to acknowledge publishes. Retry until confirmed.
- **Health checks and readiness probes** — a service that just started may need 2-5 seconds to be ready. Retry the health check before declaring the service unhealthy.

## When NOT to Use

- **Non-idempotent write operations without deduplication** — retrying `POST /orders` without an idempotency key creates duplicate orders. See [[Idempotency]] for the required deduplication mechanism.
- **User authentication failures** — retrying a 401 or 403 will not change the outcome and creates a brute-force amplification vector. Fail immediately.
- **Validation failures (4xx errors)** — if the request was invalid, retrying the same request will fail the same way. Fix the request, do not retry it.
- **Downstream service in a known degraded state** — if the circuit breaker is open ([[CircuitBreaker]]), do not retry. The circuit breaker has already determined that retries are futile.
- **Batch operations where partial failure is acceptable** — if you're processing 10,000 records and 50 fail, retry the 50 failures individually. Do not retry the entire batch.
- **Operations with strict latency SLAs** — if your SLO is p99 < 200ms and each retry adds 500ms of latency, retrying will breach your SLO. Use the retry budget to limit retries.

## Tradeoffs

### Backoff Strategies

| Strategy | Delay Pattern | Pros | Cons | Use Case |
|----------|--------------|------|------|----------|
| **Immediate** | 0ms, 0ms, 0ms... | Fastest recovery if transient | Causes thundering herd; amplifies load | Health checks on localhost |
| **Fixed delay** | 1s, 1s, 1s... | Simple to implement | All clients retry simultaneously | Non-critical background sync |
| **Exponential backoff** | 1s, 2s, 4s, 8s, 16s... | Spreads retries over time | Synchronized clients still herd | Default for most service-to-service calls |
| **Exponential + jitter** | 1s±random, 2s±random, 4s±random... | Breaks synchronization; optimal for distributed clients | Slightly more complex | **Preferred for all production systems** |
| **Full jitter** (AWS algorithm) | random(0, base_delay * 2^attempt) | Maximum smoothing; bounded worst-case delay | Higher average latency than exponential | High-scale systems with many concurrent clients |

### The Jitter Necessity

Without jitter, all clients that failed at the same time retry at the same time. If 1,000 clients fail at T=0, they all retry at T=1s, all fail again, all retry at T=2s, etc. The downstream service sees a square wave of load — 0 requests, then 1,000 requests, then 0, then 1,000. This prevents recovery.

With jitter, the 1,000 retries are distributed across the backoff window. The downstream service sees a steady, manageable load that allows it to recover.

**Rule: always use jitter in production systems with more than one client.** The single-client case is the only scenario where jitter is unnecessary, and even then, it costs nothing to include.

### Retry Budgets

A retry budget limits the percentage of total requests that may be retries. Google SRE recommends: **retries should not exceed 10-20% of total request volume**. If retries exceed this budget, the system is amplifying load rather than recovering from transient failures.

Implementation: track a sliding window of total requests and retried requests. When retry percentage exceeds the budget, stop retrying and fail fast. This protects the downstream service from retry storms.

## Alternatives

- **Circuit breaker** ([[CircuitBreaker]]) — opens after repeated failures, preventing *any* requests (including retries) from reaching the failing service. Complementary to retry: use retry for individual transient failures, circuit breaker for systemic failures.
- **Bulkhead** ([[BulkheadPattern]]) — isolate retry traffic from normal traffic using separate connection pools. Prevents retries from consuming all resources and blocking new requests.
- **Timeout** — set a deadline and fail if not met, rather than retrying. Appropriate for operations where the result is time-sensitive (a response that arrives after the user has navigated away is useless).
- **Fallback / default value** — return a cached or default value instead of retrying. Appropriate for read operations where stale data is acceptable (product catalog, user preferences).
- **Queue-based retry** — enqueue failed requests for later processing instead of synchronous retry. Appropriate for non-urgent operations (email notifications, analytics events) where eventual success is sufficient.

## Failure Modes

1. **Retry storm (thundering herd)** — 10,000 concurrent clients experience a 500ms timeout, all retry simultaneously after 1s, the downstream service (which was recovering) is overwhelmed by the retry wave and fails again, causing another retry wave. This positive feedback loop causes total system collapse. Real incident: a CDN origin server recovered from a brief outage but was immediately taken down by synchronized retries from 50,000 edge nodes. The retry storm lasted 47 minutes and required a full CDN cache flush to break. Mitigation: **always use exponential backoff with jitter**, implement retry budgets, and coordinate retries across clients (randomize initial delay).

2. **Non-idempotent retry causes data duplication** — a payment service retries a `POST /charges` request after a timeout. The original request succeeded (the charge was created) but the response was lost. The retry creates a second charge. The customer is double-charged. Mitigation: **every retried write must have an idempotency key** — a unique identifier that the server uses to detect and deduplicate duplicate requests. The key is generated by the caller and sent as a header (`Idempotency-Key: req-abc123`). The server stores the key+result and returns the cached result on duplicate requests. See [[Idempotency]].

3. **Infinite retry loop on permanent errors** — retrying a 404 Not Found or 403 Forbidden indefinitely because the retry logic treats all errors as transient. The request loops forever, consuming resources and filling logs. Mitigation: **maintain an allowlist of retryable errors**, not a blocklist. Only retry errors you have positively identified as transient. Default behavior: fail immediately.

```typescript
// Good: allowlist of retryable errors
const RETRYABLE_STATUS_CODES = new Set([408, 429, 500, 502, 503, 504]);
const RETRYABLE_ERROR_CODES = new Set([
  "ECONNRESET",
  "ECONNREFUSED",
  "ETIMEDOUT",
  "EAI_AGAIN",
]);

function isRetryable(error: Error | { status: number }): boolean {
  if ("status" in error) {
    return RETRYABLE_STATUS_CODES.has(error.status);
  }
  if ("code" in error) {
    return RETRYABLE_ERROR_CODES.has(error.code);
  }
  return false; // Default: not retryable
}
```

4. **Retry amplifies partial outages into total outages** — Service A calls Service B (healthy) which calls Service C (degraded). Service B's requests to C timeout, so B retries. The retries consume B's connection pool, so A's requests to B also timeout. A retries. Now both A and B are at 100% CPU processing retries, and C is still degraded. A 10% degradation in C caused a 100% outage in A and B. Mitigation: implement retry budgets, set absolute retry limits, and use circuit breakers at each hop. The circuit breaker at B should open after C's failure rate exceeds a threshold, preventing A's retries from consuming B's resources.

5. **Backoff delay exceeds operation deadline** — a service has a 2-second end-to-end SLO. The retry policy is: 3 attempts with exponential backoff (1s, 2s, 4s). The first attempt takes 2s (timeout), the second retry starts at T+3s (already past the SLO), the third at T+6s. The retries are pointless because the result will arrive too late to be useful. Mitigation: **calculate retry deadlines from the original deadline, not from each attempt**. If the total deadline is 2s, the first attempt gets 1s, the second gets 0.5s, the third gets 0.25s. Or better: set a total retry deadline and cancel all retries when it expires.

```go
// Good: budget-aware retry with deadline
ctx, cancel := context.WithTimeout(ctx, 2*time.Second)
defer cancel()

backoff := retry.WithMaxRetries(5, retry.WithJitter(
    retry.ExponentialBackoff(100*time.Millisecond, 1*time.Second),
))

result, err := retry.Do(ctx, backoff, func(ctx context.Context) (*Result, error) {
    // Each attempt gets the remaining deadline from context
    return callService(ctx)
})
```

6. **Retry state is lost across process restarts** — an in-process retry counter or state machine is lost when the process restarts (deployment, crash, OOM kill). A retry that was on its 3rd attempt starts over from the 1st attempt, potentially exceeding the intended total retry count across the process lifetime. For operations that span hours (async job processing), this means operations are retried far more times than intended. Mitigation: persist retry state externally (database, message queue with delivery count, Redis counter) for operations that outlive a single process. For in-process retries, ensure the total wall-clock time (not just attempt count) is bounded.

7. **Missing observability hides retry behavior** — retries happen silently. The caller retries, the retry succeeds on attempt 3, and the operation returns success. From the outside, everything looks fine. But the downstream service is experiencing 3x the intended load. After weeks of silent retry amplification, a minor downstream degradation triggers a cascade that nobody can diagnose because there are no retry metrics. Mitigation: **emit metrics for every retry attempt**: retry count per operation, retry success rate, retry-induced error rate, and retry budget utilization. Create dashboards and alerts for retry budget exhaustion.

8. **Retrying with stale authentication tokens** — a service retries an API call with an expired OAuth token. Each retry returns 401. The retry logic treats 401 as non-retryable (correct), but the underlying issue is that the token expired during the operation. The operation fails permanently even though it would have succeeded with a refreshed token. Mitigation: implement token refresh before retry for authentication errors. Alternatively, catch 401, refresh the token, and retry exactly once (not as part of the normal retry loop).

## Real-World Implementation

### Production-grade retry with full jitter (AWS algorithm)

```python
import random
import time
from typing import Callable, TypeVar, Optional

T = TypeVar("T")

def calculate_full_jitter_backoff(
    base_delay_ms: int,
    max_delay_ms: int,
    attempt: int,
) -> float:
    """AWS Full Jitter algorithm."""
    exponential = base_delay_ms * (2 ** attempt)
    capped = min(exponential, max_delay_ms)
    return random.uniform(0, capped) / 1000.0  # Convert to seconds

def retry_with_backoff(
    fn: Callable[[], T],
    max_attempts: int = 5,
    base_delay_ms: int = 100,
    max_delay_ms: int = 30_000,
    retryable: Callable[[Exception], bool] = is_retryable,
    on_retry: Optional[Callable[[int, Exception, float], None]] = None,
) -> T:
    """
    Execute fn with exponential backoff and full jitter.

    Tracks: attempt number, error that caused retry, delay before retry.
    Respects: is_retryable predicate, max_attempts limit.
    """
    last_error: Optional[Exception] = None

    for attempt in range(max_attempts):
        try:
            return fn()
        except Exception as e:
            last_error = e
            if not retryable(e):
                raise  # Not retryable — fail immediately

            if attempt == max_attempts - 1:
                break  # Last attempt — fall through to raise

            delay = calculate_full_jitter_backoff(base_delay_ms, max_delay_ms, attempt)
            if on_retry:
                on_retry(attempt + 1, e, delay)
            time.sleep(delay)

    raise last_error  # All attempts exhausted
```

### Go — Retry with context deadline and per-attempt timeout

```go
package retry

import (
    "context"
    "fmt"
    "math/rand"
    "time"
)

type Config struct {
    MaxAttempts  int
    BaseDelay    time.Duration
    MaxDelay     time.Duration
    IsRetryable  func(error) bool
    OnRetry      func(attempt int, err error, delay time.Duration)
}

func DefaultConfig() Config {
    return Config{
        MaxAttempts: 5,
        BaseDelay:   100 * time.Millisecond,
        MaxDelay:    30 * time.Second,
        IsRetryable: IsRetryable,
    }
}

func Do[T any](ctx context.Context, cfg Config, fn func(context.Context) (T, error)) (T, error) {
    var zero T
    var lastErr error

    for attempt := 0; attempt < cfg.MaxAttempts; attempt++ {
        result, err := fn(ctx)
        if err == nil {
            return result, nil
        }

        lastErr = err

        if cfg.IsRetryable != nil && !cfg.IsRetryable(err) {
            return zero, err
        }

        if attempt == cfg.MaxAttempts-1 {
            break
        }

        delay := fullJitter(cfg.BaseDelay, cfg.MaxDelay, attempt)

        // Cap delay to remaining context deadline
        if deadline, ok := ctx.Deadline(); ok {
            remaining := time.Until(deadline)
            if delay > remaining {
                return zero, fmt.Errorf("retry delay (%v) exceeds remaining deadline (%v): %w",
                    delay, remaining, context.DeadlineExceeded)
            }
        }

        if cfg.OnRetry != nil {
            cfg.OnRetry(attempt+1, err, delay)
        }

        select {
        case <-ctx.Done():
            return zero, ctx.Err()
        case <-time.After(delay):
        }
    }

    return zero, fmt.Errorf("after %d attempts: %w", cfg.MaxAttempts, lastErr)
}

func fullJitter(base, max time.Duration, attempt int) time.Duration {
    exp := base * time.Duration(1<<uint(attempt)) // base * 2^attempt
    if exp > max {
        exp = max
    }
    return time.Duration(rand.Int63n(int64(exp)))
}
```

### Resilience4j (Java) — Retry configuration

```java
RetryConfig retryConfig = RetryConfig.custom()
    .maxAttempts(5)
    .waitDuration(Duration.ofMillis(100))
    .enableExponentialBackoff(true)
    .exponentialBackoffMultiplier(2.0)
    .maxWaitDuration(Duration.ofSeconds(30))
    .enableRandomizedWait(true)       // Built-in jitter
    .randomizedWaitFactor(0.5)         // ±50% jitter
    .retryExceptions(
        IOException.class,             // Connection reset, timeout
        HttpServerErrorException.ServiceUnavailable.class,  // 503
        HttpServerErrorException.GatewayTimeout.class       // 504
    )
    .ignoreExceptions(
        HttpClientErrorException.BadRequest.class,    // 400 — never retry
        HttpClientErrorException.Unauthorized.class,  // 401 — never retry
        HttpClientErrorException.NotFound.class       // 404 — never retry
    )
    .failAfterMaxAttempts(true)
    .build();

Retry retry = Retry.of("payment-service", retryConfig);

// Attach metrics — critical for observability
retry.getEventPublisher().onRetry(event -> {
    metrics.histogram("retry.delay_ms", event.getWaitTimeInMs().doubleValue());
    metrics.counter("retry.attempt", "operation", event.getName()).increment();
});
retry.getEventPublisher().onError(event -> {
    metrics.counter("retry.exhausted", "operation", event.getName()).increment();
});
```

## Best Practices

1. **Always use exponential backoff with jitter** — this is not optional. Fixed-delay retries cause thundering herd. Exponential backoff without jitter still herds if clients are synchronized. Jitter is the cheapest way to prevent cascading failures.

2. **Fail fast on non-retryable errors** — maintain an explicit allowlist of retryable errors. Everything else fails immediately. A 400 should never be retried.

3. **Make every retried operation idempotent** — if the operation has side effects (write, charge, create, delete), it must have an idempotency key. No exceptions. See [[Idempotency]].

4. **Set both max attempts AND max total time** — max attempts prevents infinite retry loops. Max total time prevents retries that exceed the operation's useful deadline. Use whichever is reached first.

5. **Emit retry metrics** — every retry should increment a counter. Track: retries per operation, retry success rate, retry-induced errors, and retry budget utilization. If you cannot measure retries, you cannot tune them.

6. **Implement retry budgets** — limit retries to 10-20% of total request volume. When the budget is exhausted, stop retrying and fail fast. This prevents retry amplification from turning a minor issue into an outage.

7. **Log retries at DEBUG level, exhausted retries at WARN/ERROR** — every successful retry is expected behavior (DEBUG). A retry that exhausts all attempts is a real failure (ERROR). Do not log every retry attempt at ERROR — it creates alert fatigue and masks real problems.

8. **Test retry behavior with fault injection** — use toxiproxy, chaos engineering tools, or mock servers that intermittently fail. Verify that: retries happen with correct backoff, non-retryable errors fail immediately, idempotency prevents duplication, and retry budgets are enforced.

9. **Coordinate retry policies across services** — if Service A retries with 1s base delay and Service B retries with 500ms base delay, their retry waves will interact unpredictably. Standardize retry policies across your organization (e.g., all services use 100ms base, 30s max, 5 attempts, full jitter).

10. **Use circuit breakers to short-circuit retries** — the circuit breaker tracks the error rate of a dependency. When it opens, all requests (including retries) fail fast without reaching the dependency. This prevents retries from consuming resources on a dependency that is demonstrably unable to handle them. Retry and circuit breaker are complementary: retry handles individual transient faults, circuit breaker handles systemic failures. See [[CircuitBreaker]].

## Related Topics

- [[CircuitBreaker]] — complementary pattern; stops retries when a dependency is systemically failing
- [[Idempotency]] — required for safe retries of operations with side effects
- [[FailFast]] — when to fail immediately instead of retrying
- [[Resilience]] — the broader discipline of building fault-tolerant systems
- [[Backpressure]] — controlling input rate when retries are contributing to overload
- [[RateLimiting]] — 429 Too Many Requests with Retry-After header tells clients when to retry
- [[BulkheadPattern]] — isolating retry traffic from normal traffic
- [[Timeout]] — deadlines that bound total retry time
- [[ErrorHandling]] — classifying which errors are retryable
- [[DistributedSystems]] — why retries are necessary (everything fails in distributed systems)
- [[Monitoring]] and [[Observability]] — measuring retry behavior in production
- [[ChaosEngineering]] — testing retry behavior by injecting failures
- [[MessageQueues]] — built-in retry with delivery count and dead-letter queues
- [[ErrorBudgets]] — using retry rate as an error budget signal
