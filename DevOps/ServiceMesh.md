---
title: Service Mesh
title_pt: Service Mesh
layer: devops
type: pattern
priority: medium
version: 1.0.0
tags:
  - DevOps
  - ServiceMesh
  - Microservices
description: Infrastructure layer for managing service-to-service communication.
description_pt: Camada de infraestrutura para gerenciar comunicação serviço-a-serviço.
prerequisites:
  - Kubernetes
  - Microservices
---

# Service Mesh

## Description

A service mesh provides a dedicated infrastructure layer for handling service-to-service communication in microservices architectures. It handles:
- Service discovery
- Load balancing
- Circuit breaking
- Observability
- Security (mTLS)

Popular implementations:
- **Istio** - Most feature-rich
- **Linkerd** - Lightweight, CNCF project
- **Consul Connect** - HashiCorp ecosystem

## Purpose

**When a service mesh is valuable:**
- Large microservices deployments (10+ services)
- When you need uniform observability across services
- For implementing zero-trust security
- When network reliability is critical

**When a service mesh adds unnecessary complexity:**
- Small deployments (under 5 services)
- Simple architectures
- When team lacks Kubernetes expertise
- When latency overhead is unacceptable

**The key question:** Do you need consistent communication handling across many services?

## Examples

### Istio Configuration

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        x-canary:
          exact: "true"
    route:
    - destination:
        host: reviews
        subset: v2
      weight: 20
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 80
```

### mTLS Configuration

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
```

## Failure Modes

- **Sidecar resource exhaustion** → proxy consumes excessive memory/CPU → application degradation → monitor sidecar resource usage and set limits
- **mTLS misconfiguration** → service-to-service communication breaks → cascading failures → test mTLS in permissive mode before enforcing STRICT
- **Control plane outage** → no config updates → stale routing → run control plane with high availability and backup configs
- **Configuration drift** → inconsistent policies → unpredictable behavior → version control all mesh configurations and use GitOps
- **Latency overhead accumulation** → each hop adds proxy delay → unacceptable end-to-end latency → benchmark and optimize proxy settings
- **Egress gateway bottleneck** → single point of failure for outbound traffic → service isolation → deploy redundant egress gateways
- **Certificate rotation failure** → expired certs → mTLS breakdown → automate cert rotation and monitor expiration dates

## Anti-Patterns

### 1. Service Mesh for Small Deployments

**Bad:** Deploying Istio or Linkerd for an application with 3 services
**Why it's bad:** The operational complexity, resource overhead, and learning curve far exceed the benefits — you are solving a problem you do not have
**Good:** Start with simple service discovery and load balancing — add a service mesh only when you have 10+ services and need uniform observability, mTLS, or traffic management

### 2. Enabling All Features at Once

**Bad:** Turning on mTLS, traffic splitting, rate limiting, observability, and policy enforcement in the initial deployment
**Why it's bad:** When something breaks, you cannot determine which feature caused it — the blast radius of misconfiguration is the entire mesh
**Good:** Start with minimal configuration — enable features incrementally as needs arise, testing each one before enabling the next

### 3. Ignoring Sidecar Resource Overhead

**Bad:** Deploying sidecar proxies without monitoring their CPU and memory consumption
**Why it's bad:** Sidecars consume resources on every pod — across hundreds of services, the aggregate overhead can be significant, causing application degradation
**Good:** Monitor sidecar resource usage, set resource limits, and benchmark the latency overhead — factor sidecar costs into capacity planning

### 4. mTLS Without Testing

**Bad:** Switching mTLS to STRICT mode without testing in PERMISSIVE mode first
**Why it's bad:** Any misconfigured service immediately loses connectivity — the entire mesh can break if even one service is not properly configured for mTLS
**Good:** Test mTLS in PERMISSIVE mode first — monitor for connection failures, fix misconfigurations, then switch to STRICT

## Best Practices

1. **Start with minimal configuration** - Enable features as needed
2. **Monitor sidecar resource usage** - Memory/CPU overhead
3. **Use egress control** - Control outbound traffic
4. **Implement gradual rollout** - Canary for config changes
5. **Plan for failure** - Mesh itself is a single point of failure

## Related Topics

- [[Kubernetes]]
- [[Docker]]
- [[ContainerOrchestration]]
- [[Monitoring]]
- [[TlsSsl]]
- [[APIDesign]]
- [[REST]]
- [[Logging]]

## Key Takeaways

- A service mesh provides a dedicated infrastructure layer for handling service-to-service communication, including discovery, load balancing, circuit breaking, observability, and mTLS.
- Use in large microservices deployments (10+ services) needing uniform observability, zero-trust security, or critical network reliability.
- Do NOT use for small deployments under 5 services, simple architectures, or when latency overhead from sidecar proxies is unacceptable.
- Key tradeoff: consistent communication handling and security across services vs. added operational complexity and per-hop latency.
- Main failure mode: sidecar resource exhaustion or mTLS misconfiguration causing cascading communication failures across all services.
- Best practice: start with minimal configuration, monitor sidecar resource usage, use egress control, and implement gradual rollout for config changes.
- Related concepts: Kubernetes, Envoy Proxy, mTLS, Observability, Circuit Breaker, API Gateway, Istio, Linkerd.