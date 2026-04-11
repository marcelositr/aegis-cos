---
title: Container Orchestration
title_pt: Orquestração de Containers
layer: devops
type: concept
priority: high
version: 1.0.0
tags:
  - DevOps
  - Containers
  - Orchestration
  - Kubernetes
description: Managing containerized applications at scale.
description_pt: Gerenciando aplicações containerizadas em escala.
prerequisites:
  - DevOps
  - Docker
estimated_read_time: 15 min
difficulty: intermediate
---

# Container Orchestration

## Description

Container orchestration automates deployment, scaling, and management of containerized applications. Tools like Kubernetes, Docker Swarm, and Nomad handle:

- **Scheduling**: Which node runs which container
- **Scaling**: Adding/removing containers based on load
- **Service Discovery**: Finding services across containers
- **Load Balancing**: Distributing traffic
- **Health Monitoring**: Detecting and replacing failed containers
- **Rolling Updates**: Deploying new versions without downtime

## Purpose

**When container orchestration is essential:**
- For microservices architectures with multiple services
- When you need automatic scaling
- For high availability requirements
- When managing multiple environments (dev, staging, prod)
- For self-healing infrastructure

**When simpler deployment works:**
- For single applications
- When scale is predictable and low
- For development/staging without production needs
- When team lacks Kubernetes expertise

**The key question:** Do we need automated management of multiple containers across multiple hosts?

## Rules

1. **Use declarative configurations** - Define desired state, not steps
2. **Implement health checks** - Liveness and readiness probes
3. **Configure resource limits** - Prevent resource starvation
4. **Use namespaces** - Isolate environments and teams
5. **Implement RBAC** - Control access to cluster

## Examples

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "250m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Kubernetes Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

### Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Anti-Patterns

### 1. No Resource Limits

```yaml
# BAD - No limits, can starve other pods
containers:
- name: app
  image: my-app:latest

# GOOD - Set limits
containers:
- name: app
  image: my-app:latest
  resources:
    limits:
      memory: "256Mi"
      cpu: "500m"
```

### 2. No Health Checks

```yaml
# BAD - Kubernetes doesn't know if app is healthy
containers:
- name: app
  image: my-app:latest

# GOOD - Health checks enabled
containers:
- name: app
  image: my-app:latest
  livenessProbe:
    httpGet:
      path: /health
      port: 8080
```

### 3. Running as Root

```yaml
# BAD - Security risk
containers:
- name: app
  image: my-app:latest
  securityContext:
    runAsUser: 0

# GOOD - Run as non-root
containers:
- name: app
  image: my-app:latest
  securityContext:
    runAsUser: 1000
    runAsNonRoot: true
```

## Failure Modes

- **No resource limits** → resource starvation → cascading pod failures → set CPU/memory requests and limits on all containers
- **Missing health checks** → unhealthy pods receive traffic → user-facing errors → configure liveness and readiness probes
- **Running as root** → container escape → privilege escalation → enforce runAsNonRoot and drop all capabilities
- **No pod disruption budgets** → simultaneous pod evictions → service outage → define PDBs for critical workloads
- **Image pull failures** → deployments stuck → unavailable services → use image pull secrets and local registry caching
- **Misconfigured autoscaling** → over/under-provisioning → wasted cost or degraded performance → tune HPA metrics and cooldown periods
- **Etcd cluster failure** → control plane down → no scheduling or scaling → run etcd with redundancy and regular backups

## Best Practices

### 1. Use ConfigMaps and Secrets

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: "db.example.com"
  LOG_LEVEL: "info"
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
data:
  # Base64 encoded!
  DB_PASSWORD: c2VjcmV0
```

### 2. Implement Proper Networking

```yaml
# Use NetworkPolicies to restrict traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-policy
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
```

### 3. Use Namespaces for Isolation

```bash
# Create namespaces
kubectl create namespace production
kubectl create namespace staging
kubectl create namespace development

# Apply quota per namespace
kubectl apply -f quota.yaml
```

## Related Topics

- [[Docker]]
- [[Kubernetes]]
- [[ServiceMesh]]
- [[Monitoring]]
- [[CiCd]]
- [[InfrastructureAsCode]]
- [[GitOps]]
- [[LoadTesting]]

## Additional Notes

**Orchestration Tools:**
- Kubernetes - Most popular, feature-rich
- Docker Swarm - Simpler, Docker-native
- Nomad - Simple, flexible
- Amazon ECS/EKS - Cloud-managed
- Google GKE - Cloud-managed

**Key Concepts:**
- Pod: Smallest deployable unit
- ReplicaSet: Ensures pod count
- Deployment: Manages ReplicaSets
- Service: Network abstraction
- Ingress: HTTP routing
- StatefulSet: For stateful apps