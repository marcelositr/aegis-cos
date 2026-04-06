---
layer: foundation
type: principle
priority: critical
read_order: 4
version: 1.0.0
tags:
  - solid
  - isp
  - interface-segregation
  - decoupling
---

# ISP

## Definition

> "Clients should not be forced to depend on interfaces they do not use."

## Core Concept

| Term | Meaning |
|------|---------|
| Client | Code that uses interface |
| Interface | Contract of methods |
| Segregated | Split by client need |

## ISP in Agent Context

### Fat Interface Problem

```
┌─────────────────────────────────────────┐
│         FAT GOVERNANCE_INTERFACE        │
├─────────────────────────────────────────┤
│ + validate_identity()                   │
│ + check_scope()                         │
│ + enforce_rules()                        │
│ + monitor_performance()                  │
│ + handle_errors()                       │
│ + log_activity()                        │
│ + manage_memory()                        │
│ + coordinate_tasks()                    │
└─────────────────────────────────────────┘
        │
        │ Problem: All clients must implement ALL methods
        ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│    Identity   │   │   Executor    │   │    Guard      │
│   Module      │   │   Module      │   │    Module     │
│               │   │               │   │               │
│ Needs: ✓      │   │ Needs: ✓      │   │ Needs: ✓      │
│ - validate    │   │ - enforce     │   │ - monitor     │
│ ✗ performance │   │ ✗ memory      │   │ ✗ coordinate  │
│ ✗ coordinate  │   │ ✗ identity    │   │ ✗ errors      │
└───────────────┘   └───────────────┘   └───────────────┘
```

### Segregated Interfaces

```
┌─────────────────────────────────────────┐
│         SEGREGATED INTERFACES           │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌──────────┐  │
│  │Identity │ │Execution│ │  Guard   │  │
│  │Interface│ │Interface│ │Interface │  │
│  └────┬────┘ └────┬────┘ └────┬─────┘  │
│       │           │           │         │
│       └───────────┴───────────┘         │
│                   │                    │
│            ┌─────┴─────┐               │
│            │ Agent     │               │
│            │ (implements all)          │
│            └───────────┘               │
└─────────────────────────────────────────┘
```

## Implementation Rules

### Rule 1: Role-Based Interfaces

| Interface | Methods | Clients |
|-----------|---------|---------|
| IValidation | validate() | Identity, Guard |
| IExecution | execute() | Executor |
| IMonitoring | check() | Guard |
| IStorage | save(), load() | Memory |

### Rule 2: Small, Focused Contracts

```
✗ BAD: IAgent with 20 methods
✓ GOOD: IValidator, IExecutor, IGuard, IMemory
```

### Rule 3: Client-Specific Interfaces

```
For each client, ask:
- What does it NEED?
- What does it USE?
- Create interface for exactly that
```

## Portuguese

### Definição

> "Clientes não devem ser forçados a depender de interfaces que não usam."

### Conceito Central

| Termo | Significado |
|-------|------------|
| Cliente | Código que usa interface |
| Interface | Contrato de métodos |
| Segregada | Dividida por necessidade |

### Problema da Interface Gorda

```
Interface com 20 métodos força implementações desnecessárias
```

### Solução: Interfaces Segregadas

```
IValidation (2 métodos) → para Identity
IExecution (3 métodos) → para Executor  
IMonitoring (2 métodos) → para Guard
IMemory (2 métodos) → para Memory
```

## Related

- [[knowledge/md/foundation/LSP]]
- [[knowledge/md/foundation/DIP]]
- [[knowledge/md/foundation/Contracts]]
- [[knowledge/md/foundation/ModeInterface]]