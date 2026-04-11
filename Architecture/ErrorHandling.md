---
title: Error Handling
layer: architecture
type: concept
priority: high
version: 2.0.0
tags:
  - Architecture
  - ErrorHandling
  - Resilience
  - Reliability
  - API_Design
description: Systematic strategies for detecting, classifying, reporting, and recovering from errors across all layers of a software system.
---

# Error Handling

## Description

Error handling is the discipline of making failure modes explicit, classifiable, and recoverable. It spans three concerns:

1. **Detection** — knowing that something went wrong (exceptions, error codes, health checks, assertions)
2. **Classification** — determining what *kind* of wrongness occurred (transient vs. permanent, client vs. server, expected vs. unexpected)
3. **Response** — deciding what to do about it (retry, fail fast, degrade gracefully, alert, compensate)

Good error handling makes systems *observable under failure* — an engineer can look at a log, metric, or error response and immediately understand: what failed, why it failed, whether it's retryable, and what action to take. Bad error handling makes failures invisible until users report them.

The fundamental principle: **errors are data**. Every error carries information about the state of the system. Your job is to preserve that information and route it to the right consumer (the caller, the monitoring system, the on-call engineer).

## When to Use

- **Every system that interacts with unreliable dependencies** — databases, network calls, file systems, external APIs, message queues. All of these fail regularly. Your code must handle it.
- **Public API design** — API consumers need structured, machine-parseable error responses to implement their own retry logic, user-facing error messages, and debugging workflows.
- **Boundary layers** — every trust boundary (client/server, service/service, system/external) is a failure boundary. Errors must be classified and translated at these boundaries.
- **Systems with SLOs/SLAs** — error budgets ([[ErrorBudgets]]) require precise error classification. You cannot measure your error budget if you cannot distinguish between a 4xx client error and a 5xx server error.

## When NOT to Use

- **For expected control flow** — using exceptions for normal control flow (e.g., throwing `NotFoundException` as the primary way to check if a record exists) is an anti-pattern. Use `Option`/`Maybe` types, boolean returns, or explicit result types for expected absence. Reserve exceptions for unexpected conditions.
- **In tight loops with high error rates** — if a code path throws exceptions > 1% of the time, the exception handling overhead (stack trace construction, unwinding) becomes a performance problem. Fix the root cause or pre-validate conditions.
- **When the error cannot be acted upon** — catching an exception, logging it, and continuing without any recovery action or alert is worse than letting it crash. Silent failure is the worst failure mode.

## Error Classification Taxonomy

How you classify errors determines how you respond to them. This taxonomy applies across all layers:

| Category | Examples | Response | Retryable? |
|----------|----------|----------|------------|
| **Client errors (4xx)** | Invalid input, authentication failure, resource not found, rate limited | Return error to caller, do not retry the same request | No (fix the request first) |
| **Transient server errors (5xx)** | Timeout, connection refused, 502/503, resource temporarily unavailable | Retry with backoff ([[RetryPattern]]) | Yes |
| **Permanent server errors (5xx)** | 500 internal error, data corruption, assertion failure, out of memory | Do not retry, alert immediately, fail fast | No |
| **Dependency errors** | Database down, external API timeout, DNS resolution failure | Circuit break ([[CircuitBreaker]]), degrade gracefully, or fail fast | Depends on dependency |
| **Domain errors** | Insufficient funds, validation failure, business rule violation | Return domain-specific error to caller, do not retry | No |

### The Error Hierarchy (Application Level)

```
Error
├── AppError (application-level, all errors inherit from this)
│   ├── ClientError (caller's fault)
│   │   ├── ValidationError (bad input)
│   │   ├── AuthenticationError (invalid/expired credentials)
│   │   ├── AuthorizationError (insufficient permissions)
│   │   ├── NotFoundError (resource does not exist)
│   │   └── RateLimitError (caller exceeded quota)
│   ├── ServerError (our fault)
│   │   ├── TransientError (retryable)
│   │   │   ├── TimeoutError
│   │   │   ├── ConnectionError
│   │   │   └── OverloadedError
│   │   └── PermanentError (non-retryable)
│   │       ├── InternalError (unexpected exception)
│   │       ├── DataCorruptionError
│   │       └── ConfigurationError
│   └── DomainError (business rule violation)
│       ├── InsufficientFundsError
│       ├── DuplicateResourceError
│       └── StateTransitionError
```

This hierarchy enables pattern matching on error types at the boundary layer:

