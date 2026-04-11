---
title: Schema Evolution
title_pt: Evolução de Schema
layer: databases
type: practice
priority: high
version: 1.0.0
tags:
  - Databases
  - Architecture
  - Migration
  - Compatibility
description: Strategies for evolving database schemas without downtime or data loss.
description_pt: Estratégias para evoluir schemas de banco de dados sem downtime ou perda de dados.
prerequisites:
  - SQL
  - CI/CD
estimated_read_time: 10 min
difficulty: intermediate
---

# Schema Evolution

## Description

Schema evolution is the practice of changing database structures (tables, columns, indexes) without downtime or data loss. In production systems, schema changes must be backward-compatible with running code and forward-compatible with upcoming deployments.

Key concepts:
- **Backward Compatibility** — New schema works with old code
- **Forward Compatibility** — Old schema works with new code
- **Expand-Contract** — Add new, migrate data, remove old
- **Online Migration** — Schema changes without locking tables
- **Zero-Downtime Deployment** — Code and schema changes without service interruption

## Purpose

**When schema evolution is critical:**
- Production databases with 24/7 availability requirements
- Microservices with independent deployment cycles
- Large tables where migrations take minutes or hours
- Systems with multiple services sharing a database

**When schema evolution may be simpler:**
- Development databases (can drop and recreate)
- Single-service applications with maintenance windows
- Small tables where migrations complete instantly

**The key question:** Can I deploy this schema change without stopping the application?

## Patterns

### Expand-Contract (Safest)

```sql
-- Phase 1: EXPAND — Add new column (old code ignores it, new code uses it)
ALTER TABLE users ADD COLUMN email_normalized VARCHAR(255);

-- Deploy new code that writes to both old and new columns

-- Phase 2: MIGRATE — Backfill data
UPDATE users SET email_normalized = LOWER(email) WHERE email_normalized IS NULL;

-- Deploy new code that reads from new column

-- Phase 3: CONTRACT — Remove old column (after confirming all code uses new)
ALTER TABLE users DROP COLUMN email;
```

### Online Index Creation

```sql
-- PostgreSQL: CREATE INDEX CONCURRENTLY (doesn't lock table)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- MySQL: pt-online-schema-change
-- pt-online-schema-change --alter "ADD INDEX idx_email (email)" D=mydb,t=users
```

### Parallel Schema Change

```python
# Code that works with both old and new schema
class UserRepository:
    def get_user_email(self, user_id):
        # Try new column first
        result = self.db.query(
            "SELECT email_normalized FROM users WHERE id = %s", user_id
        )
        if result and result.email_normalized:
            return result.email_normalized
        
        # Fallback to old column
        result = self.db.query(
            "SELECT email FROM users WHERE id = %s", user_id
        )
        return result.email
```

## Anti-Patterns

### 1. Breaking Changes in Single Migration

**Bad:** `ALTER TABLE users DROP COLUMN email, ADD COLUMN email_normalized`
**Solution:** Use expand-contract pattern — add first, remove later

### 2. Long-Running Migrations Without Testing

**Bad:** Migration on 100M row table → 2-hour table lock → outage
**Solution:** Test migration time on production-sized data, use online tools

### 3. No Rollback Plan

**Bad:** Migration fails halfway → corrupted schema → manual recovery
**Solution:** Test rollback, use transactions where possible

### 4. Schema Drift Between Environments

**Bad:** Dev schema differs from production → migration fails in prod
**Solution:** Run migrations in CI, use migration tools (Flyway, Alembic)

### 5. Ignoring Index Impact

**Bad:** Adding column without considering index → slow queries
**Solution:** Plan indexes alongside column changes, create concurrently

## Best Practices

1. **Always backward-compatible** — old code must work with new schema
2. **Use migration tools** — Flyway, Alembic, Liquibase for versioned migrations
3. **Test on production-sized data** — migrations that work on 100 rows may fail on 100M
4. **Monitor migration progress** — long migrations need visibility
5. **Run during low traffic** — minimize impact of schema locks
6. **Version your schema** — track migration state
7. **Never drop data immediately** — soft delete first, hard delete later

## Failure Modes

- **Table lock during migration** — application hangs → timeout → outage
- **Migration fails mid-way** — partial schema change → data inconsistency
- **Code deployed before migration** — new code expects column that doesn't exist → crash
- **Migration deployed before code** — old code writes to wrong column → data loss
- **Index creation locks table** — writes blocked → application errors
- **Foreign key check fails** — orphaned records prevent schema change

## Related Topics

- [[SQL]] — Schema definition and constraints
- [[DatabaseOptimization]] — Index strategy during schema changes
- [[CiCd]] — Running migrations as part of deployment pipeline
- [[Microservices]] — Database per service simplifies schema evolution
- [[DDD]] — Bounded contexts reduce shared schema complexity
- [[CQRS]] — Separate read/write models simplify schema changes
- [[Monitoring]] — Tracking migration progress and impact
- [[DisasterRecovery]] — Rollback plans for failed migrations

## Key Takeaways

- Schema evolution changes database structures without downtime by ensuring backward and forward compatibility between schema versions and running code.
- Use for production databases with 24/7 availability, microservices with independent deployments, or large tables where migrations take significant time.
- Do NOT over-engineer for development databases, single-service apps with maintenance windows, or small tables where migrations complete instantly.
- Key tradeoff: zero-downtime deployments vs. multi-phase migration complexity requiring careful coordination between code and schema changes.
- Main failure mode: table locks during migration on large tables causing application hangs and outages.
- Best practice: use the expand-contract pattern (add new, migrate, remove old), always maintain backward compatibility, use online migration tools, and test on production-sized data.
- Related concepts: Expand-Contract Pattern, Online Migrations, Flyway, Alembic, CQRS, DDD, CI/CD, Database per Service.
