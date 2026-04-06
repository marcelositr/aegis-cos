---
layer: control
type: scope-boundary
priority: critical
read_order: 1
version: 1.0.0
tags:
  - scope
  - discipline
  - boundaries
---

# Scope

## Purpose

Defines task scope discipline rules. Prevents scope expansion.

## Allowed Actions

| # | Action |
|---|--------|
| 1 | Solve the requested task |
| 2 | Modify only necessary code |
| 3 | Follow existing patterns |
| 4 | Fix directly related issues |

## Forbidden Actions

| # | Action | Example |
|---|--------|---------|
| 1 | Refactoring unrelated code | "This could be cleaner" |
| 2 | Redesigning architecture | "Let me restructure this" |
| 3 | Adding future proofing | "In case we need..." |
| 4 | Generalizing solutions | "Making it more reusable" |
| 5 | Improving unrelated components | "While I'm here..." |
| 6 | Adding new layers | "Should add abstraction" |
| 7 | Adding configuration systems | "Let me make it configurable" |
| 8 | Adding logging systems | "We should log this" |
| 9 | Adding error handling | "What if..." |

## Scope Drift Detection

### Trigger Phrases

When you catch yourself thinking:

| Phrase | Meaning |
|--------|---------|
| "While I am here I could..." | Scope expansion |
| "This could be improved..." | Not your task |
| "It would be better if..." | Not requested |
| "In the future we might..." | Future proofing |
| "This should be refactored..." | Not your scope |

### Rule

> **STOP.** This is scope drift.

## Core Rule

> "Solve only what was requested.
> Ignore everything else unless it blocks task completion."

## Portuguese

### Propósito

Define regras de disciplina de escopo. Previne expansão de escopo.

### Ações Permitidas

| # | Ação |
|---|------|
| 1 | Resolver a tarefa solicitada |
| 2 | Modificar apenas código necessário |
| 3 | Seguir padrões existentes |
| 4 | Corrigir problemas diretamente relacionados |

### Ações Proibidas

| # | Ação | Exemplo |
|---|------|---------|
| 1 | Refatorar código não relacionado | "Isso poderia ser mais limpo" |
| 2 | Redesenhar arquitetura | "Deixa eu restructurar isso" |
| 3 | Adicionar future proofing | "No caso de precisarmos..." |
| 4 | Generalizar soluções | "Tornando mais reutilizável" |
| 5 | Melhorar componentes não relacionados | "Já que estou aqui..." |
| 6 | Adicionar novas camadas | "Devo adicionar abstração" |
| 7 | Adicionar sistemas de configuração | "Deixa eu tornar configurável" |
| 8 | Adicionar sistemas de logging | "Devemos logar isso" |
| 9 | Adicionar tratamento de erros | "E se..." |

### Regra Central

> "Resolva apenas o solicitado.
> Ignore o resto, salvo se bloquear a tarefa."

## Related

- [[knowledge/md/agent/Contract]]
- [[knowledge/md/control/SelfCheck]]
- [[knowledge/md/failure/ScopeDrift]]
- [[knowledge/md/execution/Done]]
