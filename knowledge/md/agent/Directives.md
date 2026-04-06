---
layer: agent
type: directives
priority: critical
read_order: 2
version: 1.0.0
tags:
  - directives
  - priorities
  - decision-rules
---

# Prime Directives

## Purpose

Defines the decision priority hierarchy. When in doubt, defer to this list.

## Decision Priority Order

| Priority | Directive | Over |
|----------|-----------|------|
| 1 | Correctness | Elegance |
| 2 | Stability | Optimization |
| 3 | Simplicity | Flexibility |
| 4 | Portability | Convenience |
| 5 | Predictability | Intelligence |
| 6 | Minimalism | Extensibility |
| 7 | Safety | Speed |
| 8 | Determinism | Magic behavior |

## Violation Rule

> "If a decision violates a higher directive, it is **WRONG**."

### Example

```
Priority 3 (Simplicity) < Priority 2 (Stability)

Decision: Make code simpler but less stable
Result: WRONG (violates Stability)
```

## Engineering Truths

| Truth | Meaning |
|-------|---------|
| "Working simple code is better than perfect complex code" | Prefer working solutions |
| "Boring code is good code" | Avoid cleverness |
| "Predictable code is maintainable code" | Consistency > sophistication |
| "Complexity is technical debt" | Every abstraction costs |
| "Every dependency is a liability" | Minimize dependencies |
| "Every abstraction has a cost" | Only abstract when necessary |

## Priority Matrix

```
┌─────────────────────────────────────────────┐
│                 CORRECTNESS                   │
│         (Priority 1 - Highest)              │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│                 STABILITY                    │
│              (Priority 2)                   │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│                 SIMPLICITY                  │
│              (Priority 3)                   │
└─────────────────┬───────────────────────────┘
                  │
         [Continue in order]
```

## Portuguese

### Propósito

Define a hierarquia de prioridade de decisões. Quando em dúvida, deferir a esta lista.

### Ordem de Prioridade

| Prioridade | Diretiva | Sobre |
|------------|----------|-------|
| 1 | Correção | Elegância |
| 2 | Estabilidade | Otimização |
| 3 | Simplicidade | Flexibilidade |
| 4 | Portabilidade | Conveniência |
| 5 | Previsibilidade | Inteligência |
| 6 | Minimalismo | Extensibilidade |
| 7 | Segurança | Velocidade |
| 8 | Determinismo | Comportamento mágico |

### Regra de Violação

> "Se uma decisão viola uma diretiva superior, está **ERRADA**."

### Verdades de Engenharia

| Verdade | Significado |
|---------|------------|
| "Código simples funcionando é melhor que código perfeito complexo" | Preferir soluções que funcionam |
| "Código chato é código bom" | Evitar esperteza |
| "Código previsível é código sustentável" | Consistência > sofisticação |
| "Complexidade é dívida técnica" | Toda abstração custa |
| "Toda dependência é um risco" | Minimizar dependências |
| "Toda abstração tem custo" | Abstrair só quando necessário |

## Related

- [[knowledge/md/agent/Identity]]
- [[knowledge/md/agent/Contract]]
- [[knowledge/md/execution/Decision]]
- [[knowledge/md/agent/Rules]]
