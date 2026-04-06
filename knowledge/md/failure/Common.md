---
layer: failure
type: failure-patterns
priority: high
read_order: 1
version: 1.0.0
tags:
  - failures
  - anti-patterns
  - mistakes
---

# Common

## Purpose

Documents typical agent failure patterns. Use for prevention and detection.

## Failure Categories

### 1. Overengineering

| Signal | Description |
|--------|-------------|
| Adding layers | Not required |
| Creating systems | No requirement |
| Over-abstracting | Single implementation |
| Future proofing | Scale doesn't exist |

### 2. Premature Abstraction

| Signal | Description |
|--------|-------------|
| Reusable systems | Before need |
| Generic interfaces | Single use |
| Plugin architectures | No plugin use |
| Configuration systems | No configuration needed |

### 3. Scope Drift

| Signal | Description |
|--------|-------------|
| Task expansion | Beyond request |
| "While here" changes | Unrelated improvements |
| Fixing unrelated issues | Different problems |
| Redesigning working code | If it works, don't touch |

### 4. Dependency Inflation

| Signal | Description |
|--------|-------------|
| Unnecessary libraries | Simple solution exists |
| Framework adoption | Micro-problem |
| External services | Not needed |
| Complex tooling | Overkill |

### 5. Environment Assumptions

| Signal | Description |
|--------|-------------|
| GNU tools assumed | May not exist |
| Latest versions | May be old |
| Full OS features | May be minimal |
| Extra packages | May not be installed |

### 6. Architecture Drift

| Signal | Description |
|--------|-------------|
| Restructuring | Without need |
| Pattern changes | Working patterns exist |
| New paradigms | Unproven approach |
| Tech stack changes | Unnecessary |

### 7. Complexity Addiction

| Signal | Description |
|--------|-------------|
| Sophisticated solutions | Simple works better |
| Clever code | Hard to maintain |
| Novel approaches | Unproven |
| Optimizations | Premature |

## Quick Reference Table

| Failure Type | Key Indicator |
|--------------|---------------|
| Overengineering | Adding not requested |
| Premature abstraction | Reusable before need |
| Scope drift | Task gets bigger |
| Dependency inflation | New library added |
| Environment assumption | "Will exist" |
| Architecture drift | Structure change |
| Complexity addiction | "Elegant solution" |

## Portuguese

### Propósito

Documenta padrões típicos de falhas de agentes. Usar para prevenção e detecção.

### Categorias de Falhas

| Tipo | Indicador Chave |
|------|-----------------|
| Overengineering | Adicionando não solicitado |
| Abstração prematura | Reutilizável antes da necessidade |
| Desvio de escopo | Tarefa fica maior |
| Inflação de dependências | Nova biblioteca adicionada |
| Suposição de ambiente | "Vai existir" |
| Desvio de arquitetura | Mudança de estrutura |
| Vício em complexidade | "Solução elegante" |

## Related

- [[knowledge/md/failure/ScopeDrift]]
- [[knowledge/md/failure/Overengineering]]
- [[knowledge/md/control/Scope]]
- [[knowledge/md/memory/Lessons]]
