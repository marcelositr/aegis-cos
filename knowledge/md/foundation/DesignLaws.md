---
layer: foundation
type: design-laws
priority: high
read_order: 11
version: 1.0.0
tags:
  - architecture
  - design
  - structure
---

# Design Laws

## Purpose

Defines architectural principles and constraints.

## Design Laws

| # | Law |
|---|-----|
| 1 | Simple architecture > Flexible architecture |
| 2 | Stable architecture > Extensible architecture |
| 3 | Explicit structure > Dynamic structure |

## Avoid

| # | Anti-pattern |
|---|--------------|
| 1 | Deep hierarchies |
| 2 | Unnecessary layers |
| 3 | Premature modularization |
| 4 | Over-abstracted components |

## Prefer

| # | Good pattern |
|---|--------------|
| 1 | Flat structures |
| 2 | Clear flows |
| 3 | Minimal moving parts |
| 4 | Explicit dependencies |

## Architecture Justification Rule

> "Structure must justify its existence."

### Justification Questions

| Question | If Unclear → |
|----------|-------------|
| Why does this layer exist? | Remove it |
| Why this abstraction? | Remove it |
| Why this hierarchy? | Flatten it |
| Why this coupling? | Decouple it |

## Complexity Budget

| Component Type | Max Depth | Max Coupling |
|----------------|----------|--------------|
| Package | 3 levels | 5 dependencies |
| Class | 1 level | 3 dependencies |
| Function | 0 levels | 2 dependencies |

## Portuguese

### Propósito

Define princípios e restrições arquiteturais.

### Leis de Design

| # | Lei |
|---|-----|
| 1 | Arquitetura simples > Arquitetura flexível |
| 2 | Arquitetura estável > Arquitetura extensível |
| 3 | Estrutura explícita > Estrutura dinâmica |

### Preferir

| # | Bom padrão |
|---|------------|
| 1 | Estruturas planas |
| 2 | Fluxos claros |
| 3 | Poucas partes móveis |
| 4 | Dependências explícitas |

### Regra de Justificativa

> "Estrutura deve justificar existência."

## Related

- [[knowledge/md/failure/Overengineering]]
- [[knowledge/md/execution/Decision]]
- [[knowledge/md/control/Scope]]
- [[knowledge/md/agent/Directives]]