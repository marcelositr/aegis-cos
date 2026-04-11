---
title: DevOps MOC
title_pt: DevOps — Mapa de Conteúdo
layer: devops
type: index
version: 1.0.0
tags:
  - DevOps
  - MOC
  - Index
description: Navigation hub for CI/CD, containers, infrastructure, monitoring, and operational practices.
description_pt: Hub de navegação para CI/CD, containers, infraestrutura, monitoramento e práticas operacionais.
---

# DevOps MOC

## CI/CD & Automation

- [[CiCd]] — Continuous Integration and Continuous Delivery/Deployment
- [[GitOps]] — Managing infrastructure and applications through Git as source of truth
- [[InfrastructureAsCode]] — Managing infrastructure through machine-readable definition files

## Containers & Orchestration

- [[Docker]] — Containerization platform for packaging and running applications
- [[ContainerOrchestration]] — Automating deployment, scaling, and management of containers
- [[Kubernetes]] — Industry-standard container orchestration platform
- [[ServiceMesh]] — Dedicated infrastructure layer for service-to-service communication

## Observability & Operations

- [[Observability]] — Understanding system state from external outputs (logs, metrics, traces)
- [[Monitoring]] — Collecting and analyzing system metrics to detect issues
- [[Logging]] — Recording system events for debugging, auditing, and analysis
- [[Alerting]] — Notifying teams when systems require attention
- [[IncidentManagement]] — Structured process for responding to and resolving incidents
- [[ChaosEngineering]] — Proactively testing system resilience through controlled experiments

## Reasoning Path

1. Automate delivery: [[CiCd]] → [[GitOps]] → [[InfrastructureAsCode]]
2. Containerize: [[Docker]] → [[ContainerOrchestration]] → [[Kubernetes]]
3. Observe: [[Observability]] → [[Monitoring]] → [[Logging]] → [[Alerting]]
4. Respond: [[IncidentManagement]] → [[ChaosEngineering]]
5. Communicate: [[ServiceMesh]]

## Cross-Domain Links

- [[CiCd]] → [[Testing]] → [[QualityGates]] → [[Monitoring]]
- [[GitOps]] → [[InfrastructureAsCode]] → [[Docker]] → [[Kubernetes]]
- [[Docker]] → [[Microservices]] → [[ContainerOrchestration]]
- [[Kubernetes]] → [[ServiceMesh]] → [[Observability]]
- [[Observability]] → [[Monitoring]] → [[Logging]] → [[Alerting]]
- [[Monitoring]] → [[PerformanceProfiling]] → [[PerformanceOptimization]]
- [[Logging]] → [[IncidentManagement]] → [[ChaosEngineering]]
- [[Alerting]] → [[SRE]] (planned) → [[ErrorBudgets]]
- [[ChaosEngineering]] → [[DistributedSystems]] → [[ResiliencePatterns]]
- [[ServiceMesh]] → [[ZeroTrust]] → [[TlsSsl]]
- [[InfrastructureAsCode]] → [[SecretsManagement]] → [[SecurityAudit]]
