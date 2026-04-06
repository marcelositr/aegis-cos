---
layer: foundation
type: principle
priority: critical
read_order: 2
version: 1.0.0
tags:
  - solid
  - ocp
  - open-closed
  - extension
---

# OCP

## Definition

> "Software entities should be **open for extension**, **closed for modification**."

## Core Concept

| State | Meaning |
|-------|--------|
| Open for extension | Can add new behavior |
| Closed for modification | Don't change existing code |

## OCP in Agent Context

### Extensible Design

| Layer | Open For | Closed For |
|-------|---------|------------|
| CORE | New identities | Existing identity logic |
| CONTROL | New protocols | Enforcement rules |
| EXECUTION | New workflows | Task protocol steps |
| FAILURE | New patterns | Detection logic |

### Extension Points

```
┌─────────────────────────────────────┐
│          CLOSED (Don't Change)       │
│  ┌─────────────────────────────────┐│
│  │    Base Behavior / Protocol     ││
│  └─────────────────────────────────┘│
│                 ▲                   │
│                 │ Extension         │
│                 │                   │
│  ┌─────────────────────────────────┐│
│  │    New Implementation           ││
│  └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

### Violations

| Anti-pattern | Why Wrong |
|--------------|-----------|
| Modify existing for new feature | Breaks existing behavior |
| Touch tested code | Introduces bugs |
| Change base class | Breaks subclasses |

## Implementation Rules

### Rule 1: Abstract Core Behavior

```
┌─────────────────────┐
│  Abstract Protocol  │ ← Closed for modification
└──────────┬──────────┘
            │
     ┌──────┴──────┐
     ▼             ▼
┌───────┐   ┌───────┐
│ Mode A│   │ Mode B│ ← Open for extension
└───────┘   └───────┘
```

### Rule 2: Add, Don't Modify

| Need | Instead Of | Do |
|------|-----------|-----|
| New behavior | Modify base | Extend base |
| New mode | Change core | Add new mode |
| New pattern | Edit protocol | Create new file |

### Rule 3: Extension Pattern

```
Existing (Closed):
- CORE_Behavioral_Contract.md

Extension (Open):
- Create MODE_SPECIFIC_rules.md
- Reference base, don't modify it
```

## Portuguese

### Definição

> "Entidades de software devem ser **abertas para extensão**, **fechadas para modificação**."

### Conceito Central

| Estado | Significado |
|--------|------------|
| Aberto para extensão | Pode adicionar novo comportamento |
| Fechado para modificação | Não muda código existente |

### Padrão de Extensão

| Comum | Extensão |
|-------|----------|
| Protocolo base | Modos específicos |
| Regras centrais | Casos especiais |
| Comportamento core | Customizações |

## Related

- [[knowledge/md/foundation/SRP]]
- [[knowledge/md/foundation/LSP]]
- [[knowledge/md/foundation/ModeInterface]]
- [[knowledge/md/foundation/DesignLaws]]