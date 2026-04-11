---
title: Idempotency Principle
title_pt: Princípio de Idempotência
layer: principles
type: concept
priority: high
version: 1.0.0
tags:
  - Principles
  - Idempotency
description: Operations that produce the same result no matter how many times they're executed.
description_pt: Operações que produzem o mesmo resultado independentemento de quantas vezes são executadas.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Idempotency Principle

## Description

An operation is idempotent if calling it multiple times has the same effect as calling it once. This is crucial for:
- Retry logic
- Distributed systems
- Event processing
- API design

Types:
- **Idempotent**: Same result on repeat (GET, PUT, DELETE)
- **Non-idempotent**: Different result on repeat (POST, increment)

## Purpose

**When idempotency is required:**
- Building reliable retry mechanisms (network failures, timeouts)
- Designing APIs that can be safely called multiple times
- Processing events that may be delivered multiple times
- Implementing distributed systems with at-least-once delivery
- Handling payment operations where duplicate charges are unacceptable

**When idempotency may be overkill:**
- Internal tools with single-user, single-request workflows
- Read-only operations that are inherently safe
- Ephemeral compute functions with no side effects
- Prototypes where reliability is not a concern
- High-throughput scenarios where idempotency keys add overhead

**The key question:** If this operation is executed twice (due to network retry, user double-click, or system failure), will the result be the same?

## Rules

1. **Make writes idempotent by default** - Use upserts, unique constraints, idempotency keys
2. **Use idempotency keys for critical operations** - Payments, orders, user creation
3. **Design for at-least-once delivery** - Assume messages may be delivered multiple times
4. **Leverage HTTP semantics** - PUT/DELETE are idempotent, POST is not
5. **Test idempotency** - Verify repeated calls produce same result

## Examples

### Good - Idempotent Operation

```python
# DELETE is idempotent
# First call: deletes resource, returns 200
# Subsequent calls: resource already gone, returns 404 or 200
def delete_user(user_id):
    if user_exists(user_id):
        remove_user(user_id)
    return {"status": "deleted"}

# First call
delete_user("123")  # Deletes user
# Second call
delete_user("123")  # Still "deleted" (idempotent)
```

### Bad - Non-Idempotent Operation

```python
# Increment is NOT idempotent
def increment_counter(counter_id):
    counter = get_counter(counter_id)
    counter.value += 1
    save_counter(counter)
    return counter.value

# First call: 1
# Second call: 2  (different result!)
```

### Good - Idempotency Key

```python
# Use idempotency key for non-idempotent operations
def create_order(order_data, idempotency_key):
    # Check if already processed
    if cache.get(idempotency_key):
        return cache.get(idempotency_key)
    
    # Process order
    order = OrderService().create(order_data)
    
    # Store result with key
    cache.set(idempotency_key, order, ttl=86400)
    return order

# Multiple calls with same key return same result
create_order(data, "key123")  # Creates order
create_order(data, "key123")  # Returns cached order
```

### Good - API Idempotency

```python
# REST methods
# Idempotent: GET, PUT, DELETE, PATCH
# Non-idempotent: POST

# Good API design
@app.post("/orders")           # Not idempotent
def create_order():
    return Order()

@app.put("/orders/{id}")       # Idempotent
def update_order(id, data):
    return OrderService().update(id, data)

@app.delete("/orders/{id}")    # Idempotent
def delete_order(id):
    return OrderService().delete(id)
```

## Anti-Patterns

### 1. Non-Idempotent Retries

**Bad:** Retrying a POST request that creates a new resource without an idempotency key
**Why it's bad:** A network timeout triggers a retry, and the client gets charged twice or creates duplicate orders
**Good:** Use idempotency keys for all retryable operations — check if the key was already processed before executing

### 2. Idempotency Key Collision

**Bad:** Reusing the same idempotency key across different operations or using low-entropy keys
**Why it's bad:** A legitimate new operation is blocked because its key matches a previous one — or worse, returns stale cached results
**Good:** Generate unique idempotency keys per operation with sufficient entropy (UUIDs or cryptographic hashes of request content)

