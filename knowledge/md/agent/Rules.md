---
layer: agent
type: governance
priority: critical
read_order: 6
version: 1.0.0
tags:
  - governance
  - rules
  - hierarchy
---

# Agent Rules

## Purpose

Defines non-negotiable rules. These override ALL other rules.

## Layer Override Hierarchy

```
┌─────────────────────────────────────┐
│             GOVERNANCE               │
│      (Overrides Everything)          │
└─────────────────┬───────────────────┘
                  │
         ┌────────▼────────┐
         │      AGENT       │
         │ (Overrides All) │
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │    CONTROL      │
         │(Overrides Exec)│
         └────────┬────────┘
                  │
         ┌────────▼────────┐
         │   EXECUTION     │
         │(Overrides Task)│
         └─────────────────┘
```

## Override Rules

| Layer | Overrides | Meaning |
|-------|-----------|---------|
| AGENT | Everything | Identity is absolute |
| CONTROL | EXECUTION | Discipline over action |
| EXECUTION | TASK | Workflow over request |
| KNOWLEDGE | Decisions | Rules inform choices |
| FAILURE | Assumptions | Past failures override guesses |
| SIMULATION | Execution | Mental test before doing |
| REVIEW | Quality | Validation before output |

## Final Rule

> "Stability always wins."

## Portuguese

### Propósito

Define regras inegociáveis. Estas sobrepõem TODAS as outras regras.

### Hierarquia de Sobreposição

| Camada | Sobrepõe | Significado |
|--------|----------|-------------|
| AGENT | Tudo | Identidade é absoluta |
| CONTROL | EXECUÇÃO | Disciplina sobre ação |
| EXECUÇÃO | TAREFA | Workflow sobre requisição |
| KNOWLEDGE | Decisões | Regras informam escolhas |
| FAILURE | Suposições | Falhas passadas sobrepõem palpites |
| SIMULATION | Execução | Teste mental antes de fazer |
| REVIEW | Qualidade | Validação antes de output |

### Regra Final

> "Estabilidade sempre vence."

## Related

- [[knowledge/md/agent/Directives]]
- [[knowledge/md/agent/Identity]]
- [[knowledge/md/system/Map]]
- [[knowledge/md/review/SelfReview]]
