---
layer: task
type: task-template
priority: high
read_order: 1
version: 1.0.0
tags:
  - task
  - template
  - structure
---

# Template

## Purpose

Standard structure for defining tasks. Use for clear communication.

## Template Structure

```
┌─────────────────────────────────────┐
│              TASK                   │
├─────────────────────────────────────┤
│  OBJECTIVE: [What to achieve]       │
│                                     │
│  CONSTRAINTS: [What must NOT change]│
│                                     │
│  LIMITS: [What must NOT be touched] │
│                                     │
│  SUCCESS: [How completion is defined]│
│                                     │
│  FAILURE: [What makes task wrong]   │
└─────────────────────────────────────┘
```

## Field Definitions

### OBJECTIVE

| Element | Description |
|---------|-------------|
| Purpose | Clear goal statement |
| Deliverable | What will be produced |
| Context | Background information |

### CONSTRAINTS

| Element | Description |
|---------|-------------|
| Must not change | Sacred elements |
| Must preserve | Existing behavior |
| Must maintain | Compatibility |

### LIMITS

| Element | Description |
|---------|-------------|
| Must not touch | Out of scope areas |
| Must not modify | Protected code |
| Must not add | Forbidden additions |

### SUCCESS

| Element | Description |
|---------|-------------|
| Criteria | Measurable outcomes |
| Verification | How to confirm |
| Acceptance | When task is done |

### FAILURE

| Element | Description |
|---------|-------------|
| Anti-criteria | What would be wrong |
| Red flags | Warning signs |
| Rejection | When to abort |

## Example

```
TASK:
  OBJECTIVE: Fix login validation bug
  CONSTRAINTS: Do not change UI
  LIMITS: Do not touch user model
  SUCCESS: Users can login with valid credentials
  FAILURE: Introducing new validation rules
```

## Portuguese

### Propósito

Estrutura padrão para definir tarefas. Usar para comunicação clara.

### Exemplo

```
TAREFA:
  OBJETIVO: Corrigir bug de validação de login
  RESTRIÇÕES: Não mudar UI
  LIMITES: Não tocar modelo de usuário
  SUCESSO: Usuários podem logar com credenciais válidas
  FALHA: Introduzir novas regras de validação
```

## Related

- [[knowledge/md/execution/Protocol]]
- [[knowledge/md/execution/Done]]
- [[knowledge/md/control/Scope]]
