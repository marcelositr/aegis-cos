---
title: Auto Scaling
layer: architecture
type: concept
priority: high
version: 2.0.0
tags:
  - Architecture
  - Scaling
  - Cloud
  - Resilience
  - CostOptimization
description: Automatically adjusting compute resources based on demand to maintain SLOs and optimize infrastructure costs.
---

# Auto Scaling

## Description

Auto scaling is the automated provisioning and deprovisioning of compute capacity in response to real-time or predicted workload metrics. It operates on a control loop: observe metrics, evaluate against thresholds or models, and adjust capacity. The goal is to maintain service-level objectives (p99 latency, error rate, throughput) while minimizing idle resource costs.

Auto scaling is not a single mechanism — it is a control system. Like any control system, it has latency (time to detect, decide, and actuate), stability concerns (oscillation, thrashing), and tuning parameters (thresholds, cooldown, step sizes) that must be calibrated against your workload characteristics.

## When to Use

- **Diurnal or event-driven traffic patterns** — your traffic varies by >3x between peak and trough, making static over-provisioning economically wasteful. Example: an e-commerce platform that sees 10x traffic spikes during flash sales or holiday seasons.
- **Unpredictable burst workloads** — viral content launches, API consumers with irregular batch patterns, or ML inference endpoints with sporadic load.
- **Background processing pipelines** — worker pools that consume from message queues (SQS, RabbitMQ, Kafka consumer groups) where queue depth is a direct signal for required capacity.
- **Cost-sensitive environments** — staging/dev environments that can scale to zero during off-hours, or production workloads on spot/preemptible instances that benefit from dynamic capacity management.

## When NOT to Use

- **Flat, predictable traffic** — if your p95 and p50 traffic differ by <20% over a month, auto scaling adds operational complexity without meaningful cost savings.
- **Stateful services without migration strategy** — databases with in-memory caches, WebSocket servers with sticky sessions, or services holding TCP connections to clients. Scaling these in/out requires connection draining and session migration that may be more complex than it's worth.
- **Cold-start-sensitive latency SLAs** — if your SLO requires sub-200ms p99 and your container runtime has 5-15s cold starts, reactive scaling will breach SLAs on every scale-out event. Use predictive scaling or over-provision a warm pool instead.
- **Teams without observability maturity** — if you cannot reliably distinguish between a traffic spike and a downstream degradation causing request pile-up, auto scaling will amplify the problem rather than solve it.

## Tradeoffs

| Dimension | Static Over-Provisioning | Reactive Auto Scaling | Predictive Auto Scaling |
|-----------|-------------------------|----------------------|------------------------|
| **Cost** | 40-70% waste during off-peak | 10-30% waste | 5-15% waste |
| **Response latency** | 0 (always warm) | 2-15 min for new instances | 30s-2 min (pre-warmed) |
| **Operational complexity** | Low | Medium-High | High |
| **Risk of under-provisioning** | None | Moderate (lag time) | Low (if model is accurate) |
| **Thundering herd resilience** | High | Medium (depends on step size) | High (capacity pre-provisioned) |

**The fundamental tradeoff**: every scaling decision is a bet about future load. Reactive scaling bets that the current trend will continue. Predictive scaling bets that historical patterns will repeat. Static provisioning bets that the cost of waste is lower than the cost of being wrong.

### Horizontal vs. Vertical Scaling

Horizontal scaling (adding instances) is the default for cloud-native systems because it avoids single-point-of-failure and enables geographic distribution. Vertical scaling (increasing instance size) is appropriate for stateful workloads (databases, caches) where data migration would be disruptive, but it hits hard ceilings (max instance size) and requires downtime or live migration.

## Alternatives

- **Static capacity planning** — size for peak + 20% buffer. Correct choice when traffic is flat and predictable, or when you have hard SLOs that cannot tolerate scaling latency.
- **Request shedding / load shedding** — drop low-priority requests during overload rather than adding capacity. Used by CDNs, API gateways, and systems at the edge of failure. Preferable to scaling when cost of added capacity exceeds cost of dropped requests.
- **Concurrency tuning** — increasing thread pools, connection pools, or async I/O on existing instances before scaling out. Often the cheapest first step: a service running at 40% CPU with misconfigured thread pools may handle 3x more load after tuning.
- **Caching layers** — Redis, Memcached, or CDN caching can reduce backend load by 10-100x for read-heavy workloads. Always consider caching before auto scaling read paths.

