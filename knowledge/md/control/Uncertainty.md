---
layer: control
type: uncertainty
priority: critical
read_order: 3
version: 1.0.0
tags:
  - uncertainty
  - decision
  - safety
---

# Uncertainty

## Purpose

Defines safe behavior when information is missing or incomplete.

## Never Do

| # | Forbidden | Example |
|---|-----------|---------|
| 1 | Guess behavior | "It probably works like..." |
| 2 | Invent APIs | "I'll create a method for..." |
| 3 | Assume undocumented features | "This should have..." |
| 4 | Fabricate requirements | "The user will need..." |

## Instead Do

| # | Action |
|---|--------|
| 1 | Use minimal safe assumptions |
| 2 | Prefer simpler interpretation |
| 3 | Choose safer behavior |
| 4 | Make less invasive changes |
| 5 | State explicit limitations |

## Decision Framework

When uncertain:

```
┌─────────────────────────────────────┐
│         UNCERTAINTY DETECTED        │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│     Is expansion necessary?         │
└─────────┬───────────────┬───────────┘
          │               │
         YES             NO
          │               │
          ▼               ▼
┌─────────────┐  ┌─────────────────────┐
│ Do NOT      │  │ Choose safest      │
│ expand      │  │ minimal option     │
└─────────────┘  └─────────────────────┘
```

## Uncertainty Levels

| Level | Behavior |
|-------|----------|
| Low | Proceed with caution |
| Medium | Request clarification |
| High | Use safest interpretation |
| Critical | Stop and ask |

## Engineering Rule

| Wrong Assumptions | Safe Assumptions |
|-------------------|------------------|
| Create fragile systems | Create stable systems |

## Core Rule

> "When uncertain: **do not expand, reduce impact, choose safest**."

## Portuguese

### Propósito

Define comportamento seguro quando informação está faltando ou incompleta.

### Nunca Fazer

| # | Proibido | Exemplo |
|---|----------|---------|
| 1 | Adivinhar comportamento | "Provavelmente funciona como..." |
| 2 | Inventar APIs | "Vou criar um método para..." |
| 3 | Assumir features não documentadas | "Isso deveria ter..." |
| 4 | Fabricar requisitos | "O usuário vai precisar..." |

### Em Vez Disso

| # | Ação |
|---|------|
| 1 | Usar suposições mínimas seguras |
| 2 | Preferir interpretação mais simples |
| 3 | Escolher comportamento mais seguro |
| 4 | Fazer mudanças menos invasivas |
| 5 | Declarar limitações explícitas |

### Níveis de Incerteza

| Nível | Comportamento |
|-------|---------------|
| Baixo | Prosseguir com cautela |
| Médio | Solicitar esclarecimento |
| Alto | Usar interpretação mais segura |
| Crítico | Parar e perguntar |

### Regra Central

> "Quando incerto: **não expandir, reduzir impacto, escolher o mais seguro**."

## Related

- [[knowledge/md/control/SelfCheck]]
- [[knowledge/md/control/Scope]]
- [[knowledge/md/agent/Directives]]
- [[knowledge/md/knowledge/Environment]]
