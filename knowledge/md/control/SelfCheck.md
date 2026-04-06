---
layer: control
type: self-check
priority: critical
read_order: 2
version: 1.0.0
tags:
  - verification
  - checklist
  - quality-control
---

# SelfCheck

## Purpose

Mental checklist to run before finalizing any task. Prevents common mistakes.

## Checklist

### Environment Check

| Question | If YES → |
|----------|----------|
| Did I assume tools exist? | Document dependency |
| Did I assume OS behavior? | Add detection |
| Did I assume dependencies? | Verify availability |

### Complexity Check

| Question | If YES → |
|----------|----------|
| Did I add unnecessary logic? | Remove it |
| Did I introduce abstractions? | Justify need |
| Did I increase cognitive load? | Simplify |

### Scope Check

| Question | If YES → |
|----------|----------|
| Did I expand beyond request? | Revert to minimal |
| Did I modify unrelated parts? | Restore original |
| Did I introduce unasked improvements? | Remove |

### Dependency Check

| Question | If YES → |
|----------|----------|
| Did I add libraries? | Verify necessity |
| Were they necessary? | Remove if not |

### Risk Check

| Question | If YES → |
|----------|----------|
| Did I increase fragility? | Add stability |
| Did I introduce hidden behavior? | Make explicit |

## Decision Matrix

| Any YES? | Action |
|----------|--------|
| Yes | Re-evaluate solution |
| Multiple YES | Simplify significantly |
| All NO | Proceed |

## Core Rule

> "When in doubt, **simplify**."

## Portuguese

### Propósito

Checklist mental para executar antes de finalizar qualquer tarefa. Previne erros comuns.

### Verificação de Ambiente

| Pergunta | Se SIM → |
|----------|----------|
| Assumi existência de ferramentas? | Documentar dependência |
| Assumi comportamento de OS? | Adicionar detecção |
| Assumi dependências? | Verificar disponibilidade |

### Verificação de Complexidade

| Pergunta | Se SIM → |
|----------|----------|
| Adicionei lógica desnecessária? | Remover |
| Introduzi abstrações? | Justificar necessidade |
| Aumentei carga cognitiva? | Simplificar |

### Verificação de Escopo

| Pergunta | Se SIM → |
|----------|----------|
| Expandi além do pedido? | Reverter para mínimo |
| Modifiquei partes não relacionadas? | Restaurar original |
| Introduzi melhorias não pedidas? | Remover |

### Verificação de Dependências

| Pergunta | Se SIM → |
|----------|----------|
| Adicionei bibliotecas? | Verificar necessidade |
| Eram necessárias? | Remover se não |

### Verificação de Risco

| Pergunta | Se SIM → |
|----------|----------|
| Aumentei fragilidade? | Adicionar estabilidade |
| Introduzi comportamento oculto? | Tornar explícito |

### Regra Central

> "Quando em dúvida, **simplifique**."

## Related

- [[knowledge/md/control/Scope]]
- [[knowledge/md/control/Uncertainty]]
- [[knowledge/md/agent/Directives]]
- [[knowledge/md/execution/Done]]
