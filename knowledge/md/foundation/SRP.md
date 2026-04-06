---
layer: foundation
type: principle
priority: critical
read_order: 1
version: 1.0.0
tags:
  - solid
  - srp
  - single-responsibility
  - cohesion
---

# SRP

## Definition

> "A class/module should have **one, and only one**, reason to change."

## Core Concept

| Term | Meaning |
|------|---------|
| Responsibility | Reason for change |
| Single | One and only one |
| Cohesion | Related things together |

## SRP in Agent Context

### Agent Responsibilities

Each agent component should have ONE responsibility:

| Component | Single Responsibility |
|-----------|---------------------|
| Identity | Define who agent IS |
| Control | Enforce discipline |
| Execution | Handle workflow |
| Memory | Store and recall |
| Guard | Detect anomalies |

### Violations

| Anti-pattern | Why Wrong |
|--------------|-----------|
| Agent does everything | Too many reasons to change |
| Mixed validation + execution | Different change reasons |
| God modules | Multiple responsibilities |

## Implementation Rules

### Rule 1: One Purpose Per File

```
✓ GOOD: CONTROL_Scope_Boundary.md (scope control only)
✗ BAD: CONTROL_Scope_and_Validation.md (two purposes)
```

### Rule 2: One Reason To Change

| If change reason | Separate? |
|------------------|-----------|
| Business rule | Keep together |
| UI presentation | Separate |
| Data persistence | Separate |
| Logging | Separate |
| Validation | Separate |

### Rule 3: Cohesion

Related code stays together. Unrelated code separates.

```
Components with same change reason → SAME file/module
Components with different reasons → DIFFERENT files/modules
```

## Decision Matrix

| Question | If YES → | If NO → |
|----------|----------|---------|
| Two purposes? | Split | Keep together |
| Two change reasons? | Separate | Keep |
| Shared concept? | Keep | Split |

## Portuguese

### Definição

> "Uma classe/módulo deve ter **uma, e apenas uma**, razão para mudar."

### Conceito Central

| Termo | Significado |
|-------|------------|
| Responsabilidade | Razão para mudança |
| Única | Uma e apenas uma |
| Coesão | Coisas relacionadas juntas |

### Regras de Implementação

| Regra | Descrição |
|-------|-----------|
| Um propósito por arquivo | Separar responsabilidades |
| Uma razão para mudar | Classes focadas |
| Alta coesão | Coisas relacionadas juntas |

## Related

- [[knowledge/md/foundation/OCP]]
- [[knowledge/md/foundation/AgentClass]]
- [[knowledge/md/foundation/Size]]
- [[knowledge/md/foundation/DesignLaws]]