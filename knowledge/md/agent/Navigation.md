---
layer: agent
type: navigation
priority: critical
read_order: 4
version: 1.0.0
tags:
  - navigation
  - structure
  - reading-order
---

# Navigation

## Purpose

Defines the cognitive foundation of the agent. This is the **entry point** for all agent operations.

## Reading Order

```mermaid
graph LR
    A[Navigation] --> B[Identity]
    B --> C[Contract]
    C --> D[Directives]
```

| Order | File | Purpose |
|-------|------|---------|
| 1 | [[knowledge/md/agent/Navigation]] | This file - Foundation |
| 2 | [[knowledge/md/agent/Identity]] | Who you are |
| 3 | [[knowledge/md/agent/Contract]] | How you behave |
| 4 | [[knowledge/md/agent/Directives]] | How you decide |

## Core Foundation

These files define:

| Question | Answer File |
|----------|-------------|
| Who you are | [[knowledge/md/agent/Identity]] |
| How you behave | [[knowledge/md/agent/Contract]] |
| How you decide | [[knowledge/md/agent/Directives]] |

## Critical Rule

> "Do not execute tasks before reading these files."

## Layer Dependencies

```
AGENT (Foundation)
    │
    ├──► CONTROL (Discipline)
    │        │
    │        ├──► EXECUTION (Workflow)
    │        │
    │        └──► GUARD (Detection)
    │
    ├──► FAILURE (Anti-patterns)
    │
    ├──► KNOWLEDGE (Engineering Rules)
    │
    ├──► MEMORY (Learning)
    │
    └──► SYSTEM (Runtime)
```

## Portuguese

### Propósito

Define a fundação cognitiva do agente. Este é o **ponto de entrada** para todas as operações do agente.

### Ordem de Leitura

| Ordem | Arquivo | Propósito |
|-------|---------|-----------|
| 1 | [[knowledge/md/agent/Navigation]] | Este arquivo - Fundação |
| 2 | [[knowledge/md/agent/Identity]] | Quem você é |
| 3 | [[knowledge/md/agent/Contract]] | Como você se comporta |
| 4 | [[knowledge/md/agent/Directives]] | Como você decide |

### Regra Crítica

> "Não executar tarefas antes de ler estes arquivos."

## Related

- [[knowledge/md/system/Kernel]]
- [[knowledge/md/system/Map]]
- [[knowledge/md/agent/Identity]]
- [[knowledge/md/agent/Contract]]
- [[knowledge/md/agent/Directives]]
