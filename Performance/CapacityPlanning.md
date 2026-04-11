---
title: Capacity Planning
title_pt: Planejamento de Capacidade
layer: performance
type: practice
priority: high
version: 1.0.0
tags:
  - Performance
  - Operations
  - Planning
description: Predicting future resource needs based on growth, load patterns, and performance requirements.
description_pt: Prevendo necessidades futuras de recursos com base em crescimento, padrões de carga e requisitos de performance.
prerequisites:
  - Monitoring
  - Performance Profiling
estimated_read_time: 10 min
difficulty: intermediate
---

# Capacity Planning

## Description

Capacity planning is the practice of predicting future resource needs (CPU, memory, storage, network) based on growth trends, load patterns, and performance requirements. It prevents both over-provisioning (wasted money) and under-provisioning (outages).

Key concepts:
- **Headroom** — Buffer between current usage and capacity limit
- **Utilization** — Percentage of resource being used
- **Saturation** — Queue depth when resource is fully utilized
- **Growth rate** — How fast resource consumption increases
- **Peak vs Average** — Planning for peaks, not averages

## Purpose

**When capacity planning is essential:**
- Systems with growth trajectories
- Systems with seasonal/cyclical load patterns
- When infrastructure costs are significant
- When outages from capacity exhaustion are costly
- Before major launches or marketing campaigns

**When capacity planning may be lighter:**
- Serverless environments (auto-scales transparently)
- Very small systems with predictable, flat load
- Early-stage prototypes

**The key question:** At current growth rate, when will we run out of resources?

## Capacity Model

```python
# Simple capacity projection
def project_capacity(
    current_usage: float,
    growth_rate_monthly: float,
    max_capacity: float,
    headroom_target: float = 0.2
) -> dict:
    """
    When will we hit our headroom target?
    """
    usage = current_usage
    months = 0
    target = max_capacity * (1 - headroom_target)
    
    while usage < target:
        usage *= (1 + growth_rate_monthly)
        months += 1
    
    return {
        "months_until_action": months,
        "projected_usage": usage,
        "action": "scale_up" if months < 3 else "monitor"
    }

# Example: 50% CPU, 10% monthly growth, 80% target
result = project_capacity(
    current_usage=0.50,
    growth_rate_monthly=0.10,
    max_capacity=1.0,
    headroom_target=0.20
)
# → months_until_action: 4, action: "monitor"
```

## Load Modeling

```
Traffic model:
- Average: 1000 requests/second
- Peak: 5000 requests/second (5x average)
- Growth: 20% month-over-month
- Resource per request: 2ms CPU, 50KB memory

Current capacity:
- 10 servers × 4 cores = 40 cores
- 10 servers × 8GB = 80GB RAM
- Max throughput: 40 cores / 0.002s = 20,000 RPS

At current growth:
- Month 1: 1000 × 1.2 = 1,200 RPS (6% of capacity)
- Month 6: 1000 × 1.2^6 = 2,986 RPS (15% of capacity)
- Month 12: 1000 × 1.2^12 = 8,916 RPS (45% of capacity)
- Month 18: 1000 × 1.2^18 = 26,623 RPS (133% → NEED MORE CAPACITY)
```

## Anti-Patterns

### 1. Planning for Average, Not Peak

**Bad:** Sizing for 1000 RPS average → 5000 RPS peak crashes system
**Solution:** Size for peak + headroom, or implement auto-scaling

### 2. No Growth Projection

**Bad:** "We have enough capacity now" → runs out in 3 months
**Solution:** Project growth, set alerts at 60% and 80% utilization

### 3. Single Resource Focus

**Bad:** Monitoring CPU but running out of disk IOPS
**Solution:** Monitor all resources: CPU, memory, disk, network, connections

### 4. Static Capacity

**Bad:** Fixed infrastructure → can't handle traffic spikes
**Solution:** Auto-scaling groups, serverless, or elastic resources

## Best Practices

1. **Monitor all resources** — CPU, memory, disk, network, connections, file descriptors
2. **Set utilization alerts** — 60% (plan), 80% (act), 90% (emergency)
3. **Model growth** — project 3, 6, 12 months ahead
4. **Plan for peaks** — not averages
5. **Test capacity** — load test to find actual limits
6. **Automate scaling** — don't rely on manual intervention
7. **Review quarterly** — update projections with actual data

## Failure Modes

- **Silent saturation** — resource at 100% but no alert → gradual degradation
- **Wrong metric** — monitoring CPU but bottleneck is disk I/O
- **Scaling too slow** — auto-scaling takes 5 minutes → 5 minutes of degraded service
- **Scaling too aggressive** — scale up on spike → scale down immediately → oscillation
- **Cost explosion** — auto-scaling without budget guardrails → surprise bill

## Related Topics

- [[PerformanceOptimization]] — Reducing resource needs per request
- [[PerformanceProfiling]] — Identifying resource bottlenecks
- [[LoadTesting]] — Finding actual capacity limits
- [[Monitoring]] — Tracking resource utilization trends
- [[SRE]] — Capacity as reliability objective
- [[AutoScaling]] — Automated capacity adjustment
- [[CloudComputing]] — Elastic capacity on demand
- [[DistributedSystems]] — Capacity across multiple nodes

## Key Takeaways

- Capacity planning predicts future resource needs based on growth trends, load patterns, and performance requirements to prevent over- or under-provisioning.
- Use for systems with growth trajectories, seasonal/cyclical load patterns, significant infrastructure costs, or before major launches.
- Do NOT over-invest for serverless environments (auto-scales transparently), very small flat-load systems, or early-stage prototypes.
- Key tradeoff: avoiding costly outages through proactive scaling vs. risk of over-provisioning and wasted infrastructure spend.
- Main failure mode: planning for average load instead of peak, causing system crashes during traffic spikes.
- Best practice: monitor all resources (CPU, memory, disk, network), set utilization alerts at 60/80/90%, model growth 3-12 months ahead, and automate scaling.
- Related concepts: Auto Scaling, Load Testing, Performance Profiling, Monitoring, SRE, Cloud Computing, Headroom Planning.
