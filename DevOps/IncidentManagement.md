---
title: Incident Management
title_pt: Gerenciamento de Incidentes
layer: devops
type: concept
priority: high
version: 1.0.0
tags:
  - DevOps
  - SRE
  - Operations
  - On-Call
description: Structured approach to responding to, managing, and learning from production incidents.
description_pt: Abordagem estruturada para responder, gerenciar e aprender com incidentes de produção.
prerequisites:
  - Observability
  - Alerting
estimated_read_time: 10 min
difficulty: intermediate
---

# Incident Management

## Description

Incident Management is the structured process of responding to, resolving, and learning from production incidents. It encompasses everything from detecting issues through alerts, through diagnosis and remediation, to conducting post-mortems and implementing improvements.

## Purpose

**When structured incident management adds value:**
- Complex systems with many dependencies
- High-availability requirements (99.9%+ SLA)
- Multiple teams contributing to system operation
- When you need to reduce MTTR (Mean Time To Recovery)
- Regulatory compliance requiring documented processes

**When simplified processes work:**
- Small teams with single/simple systems
- Low traffic applications where brief outages are acceptable
- Early-stage startups prioritizing speed over process

**The key question:** When something breaks at 3am, does your team know exactly what to do?

## Rules

1. **Detect fast** - Good alerting + observability
2. **Respond faster** - Clear escalation paths
3. **Communicate early** - Stakeholders need awareness
4. **Fix root cause** - Address the underlying issue, not symptoms
5. **Learn always** - Post-mortem leads to prevention

## Examples

### Incident Severity Levels

| Level | Response Time | Example |
|-------|---------------|----------|
| SEV1 | Immediate | Complete service outage |
| SEV2 | 15 min | Major feature broken |
| SEV3 | 1 hour | Degraded performance |
| SEV4 | 4 hours | Minor issue, cosmetic |

### Runbook Example

```markdown
# Database Connection Errors Runbook

## Symptoms
- 5xx errors on /api/users
- High database CPU
- Connection pool exhausted

## Diagnosis
1. Check pg_stat_activity
2. Identify long-running queries
3. Check for recent deployments

## Remediation
1. Kill blocking queries: SELECT pg_terminate_backend(pid)...
2. Scale up database temporarily
3. Rollback recent changes if needed

## Escalation
- If > 30 min: escalate to DBA
- If data loss suspected: escalate to security
```

### Incident Communication Template

```markdown
# Incident Update

## Status: INVESTIGATING
## Severity: SEV2
## Duration: 25 min

### What's happening
Payment service returning 500 errors

### Impact
- 30% of checkout requests failing
- No data loss detected

### Actions taken
- Identified database connection spike
- Scaling up connection pool

### Next steps
- Monitor for 10 minutes
- Prepare rollback if needed

### ETA for resolution: 45 min
```

## Anti-Patterns

### 1. Blame-Oriented Post-Mortems

```markdown
# BAD
- John forgot to add index
- Dev team was careless

# GOOD
- Index was missing because migration didn't include it
- How can we detect this automatically next time?
```

### 2. Ignoring Low-Severity Issues

```python
# BAD - "It's just a 5% error rate, not urgent"
# Eventually escalates to SEV1

# GOOD
- Investigate all error rates > 1%
- Address patterns before they grow
```

### 3. No Clear Ownership

```python
# BAD - Everyone looks, no one acts
# "I thought you were handling it"

# GOOD
- Incident commander explicitly assigned
- Clear ownership until resolved
```

## Failure Modes

- **Delayed detection** → incidents go unnoticed → extended downtime → implement automated alerting with SLO-based thresholds
- **Unclear ownership** → no incident commander → chaotic response → assign IC role immediately upon incident declaration
- **Poor communication** → stakeholders uninformed → duplicated effort → use standardized incident communication templates
- **Blame-oriented post-mortems** → team hides issues → recurring incidents → focus on systemic causes, not individuals
- **Missing runbooks** → responders improvise → slower MTTR → maintain updated runbooks for common failure scenarios
- **Alert fatigue** → critical alerts ignored → missed incidents → tune alert thresholds and implement severity tiers
- **No escalation path** → incident stalls → prolonged outage → define clear time-based escalation policies

## Best Practices

### On-Call Rotation

```
Requirements:
- Maximum 12-hour shifts
- Maximum 3 consecutive nights
- Minimum 2 people per rotation
- Clear escalation path

Compensation:
- On-call pay or time off
- Training on systems
- Reduced responsibilities during on-call
```

### Post-Mortem Template

```markdown
# Incident Post-Mortem

## Summary
Database lock contention caused 45min outage

## Timeline (UTC)
- 14:00 - Alert triggered
- 14:05 - Incident declared
- 14:20 - Root cause identified
- 14:45 - Resolution deployed

## Root Cause
Migration created table lock on orders table
Queries blocked, connection pool exhausted

## What Went Well
- Alert detected quickly (30s)
- Rollback completed in 5 min

## What Went Wrong
- Runbook didn't include kill-long-queries step
- No canary deployment to catch this

## Action Items
- [ ] Add query kill step to runbook (Owner: Jane, Due: Friday)
- [ ] Add canary deployment for migrations (Owner: Team, Due: Q2)
- [ ] Add migration review checklist (Owner: Tom, Due: Monday)
```

### Incident Commander Role

```
Responsibilities:
1. Own the incident response
2. Make final decisions on actions
3. Ensure communication happens
4. Decide when to escalate

Powers:
- Command all incident responders
- Call in additional resources
- Make trade-off decisions (speed vs. safety)

Hand-off:
- Explicit handoff to next IC
- Brief on current state
- Confirm handoff accepted
```

## Related Topics

- [[Monitoring]]
- [[Alerting]]
- [[ChaosEngineering]]
- [[Logging]]
- [[CiCd]]
- [[LoadTesting]]
- [[PerformanceOptimization]]
- [[PostMortems]]

## Additional Notes

**Key Metrics:**
- MTTD (Mean Time To Detect) - How fast you find issues
- MTTR (Mean Time To Recover) - How fast you fix them
- MTTM (Mean Time To Mitigate) - How fast you reduce impact

Goal is to reduce all three through better alerting, runbooks, and automation.