### 3. Unbounded Idempotency Storage

**Bad:** Storing idempotency keys forever without expiration or cleanup
**Why it's bad:** The idempotency store grows without bound, queries slow down, and eventually it becomes a performance bottleneck
**Good:** Implement key expiration with TTL longer than maximum processing time, plus periodic cleanup jobs

### 4. Partial Operation Idempotency

**Bad:** An operation that succeeds partially (e.g., charges the card) then fails on a subsequent step (e.g., creating the order record)
**Why it's bad:** On retry, the card is charged again because the first partial success was not recorded — the operation is not truly all-or-nothing
**Good:** Use database transactions or compensating actions to ensure the entire operation is atomic — either fully succeeded or fully rolled back

## Best Practices

### 1. Design for Idempotency

```python
# Use upsert (insert or update)
def save_user(user_data):
    if user_exists(user_data['id']):
        return update_user(user_data)
    else:
        return create_user(user_data)

# Both insert and update lead to same final state
save_user({'id': '1', 'name': 'John'})  # Creates
save_user({'id': '1', 'name': 'John'})  # Same result!
```

### 2. Use Unique Keys

```python
# For events, use idempotency keys
class EventProcessor:
    def process(self, event):
        if self.is_processed(event.id):
            return self.get_result(event.id)
        
        result = self.do_processing(event)
        self.mark_processed(event.id, result)
        return result
```

### 3. Embrace HTTP Semantics

```python
# Use appropriate HTTP methods
GET    # Idempotent - safe to call multiple times
PUT     # Idempotent - set to value, same result
DELETE  # Idempotent - removed, stays removed
POST    # Not idempotent - creates new each time
PATCH   # Usually idempotent but depends on implementation
```

## Failure Modes

- **Non-idempotent retry logic** → network timeout triggers duplicate operations → double charges or duplicate records → use idempotency keys and check-before-do patterns for all retryable operations
- **Idempotency key collision** → different operations share same idempotency key → one operation blocks another → generate unique idempotency keys per operation with sufficient entropy
- **Idempotency key expiration too short** → key expires before client receives response → client retries and creates duplicate → set idempotency key TTL longer than maximum expected processing time
- **Not making read operations idempotent** → read operations with side effects like counters or logs → repeated reads change state → ensure read operations are truly side-effect free
- **Idempotency storage becoming bottleneck** → all idempotency keys stored in single database → storage grows unbounded and queries slow → implement key expiration, cleanup jobs, and distributed idempotency stores
- **Partial operation idempotency** → operation succeeds partially then fails on retry → inconsistent state → use transactions or compensating actions to ensure all-or-nothing idempotent operations
- **Assuming HTTP method idempotency** → treating POST as idempotent or PUT as non-idempotent → incorrect retry behavior → follow HTTP semantics: GET, PUT, DELETE are idempotent, POST is not

## Related Topics

- [[EventArchitecture]]
- [[APIDesign]]
- [[REST]]
- [[Determinism]]
- [[CiCd]]
- [[Caching]]
- [[DatabaseOptimization]]
- [[FaultTolerance]]

## Key Takeaways

- Idempotency ensures operations produce the same result regardless of execution count, critical for retries, distributed systems, and event processing
- Required for reliable retry mechanisms, APIs called multiple times, at-least-once event delivery, and payment operations where duplicate charges are unacceptable
- Overkill for internal single-user tools, inherently safe read-only operations, ephemeral compute with no side effects, or prototypes
- Tradeoff: safe retry behavior and duplicate protection versus idempotency key storage overhead and implementation complexity
- Main failure mode: non-idempotent retry logic on network timeouts causes duplicate operations like double charges or duplicate records
- Best practice: use idempotency keys for all retryable operations, design for at-least-once delivery with check-before-do patterns, leverage HTTP semantics where GET/PUT/DELETE are idempotent and POST is not, and implement key expiration with TTL longer than max processing time
- Related: event-driven architecture, API design, REST, determinism, CI/CD, caching, database optimization
