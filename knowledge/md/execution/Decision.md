---
layer: execution
type: decision-flow
priority: critical
read_order: 2
version: 1.0.0
tags:
  - decision
  - flow
  - selection
---

# Decision

## Purpose

Defines criteria for selecting between multiple solutions.

## Solution Selection Hierarchy

When multiple solutions exist, choose in this order:

| Priority | Criteria | Description |
|----------|----------|-------------|
| 1 | Least complexity | Minimize cognitive load |
| 2 | Least dependencies | Reduce external coupling |
| 3 | Project patterns | Maintain consistency |
| 4 | Highest predictability | Knowable behavior |
| 5 | Easiest maintain | Simple maintenance |

## Decision Matrix

| Solution A | Solution B | Choose |
|-----------|-----------|--------|
| More complex | Less complex | Less complex |
| More dependencies | Less dependencies | Less dependencies |
| Different patterns | Same patterns | Same patterns |
| Unpredictable | Predictable | Predictable |
| Hard to maintain | Easy to maintain | Easy to maintain |

## Avoid

| # | Forbidden |
|---|-----------|
| 1 | Clever solutions |
| 2 | Smart tricks |
| 3 | Complex abstractions |
| 4 | Future proof designs |
| 5 | Premature optimization |

## Engineering Rule

> "The simplest working solution is usually correct."

## Engineering Reality

| Complex Solutions | Simple Solutions |
|-------------------|------------------|
| Fail more often | Survive longer |
| Hard to maintain | Easy to understand |
| Unpredictable | Predictable behavior |

## Portuguese

### Propósito

Define critérios para selecionar entre múltiplas soluções.

### Hierarquia de Seleção

Quando múltiplas soluções existirem, escolher nesta ordem:

| Prioridade | Critério | Descrição |
|------------|----------|-----------|
| 1 | Menor complexidade | Minimizar carga cognitiva |
| 2 | Menos dependências | Reduzir acoplamento externo |
| 3 | Padrões do projeto | Manter consistência |
| 4 | Maior previsibilidade | Comportamento conhecível |
| 5 | Mais fácil manter | Manutenção simples |

### Evitar

| # | Proibido |
|---|----------|
| 1 | Soluções inteligentes demais |
| 2 | Truques complexos |
| 3 | Abstrações complexas |
| 4 | Design future proof |
| 5 | Otimização prematura |

### Regra de Decisão

> "A solução simples funcionando normalmente é correta."

### Realidade de Engenharia

| Soluções Complexas | Soluções Simples |
|--------------------|------------------|
| Falham mais | Sobrevivem mais |
| Difíceis de manter | Fáceis de entender |
| Imprevisíveis | Comportamento previsível |

## Related

- [[knowledge/md/agent/Directives]]
- [[knowledge/md/control/Uncertainty]]
- [[knowledge/md/execution/Protocol]]
- [[knowledge/md/failure/Overengineering]]
