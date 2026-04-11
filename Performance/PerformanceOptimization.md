---
title: Performance Optimization
title_pt: Otimização de Performance
layer: performance
type: practice
priority: high
version: 1.0.0
tags:
  - Performance
  - Optimization
  - Practice
description: Techniques for improving application performance.
description_pt: Técnicas para melhorar o desempenho da aplicação.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Performance Optimization

## Description

Performance optimization is the systematic process of improving application speed and efficiency. It involves identifying bottlenecks, implementing fixes, and verifying improvements. Good optimization requires understanding where time is spent and making targeted improvements.

Key areas for optimization:
- **Database** - Queries, indexes, connections
- **Computation** - Algorithms, caching
- **I/O** - Network, disk operations
- **Memory** - Allocation, leaks
- **Rendering** - Frontend performance

The optimization process:
1. **Identify** - Find bottlenecks via profiling
2. **Analyze** - Understand root cause
3. **Implement** - Make targeted fix
4. **Verify** - Measure improvement

## Purpose

**When to optimize:**
- When performance doesn't meet requirements
- After profiling reveals bottlenecks
- Before major releases

**What to optimize:**
- Most frequently executed code
- Critical user paths
- Large data operations

## Rules

1. **Measure first** - Don't guess, profile
2. **Optimize hot spots** - Focus on where time is spent
3. **Change one thing** - Track impact of each change
4. **Verify improvement** - Re-measure after changes
5. **Balance readability** - Don't over-optimize

## Examples

### Database Optimizations

```python
# BAD: N+1 query problem
users = get_all_users()
for user in users:
    orders = get_orders_by_user(user.id)  # Query for each user!
    print(f"{user.name}: {len(orders)} orders")

# GOOD: Single query with JOIN
results = db.query('''
    SELECT u.name, COUNT(o.id) as order_count
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.id
''')
for row in results:
    print(f"{row.name}: {row.order_count} orders")

# GOOD: Eager loading
users = get_all_users(load_orders=True)  # Load in single query
for user in users:
    print(f"{user.name}: {len(user.orders)} orders")
```

### Caching Results

```python
# BAD: Expensive computation every time
def get_user_stats(user_id):
    # Recompute every time!
    orders = db.get_orders(user_id)
    total = sum(o.total for o in orders)
    items = sum(o.quantity for o in orders)
    return {'total': total, 'items': items}

# GOOD: Cache expensive results
cache = {}

def get_user_stats(user_id):
    if user_id in cache:
        return cache[user_id]
    
    orders = db.get_orders(user_id)
    total = sum(o.total for o in orders)
    items = sum(o.quantity for o in orders)
    result = {'total': total, 'items': items}
    
    cache[user_id] = result
    return result

# BETTER: Use proper cache with TTL
from functools import lru_cache

@lru_cache(maxsize=1000)
def get_user_stats_cached(user_id):
    orders = db.get_orders(user_id)
    return {
        'total': sum(o.total for o in orders),
        'items': sum(o.quantity for o in orders)
    }
```

### Async Operations

```python
# BAD: Blocking I/O
def fetch_user_data(user_id):
    user = http.get(f'/users/{user_id}')  # Waits!
    orders = http.get(f'/users/{user_id}/orders')  # Waits again!
    return {'user': user, 'orders': orders}

# GOOD: Concurrent requests
import asyncio
import aiohttp

async def fetch_user_data(user_id):
    async with aiohttp.ClientSession() as session:
        user_task = session.get(f'/users/{user_id}')
        orders_task = session.get(f'/users/{user_id}/orders')
        
        user, orders = await asyncio.gather(user_task, orders_task)
        
        return {'user': await user.json(), 'orders': await orders.json()}

# Synchronous version with concurrent.futures
from concurrent.futures import ThreadPoolExecutor

def fetch_user_data(user_id):
    with ThreadPoolExecutor(max_workers=2) as executor:
        user_future = executor.submit(http.get, f'/users/{user_id}')
        orders_future = executor.submit(http.get, f'/users/{user_id}/orders')
        
        user = user_future.result()
        orders = orders_future.result()
        
        return {'user': user, 'orders': orders}
```

### Frontend Optimizations

