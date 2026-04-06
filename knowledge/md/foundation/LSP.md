---
layer: foundation
type: principle
priority: critical
read_order: 3
version: 1.0.0
tags:
  - solid
  - lsp
  - liskov-substitution
  - polymorphism
---

# LSP

## Definition

> "Objects of a superclass should be **replaceable** with objects of a subclass **without breaking** the application."

## Core Concept

| Term | Meaning |
|------|---------|
| Subtype | Implementation of contract |
| Substitutable | Can swap without issues |
| Behavioral | Same behavior guaranteed |

## LSP in Agent Context

### Agent Modes as Subtypes

```
┌─────────────────────────┐
│    AGENT_MODE           │ ← Contract/Interface
│    (Abstract)           │
└───────────┬─────────────┘
            │ Implements
    ┌───────┼───────┬───────────┐
    ▼       ▼       ▼           ▼
┌───────┐ ┌────┐ ┌────────┐ ┌─────────┐
│ STRICT│ │MINI│ │ANALYSIS│ │PARANOID│ ← Subtypes
└───────┘ └────┘ └────────┘ └─────────┘

Any mode can replace AGENT_MODE without breaking behavior
```

### Mode Contract

All modes MUST implement:

| Behavior | STRICT | MINIMAL | ANALYSIS | PARANOID |
|----------|--------|---------|----------|----------|
| respect_scope | ✓ | ✓ | ✓ | ✓ |
| self_check | ✓ | ✓ | ✓ | ✓ |
| validate_before_execute | ✓ | ✓ | ✓ | ✓ |
| report_uncertainty | ✓ | ✓ | ✓ | ✓ |

### Violations

| Anti-pattern | Why Wrong |
|--------------|-----------|
| Mode removes required behavior | Breaks contract |
| Mode throws for valid input | Unexpected failure |
| Mode adds new requirements | Subclass more restrictive |

## Implementation Rules

### Rule 1: Maintain Contract

```
Base Contract:
  - Must do X
  - Must not do Y
  - Must handle Z

Subtype: ✓ Can do more X
         ✓ Can be stricter on Y
         ✗ Cannot remove X
         ✗ Cannot be looser on Y
         ✗ Cannot break Z
```

### Rule 2: Behavioral Compatibility

| If Base does | Subtype must |
|--------------|-------------|
| Accepts X | Accept X or subset |
| Returns Y | Return Y or subtype |
| Throws Z | Throw Z or subset |

### Rule 3: Invariant Preservation

```
Base invariant: "State must be valid after operation"
Subtype: ✓ Strengthen invariants
         ✗ Weaken invariants
```

## Portuguese

### Definição

> "Objetos de uma superclasse devem ser **substituíveis** por objetos de uma subclasse **sem quebrar** a aplicação."

### Conceito Central

| Termo | Significado |
|-------|------------|
| Subtipo | Implementação de contrato |
| Substituível | Pode trocar sem problemas |
| Comportamental | Mesmo comportamento garantido |

### Contrato de Modos

Todos os modos DEVEM implementar:

| Comportamento | STRICT | MINIMAL | ANALYSIS | PARANOID |
|---------------|--------|---------|----------|----------|
| respeitar_escopo | ✓ | ✓ | ✓ | ✓ |
| auto_verificar | ✓ | ✓ | ✓ | ✓ |
| validar_antes_executar | ✓ | ✓ | ✓ | ✓ |
| reportar_incerteza | ✓ | ✓ | ✓ | ✓ |

## Related

- [[knowledge/md/foundation/OCP]]
- [[knowledge/md/foundation/ISP]]
- [[knowledge/md/foundation/ModeInterface]]
- [[knowledge/md/foundation/AgentStates]]