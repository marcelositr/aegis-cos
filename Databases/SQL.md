---
title: SQL
title_pt: SQL (Structured Query Language)
layer: databases
type: concept
priority: high
version: 1.0.0
tags:
  - Databases
  - SQL
  - Relational
  - Concept
description: Relational database concepts, design, and optimization.
description_pt: Conceitos, design e otimização de banco de dados relacional.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# SQL

## Description

SQL (Structured Query Language) is the standard language for managing relational databases. SQL databases organize data into tables with rows and columns, using a schema to define structure. They provide ACID (Atomicity, Consistency, Isolation, Durability) guarantees, making them reliable for transactional systems.

Key SQL concepts:
- **Tables** - Collections of rows with columns
- **Schemas** - Logical grouping of tables
- **Indexes** - Data structures for fast lookups
- **Constraints** - Rules for data integrity
- **Joins** - Combining related tables
- **Transactions** - Atomic operations

SQL is essential for:
- Transactional systems (banking, e-commerce)
- Complex reporting and analytics
- Data warehousing
- Applications requiring strong consistency

Modern SQL databases include PostgreSQL, MySQL, SQL Server, and Oracle. Each has extensions and features, but core SQL is standardized.

## Purpose

**When SQL is appropriate:**
- For transactional applications
- When ACID compliance is needed
- For complex queries and joins
- For structured data with clear schema

**When alternatives are better:**
- For unstructured data
- When horizontal scaling is critical
- For rapid prototyping
- For document-like data

## Rules

1. **Normalize appropriately** - Don't over-normalize
2. **Index strategically** - For frequently queried columns
3. **Use constraints** - Ensure data integrity
4. **Write efficient queries** - Avoid SELECT *
5. **Use connection pooling** - Manage connections
6. **Back up regularly** - Prevent data loss
7. **Monitor performance** - Track slow queries

## Examples

### Table Design

```sql
-- Users table with constraints
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Orders table with foreign key
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP,
    
    CONSTRAINT valid_status CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    CONSTRAINT positive_total CHECK (total >= 0)
);

-- Order items
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT unique_order_product UNIQUE (order_id, product_id)
);

-- Indexes for performance
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

### Queries

```sql
-- Join multiple tables
SELECT 
    u.username,
    o.id AS order_id,
    o.status,
    o.total,
    oi.product_id,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.created_at >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.created_at DESC;

-- Aggregation with window functions
SELECT 
    u.id AS user_id,
    u.username,
    COUNT(o.id) AS total_orders,
    SUM(o.total) AS total_spent,
    AVG(o.total) AS avg_order_value,
    MAX(o.created_at) AS last_order_date,
    RANK() OVER (ORDER BY SUM(o.total) DESC) AS spending_rank
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled')
GROUP BY u.id, u.username
ORDER BY total_spent DESC;

-- CTE for complex logic
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        COUNT(*) AS order_count,
        SUM(total) AS revenue
    FROM orders
    WHERE created_at >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', created_at)
),
running_total AS (
    SELECT 
        month,
        order_count,
        revenue,
        SUM(revenue) OVER (ORDER BY month) AS cumulative_revenue
    FROM monthly_sales
)
SELECT 
    TO_CHAR(month, 'YYYY-MM') AS month,
    order_count,
    revenue,
    cumulative_revenue,
    ROUND(100.0 * revenue / LAG(revenue) OVER (ORDER BY month) - 100, 2) AS growth_percent
FROM running_total
ORDER BY month;
```

### Transactions

```sql
-- Atomic transaction
BEGIN;

-- Update inventory
UPDATE products 
SET stock_quantity = stock_quantity - 5 
WHERE id = 123 AND stock_quantity >= 5;

-- Create order
INSERT INTO orders (user_id, total, status)
VALUES (456, 99.99, 'confirmed')
RETURNING id;

-- Create order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES 
    (789, 123, 2, 29.99),
    (789, 456, 1, 40.00);

-- Commit or rollback
COMMIT;

-- Example with savepoint
BEGIN;
    INSERT INTO orders (user_id, total) VALUES (1, 100);
    SAVEPOINT order_created;
    
    -- If this fails, can rollback to savepoint
    INSERT INTO order_items (order_id, product_id, quantity) 
    VALUES (currval('orders_id_seq'), 1, 1);
    
    -- But if something goes wrong:
    ROLLBACK TO SAVEPOINT order_created;
    
