---
layer: memory
type: lessons-learned
priority: high
read_order: 2
version: 1.0.0
tags:
  - memory
  - lessons
  - failures
---

# Lessons

## Purpose

Documents accumulated engineering lessons. Derived from failures.

## Core Lessons

| # | Lesson | Consequence |
|---|--------|-------------|
| 1 | Adding abstractions too early | Creates maintenance cost |
| 2 | Adding dependencies | Increases failure probability |
| 3 | Generalization | Increases complexity |
| 4 | Simple code vs clever code | Simple survives longer |
| 5 | Environment assumptions | Break portability |
| 6 | Minimal solutions | Reduce bugs |

## Lesson Deep Dive

### Lesson 1: Abstraction Cost

```
Early abstraction = Future maintenance burden

Cost of change = Abstraction + Implementation + Test
```

### Lesson 2: Dependency Risk

```
Dependencies added = Failure points multiplied

Each dependency:
├─ Version compatibility
├─ Security vulnerability
├─ Maintenance burden
└─ API changes
```

### Lesson 3: Generalization Trap

```
General solution = More code + More tests + More complexity
Specific solution = Less code + Less tests + Less complexity
```

### Lesson 4: Code Simplicity

| Clever Code | Simple Code |
|-------------|-------------|
| Hard to read | Easy to read |
| Hard to debug | Easy to debug |
| Hard to maintain | Easy to maintain |
| Fails in production | Survives production |

### Lesson 5: Environment Reality

> "What works on your machine may not work in production."

### Lesson 6: Minimalism Works

> "The best code is the code you don't write."

## Memory Integration

This file feeds into:

- [[knowledge/md/failure/Common]] - Pattern detection
- [[knowledge/md/control/SelfCheck]] - Pre-execution checklist
- [[knowledge/md/system/Feedback]] - Learning cycle

## Portuguese

### Propósito

Documenta lições de engenharia acumuladas. Derivadas de falhas.

### Lições Centrais

| # | Lição | Consequência |
|---|-------|--------------|
| 1 | Abstrações cedo demais | Cria custo de manutenção |
| 2 | Adicionar dependências | Aumenta chance de falha |
| 3 | Generalização | Aumenta complexidade |
| 4 | Código simples vs esperto | Simples sobrevive mais |
| 5 | Suposições de ambiente | Quebram portabilidade |
| 6 | Soluções mínimas | Reduzem bugs |

## Related

- [[knowledge/md/memory/Engineering]]
- [[knowledge/md/failure/Common]]
- [[knowledge/md/failure/Overengineering]]
- [[knowledge/md/agent/Directives]]
