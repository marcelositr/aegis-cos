---
title: Disaster Recovery
title_pt: Recuperação de Desastres
layer: devops
type: practice
priority: high
version: 1.0.0
tags:
  - DevOps
  - Reliability
  - Operations
  - Backup
description: Strategies and procedures for recovering systems after catastrophic failures.
description_pt: Estratégias e procedimentos para recuperar sistemas após falhas catastróficas.
prerequisites:
  - Monitoring
  - Infrastructure as Code
estimated_read_time: 12 min
difficulty: advanced
---

# Disaster Recovery

## Description

Disaster Recovery (DR) is the process of restoring systems and data after catastrophic events: data center outages, natural disasters, ransomware, or human errors that cause widespread damage.

Key metrics:
- **RTO (Recovery Time Objective)** — How fast you must recover (e.g., 4 hours)
- **RPO (Recovery Point Objective)** — How much data you can lose (e.g., 1 hour)
- **MTTR (Mean Time To Recovery)** — Average time to restore service
- **Failover** — Switching to backup systems
- **Failback** — Returning to primary systems after recovery

## Purpose

**When disaster recovery planning is essential:**
- Systems with availability SLAs
- Systems storing critical business data
- Compliance requirements (SOC2, HIPAA, PCI)
- When downtime has financial impact
- When data loss is unacceptable

**When DR may be lighter:**
- Development/staging environments
- Internal tools with no business impact
- Disposable infrastructure (can rebuild from IaC)

**The key question:** If this data center burns down, how fast can we be back online and how much data will we lose?

## DR Strategies

### Backup and Restore (Cheapest, Slowest)

```
RTO: Hours to days
RPO: Hours (last backup)
Cost: Low
```

```yaml
# Automated backups
- name: Database Backup
  schedule: "0 */6 * * *"  # Every 6 hours
  action: pg_dump production_db | gzip > backup_$(date +%s).sql.gz
  storage: s3://backups/database/
  retention: 30 days
```

### Pilot Light (Medium Cost, Medium Speed)

```
RTO: Minutes to hours
RPO: Minutes
Cost: Medium
```

Minimal infrastructure always running in DR region. Scale up when disaster strikes.

```yaml
# Terraform - pilot light in DR region
resource "aws_db_instance" "dr_replica" {
  # Read replica in DR region
  source_db_instance_identifier = var.primary_db
  region                        = "us-west-2"
  instance_class                = "db.t3.micro"  # Small, cheap
}

# On disaster: promote replica, scale up
# aws rds promote-read-replica --db-instance-identifier dr-replica
# terraform apply -var="instance_class=db.r5.xlarge"
```

### Warm Standby (Higher Cost, Faster Recovery)

```
RTO: Minutes
RPO: Seconds to minutes
Cost: High
```

Full infrastructure running in DR region, receiving replicated data.

### Active-Active (Most Expensive, Fastest Recovery)

```
RTO: Near-zero
RPO: Near-zero
Cost: Very high
```

Both regions serve traffic simultaneously. Automatic failover.

## Anti-Patterns

### 1. Untested DR Plan

**Bad:** DR plan exists but never tested → fails when needed
**Solution:** Run DR drills quarterly, document results

### 2. No RTO/RPO Targets

**Bad:** "Recover as fast as possible" → no guidance for investment decisions
**Solution:** Define RTO/RPO per system, design DR strategy to match

### 3. Single Region Dependency

**Bad:** All infrastructure in one region → region outage = total outage
**Solution:** Multi-region deployment, even if passive

### 4. Backup Without Restore Testing

**Bad:** Backups exist but no one knows if they work
**Solution:** Automated restore tests, verify data integrity

### 5. Manual DR Process

**Bad:** DR requires humans following runbooks → slow, error-prone
**Solution:** Automate failover with Infrastructure as Code

## Best Practices

1. **Define RTO/RPO per system** — not one-size-fits-all
2. **Test DR regularly** — quarterly drills minimum
3. **Automate failover** — Infrastructure as Code enables rapid recovery
4. **Monitor replication lag** — know your actual RPO
5. **Document runbooks** — clear, step-by-step recovery procedures
6. **Practice blameless post-mortems** — improve DR after each incident
7. **Keep DR infrastructure current** — don't let it drift from production

## Failure Modes

- **Backup corruption** → restore fails → need multiple backup copies
- **Replication lag** → RPO exceeded → data loss on failover
- **DNS propagation delay** → failover takes longer than expected
- **Dependency not in DR** — service recovered but dependency still down
- **Human error during recovery** — wrong commands make things worse → automate
- **DR environment outdated** — IaC drift → recovery produces broken system

## Related Topics

- [[InfrastructureAsCode]] — Automating DR infrastructure
- [[Monitoring]] — Detecting disasters and tracking recovery
- [[SRE]] — RTO/RPO as reliability objectives
- [[BackupStrategies]] — Foundation of disaster recovery
- [[IncidentManagement]] — Coordinating recovery efforts
- [[ChaosEngineering]] — Testing DR by simulating failures
- [[CiCd]] — Deploying to DR region
- [[SecretsManagement]] — Replicating secrets to DR region

## Key Takeaways

- Disaster Recovery restores systems and data after catastrophic events using strategies defined by RTO (recovery time) and RPO (data loss) objectives.
- Use for systems with availability SLAs, critical business data, compliance requirements, or when downtime has financial impact.
- Do NOT over-invest for development/staging environments, internal tools with no business impact, or fully disposable infrastructure rebuildable from IaC.
- Key tradeoff: faster recovery times (active-active) vs. exponentially higher costs; backup-and-restore is cheapest but slowest.
- Main failure mode: untested DR plans that fail when actually needed, or backups that exist but have never been verified for restorability.
- Best practice: define RTO/RPO per system, test DR quarterly with drills, automate failover with IaC, monitor replication lag, and keep DR infrastructure current.
- Related concepts: RTO/RPO, Backup Strategies, Infrastructure as Code, SRE, Chaos Engineering, Incident Management, Multi-Region Deployment.