COMMIT;
```

### Views and Functions

```sql
-- View for common query
CREATE OR REPLACE VIEW user_order_summary AS
SELECT 
    u.id AS user_id,
    u.username,
    u.email,
    COUNT(o.id) AS total_orders,
    COALESCE(SUM(o.total), 0) AS lifetime_value,
    MAX(o.created_at) AS last_order,
    CASE 
        WHEN MAX(o.created_at) >= CURRENT_DATE - INTERVAL '30 days' THEN 'active'
        WHEN MAX(o.created_at) >= CURRENT_DATE - INTERVAL '90 days' THEN 'at_risk'
        ELSE 'inactive'
    END AS engagement_status
FROM users u
LEFT JOIN orders o ON u.id = o.user_id AND o.status != 'cancelled'
GROUP BY u.id, u.username, u.email;

-- Stored function
CREATE OR REPLACE FUNCTION calculate_discount(
    p_total DECIMAL,
    p_customer_tier VARCHAR
) RETURNS DECIMAL AS $$
BEGIN
    CASE p_customer_tier
        WHEN 'platinum' THEN
            RETURN p_total * 0.20; -- 20% discount
        WHEN 'gold' THEN
            RETURN p_total * 0.15; -- 15% discount
        WHEN 'silver' THEN
            RETURN p_total * 0.10; -- 10% discount
        ELSE
            RETURN 0; -- No discount
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
```

## Anti-Patterns

### 1. SELECT *

```sql
-- BAD - Gets all columns
SELECT * FROM orders WHERE id = 123;

-- GOOD - Only needed columns
SELECT id, status, total, created_at 
FROM orders WHERE id = 123;
```

### 2. N+1 Queries

```sql
-- BAD - Multiple queries in loop (usually in code)
-- For each user, fetch orders separately

-- GOOD - Single query with JOIN
SELECT u.*, o.*
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```

### 3. Missing Indexes

```sql
-- If you frequently query:
WHERE email = 'user@example.com'
-- Add index
CREATE INDEX idx_users_email ON users(email);

-- For composite queries:
WHERE status = 'pending' AND created_at > '2024-01-01'
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
```

## Failure Modes

- **Missing indexes on WHERE columns** → full table scans → query timeout under load → analyze query plans and add targeted indexes
- **N+1 query patterns** → excessive database round trips → connection pool exhaustion → use JOINs or eager loading instead of loops
- **No connection pooling** → connection creation overhead → degraded throughput under concurrency → implement connection pooling with proper sizing
- **Unparameterized queries** → SQL injection → data breach or destruction → always use parameterized queries or ORM
- **SELECT * usage** → unnecessary data transfer → memory pressure and slow queries → select only required columns
- **Long-running transactions** → lock contention → blocked queries and timeouts → keep transactions short and use appropriate isolation levels
- **No backup strategy** → data loss from failure → unrecoverable data → implement automated backups with regular restore testing

## Best Practices

### Connection Pooling

```python
# Python with connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:pass@localhost/mydb',
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

### Query Optimization

```sql
-- Use EXPLAIN ANALYZE to see query plan
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders 
WHERE user_id = 123 
AND created_at > '2024-01-01';

-- Create covering index for frequently used queries
CREATE INDEX idx_orders_user_date 
ON orders(user_id, created_at) 
INCLUDE (status, total);
```

## Technology Stack

| Database | Use Case |
|----------|----------|
| PostgreSQL | Feature-rich, open source |
| MySQL | Web applications |
| SQL Server | Enterprise Windows |
| Oracle | Enterprise large scale |

## Related Topics

- [[NoSQL]]
- [[DatabaseOptimization]]
- [[Caching]]
- [[SQLInjection]]
- [[DataStructures]]
- [[Complexity]]
- [[Monitoring]]
- [[BackupAndRecovery]]

## Additional Notes

**Key Concepts:**
- ACID properties
- Normalization
- Indexes
- Transactions

**Optimization Tips:**
- Use EXPLAIN ANALYZE
- Index WHERE clauses
- Avoid SELECT *
- Use connection pooling

**PostgreSQL Features:**
- JSON support
- Full-text search
- Arrays
- Window functions