---
title: ConnectionPooling
title_pt: Pool de Conexões
layer: performance
type: concept
priority: high
version: 1.0.0
tags:
  - Performance
  - Database
  - Connections
description: Managing database and service connections efficiently.
description_pt: Gerenciando conexões de banco de dados e serviços eficientemente.
prerequisites:
  - SQL
  - DatabaseOptimization
estimated_read_time: 10 min
difficulty: intermediate
---

# Connection Pooling

## Description

[[ConnectionPooling]] maintains a pool of pre-established database connections that can be reused, avoiding the overhead of establishing a new connection for each request.

Key concepts:
- **Pool size** — Number of maintained connections
- **Connection acquisition** — Borrowing from pool
- **Connection release** — Returning to pool
- **Pool eviction** — Removing dead connections

## Purpose

**When connection pooling is essential:**
- High-throughput applications
- Any application with repeated database access
- Microservices with database per service

**When simpler approaches work:**
- Very low traffic applications
- One-time batch jobs

**The key question:** Can your application handle the connection overhead without pooling?

## Implementation

### Database Connection Pool

```python
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

# Create pooled engine
engine = create_engine(
    'postgresql://user:pass@localhost/mydb',
    poolclass=QueuePool,
    pool_size=10,          # Base connections
    max_overflow=20,       # Extra on demand
    pool_pre_ping=True,    # Test on checkout
    pool_recycle=3600,     # Recycle after 1 hour
    pool_timeout=30        # Wait max 30s
)

# Usage: each request uses pooled connection
with engine.connect() as conn:
    result = conn.execute(text("SELECT * FROM users"))
```

### HTTP Connection Pool

```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Create session with connection pooling
session = requests.Session()

# Configure retry strategy
retry_strategy = Retry(
    total=3,
    backoff_factor=1,
    status_forcelist=[429, 500, 502, 503, 504]
)

# Configure adapter with pool
adapter = HTTPAdapter(
    pool_connections=10,
    pool_maxsize=20,
    max_retries=retry_strategy
)

session.mount("http://", adapter)
session.mount("https://", adapter)
```

## Failure Modes

- **Pool exhaustion** → All connections in use → requests timeout → increase pool size or add circuit breaker
- **Stale connections** → Dead connections in pool → failed queries → use connection validation (pre-ping)
- **Connection leaks** → Connections not returned → pool empties → use context managers or finally blocks
- **Pool saturation** → Too many concurrent requests → slow responses → implement queuing or reduce concurrency

## Anti-Patterns

### 1. No Connection Pooling

**Bad:** New connection for each request
```python
# Expensive!
def query(sql):
    conn = psycopg2.connect(DB_URL)  # New connection each time
    cursor = conn.cursor()
    cursor.execute(sql)
    return cursor.fetchall()
```

**Good:** Use connection pool
```python
# Fast!
pool = ConnectionPool(10)

def query(sql):
    conn = pool.get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(sql)
        return cursor.fetchall()
    finally:
        conn.return_to_pool()
```

### 2. Wrong Pool Size

**Bad:** Too small or too large
```python
# Too small: constant contention
pool = ConnectionPool(2)  # Too small for 100 concurrent users

# Too large: resource waste
pool = ConnectionPool(1000)  # Wastes file descriptors
```

**Good:** Right-size based on workload
```python
# Match to concurrency and database capacity
pool = ConnectionPool(
    size=20,              # Base: concurrent requests / 5
    max_overflow=10,      # Burst capacity
    timeout=30           # Don't wait forever
)
```

### 3. Not Returning Connections

**Bad:** Connection leak
```python
# Forgot to return
def query(sql):
    conn = pool.get()
    result = do_something(conn)
    # Forgot: conn.return_to_pool()
    return result
```

**Good:** Always release
```python
def query(sql):
    conn = pool.get()
    try:
        return do_something(conn)
    finally:
        conn.return_to_pool()  # Always release

# Or use context manager
def query(sql):
    with pool.connection() as conn:
        return do_something(conn)
```

## Best Practices

### 1. Monitor Pool Metrics

```python
# Track pool health
pool = create_engine(...)

# Log pool stats
print(f"Pool size: {pool.size()}")
print(f"Checked out: {pool.checkedout()}")
print(f"Overflow: {pool.overflow()}")
print(f"Invalid: {pool.invalidated()}")
```

### 2. Use Pre-ping

```python
# Test connection before use
engine = create_engine(
    'postgresql://...',
    pool_pre_ping=True  # Validates on checkout
)
```

### 3. Set Appropriate Timeouts

```python
# Don't wait forever
engine = create_engine(
    'postgresql://...',
    pool_timeout=30,       # 30 second timeout
    pool_recycle=3600      # Recycle connections hourly
)
```

## Related Topics

- [[SQL]] — Database connections
- [[DatabaseOptimization]] — Query performance
- [[PerformanceOptimization]] — Overall performance

## Key Takeaways

- Connection pooling avoids connection establishment overhead
- Size pool based on concurrent users and database capacity
- Always return connections in finally blocks or context managers
- Use pool_pre_ping to detect stale connections
- Monitor pool metrics: size, checked out, overflow, invalid
- Set timeouts to prevent indefinite waits