---
title: GitOps
title_pt: GitOps
layer: devops
type: practice
priority: medium
version: 1.0.0
tags:
  - DevOps
  - GitOps
  - Practice
description: Git-based workflow for managing infrastructure and deployments.
description_pt: Fluxo baseado em Git para gerenciar infraestrutura e implantações.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# GitOps

## Description

GitOps is an operational framework that uses Git as the single source of truth for declarative infrastructure and applications. It brings the same Git workflows used for software development to infrastructure and deployment management.

In GitOps:
- **Infrastructure as Code** - All infrastructure defined in code
- **Git as Source of Truth** - All changes go through Git
- **Declarative Configurations** - Define desired state, not steps
- **Automated Synchronization** - System reconciles with Git state

GitOps provides several benefits:
- **Audit trail** - Every change tracked in Git
- **Self-documenting infrastructure** - Code is the documentation
- **Faster rollbacks** - Just revert Git commit
- **Improved security** - Git access control
- **Easier collaboration** - Pull request workflow

GitOps works well with Kubernetes, where you can:
- Store manifests in Git
- Use controllers to sync with cluster
- Implement drift detection
- Enable automated rollbacks

## Purpose

**When GitOps is valuable:**
- For Kubernetes deployments
- When audit trail is important
- For team collaboration
- For automated operations

**What can be GitOps-managed:**
- Kubernetes manifests
- Helm charts
- Terraform state
- Application deployments

## Rules

1. **Git is the source of truth** - Don't make manual changes
2. **Declarative configurations** - Define desired state
3. **Automated reconciliation** - System syncs with Git
4. **Pull-based deployments** - Not push-based
5. **Immutable artifacts** - Version everything

## Examples

### ArgoCD Application

```yaml
# argo-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/myapp.git
    targetRevision: main
    path: k8s/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

### GitOps Repository Structure

```
infrastructure/
├── apps/
│   ├── myapp/
│   │   ├── base/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── kustomization.yaml
│   │   ├── staging/
│   │   │   ├── kustomization.yaml
│   │   │   └── values.yaml
│   │   └── production/
│   │       ├── kustomization.yaml
│   │       └── values.yaml
│   └── other-app/
│       └── ...
├── platform/
│   ├── argocd/
│   │   └── application.yaml
│   ├── cert-manager/
│   └── ingress-nginx/
└── clusters/
    ├── staging/
    │   └── config.yaml
    └── production/
        └── config.yaml
```

### Flux Configuration

```yaml
# flux-system/gotk-components.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: myapp
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/example/myapp.git
  ref:
    branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: myapp
  namespace: flux-system
spec:
  sourceRef:
    kind: GitRepository
    name: myapp
  path: "./k8s/production"
  interval: 5m
  prune: true
  validation: client
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: myapp
      namespace: production
```

### Kustomize Overlay

```yaml
# k8s/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

patches:
  - patch: |- 
      - op: replace
        path: /spec/replicas
        value: 5
    target:
      kind: Deployment
      name: myapp
  - patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/image
        value: myapp:production
    target:
      kind: Deployment
      name: myapp

configMapGenerator:
  - name: myapp-config
    behavior: merge
    literals:
      - LOG_LEVEL=info
      - ENVIRONMENT=production

replicas:
  - name: myapp
    count: 5
```

## Anti-Patterns

### 1. Manual Changes

```bash
# BAD - Don't do this!
kubectl apply -f deployment.yaml
# Changes not in Git!

# GOOD - All changes via Git
git add k8s/production/deployment.yaml
git commit -m "Scale to 5 replicas"
git push
# ArgoCD/Flux syncs automatically
```

### 2. Pushing Credentials

```yaml
# BAD - Never commit secrets
apiVersion: v1
kind: Secret
metadata:
  name: db-creds
data:
  password: c2VjcmV0  # Base64 encoded!

# GOOD - Use sealed secrets or external secrets
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: db-creds
spec:
  encryptedData:
    password: AgBy...  # Encrypted
```

### 3. Large Repositories

```yaml
# BAD - One big repo with everything
# Difficult to review, slow to clone

# GOOD - Multiple repositories by team/component
# apps/ - Application manifests
# infrastructure/ - Platform components
# clusters/ - Cluster configurations
```

## Best Practices

### PR Review Process

```yaml
# Required reviewers for production changes
# .github/CODEOWNERS
* @platform-team
/apps/* @app-team @platform-team
/infrastructure/* @platform-team
/cluster-config/* @platform-team @security-team
```

### Drift Detection

```yaml
# Alert on drift - ArgoCD
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
spec:
  syncPolicy:
    automated:
      selfHeal: true
    # Alert when out of sync
---
# Prometheus alert for drift
- alert: ArgoCDOutOfSync
  expr: argocd_app_sync_status{phase="OutOfSync"} == 1
  for: 5m
  labels:
    severity: warning
  annotations:
    description: "Application {{ $labels.name }} is out of sync"
```

## Failure Modes

- **Git repo down** → can't deploy → single point of failure → use multiple Git providers, mirror repos
- **Drift detection lag** → manual changes not caught → cluster diverges from Git → set frequent sync intervals
- **Secrets in Git** → even encrypted, risk of exposure → use external secret managers (Vault, Sealed Secrets)
- **Sync loop** → controller constantly reconciling → resource exhaustion → fix root cause of drift
- **Merge conflicts in manifests** → broken desired state → deployment blocked → use structured manifests, code review
- **Over-permissive Git access** → anyone can change production → branch protection, required reviews
- **Controller compromise** → attacker pushes malicious manifest → cluster takeover → RBAC, audit logs, image signing

## Technology Stack

| Tool | Use Case |
|------|----------|
| ArgoCD | Kubernetes GitOps |
| Flux | Kubernetes GitOps |
| Crossplane | Cloud control plane |
| Spacelift | Terraform GitOps |

## Related Topics

- [[Kubernetes]]
- [[CiCd]]
- [[InfrastructureAsCode]]
- [[Docker]]
- [[Monitoring]]
- [[Logging]]
- [[ContainerOrchestration]]
- [[SecurityHeaders]]

## Additional Notes

**Key Concepts:**
- Declarative desired state
- Automated reconciliation
- Pull-based deployment
- Git as single source of truth

**Benefits:**
- Audit trail
- Faster rollbacks
- Self-documenting
- Security

**Workflow:**
1. Developer commits to Git
2. GitOps controller detects change
3. Controller reconciles cluster
4. Cluster matches desired state