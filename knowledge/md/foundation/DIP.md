---
layer: foundation
type: principle
priority: critical
read_order: 5
version: 1.0.0
tags:
  - solid
  - dip
  - dependency-inversion
  - abstractions
---

# DIP

## Definition

> "High-level modules should not depend on low-level modules. Both should depend on **abstractions**."

## Core Concept

| Term | Meaning |
|------|---------|
| High-level | Core business logic |
| Low-level | Infrastructure details |
| Abstractions | Interfaces/Contracts |

## DIP in Agent Context

### Problem: Direct Dependency

```
┌─────────────────────┐
│   GOVERNANCE        │ ← High-level
│   (Core Logic)      │
└──────────┬──────────┘
            │
            │ Depends on
            ▼
┌─────────────────────┐
│   FILE_STORAGE      │ ← Low-level
│   (Implementation)  │
└─────────────────────┘

Problem: GOVERNANCE breaks if FILE_STORAGE changes
```

### Solution: Dependency Inversion

```
┌─────────────────────┐
│   GOVERNANCE        │ ← High-level
│   (Core Logic)      │
└──────────┬──────────┘
            │
            │ Depends on
            ▼
┌─────────────────────┐
│   I_STORAGE         │ ← Abstraction
│   (Interface)       │
└──────────┬──────────┘
            │
     ┌──────┴──────┐
     ▼             ▼
┌───────────┐ ┌───────────┐
│FileStorage│ │CloudStorage│ ← Low-level (implements)
└───────────┘ └───────────┘
```

### Layer Dependencies (Correct)

```
                    ┌─────────────┐
                    │ GOVERNANCE  │
                    │ (High-level)│
                    └──────┬──────┘
                           │ depends on
                    ┌──────▼──────┐
                    │ I_PROTOCOLS │ ← Abstractions
                    │ I_STORAGE   │
                    │ I_VALIDATION│
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
     ┌───────────┐   ┌───────────┐   ┌───────────┐
     │FileStorage│   │Validation │   │Protocol_X │
     └───────────┘   └───────────┘   └───────────┘
```

## Implementation Rules

### Rule 1: Depend on Abstractions

| Instead Of | Do |
|------------|-----|
| `uses ConcreteClass` | `uses IInterface` |
| `imports specific impl` | `imports abstract contract` |
| `new FileStorage()` | `new IStorage` |

### Rule 2: Inject Dependencies

```
┌─────────────────────────────────────┐
│  Constructor Injection               │
├─────────────────────────────────────┤
│  Agent(storage: IStorage) {         │
│    this.storage = storage           │
│  }                                  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Instead of                         │
├─────────────────────────────────────┤
│  Agent() {                         │
│    this.storage = new FileStorage() │ ← ❌
│  }                                  │
└─────────────────────────────────────┘
```

### Rule 3: Abstract at Boundaries

| High-level | → | Depends on | ← | Low-level |
|-----------|---|------------|---|-----------|
| GOVERNANCE | | IValidation | | FileValidator |
| CONTROL | | IProtocol | | StrictProtocol |
| MEMORY | | IStorage | | FileStorage |

## Portuguese

### Definição

> "Módulos de alto nível não devem depender de módulos de baixo nível. Ambos devem depender de **abstrações**."

### Conceito Central

| Termo | Significado |
|-------|------------|
| Alto nível | Lógica de negócio core |
| Baixo nível | Detalhes de infraestrutura |
| Abstrações | Interfaces/Contratos |

### Solução

```
Módulos de negócio → Interfaces → Implementações concretas
```

## Related

- [[knowledge/md/foundation/ISP]]
- [[knowledge/md/foundation/Contracts]]
- [[knowledge/md/foundation/ModeInterface]]
- [[knowledge/md/foundation/DesignLaws]]