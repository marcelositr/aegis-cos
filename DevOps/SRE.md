---
title: SRE
title_pt: Engenharia de Confiabilidade do Site
layer: devops
type: concept
priority: high
version: 1.0.0
tags:
  - DevOps
  - SRE
  - Reliability
  - Operations
description: Site Reliability Engineering practices for building and maintaining reliable systems at scale.
description_pt: Práticas de Engenharia de Confiabilidade do Site para construir e manter sistemas confiáveis em escala.
prerequisites:
  - Monitoring
  - Observability
estimated_read_time: 15 min
difficulty: advanced
---

# SRE

## Description

Site Reliability Engineering (SRE) is a discipline that applies software engineering principles to operations problems. Created by Google, SRE bridges the gap between development and operations by treating operations as a software problem.

Core SRE concepts:
- **SLI (Service Level Indicator)** — What you measure (latency, error rate, throughput)
- **SLO (Service Level Objective)** — Your target for the SLI (99.9% availability)
- **SLA (Service Level Agreement)** — Contract with users, includes penalties
- **Error Budget** — How much unreliability you can afford (100% - SLO)
- **Burn Rate** — How fast you're consuming your error budget
- **Toil** — Manual, repetitive, automatable operational work

## Purpose

**When SRE practices are essential:**
- Production systems with availability requirements
- Teams managing services at scale
- Organizations with multiple services and dependencies
- When you need data-driven reliability decisions
- When incident response needs structure

**When SRE may be overkill:**
- Single-service applications
- Internal tools with no SLA
- Early-stage startups still finding product-market fit
- When you can't measure your system yet

**The key question:** What level of reliability do we need, and what's the cost of achieving it?

## Rules

1. **Define SLIs before SLOs** — you can't set objectives without knowing what to measure
2. **Set SLOs based on user experience** — not technical metrics
3. **Use error budgets for release decisions** — no budget = no risky changes
4. **Track burn rate, not just error rate** — 0.1% errors over 1 hour ≠ 0.1% over 30 days
5. **Eliminate toil** — automate repetitive operational work

## SLI/SLO Examples

### Availability SLO

```
SLI: Percentage of successful requests
SLO: 99.9% of requests return 2xx over 30-day window
Error Budget: 0.1% = ~43 minutes of downtime per month
```

### Latency SLO

```
SLI: Request latency (p99)
SLO: 99% of requests complete in < 200ms over 30-day window
Error Budget: 1% of requests can be slow
```

### Throughput SLO

```
SLI: Requests per second handled
SLO: System handles 1000 RPS without degradation
```

## Burn Rate Alerting

```python
# Burn rate = (actual error rate) / (error budget rate)
# If SLO is 99.9%, error budget is 0.1%
# If actual error rate is 1%, burn rate = 1% / 0.1% = 10x

# Multi-window burn rate alerts:
# Fast burn (2% budget in 1 hour) → page immediately
# Slow burn (5% budget in 6 hours) → page during business hours
# Long burn (10% budget in 3 days) → ticket, investigate

# Prometheus burn rate rule
# 99.9% SLO → 0.1% error budget
# Fast burn: 14.4x budget consumption rate over 5 minutes
record: slo_error_budget_burn_rate:ratio_rate5m
expr: |
    (1 - (
        sum(rate(http_requests_total{status=~"5.."}[5m]))
        /
        sum(rate(http_requests_total[5m]))
    )) / 0.001
```

## Error Budget Policy

```
Error Budget Exhaustion Policy:

1. Budget remaining > 50% → Normal operations
2. Budget remaining 20-50% → Review recent changes
3. Budget remaining 5-20% → Freeze risky deployments
4. Budget remaining < 5% → Only critical fixes, full review

Budget Reset: Rolling 30-day window
```

## Anti-Patterns

### 1. SLOs Without User Impact

**Bad:** SLO on internal metric users don't experience
**Solution:** SLIs should map to user experience (can they use the product?)

### 2. 100% SLO

**Bad:** Setting 100% availability → zero error budget → no deployments
**Solution:** 99.9% or 99.95% — allow room for improvement and change

### 3. Ignoring Error Budget

**Bad:** SLOs defined but deployments continue when budget is exhausted
**Solution:** Make error budget a gate for risky changes

### 4. Too Many SLOs

**Bad:** 50 SLOs per service → no one knows what matters
**Solution:** 3-5 SLOs per service, focused on user-critical paths

### 5. No Toil Reduction

**Bad:** SRE team doing manual ops work → no time for engineering
**Solution:** Cap toil at 50% of SRE time, automate the rest

## Best Practices

1. **Start with user journeys** — what does the user actually experience?
2. **Measure before setting targets** — baseline first, then set SLOs
3. **Use multi-window burn rate** — catch both fast and slow degradation
4. **Make error budget visible** — dashboard everyone can see
5. **Blameless post-mortems** — focus on system fixes, not individual blame
6. **Automate toil** — if you do it twice, automate it
7. **Review SLOs regularly** — adjust as user expectations change

## Failure Modes

- **Wrong SLI** → measuring the wrong thing → false sense of reliability
- **SLO too tight** → constant budget exhaustion → team can't ship features
- **SLO too loose** → users experience outages → trust erosion
- **No burn rate alerting** → budget exhausted before anyone notices
- **Ignoring toil** → SRE team becomes ops team → no engineering improvements
- **Siloed SRE** → SRE team owns reliability alone → developers don't care

## Related Topics

- [[Observability]] — SLIs come from observability data
- [[Monitoring]] — Traditional monitoring feeds into SRE
- [[Alerting]] — Burn rate alerts replace threshold alerts
- [[IncidentManagement]] — SRE drives incident response
- [[ChaosEngineering]] — Proactively testing reliability
- [[CiCd]] — Error budget gates deployment decisions
- [[Microservices]] — SRE for distributed systems
- [[DistributedSystems]] — Reliability across service boundaries
- [[PerformanceOptimization]] — Latency SLOs drive optimization
- [[CapacityPlanning]] — Throughput SLOs drive capacity decisions

## Key Takeaways

- SRE applies software engineering to operations, using SLIs, SLOs, error budgets, and burn rate alerting to make data-driven reliability decisions.
- Use for production systems with availability requirements, teams managing services at scale, or when incident response needs structure.
- Do NOT use for single-service applications, internal tools with no SLA, early-stage startups, or when you can't measure your system yet.
- Key tradeoff: quantifiable reliability targets enabling feature velocity vs. discipline required to respect error budgets and reduce toil.
- Main failure mode: setting 100% SLOs (zero error budget, no deployments possible) or defining SLIs that don't map to actual user experience.
- Best practice: define SLIs before SLOs based on user journeys, use multi-window burn rate alerting, cap toil at 50% of SRE time, and run blameless post-mortems.
- Related concepts: SLI/SLO/SLA, Error Budgets, Burn Rate, Toil Reduction, Observability, Incident Management, Chaos Engineering, Blameless Post-Mortems.
