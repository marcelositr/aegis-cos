---
title: Database Optimization
title_pt: Otimização de Banco de Dados
layer: databases
type: concept
priority: high
version: 1.0.0
tags:
  - Databases
  - Optimization
  - Performance
  - Concept
description: Techniques for improving database performance.
description_pt: Técnicas para melhorar o desempenho do banco de dados.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Database Optimization

## Description

Database optimization involves improving the performance of database operations through various techniques. This includes query optimization, indexing strategies, schema design, and hardware considerations. Proper optimization can dramatically improve application responsiveness.

Key areas of optimization:
- **Query Optimization** - Writing efficient queries
- **Indexing** - Creating appropriate indexes
- **Schema Design** - Normalization vs denormalization
- **Configuration** - Tuning database settings
- **Hardware** - Memory, disk, CPU considerations
- **Caching** - Reducing database load

The goal is to minimize:
- Query execution time
- I/O operations
- Lock contention
- Memory usage

## Purpose

**When to optimize:**
- Slow query performance
- High CPU or I/O usage
- Locking issues
- Scaling challenges

**What to optimize:**
- Frequently executed queries
- Large table scans
- Complex joins
- Unoptimized indexes

## Rules

1. **Measure first** - Don't optimize without data
2. **Use indexes wisely** - Not too many, not too few
3. **Write efficient queries** - Avoid SELECT *
4. **Monitor query plans** - Understand execution
5. **Consider denormalization** - Trade consistency for speed

## Examples

### Query Analysis

```sql
-- PostgreSQL: Explain query plan
EXPLAIN ANALYZE
SELECT o.id, u.username, o.total, o.status
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.created_at >= '2024-01-01'
AND o.status = 'pending'
ORDER BY o.created_at DESC
LIMIT 100;

-- Result analysis
-- Seq Scan on orders: full table scan - BAD
-- Index Scan using idx_orders_status: using index - GOOD
-- Nested Loop: join strategy - may be slow
```

### Index Optimization

```sql
-- Create composite index for common query
CREATE INDEX idx_orders_status_created 
ON orders(status, created_at DESC);

-- Partial index for active data
CREATE INDEX idx_orders_active 
ON orders(user_id, created_at DESC)
WHERE status NOT IN ('cancelled', 'refunded');

-- Covering index (includes all columns needed)
CREATE INDEX idx_users_email 
ON users(email) 
INCLUDE (username, created_at);

-- Expression index
CREATE INDEX idx_users_lower_email 
ON users(LOWER(email));

-- Remove unused indexes
DROP INDEX idx_orders_old_status;
```

### Query Optimization

```sql
-- BAD: Using functions on indexed column
SELECT * FROM orders 
WHERE DATE(created_at) = '2024-01-15';

-- GOOD: Use range query
SELECT * FROM orders 
WHERE created_at >= '2024-01-15' 
AND created_at < '2024-01-16';

-- BAD: Subquery in SELECT
SELECT 
    id,
    (SELECT COUNT(*) FROM order_items WHERE order_id = orders.id) as item_count
FROM orders;

-- GOOD: Use JOIN
SELECT o.id, COUNT(oi.id) as item_count
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;

-- BAD: OR condition
SELECT * FROM orders 
WHERE user_id = 123 OR status = 'pending';

-- GOOD: Use UNION
SELECT * FROM orders WHERE user_id = 123
UNION ALL
SELECT * FROM orders WHERE status = 'pending' AND user_id != 123;
```

### Connection Pooling

```python
# PostgreSQL with connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:pass@localhost/db',
    poolclass=QueuePool,
    pool_size=20,           # Normal connections
    max_overflow=30,        # Additional when needed
    pool_timeout=30,        # Wait time for connection
    pool_recycle=1800,     # Recycle connections
    pool_pre_ping=True     # Check connection is alive
)

# For async (asyncpg)
import asyncpg
pool = await asyncpg.create_pool(
    min_size=10,
    max_size=30,
    command_timeout=60
)
```

## Anti-Patterns

### 1. Missing Indexes

```sql
-- Query without index - full table scan
SELECT * FROM orders WHERE status = 'pending';

-- Add index
CREATE INDEX idx_orders_status ON orders(status);
```

### 2. SELECT *

```sql
-- BAD
SELECT * FROM orders WHERE id = 123;

-- GOOD - specific columns
SELECT id, user_id, total, status FROM orders WHERE id = 123;
```

### 3. Multiple Queries in Loop

```python
# BAD - N+1 problem
users = get_all_users()
for user in users:
    orders = get_orders_by_user(user.id)  # New query each time!

# GOOD - Single query
users = get_all_users_with_orders()
```

## Failure Modes

- **Optimizing without measuring** → wrong bottleneck targeted → wasted effort with no improvement → profile queries before and after changes
- **Too many indexes** → write performance degrades → slow inserts and updates → audit index usage and remove unused indexes
- **Functions on indexed columns** → index bypass → full table scan → rewrite queries to use sargable expressions
- **Missing composite index order** → suboptimal index usage → slower queries → order composite index columns by selectivity
- **Connection pool exhaustion** → queries queue up → timeout cascades → size pools based on concurrent workload and add overflow
- **Lock contention** → blocked transactions → cascading timeouts → use row-level locks and keep transactions short
- **Stale statistics** → bad query plans → unpredictable performance → run ANALYZE/VACUUM regularly to update planner statistics

## Best Practices

### Monitoring

```sql
-- PostgreSQL: Find slow queries
SELECT query, calls, mean_time, total_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- MySQL: Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;
```

### Configuration

```sql
-- PostgreSQL tuning
-- shared_buffers = 25% of RAM
ALTER SYSTEM SET shared_buffers = '4GB';

-- work_mem = for sorting operations
ALTER SYSTEM SET work_mem = '256MB';

-- maintenance_work_mem = for VACUUM, CREATE INDEX
ALTER SYSTEM SET maintenance_work_mem = '1GB';

-- effective_cache_size = for query planning
ALTER SYSTEM SET effective_cache_size = '12GB';
```

## Technology Stack

| Tool | Use Case |
|------|----------|
| pg_stat_statements | PostgreSQL query stats |
| MySQL Slow Query Log | Query analysis |
| EXPLAIN | Query plans |
| pgAdmin | PostgreSQL GUI |

## Related Topics

- [[SQL]]
- [[Caching]]
- [[NoSQL]]
- [[PerformanceOptimization]]
- [[PerformanceProfiling]]
- [[Monitoring]]
- [[DataStructures]]
- [[Algorithms]]

## Additional Notes

**Key Metrics:**
- Query response time
- Rows scanned vs returned
- Index hit ratio
- Connection pool usage

**Optimization Process:**
1. Identify slow queries
2. Analyze query plan
3. Add or adjust indexes
4. Rewrite queries if needed
5. Verify improvement