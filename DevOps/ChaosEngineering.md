---
title: Chaos Engineering
title_pt: Engenharia do Caos
layer: devops
type: concept
priority: high
version: 1.0.0
tags:
  - DevOps
  - Resilience
  - Testing
  - SRE
description: Deliberately injecting failures into systems to test resilience and discover weaknesses before they cause outages.
description_pt: Injeção deliberada de falhas em sistemas para testar resiliência e descobrir vulnerabilidades antes de causar interrupções.
prerequisites:
  - DistributedSystems
  - Observability
estimated_read_time: 12 min
difficulty: advanced
---

# Chaos Engineering

## Description

Chaos Engineering is the discipline of experimenting on a system to build confidence in its ability to withstand turbulent conditions in production. It involves deliberately introducing faults (killing services, adding latency, corrupting data) to observe how the system responds and improve its resilience.

## Purpose

**When chaos engineering adds value:**
- Complex distributed systems where failure modes are unknown
- Systems requiring high availability (99.9%+ SLA)
- After major architectural changes or migrations
- To validate disaster recovery procedures
- When you need confidence in fallback mechanisms

**When chaos engineering is unnecessary:**
- Simple single-instance applications
- Systems with low availability requirements
- Early development stages (before production-like environments)
- When the cost of experimentation exceeds the risk tolerance

**The key question:** What would happen if this component suddenly failed? Can we find out before users experience it?

## Rules

1. **Start small** - Experiment on non-critical components first
2. **Define steady state** - Establish what "normal" looks like before testing
3. **Minimize blast radius** - Limit impact to specific services or regions
4. **Never break production on purpose** - Use read-only or replay-safe experiments
5. **Automate and measure** - Make chaos part of CI/CD, measure resilience metrics

## Examples

### Netflix Chaos Monkey

```python
# Example: Randomly terminating instances
import random
import boto3

def terminate_instance():
    ec2 = boto3.client('ec2')
    
    # Get running instances in non-production
    instances = ec2.describe_instances(
        Filters=[
            {'Name': 'tag:Environment', 'Values': ['staging']},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )
    
    instance_ids = [i['InstanceId'] for r in instances['Reservations'] 
                    for i in r['Instances']]
    
    if instance_ids:
        target = random.choice(instance_ids)
        ec2.terminate_instances(InstanceIds=[target])
        print(f"Terminated: {target}")

# Run during business hours only
if is_business_hours():
    terminate_instance()
```

### Latency Injection

```python
# Adding network latency to test timeout handling
import asyncio
import random

async def inject_latency(request):
    delay = random.choice([0.5, 1.0, 2.0, 5.0])  # seconds
    await asyncio.sleep(delay)
    return await process_request(request)

# Test: Does your service handle 5s latency gracefully?
```

### Failure Mode Testing

```yaml
# Kubernetes chaos experiment manifest
apiVersion: v1
kind: Pod
metadata:
  name: chaos-pod
spec:
  containers:
  - name: chaos-tool
    image: chaos-tool:latest
    env:
    - name: EXPERIMENT_TYPE
      value: "pod-kill"
    - name: TARGET_LABEL
      value: "app=payment-service"
    - name: PERCENTAGE
      value: "25"
```

## Anti-Patterns

### 1. Testing in Production Without Guardrails

```python
# BAD - No safety measures
def chaos_experiment():
    kill_all_services()  # Never do this!

# GOOD - Controlled blast radius
def chaos_experiment():
    target_group = get_non_critical_services()
    max_impact = 0.1  # Max 10% of instances
    kill_percentage(target_group, max_impact)
```

### 2. Not Measuring Impact

```python
# BAD - "Let's see what happens"
run_chaos()
# Hope for the best...

# GOOD - Define success metrics beforehand
def chaos_experiment():
    baseline = measure_error_rate()
    run_chaos()
    actual = measure_error_rate()
    assert actual < baseline + 0.05  # Max 5% degradation
```

### 3. No Rollback Plan

```python
# BAD
run_chaos()
# Uh oh, can't recover...

# GOOD
def chaos_experiment():
    snapshot = backup_state()
    try:
        run_chaos()
    finally:
        restore(snapshot)  # Always cleanup
```

## Best Practices

### Experiment Design

```
1. Hypothesis: "If the database fails, the cache will handle reads"
2. Steady state: Normal error rate < 1%
3. Experiment: Kill primary database
4. Measure: Cache hit rate, error rate, latency
5. Outcome: Did we meet the hypothesis?
```

### Tools

- **Chaos Monkey** - Netflix's random instance terminator
- **Litmus** - Kubernetes-native chaos engineering
- **Gremlin** - Commercial chaos platform
- **Chaos Mesh** - Cloud-native chaos engineering
- **AWS Fault Injection Simulator** - Managed chaos

### Runbook Template

```markdown
# Experiment: Service Pod Kill

## Hypothesis
Application handles pod restarts without user impact

## Steady State
- Error rate < 1%
- P99 latency < 500ms

## Experiment
Kill 1 pod every 30 seconds for 5 minutes

## Success Criteria
- Error rate remains < 1%
- No 5xx errors during restart
- Client-side retries work

## Rollback
Auto-healing replaces pods within 60 seconds

## Contacts
- On-call: @sre-team
- Slack: #chaos-engineering
```

## Failure Modes

- **Experiment too aggressive** → takes down production → start in staging, use blast radius controls
- **No steady state defined** → can't tell if experiment succeeded → define metrics before running
- **Missing rollback plan** → can't stop experiment → system stays broken → automatic abort conditions
- **Running without monitoring** → can't observe impact → experiment is useless → full observability required
- **Team not informed** → on-call panics during experiment → communicate schedule, use game days
- **Only testing known failures** → false confidence → explore unknown failure modes
- **No hypothesis** → running experiments without purpose → waste of time

## Related Topics

- [[Monitoring]]
- [[IncidentManagement]]
- [[LoadTesting]]
- [[Kubernetes]]
- [[Alerting]]
- [[Logging]]
- [[CiCd]]
- [[PerformanceProfiling]]

## Additional Notes

**Primer's 7 Steps:**
1. Define steady state
2. Hypothesize that steady state continues
3. Introduce real-world failure
4. Verify steady state broke
5. Mitigate or accept the risk
6. Fix root cause
7. Expand scope

Start with low-impact experiments and gradually increase scope as confidence builds.

## Key Takeaways

- Chaos Engineering deliberately injects failures into systems to build confidence in their ability to withstand turbulent production conditions.
- Use for complex distributed systems with unknown failure modes, high availability requirements (99.9%+), or after major architectural changes.
- Do NOT use for simple single-instance applications, early development stages, or when the cost of experimentation exceeds risk tolerance.
- Key tradeoff: discovering hidden failure modes before users do vs. risk of causing real outages if experiments are poorly controlled.
- Main failure mode: experiments too aggressive without blast radius controls, taking down production systems unexpectedly.
- Best practice: define steady state metrics first, start small in non-critical components, always have a rollback plan, and communicate experiment schedules.
- Related concepts: SRE, Observability, Incident Management, Load Testing, Resilience Testing, Game Days, Fault Injection.