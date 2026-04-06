---
layer: failure
type: overengineering-patterns
priority: high
read_order: 2
version: 1.0.0
tags:
  - overengineering
  - patterns
  - complexity
---

# Overengineering

## Purpose

Documents overengineering signals and patterns. Prevents unnecessary complexity.

## Overengineering Signals

### Code Level

| Signal | Description |
|--------|-------------|
| Helper classes | Without need |
| Single implementation interfaces | YAGNI |
| Configuration systems | Too early |
| Logging frameworks | Unnecessary |
| Plugin systems | No requirement |
| Factory patterns | Simple object works |
| Observer patterns | Event system overkill |

### Architecture Level

| Signal | Description |
|--------|-------------|
| Layered systems | Single layer enough |
| Microservices | Monolith works |
| Distributed systems | Single system fine |
| Message queues | Direct call works |
| CQRS | Simple CRUD enough |
| Event sourcing | State is fine |

### Design Level

| Signal | Description |
|--------|-------------|
| Scale for millions | Hundreds expected |
| Multi-tenancy | Single tenant |
| Global distribution | Single region |
| Real-time everything | Batch is fine |
| Infinite extensibility | Fixed scope works |

## Engineering Warning

> "Complexity grows faster than value."

## Core Rule

| Simple Works | Action |
|--------------|--------|
| Yes | Do not complicate |
| No | Justify complexity |
| Maybe | Default to simple |

## Complexity Value Curve

```
Value
  │
  │    ╭─────────────╮
  │   ╱               ╲
  │  ╱                 ╲
  │ ╱                   ╲
  │╱                     ╲
  └───────────────────────────► Complexity
     ▲           ▲
     │           │
   Simple     Too Complex
   (Good)      (Bad)
```

## Portuguese

### Propósito

Documenta sinais e padrões de overengineering. Previne complexidade desnecessária.

### Sinais de Overengineering

**Nível de Código:**

| Sinal | Descrição |
|-------|-----------|
| Classes helper | Sem necessidade |
| Interfaces de implementação única | YAGNI |
| Sistemas de configuração | Cedo demais |
| Frameworks de logging | Desnecessário |
| Sistemas plugin | Sem requisito |
| Padrões factory | Objeto simples funciona |
| Padrões observer | Sistema de eventos overkill |

**Nível de Arquitetura:**

| Sinal | Descrição |
|-------|-----------|
| Sistemas em camadas | Camada única é suficiente |
| Microsserviços | Monolito funciona |
| Sistemas distribuídos | Sistema único OK |
| Filas de mensagens | Chamada direta funciona |
| CQRS | CRUD simples é suficiente |
| Event sourcing | Estado é suficiente |

### Regra Central

> "Complexidade cresce mais rápido que valor."

**Regra:**

| Simples Funciona | Ação |
|------------------|------|
| Sim | Não complicar |
| Não | Justificar complexidade |
| Talvez | Padrão para simples |

## Related

- [[knowledge/md/failure/Common]]
- [[knowledge/md/execution/Decision]]
- [[knowledge/md/agent/Directives]]
- [[knowledge/md/foundation/DesignLaws]]