```typescript
// Good: classify and respond based on error type
async function handleRequest(req: Request): Promise<Response> {
  try {
    return await processOrder(req);
  } catch (error) {
    if (error instanceof ClientError) {
      return Response.badRequest({ code: error.code, message: error.userMessage });
    }
    if (error instanceof TransientError) {
      metrics.increment("errors.transient");
      return Response.serviceUnavailable({
        code: "TEMPORARILY_UNAVAILABLE",
        retryAfter: calculateRetryAfter(error),
      });
    }
    if (error instanceof DomainError) {
      return Response.conflict({ code: error.code, details: error.context });
    }
    // Permanent server error — alert and return 500
    alerting.critical("Unhandled server error", { route: req.path, error: sanitize(error) });
    return Response.internalServerError({ code: "INTERNAL_ERROR", traceId: req.traceId });
  }
}
```

## Tradeoffs

### Exceptions vs. Result Types (Either/Result)

| Dimension | Exceptions | Result Types (`Either<E, T>`) |
|-----------|-----------|-------------------------------|
| **Visibility** | Implicit — type signature does not declare errors | Explicit — error type is in the signature |
| **Propagation** | Automatic — bubbles up the stack until caught | Manual — each caller must handle or pass through |
| **Performance** | Stack trace overhead (microseconds to milliseconds) | No overhead, just value wrapping |
| **Language support** | Native in most languages | Requires library support (Rust `Result`, Haskell `Either`, TypeScript `neverthrow`) |
| **Best for** | Truly exceptional, unexpected failures | Expected failure modes (validation, domain errors) |

**Practical recommendation**: Use exceptions for unexpected failures (network down, OOM, assertion violations). Use result types for expected failures (validation, not found, business rule violations). This matches the semantic intent and optimizes for the common case.

### Fail-Fast vs. Graceful Degradation

**Fail-fast** ([[FailFast]]): crash immediately when an invariant is violated. Best for: data corruption detection, configuration errors at startup, assertion violations. Rationale: continuing with violated invariants causes cascading corruption that is harder to diagnose.

**Graceful degradation**: continue operating with reduced functionality. Best for: non-critical dependency failures (recommendation service down, but checkout still works), external API failures with cached fallback. Rationale: partial service is better than no service.

The choice is *per-dependency*, not per-system. Your payment processor failing → fail fast. Your recommendation engine failing → degrade gracefully.

## Alternatives

- **Process supervision / let it crash** — the Erlang/Elixir philosophy. Do not handle errors in business logic; let the process crash and have a supervisor restart it. This works because Erlang processes are lightweight and isolated stateless. Does not work for Java/Python/Node.js where process restart is expensive and state is in-process.
- **Assertion-based design** — use assertions (`assert`, `require`, `panic`) for conditions that should never be false. The program crashes immediately, making the bug obvious. Appropriate for internal invariants, not for external input validation.
- **Precondition checking** — validate all inputs and preconditions before executing the operation, so errors are caught before any side effects occur. This is the "validate early, fail early" approach used in API gateways and form handlers.

## Failure Modes

1. **Swallowed exceptions create silent data corruption** — a `catch (Exception e) { log.warn("something happened"); }` that does not rethrow, alert, or compensate means the operation silently did not complete. A real incident: a payment service caught `SQLException` on the refund path, logged a warning, and returned "success" to the caller. The refund was never processed. 2,347 customers were never refunded over 6 months before discovery. Mitigation: never catch `Exception` — catch specific types. If you must catch broad exceptions, always rethrow or alert, and never return success.

2. **Error message leakage exposes sensitive data** — returning raw exception messages to API clients reveals stack traces, SQL queries, internal hostnames, and potentially PII. Example: `{"error": "SQLException: INSERT INTO users (ssn) VALUES ('123-45-6789') - duplicate key"}` exposes both the table schema and the SSN. Mitigation: sanitize all error messages at the boundary layer. Return a stable error code and a user-safe message. Log the full details internally with the trace ID.

3. **Inconsistent error response format forces client guesswork** — some endpoints return `{"error": "message"}`, others return `{"errors": [{"code": "...", "message": "..."}]}`, and others return plain text error bodies. Client developers cannot write generic error handling code. Mitigation: standardize on a single error response schema for your entire API:
   ```json
   {
     "error": {
       "code": "VALIDATION_FAILED",
       "message": "One or more fields failed validation",
       "traceId": "req-abc123",
       "details": [
         {
           "field": "email",
           "code": "INVALID_FORMAT",
           "message": "Email address is not valid"
         }
       ]
     }
   }
   ```