## Failure Modes

1. **Scaling lag breaches SLOs** — the gap between metric crossing threshold and new instance being ready is 3-15 minutes. During this window, existing instances are overloaded and p99 latency spikes. Mitigation: use predictive scaling for known patterns, lower thresholds, or maintain a warm pool of 1-2 standby instances.

2. **Scale-in kills in-flight requests** — terminating an instance that is processing long-running requests (file uploads, batch jobs, streaming connections) causes client-visible failures. Mitigation: implement connection draining (AWS ALB deregistration delay), graceful SIGTERM handlers that finish in-flight work, and scale-in protection for critical nodes.

3. **Metric feedback loop / thrashing** — CPU-based scaling where each new instance causes CPU to drop below threshold, triggering scale-in, which raises CPU again, triggering scale-out. Observed in practice with 2-3 minute oscillation cycles. Mitigation: use longer evaluation windows (5-10 min, not 1 min), add hysteresis (different thresholds for scale-out vs scale-in), or switch to queue-depth-based scaling which is more stable.

4. **Scaling on the wrong metric** — scaling on CPU utilization when the bottleneck is database connections or external API rate limits. The application scales out, but every new instance adds more connections to the already-saturated database, making the problem worse. Mitigation: identify the actual bottleneck metric (connection pool utilization, downstream latency, queue depth) and scale on that.

5. **Thundering herd on scale-out** — 50 new instances boot simultaneously, all pulling container images from the same registry, all connecting to the same database, all warming the same caches. This causes registry throttling, connection pool exhaustion, and cache stampedes. Mitigation: stagger instance boot with step scaling (add 5 at a time, not 50), use pre-baked AMIs/images, implement connection pooling proxies (PgBouncer, ProxySQL), and warm caches lazily.

6. **Cost explosion from misconfigured max bounds** — a bug causes infinite request loops or a DDoS attack, and auto scaling faithfully provisions hundreds of instances. A real incident: a misconfigured health check caused a service to scale from 3 to 200 instances in 20 minutes, resulting in a $12,000 surprise bill. Mitigation: always set absolute `max_instances` based on budget, configure billing alerts, and use rate-limited scaling policies.

7. **Downstream cascade from scaled-up consumers** — auto scaling API consumers that call a downstream service without its own scaling causes the downstream to collapse. The scaling system is doing its job correctly, but it's pushing load onto an unprepared dependency. Mitigation: implement backpressure ([[Backpressure]]), coordinate scaling across service boundaries, or use bulkheads ([[BulkheadPattern]]).

8. **Spot instance termination without fallback** — scaling with spot/preemptible instances saves 60-90% but instances can be terminated with 30s-2min notice. If the scaling group cannot replace capacity fast enough, you get a capacity shortfall. Mitigation: use mixed instance policies (70% spot + 30% on-demand), implement the two-minute termination handler, and have on-demand fallback capacity.

## Real-World Configuration Examples

### Kubernetes HPA — CPU-based with stabilization

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 3
  maxReplicas: 50
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 65
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 120
      policies:
        - type: Pods
          value: 5
          periodSeconds: 60
        - type: Percent
          value: 50
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Pods
          value: 2
          periodSeconds: 120
        - type: Percent
          value: 10
          periodSeconds: 300
      selectPolicy: Min
