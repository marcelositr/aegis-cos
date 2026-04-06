---
layer: execution
type: mental-testing
priority: high
read_order: 4
version: 1.0.0
tags:
  - simulation
  - testing
  - mental-validation
---

# MentalTesting

## Purpose

Defines pre-execution mental testing. Validate before doing.

## Mental Test Scenarios

Before finalizing, imagine:

| # | Scenario | Question |
|---|----------|----------|
| 1 | Minimal environment | Will it run? |
| 2 | No dependencies | Does it still work? |
| 3 | Missing tools | Does it handle absence? |
| 4 | Unexpected conditions | Does it survive? |

## Testing Mindset

| Mindset | Approach |
|---------|----------|
| Assume failure first | Test for breakage |
| Verify survival second | Confirm resilience |
| Question assumptions | Challenge every claim |

## Test Matrix

```
┌─────────────────────────────────────────────┐
│              MENTAL TEST GRID               │
├─────────────┬───────────┬───────────────────┤
│   Scenario  │   Pass?   │   If Fail → Fix   │
├─────────────┼───────────┼───────────────────┤
│ Minimal env │   YES/NO  │   Simplify        │
│ No deps     │   YES/NO  │   Remove dep      │
│ Missing tool│   YES/NO  │   Add fallback    │
│ Edge cases  │   YES/NO  │   Handle better   │
└─────────────┴───────────┴───────────────────┘
```

## Engineering Reality

> "Code that survives mental testing fails less."

## Core Questions

Before output, ask:

1. Will this run in `sh` only?
2. Will this run without my tool?
3. Will this fail on edge cases?
4. Can I explain this simply?
5. Is this the minimal solution?

## Portuguese

### Propósito

Define teste mental pré-execução. Validar antes de fazer.

### Cenários de Teste Mental

Antes de finalizar, imagine:

| # | Cenário | Pergunta |
|---|---------|----------|
| 1 | Ambiente mínimo | Vai rodar? |
| 2 | Sem dependências | Ainda funciona? |
| 3 | Ferramentas faltando | Lida com ausência? |
| 4 | Condições inesperadas | Sobrevive? |

### Mentalidade de Teste

| Mentalidade | Abordagem |
|-------------|-----------|
| Assumir falha primeiro | Testar para quebrar |
| Verificar sobrevivência segundo | Confirmar resiliência |
| Questionar suposições | Desafiar cada afirmação |

## Related

- [[knowledge/md/knowledge/Environment]]
- [[knowledge/md/control/SelfCheck]]
- [[knowledge/md/failure/Common]]
- [[knowledge/md/review/SelfReview]]
