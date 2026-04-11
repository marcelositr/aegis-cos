---
title: Kubernetes
title_pt: Kubernetes (K8s)
layer: devops
type: tool
priority: high
version: 1.0.0
tags:
  - DevOps
  - Kubernetes
  - Orchestration
  - Tool
description: Container orchestration platform for automating deployment and scaling.
description_pt: Plataforma de orquestração de containers para automatizar implantação e escalonamento.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Kubernetes

## Description

Kubernetes (K8s) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. Originally developed by Google, it now belongs to the Cloud Native Computing Foundation (CNCF) and has become the standard for container orchestration.

Kubernetes provides:
- **Automated deployment and rollback** - Deploy updates with zero downtime
- **Self-healing** - Restart failed containers, replace and reschedule
- **Horizontal scaling** - Scale applications based on metrics
- **Service discovery** - Automatically find services
- **Load balancing** - Distribute traffic across containers
- **Configuration management** - Manage secrets and configmaps
- **Storage orchestration** - Mount storage systems

Key Kubernetes concepts:
- **Pod** - Smallest deployable unit (one or more containers)
- **Service** - Network abstraction for pods
- **Deployment** - Manages ReplicaSets
- **ReplicaSet** - Ensures desired number of pods
- **Namespace** - Logical isolation
- **ConfigMap/Secret** - Configuration data

Kubernetes is typically used with Docker containers but supports other container runtimes through CRI (Container Runtime Interface).

## Purpose

**When Kubernetes is valuable:**
- For microservices architectures
- When scaling is needed
- For self-healing applications
- In multi-environment deployments
- For cloud-native applications

**When to avoid:**
- Simple single-container apps
- When team lacks Kubernetes knowledge
- When infrastructure doesn't support it

## Rules

1. **Use namespaces** - Isolate environments and teams
2. **Define resource limits** - Prevent resource exhaustion
3. **Use liveness/readiness probes** - For health monitoring
4. **Store configs in ConfigMaps/Secrets** - Not in images
5. **Use Deployments** - Not raw pods
6. **Implement RBAC** - Control access
7. **Use labels** - For organization
8. **Monitor everything** - Track metrics

## Examples

### Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: myapp
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - myapp
                topologyKey: kubernetes.io/hostname
      containers:
        - name: myapp
          image: myapp:1.0.0
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: "production"
            - name: DB_HOST
              valueFrom:
                configMapKeyRef:
                  name: myapp-config
                  key: db_host
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: myapp-secrets
                  key: api_key
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
      terminationGracePeriodSeconds: 30
```

### Service

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
```

### Ingress

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  number: 80
```

### ConfigMap and Secret

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  db_host: "postgres.default.svc.cluster.local"
  db_port: "5432"
  log_level: "info"

---
# k8s/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
type: Opaque
stringData:
  api_key: "your-api-key-here"
  db_password: "your-db-password"
```

### Horizontal Pod Autoscaler

```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
```

### StatefulSet (for databases)

```yaml
# k8s/statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15
          ports:
            - containerPort: 5432
              name: postgres
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
          env:
            - name: POSTGRES_DB
              value: myapp
            - name: POSTGRES_USER
              value: appuser
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secrets
                  key: password
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: standard
        resources:
          requests:
            storage: 10Gi
```

## Anti-Patterns

### 1. Running as Root

```yaml
# BAD - runs as root
spec:
  containers:
    - name: app
      image: myapp:latest

# GOOD - runs as non-root
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
    - name: app
      image: myapp:latest
```

### 2. No Resource Limits

```yaml
# BAD - no limits
spec:
  containers:
    - name: app
      image: myapp:latest

# GOOD - with limits
spec:
  containers:
    - name: app
      image: myapp:latest
      resources:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "256Mi"
          cpu: "200m"
```

### 3. No Health Checks

```yaml
# BAD - no probes
spec:
  containers:
    - name: app
      image: myapp:latest

# GOOD - with probes
spec:
  containers:
    - name: app
      image: myapp:latest
      livenessProbe:
        httpGet:
          path: /health
          port: 3000
      readinessProbe:
        httpGet:
          path: /ready
          port: 3000
```

## Best Practices

### RBAC Configuration

```yaml
# k8s/rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: myapp
  name: myapp-editor
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "configmaps", "secrets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: myapp-editor-binding
  namespace: myapp
subjects:
  - kind: User
    name: developer
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: myapp-editor
  apiGroup: rbac.authorization.k8s.io
```

### Network Policies

```yaml
# k8s/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-policy
  namespace: myapp
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 3000
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: database
      ports:
        - protocol: TCP
          port: 5432
```

## Failure Modes

- **Misconfigured resource limits** → pod OOMKilled or CPU throttled → app crashes or hangs → always set requests and limits
- **No pod disruption budgets** → voluntary evictions take down all replicas → outage during node drains
- **StatefulSet without proper storage** → data lost on pod restart → use persistent volumes with backup
- **RBAC too permissive** → compromised pod accesses secrets cluster-wide → least privilege principle
- **No network policies** → any pod can talk to any pod → lateral movement after compromise
- **Etcd failure** → cluster control plane down → no scheduling, no scaling → backup etcd regularly
- **Image pull failures** → registry down or credentials expired → pods stuck in Pending → use image pull secrets, cache images
- **ConfigMap/Secret not mounted** → app starts with defaults → silent misconfiguration → use required env vars, fail fast

## Technology Stack

| Tool | Use Case |
|------|----------|
| Helm | Package manager |
| kubectl | CLI |
| Minikube | Local development |
| kind | Testing in Docker |
| k3s | Lightweight K8s |
| Rancher | Management UI |

## Related Topics

- [[Docker]]
- [[CiCd]]
- [[ServiceMesh]]
- [[ContainerOrchestration]]
- [[InfrastructureAsCode]]
- [[GitOps]]
- [[Monitoring]]
- [[Logging]]

## Additional Notes

**Key Commands:**
```bash
kubectl apply -f deployment.yaml
kubectl get pods
kubectl logs -f pod_name
kubectl describe pod pod_name
kubectl exec -it pod_name -- sh
kubectl scale deployment myapp --replicas=5
kubectl rollout status deployment myapp
```

**Key Concepts:**
- Pod: Container group
- Service: Network abstraction
- Deployment: Manage replicas
- ConfigMap: Configuration
- Secret: Sensitive data
- Ingress: External access

## Key Takeaways

- Kubernetes automates deployment, scaling, and management of containerized applications through self-healing, service discovery, and rolling updates.
- Use for microservices architectures, applications requiring horizontal scaling, self-healing capabilities, or multi-environment deployments.
- Do NOT use for simple single-container apps, when the team lacks Kubernetes expertise, or when infrastructure doesn't support it.
- Key tradeoff: powerful orchestration and self-healing vs. steep learning curve, operational complexity, and resource overhead.
- Main failure mode: misconfigured resource limits causing OOMKilled pods or CPU throttling, or overly permissive RBAC enabling lateral movement.
- Best practice: always set resource requests/limits, use liveness/readiness probes, implement RBAC with least privilege, and define network policies.
- Related concepts: Docker, Helm, Service Mesh, CI/CD, GitOps, Infrastructure as Code, Pod Disruption Budgets, StatefulSets.