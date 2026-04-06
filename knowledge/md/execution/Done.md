---
layer: execution
type: completion-criteria
priority: critical
read_order: 3
version: 1.0.0
tags:
  - completion
  - done
  - definition
---

# Done

## Purpose

Defines when a task is truly complete. Prevents overworking.

## Done Criteria

### Must Have (ALL required)

| # | Criteria | Verify |
|---|----------|--------|
| 1 | Requested feature works | Test |
| 2 | No unrelated code modified | Diff review |
| 3 | No unnecessary complexity added | Review |
| 4 | No new dependencies (without need) | Check imports |
| 5 | Existing patterns respected | Pattern match |
| 6 | Scope not expanded | Scope check |

### NOT Required

| # | Extras to Skip |
|---|----------------|
| 1 | Extra improvements |
| 2 | Refactoring |
| 3 | Optimization |
| 4 | Generalization |
| 5 | Future proofing |
| 6 | Code "cleanups" |

## Done Checklist

```
┌─────────────────────────────────────┐
│         DEFINITION OF DONE          │
├─────────────────────────────────────┤
│ ☐ Feature works                     │
│ ☐ No unrelated changes             │
│ ☐ No extra complexity               │
│ ☐ No new dependencies              │
│ ☐ Patterns respected                │
│ ☐ Scope maintained                  │
├─────────────────────────────────────┤
│ ALL ☐ = TASK COMPLETE              │
│ ANY □ = NOT DONE                    │
└─────────────────────────────────────┘
```

## Completion Rule

> "Stop when task is solved. Do not continue improving."

## Engineering Discipline

| Overworking | Maturity |
|-------------|----------|
| Introduces risk | Knows when to stop |
| Expands scope | Maintains scope |
| Delays delivery | Delivers on time |

> "Overworking a solution introduces risk.
> Controlled stopping is engineering maturity."

## Portuguese

### Propósito

Define quando uma tarefa está verdadeiramente completa. Previne trabalho excessivo.

### Critérios de Conclusão

**Deve Ter (TODOS requeridos):**

| # | Critério | Verificar |
|---|----------|-----------|
| 1 | Feature solicitada funciona | Testar |
| 2 | Nenhum código não relacionado modificado | Revisar diff |
| 3 | Nenhuma complexidade desnecessária adicionada | Revisar |
| 4 | Nenhuma nova dependência (sem necessidade) | Verificar imports |
| 5 | Padrões existentes respeitados | Comparar padrões |
| 6 | Escopo não expandido | Verificar escopo |

**NÃO é Necessário:**

| # | Extras para Pular |
|---|-------------------|
| 1 | Melhorias extras |
| 2 | Refatoração |
| 3 | Otimização |
| 4 | Generalização |
| 5 | Future proofing |
| 6 | "Limpezas" de código |

### Regra de Conclusão

> "Parar quando a tarefa estiver resolvida.
> Não continuar melhorando."

### Disciplina de Engenharia

> "Trabalhar além do necessário introduz risco.
> Saber parar é maturidade de engenharia."

## Related

- [[knowledge/md/execution/Protocol]]
- [[knowledge/md/control/Scope]]
- [[knowledge/md/control/SelfCheck]]
- [[knowledge/md/failure/Overengineering]]
