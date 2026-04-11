---
title: Alerting
title_pt: Alertas
layer: devops
type: practice
priority: medium
version: 1.0.0
tags:
  - DevOps
  - Alerting
  - Monitoring
description: Practices for creating and managing alerts.
description_pt: Práticas para criar e gerenciar alertas.
---

# Alerting

## Description

Alerting notifies teams when issues occur in production. Effective alerting requires well-designed alerts that are actionable and don't overwhelm on-call teams.

Key concepts:
- **Alert** - Notification of a condition
- **Incident** - Ongoing problem requiring response
- **Runbook** - Response procedures
- **Escalation** - Who gets notified



## Purpose

**When alerting is essential:**
- Production systems with users depending on availability
- Systems with SLOs that must be maintained
- Distributed systems where failures are hard to detect manually
- On-call teams that need actionable notifications

**When alerting may be lighter:**
- Development/staging environments
- Internal tools with no SLA
- Early-stage prototypes with no real users

**The key question:** If this system fails at 3am, who needs to know and how urgently?

## Examples

### Alert Rule Configuration

```yaml
# Prometheus alert rule
- alert: HighErrorRate
  expr: rate(http_requests_errors[5m]) / rate(http_requests_total[5m]) > 0.05
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"
    runbook_url: "https://wiki.runbooks.io/high-error-rate"
```

### Severity Levels

| Level | Response Time | Example |
|-------|---------------|----------|
| P1 | Immediate | Complete outage |
| P2 | 15 min | Major feature down |
| P3 | 1 hour | Degraded performance |
| P4 | Next business day | Minor issue |

## Anti-Patterns

### 1. Alert Fatigue

**Bad:** Alerting on every metric deviation — CPU spikes, memory usage, request latency — regardless of whether it affects users
**Why it's bad:** The team receives hundreds of alerts per day and learns to ignore them all — real incidents are buried in the noise and response times degrade
**Good:** Alert only on symptoms that affect users (error rate, latency, availability) — use dashboards for metrics that are informative but not actionable

### 2. Alerts Without Runbooks

**Bad:** An alert fires at 3am and the on-call engineer has no documentation on how to respond
**Why it's bad:** MTTR increases dramatically — the engineer spends time investigating instead of remediating, and the wrong fix can make things worse
**Good:** Every alert must have a runbook — document the expected response procedure, common causes, and escalation paths before the alert goes live

### 3. Alerting on Causes Instead of Symptoms

**Bad:** Alerting on "CPU > 80%" or "disk usage > 90%" without correlating to user impact
**Why it's bad:** High CPU may be normal during batch processing, and high disk usage may not affect service quality — the alert fires but there is nothing to do
**Good:** Alert on user-facing symptoms — error rate, latency, throughput — these indicate real problems that require action, regardless of the underlying cause

### 4. Missing Alerts for Critical Paths

**Bad:** No alerts for core business functions — payments, authentication, data processing — because "we assumed it would be covered"
**Why it's bad:** Users discover outages before engineers — the team is reactive instead of proactive, and SLA breaches occur before anyone is aware
**Good:** Map critical user journeys and ensure every one has alerting coverage — if a system failing at 3am would be a disaster, it must have an alert

## Best Practices

- **Alert on symptoms, not causes** — "error rate > 5%" not "CPU > 80%"
- **Set appropriate severity levels** — P1 for outages, P4 for minor issues
- **Create runbooks for each alert** — every alert must have an action
- **Minimize noise** — alert fatigue kills on-call culture
- **Use error budgets** — don't alert when within budget
- **Page humans, not bots** — if no action needed, it's not an alert

## Failure Modes

- **Alert fatigue** — too many alerts → team ignores → real incidents missed
- **Missing alerts** — silent failures → users discover before engineers
- **Wrong severity** — P4 for outage → delayed response → SLA breach
- **No runbook** — alert fires → engineer doesn't know what to do → longer MTTR

## Related Topics

- [[Monitoring]]
- [[Logging]]
- [[IncidentManagement]]
- [[CiCd]]
- [[ChaosEngineering]]
- [[PerformanceOptimization]]
- [[LoadTesting]]
- [[SRE]]