4. **Overly broad catch blocks mask root causes** — `catch (Exception e)` that handles database timeouts, validation errors, and NullPointerExceptions identically means you cannot distinguish transient failures from bugs. Every error gets the same response (usually a generic 500), and the monitoring system cannot alert on specific failure patterns. Mitigation: catch specific exception types. At minimum, separate client errors from server errors, and transient from permanent.

5. **Error handling code is untested** — teams write unit tests for the happy path but never test the error paths. When a timeout actually occurs in production, the error handling code itself has bugs (null pointer in the error handler, incorrect error response format, missing alerting). Mitigation: write tests for every error path. Use mock objects that throw specific exceptions. Treat error handling code as production code — it requires the same test coverage as the happy path.

6. **Alert fatigue from over-alerting on errors** — alerting on every 5xx error means the on-call engineer gets paged 500 times during a minor deployment issue. After 3 days of false alarms, they start ignoring alerts. Then a real outage occurs and nobody responds. Mitigation: alert on error *rate* and error *budget burn rate*, not individual errors. A single 500 is expected. A sustained 5% error rate for 5 minutes is an alert. Use [[ErrorBudgets]] to determine alerting thresholds.

7. **Error context loss across service boundaries** — Service A calls Service B which calls the database. The database returns "connection refused." Service B wraps it as "internal error." Service A wraps it as "dependency failure." The original error message and context are lost by the time it reaches the API response. The engineer sees "dependency failure" and has no idea which dependency or why. Mitigation: propagate error context through the chain. Include the original error code/type in the response. Use distributed tracing ([[Tracing]]) with error annotations at each hop.

8. **Retry on non-retryable errors causes amplification** — retrying a validation error or a domain error (duplicate key, insufficient funds) wastes resources and amplifies load. Each retry of a non-retryable error consumes a database connection, CPU cycle, and network hop for zero chance of success. At scale, this creates unnecessary load that contributes to genuine transient errors. Mitigation: classify errors as retryable or non-retryable at the point of detection. Only retry transient errors. Use the [[RetryPattern]] with an allowlist of retryable error codes.

9. **Deferred cleanup never executes** — `try { openFile(); process(); } finally { closeFile(); }` is correct, but if `process()` crashes the process (OOM, segfault, SIGKILL), the finally block never runs. Resources leak. In long-running services, leaked file descriptors, database connections, or locks accumulate until the service crashes. Mitigation: use OS-level resource limits (ulimit, cgroups) as a safety net, implement health checks that detect resource exhaustion, and design for process-level cleanup (PID file cleanup, lock TTLs).

## Real-World Examples

### Go — Idiomatic error handling with wrapping

```go
// Good: wrap errors with context, preserve the original for inspection
func GetUser(ctx context.Context, db *sql.DB, id string) (*User, error) {
    var user User
    err := db.QueryRowContext(ctx, "SELECT id, name, email FROM users WHERE id = $1", id).
        Scan(&user.ID, &user.Name, &user.Email)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, fmt.Errorf("get user %s: %w", id, ErrNotFound)
        }
        return nil, fmt.Errorf("get user %s: query failed: %w", id, err)
    }
    return &user, nil
}

// Caller classifies and responds based on error type
func (h *Handler) handleGetUser(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")
    user, err := h.svc.GetUser(r.Context(), h.db, id)
    if err != nil {
        switch {
        case errors.Is(err, ErrNotFound):
            http.Error(w, `{"error":{"code":"NOT_FOUND"}}`, http.StatusNotFound)
            return
        case isTransientDBError(err):
            http.Error(w, `{"error":{"code":"TEMPORARILY_UNAVAILABLE"}}`, http.StatusServiceUnavailable)
            return
        default:
            h.logger.Error("unexpected error getting user", "error", err, "user_id", id)
            http.Error(w, `{"error":{"code":"INTERNAL_ERROR"}}`, http.StatusInternalServerError)
            return
        }
    }
    // ... return user
}

func isTransientDBError(err error) bool {
    var pqErr *pgconn.PgError
    if errors.As(err, &pqErr) {
        // PostgreSQL error codes: 57P01 = admin_shutdown, 57P03 = cannot_connect_now
        return pqErr.Code == "57P01" || pqErr.Code == "57P03"
    }
    return errors.Is(err, context.DeadlineExceeded) || errors.Is(err, context.Canceled)
}
```

### HTTP API — Standardized error response