```

Key design decisions:
- `minReplicas: 3` — survives single AZ failure, provides baseline capacity
- `averageUtilization: 65` — target below 100% to leave headroom for traffic spikes and avoid running at the edge of degradation
- Scale-up stabilization of 120s prevents reacting to 30s metric spikes
- Scale-up limited to 5 pods or 50% per minute — prevents thundering herd
- Scale-down stabilization of 300s (5 minutes) — longer window prevents thrashing
- Scale-down limited to 2 pods or 10% per 5 minutes — conservative drain

### AWS Auto Scaling — Queue-depth-based worker scaling

```json
{
  "AutoScalingGroupName": "order-processing-workers",
  "MinSize": 2,
  "MaxSize": 100,
  "DesiredCapacity": 2,
  "TargetTrackingConfiguration": {
    "CustomizedMetricSpecification": {
      "MetricName": "ApproximateNumberOfMessagesVisible",
      "Namespace": "AWS/SQS",
      "Dimensions": [
        {
          "Name": "QueueName",
          "Value": "order-processing-queue"
        }
      ],
      "Statistic": "Average"
    },
    "TargetValue": 10.0
  }
}
```

This scales so that each worker instance has approximately 10 messages queued for it. If the queue has 500 messages, the group scales to 50 instances. The target value of 10 represents the acceptable backlog per worker — tune based on your processing latency SLO.

### Terraform — Scale-to-zero dev environment

```hcl
resource "aws_appautoscaling_target" "dev_api" {
  max_capacity       = var.is_production ? 20 : 5
  min_capacity       = var.is_production ? 3 : 0
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  schedule {
    scalable_target_action {
      min_capacity = 0
      max_capacity = 0
    }
    # Scale to zero at 8pm UTC on non-production
    schedule = var.is_production ? "" : "cron(0 20 ? * MON-FRI *)"
  }
}
```

## Best Practices

1. **Always set absolute max capacity** — base it on your monthly budget divided by per-instance cost. No exceptions.
2. **Scale on the bottleneck metric, not the convenient metric** — if your bottleneck is database connections, scale on connection count, not CPU.
3. **Use asymmetric scale policies** — scale out aggressively (low threshold, fast response), scale in conservatively (high threshold, slow response). The cost of being under-provisioned (SLO breach) is almost always higher than the cost of being over-provisioned (wasted compute).
4. **Prefer queue-depth or request-latency metrics over CPU** — CPU is a lagging indicator. Queue depth is a leading indicator of impending overload.
5. **Implement graceful shutdown** — handle SIGTERM, drain connections, finish in-flight work, deregister from load balancer before termination. Without this, every scale-in event generates errors.
6. **Test scaling in production under controlled load** — synthetic load tests do not capture real traffic patterns. Use canary deployments of scaling policies and monitor for 2-4 weeks before full rollout.
7. **Document your scaling assumptions** — what metric, what threshold, why that threshold, what is the expected scale-out time, what is the cost at max capacity. This is critical for incident response.
8. **Coordinate scaling across tiers** — if your API scales from 3 to 50 instances, your database connection pool, cache, and downstream services must handle 16x more concurrent connections.
9. **Use instance warm-up periods** — new instances take time to start, pass health checks, warm caches, and reach full throughput. Configure warm-up (AWS: `InstanceWarmup`, K8s: `stabilizationWindowSeconds`) to match your actual startup time, not the default.
10. **Budget-alert before you scale-alert** — configure billing alerts at 50%, 75%, and 90% of your expected monthly spend. Auto scaling without cost visibility is financial suicide.

## Related Topics

- [[Resilience]] — auto scaling as a resilience mechanism for handling overload
- [[Backpressure]] — complementary technique when scaling alone is insufficient
- [[CircuitBreaker]] — use together with scaling to prevent cascading failures
- [[BulkheadPattern]] — isolate scaled resources to prevent cross-service impact
- [[RateLimiting]] — control input load so scaling operates within predictable bounds
- [[Monitoring]] and [[Observability]] — you cannot scale what you cannot measure
- [[Kubernetes]] and [[ContainerOrchestration]] — primary platforms for implementing auto scaling
- [[Serverless]] — ultimate auto scaling where scaling is abstracted away
- [[CostOptimization]] and [[ErrorBudgets]] — economic constraints on scaling decisions
- [[Idempotency]] — critical when scaling causes request replays or duplicate processing
- [[LoadBalancing]] — auto scaling requires a load balancer to distribute traffic across instances
- [[CloudComputing]] — auto scaling is a core cloud-native capability