```javascript
// React: Memoize expensive components
const ExpensiveList = React.memo(function ExpensiveList({ items }) {
  return (
    <ul>
      {items.map(item => (
        <ListItem key={item.id} item={item} />
      ))}
    </ul>
  );
});

// React: Use useMemo for expensive calculations
function Dashboard({ userId }) {
  const userData = useUserData(userId);
  
  // Only recalculate when userData changes
  const stats = useMemo(() => calculateStats(userData), [userData]);
  
  // Expensive filtering only when needed
  const filteredItems = useMemo(
    () => items.filter(item => item.userId === userId),
    [items, userId]
  );
  
  return <div>{stats.total} items</div>;
}

// Lazy load components
const HeavyChart = React.lazy(() => import('./HeavyChart'));

function Dashboard() {
  return (
    <Suspense fallback={<Spinner />}>
      <HeavyChart />
    </Suspense>
  );
}
```

### API Response Optimization

```python
# BAD: Return all fields
@app.get('/users/{user_id}')
def get_user(user_id):
    user = db.get_user(user_id)
    return user  # Returns all columns including password_hash!

# GOOD: Use serialization schema
class UserSchema:
    id = fields.Int()
    name = fields.Str()
    email = fields.Str()
    created_at = fields.DateTime()
    
    # Exclude sensitive fields
    exclude = ['password_hash', 'ssn']

@app.get('/users/{user_id}')
def get_user(user_id):
    user = db.get_user(user_id)
    return UserSchema().dump(user)

# GOOD: Pagination for lists
@app.get('/users')
def list_users(page: int = 1, limit: int = 20):
    users = db.get_users(
        offset=(page-1)*limit,
        limit=limit
    )
    total = db.count_users()
    
    return {
        'data': users,
        'pagination': {
            'page': page,
            'limit': limit,
            'total': total,
            'pages': (total + limit - 1) // limit
        }
    }
```

## Anti-Patterns

### 1. Premature Optimization

```python
# BAD - Don't optimize until needed
# "I'll use a more efficient algorithm just in case"
# Usually unnecessary

# GOOD - Profile first, then optimize
# 80% of time in 20% of code
```

### 2. Ignoring Big O

```python
# BAD: O(n²) algorithm for large data
for item in large_list:
    for other in large_list:
        compare(item, other)

# GOOD: O(n) or O(n log n)
# Sort once, then compare
sorted_list = sorted(large_list)
# Efficient comparison
```

## Failure Modes

- **Premature optimization** → complex code with no measurable gain → maintenance burden → profile first, optimize only proven bottlenecks
- **Ignoring Big O complexity** → algorithm degrades at scale → system collapse under load → analyze algorithmic complexity before implementation
- **No caching strategy** → redundant computation → wasted CPU cycles → cache expensive, deterministic results with appropriate TTL
- **Blocking I/O in critical path** → sequential execution → poor throughput → use async/concurrent operations for independent I/O
- **Memory leaks** → gradual resource exhaustion → eventual crash → profile memory usage and track object lifecycle
- **Over-optimizing readability loss** → unmaintainable code → bugs during future changes → balance performance gains with code clarity
- **Not verifying improvements** → assumed optimization → no actual benefit → re-measure after every change to confirm improvement

## Best Practices

### Optimization Checklist

```
1. Profile first
   - Find where time is spent
   - Focus on hot spots

2. Database
   - Add indexes for queries
   - Optimize slow queries
   - Use connection pooling
   - Consider caching

3. Code
   - Use efficient algorithms
   - Batch operations
   - Reduce allocations

4. Network
   - Batch requests
   - Use compression
   - Consider CDN

5. Frontend
   - Lazy load
   - Minimize re-renders
   - Optimize bundles
```

### Monitoring

```python
# Track performance in production
import time

def track_performance(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        duration = time.time() - start
        
        metrics.timing(f'function.{func.__name__}', duration)
        
        if duration > 1.0:  # Log slow calls
            logger.warning(f'Slow call: {func.__name__} took {duration}s')
        
        return result
    return wrapper
```

## Technology Stack

| Area | Tools |
|------|-------|
| Profiling | py-spy, Clinic.js, Chrome DevTools |
| APM | Datadog, New Relic, AWS X-Ray |
| Caching | Redis, Memcached |
| CDN | CloudFront, Cloudflare |

## Related Topics

- [[PerformanceProfiling]]
- [[LoadTesting]]
- [[DatabaseOptimization]]
- [[Caching]]
- [[Monitoring]]
- [[Algorithms]]
- [[Complexity]]
- [[DataStructures]]

## Additional Notes

**Optimization Priorities:**
1. Database queries (biggest impact often)
2. Network calls
3. Algorithm efficiency
4. Memory usage

**When to Stop:**
- Requirements met
- Diminishing returns
- Code readability suffers

**Common Bottlenecks:**
- Database queries
- Network latency
- Unoptimized algorithms
- Missing caches