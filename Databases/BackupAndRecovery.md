---
title: Backup and Recovery
aliases:
  - Backup and Recovery
  - BackupAndRecovery
  - Backup Strategies
  - BackupStrategies
  - DataBackup
  - DisasterRecovery
layer: infrastructure
type: concept
priority: critical
version: 1.0.0
tags:
  - DevOps
  - Databases
  - Backup
  - Recovery
  - DisasterRecovery
description: Strategies for protecting data through backups and ensuring reliable recovery: full, incremental, differential, point-in-time recovery, and disaster recovery procedures.
prerequisites:
  - "[[DisasterRecovery]]"
  - "[[DatabaseOptimization]]"
estimated_read_time: 8 min
difficulty: intermediate
---

# Backup and Recovery

## Description

Strategies for protecting data through backups and ensuring reliable recovery: full, incremental, differential, point-in-time recovery (PITR), and disaster recovery procedures. Spans both infrastructure (DevOps) and data (Databases) domains.

## Purpose

**When to use:**
- Any system with data that cannot be recreated from scratch
- Compliance requirements (RPO/RTO defined in SLAs)
- Protection against human error, hardware failure, ransomware, natural disasters
- Before any major migration or schema change

**When to avoid:**
- Ephemeral data that is regenerated automatically
- When backup cost exceeds the value of the data being protected
- Prototyping with no production data

## Backup Types

| Type | What it backs up | Restore speed | Storage cost | Speed |
|------|-----------------|---------------|-------------|-------|
| **Full** | Entire dataset | Fast (single file) | High | Slow |
| **Incremental** | Changes since last backup (any type) | Slow (need full + all incrementals) | Low | Fast |
| **Differential** | Changes since last full backup | Medium (need full + last differential) | Medium | Fast |
| **Continuous (WAL/binlog)** | Every transaction log entry | Slowest (replay from backup point) | Medium | Real-time capture |

### Recommended Strategy

- **Weekly full backup** + **daily incremental** + **continuous WAL/binlog** for PITR
- Balance between storage cost, backup window, and recovery time
- Test restore procedures monthly, not just backup creation

## Point-in-Time Recovery (PITR)

Enables restoring database to any specific moment, not just the last backup point.

```sql
-- PostgreSQL PITR
-- 1. Base restore from backup
-- 2. Replay WAL segments to specific time

-- In postgresql.conf:
-- wal_level = replica
-- archive_mode = on
-- archive_command = 'cp %p /archive/%f'

-- Recovery to specific point:
-- recovery_target_time = '2025-03-15 14:30:00 UTC'
```

**When PITR is critical:**
- Accidental data deletion or corruption
- Ransomware recovery (restore to pre-infection point)
- Compliance audit requirements
- Schema migration rollback

## Rules

1. **3-2-1 rule**: 3 copies, 2 different media, 1 offsite
2. **Test restores regularly** — a backup you haven't tested restoring is not a backup
3. **Encrypt backup data** — backups are high-value targets for attackers
4. **Monitor backup jobs** — alert on failures, don't assume success
5. **Document recovery procedures** — runbooks should be executable under stress

## Examples

### Good Example — Automated Backup Pipeline

```yaml
# Backup configuration with monitoring and validation
backup:
  schedule: "0 2 * * *"  # Daily at 2 AM
  type: incremental
  full_backup_schedule: "0 2 * * 0"  # Weekly full backup on Sunday
  retention:
    daily: 30
    weekly: 12
    monthly: 12
  storage:
    primary: "s3://backups-prod/database/"
    secondary: "gs://backups-dr/database/"  # Cross-cloud DR
  encryption:
    enabled: true
    kms_key: "alias/backup-encryption-key"
  validation:
    checksum: true
    test_restore: true
    test_restore_schedule: "0 6 * * 1"  # Weekly test restore on Monday
  monitoring:
    alert_on_failure: true
    alert_channel: "#ops-alerts"
    max_backup_age_hours: 26  # Alert if backup is older than 26 hours
```

### Bad Example — Unmonitored Cron Job