```python
# FastAPI middleware that standardizes all error responses
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
import uuid

async def error_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Global error handler that produces consistent error responses."""
    trace_id = request.headers.get("X-Trace-ID", str(uuid.uuid4()))

    # Client errors — return the details
    if 400 <= exc.status_code < 500:
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": {
                    "code": exc.detail.get("code", "CLIENT_ERROR"),
                    "message": exc.detail.get("message", "Client error"),
                    "traceId": trace_id,
                }
            }
        )

    # Server errors — generic message, full details logged
    logger.exception(
        "Server error on %s %s",
        request.method, request.url.path,
        extra={"trace_id": trace_id, "error": exc.detail},
    )
    # Trigger alert for permanent server errors
    if exc.status_code == 500:
        metrics.increment("errors.permanent", tags={"route": request.url.path})

    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "An internal error occurred",
                "traceId": trace_id,
            }
        }
    )
```

### Rust — Result types with thiserror for domain errors

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum OrderError {
    #[error("product {product_id} not found")]
    ProductNotFound { product_id: String },

    #[error("insufficient stock for product {product_id}: requested {requested}, available {available}")]
    InsufficientStock { product_id: String, requested: u32, available: u32 },

    #[error("user {user_id} has reached order limit of {limit}")]
    OrderLimitExceeded { user_id: String, limit: u32 },

    #[error("database error: {0}")]
    DatabaseError(#[from] sqlx::Error),

    #[error("transient service error: {0}")]
    TransientError(String),
}

// Caller pattern-matches to determine response
async fn create_order(
    state: &AppState,
    request: CreateOrderRequest,
) -> Result<Order, OrderError> {
    let product = state.db.get_product(&request.product_id).await
        .map_err(|e| match e {
            sqlx::Error::RowNotFound => OrderError::ProductNotFound {
                product_id: request.product_id.clone(),
            },
            other => OrderError::DatabaseError(other),
        })?;

    if product.stock < request.quantity {
        return Err(OrderError::InsufficientStock {
            product_id: request.product_id,
            requested: request.quantity,
            available: product.stock,
        });
    }

    // ... proceed with order
}
```

## Best Practices

1. **Errors are part of your API contract** — document every error code your API can return, with the conditions that cause it and whether the caller should retry. This is as important as documenting your success responses.
2. **Classify errors at the boundary** — the outermost layer of your service (HTTP handler, message consumer, CLI entry point) must classify every error and respond appropriately. Inner layers should propagate errors with context.
3. **Preserve error context through wrapping** — when you catch an error and re-throw with more context, always preserve the original error (use `fmt.Errorf("%w")` in Go, `cause` in Python, `innerException` in .NET). The original error is the only thing that tells you the actual root cause.
4. **Never log and swallow** — if you catch an error, you must do at least one of: rethrow, return an error response, trigger a compensating action, or alert. Logging alone is not handling.
5. **Use structured logging with error context** — every error log should include: the error type, the error message, the operation that failed, relevant identifiers (user ID, order ID, trace ID), and any state needed to reproduce the issue.
6. **Design error responses for machines first** — API consumers are programs, not humans. Error responses must be machine-parseable with stable error codes. Human-readable messages are a secondary concern.
7. **Test error paths as rigorously as happy paths** — inject failures at every dependency boundary (database timeout, network error, malformed response). If you cannot trigger an error path in tests, you cannot trust it in production.
8. **Set error budgets and alert on burn rate** — define what percentage of requests may fail (your error budget) and alert when the burn rate exceeds acceptable levels. This is more actionable than alerting on individual errors. See [[ErrorBudgets]].
9. **Sanitize errors at trust boundaries** — never expose internal error details (stack traces, SQL, hostnames) to untrusted callers. Log internally, return generic externally. The trace ID connects the two.
10. **Make retryable vs. non-retryable explicit** — every error type should have a `isRetryable()` method or equivalent. This drives retry behavior ([[RetryPattern]]) and prevents retrying errors that will never succeed.

## Related Topics

- [[RetryPattern]] — how to retry transient errors correctly
- [[CircuitBreaker]] — when to stop retrying and fail fast
- [[FailFast]] — philosophy of failing immediately when invariants are violated
- [[Resilience]] — building systems that handle errors gracefully
- [[ErrorBudgets]] and [[Alerting]] — measuring and alerting on error rates
- [[Observability]], [[Logging]], [[Monitoring]], and [[Tracing]] — capturing error context
- [[Idempotency]] — making retries safe
- [[Backpressure]] — handling overload errors by controlling input rate
- [[RateLimiting]] — returning proper 429 errors with retry-after headers
- [[QualityGates]] — requiring error handling tests in CI
- [[TypeSafety]] — using type systems (Result, Either) to make errors explicit
- [[API Design]] — standardizing error response formats
- [[DDD]] — domain errors as part of the ubiquitous language
- [[Validation]] — distinguishing input validation errors from system errors
- [[ChaosEngineering]] — proactively testing error handling paths
