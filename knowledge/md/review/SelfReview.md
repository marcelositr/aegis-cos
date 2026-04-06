---
layer: review
type: self-review
priority: high
read_order: 1
version: 1.0.0
tags:
  - review
  - quality
  - validation
---

# SelfReview

## Purpose

Pre-completion quality check. Final gate before output.

## Review Questions

Before finalizing solution, ask:

| # | Question | If NO → |
|---|----------|---------|
| 1 | Is this simpler than alternatives? | Reconsider |
| 2 | Did I introduce risk? | Remove or justify |
| 3 | Did I introduce unnecessary logic? | Remove |
| 4 | Did I solve only the problem? | Narrow scope |
| 5 | Would a senior engineer accept this? | Improve quality |
| 6 | Would this survive production? | Test robustness |

## Review Checklist

```
┌─────────────────────────────────────┐
│          SELF REVIEW CHECK          │
├─────────────────────────────────────┤
│ ☐ Simpler than alternatives?        │
│ ☐ No new risk introduced?           │
│ ☐ No unnecessary logic?            │
│ ☐ Only problem solved?             │
│ ☐ Production-ready?                 │
│ ☐ Senior engineer approval?         │
├─────────────────────────────────────┤
│ ALL YES = Ready to output           │
│ ANY NO = Fix before output          │
└─────────────────────────────────────┘
```

## Decision Matrix

| Answer | Action |
|--------|--------|
| All YES | Proceed to output |
| Some NO | Re-evaluate solution |
| Many NO | Start over |

## Core Rule

> "If the answer is NO, re-evaluate solution."

## Portuguese

### Propósito

Verificação de qualidade pré-conclusão. Último portão antes de output.

### Perguntas de Revisão

Antes de finalizar solução, perguntar:

| # | Pergunta | Se NÃO → |
|---|----------|----------|
| 1 | É mais simples que alternativas? | Reconsiderar |
| 2 | Introduzi risco? | Remover ou justificar |
| 3 | Introduzi lógica desnecessária? | Remover |
| 4 | Resolvi só o problema? | Narrow escopo |
| 5 | Um engenheiro sênior aceitaria? | Melhorar qualidade |
| 6 | Sobreviveria em produção? | Testar robustez |

### Regra Central

> "Se a resposta for NÃO, reavaliar solução."

## Related

- [[knowledge/md/control/SelfCheck]]
- [[knowledge/md/execution/Done]]
- [[knowledge/md/execution/MentalTesting]]
- [[knowledge/md/agent/Rules]]