```bash
# Crontab entry with no monitoring, no validation, no encryption
0 2 * * * pg_dump -h localhost -U postgres mydb > /tmp/backup.sql
```

**Why it's bad:** No error handling, no monitoring (backup could silently fail), no encryption (backup file is plaintext), no offsite copy (lost if server dies), no retention policy (disk fills up), no test restore (may be corrupted).

## Anti-Patterns

### The Schrödinger Backup

A backup that has never been tested and may or may not work when needed.

**Why it's bad:** Backup success does not equal restore success. Corruption, incomplete data, or wrong format may only be discovered during an emergency. Test restores are the only validation.

### Backup Without Retention Policy

Accumulating backups indefinitely without cleanup, or deleting too aggressively.

**Why it's bad:** Either storage overflow or inability to find a restore point when needed. Define retention based on compliance requirements (e.g., keep monthly backups for 7 years for financial data).

### Single-Point Backup Storage

All backups stored on the same infrastructure as the primary data.

**Why it's bad:** If the infrastructure fails (datacenter outage, ransomware), backups fail with it. Always maintain offsite, ideally cross-cloud or cross-region copies.

## Failure Modes

- **Silent backup failures** → data loss when automated backups fail without alerting → implement monitoring and alerting on backup job status, check backup file size and checksums
- **Backup corruption** → unrecoverable data when backup files incomplete or damaged → validate backups with checksums, perform regular test restores, store checksums separately
- **Recovery procedure failures** → extended downtime when recovery procedures untested or outdated → regularly test recovery procedures in staging, document step-by-step runbooks, conduct disaster recovery drills
- **Long recovery times** → extended downtime when only full backups available → use incremental and differential backups, maintain warm standby for critical systems
- **Storage overflow** → backup jobs fail when storage runs out → implement retention policies with automatic cleanup, monitor storage utilization, alert on capacity thresholds
- **Backup window violations** → backup operations impact production performance during business hours → schedule backups during off-peak, use incremental backups, implement parallel processing
- **Point-in-time recovery gaps** → data loss when WAL or binlog not properly configured or corrupted → enable continuous archiving, monitor WAL/binlog health, test PITR regularly
- **Encrypted backup key loss** → backups exist but cannot be decrypted → store encryption keys in KMS with access controls, backup keys separately from backup data
- **Ransomware targeting backups** → attackers encrypt or delete backups before encrypting production data → use immutable storage (S3 Object Lock), air-gapped backups, separate credentials for backup access

## Best Practices

- **Automate everything** — backup creation, validation, rotation, alerting
- **Test restores monthly** — the only backup that matters is the one that restores successfully
- **Follow 3-2-1 rule** — 3 copies, 2 media types, 1 offsite (ideally cross-cloud)
- **Encrypt backup data and keys** — store keys separately from backup data
- **Monitor backup health** — alert on failures, file size anomalies, age thresholds
- **Document recovery runbooks** — step-by-step procedures that can be executed under stress at 3 AM
- **Conduct DR drills quarterly** — simulate datacenter failure, ransomware, accidental deletion
- **Implement immutable backups** — use WORM (Write Once Read Many) storage to prevent ransomware deletion
- **Define and track RPO/RTO** — Recovery Point Objective (max data loss) and Recovery Time Objective (max downtime)
- **Version backup configurations** — track changes in version control, review before modifications

## Related Topics

- [[DisasterRecovery]]
- [[DatabaseOptimization]]
- [[SecretsManagement]]
- [[Monitoring]]
- [[IncidentManagement]]
- [[ChaosEngineering]]
- [[Redis]]

## Key Takeaways

- A backup is only valid if it has been successfully restored at least once
- Follow 3-2-1 rule: 3 copies, 2 media, 1 offsite
- Combine full + incremental + continuous logs for PITR capability
- Primary failure mode: silent backup corruption discovered only during emergency
- Define RPO/RTO before designing backup strategy — requirements drive architecture
- Monitor backup age, size, and checksums — alert on anomalies
- Conduct DR drills quarterly — practice makes recovery predictable
