---
layer: foundation
type: agent-states
priority: critical
read_order: 13
version: 1.0.0
tags:
  - oop
  - states
  - behavior
---

# Agent States

## Overview

Defines all valid states for the Agent and their properties.

## State Definitions

### State Table

| State | Entry Action | Exit Action | Valid Transitions |
|-------|-------------|------------|-------------------|
| INITIALIZING | Load identity | Set mode | IDLE |
| IDLE | None | Store context | ANALYZING, SUSPENDED |
| ANALYZING | Parse task | Create plan | EXECUTING, IDLE |
| EXECUTING | Apply mode | Complete unit | VALIDATING, SUSPENDED, FAILED |
| VALIDATING | Run checks | Verify result | COMPLETED, EXECUTING |
| COMPLETED | Store memory | Reset context | IDLE |
| FAILED | Log failure | Alert guard | IDLE |
| SUSPENDED | Enable guard | Clear flags | IDLE, EXECUTING |

## State Properties

### INITIALIZING

```typescript
{
    name: 'INITIALIZING',
    description: 'Boot sequence in progress',
    allowedActions: ['load_core', 'load_identity', 'load_protocols'],
    forbiddenActions: ['execute', 'modify', 'delegate'],
    invariants: ['identity.loaded === true', 'mode !== null']
}
```

### IDLE

```typescript
{
    name: 'IDLE',
    description: 'Waiting for task input',
    allowedActions: ['receive_task', 'check_memory', 'report_status'],
    forbiddenActions: ['execute_task', 'modify_code', 'create_files'],
    invariants: ['currentTask === null', 'executionContext === null']
}
```

### ANALYZING

```typescript
{
    name: 'ANALYZING',
    description: 'Understanding and planning task',
    allowedActions: ['parse_task', 'identify_constraints', 'create_plan'],
    forbiddenActions: ['execute_plan', 'modify_workspace', 'delegate'],
    invariants: ['currentTask !== null', 'plan === null || plan.created']
}
```

### EXECUTING

```typescript
{
    name: 'EXECUTING',
    description: 'Performing task work',
    allowedActions: ['read_file', 'write_file', 'execute_command', 'validate_partial'],
    forbiddenActions: ['abort_task', 'change_mode'],
    invariants: ['plan !== null', 'context !== null']
}
```

### VALIDATING

```typescript
{
    name: 'VALIDATING',
    description: 'Self-verification phase',
    allowedActions: ['run_checks', 'compare_output', 'request_review'],
    forbiddenActions: ['modify_result', 'expand_scope'],
    invariants: ['executionComplete === true', 'result !== null']
}
```

### COMPLETED

```typescript
{
    name: 'COMPLETED',
    description: 'Task successfully finished',
    allowedActions: ['store_memory', 'report_result', 'cleanup'],
    forbiddenActions: ['execute', 'modify', 'revert'],
    invariants: ['validation.passed === true', 'result.valid === true']
}
```

### FAILED

```typescript
{
    name: 'FAILED',
    description: 'Error or validation failure',
    allowedActions: ['log_error', 'notify_guard', 'store_failure'],
    forbiddenActions: ['continue_execution', 'return_result'],
    invariants: ['error !== null', 'result === null']
}
```

### SUSPENDED

```typescript
{
    name: 'SUSPENDED',
    description: 'Paused by guard or user',
    allowedActions: ['check_guard', 'wait_signal', 'report_status'],
    forbiddenActions: ['execute', 'modify', 'delegate'],
    invariants: ['execution.paused === true', 'guard.active === true']
}
```

## State Invariants

### Per-State Invariants

| State | Must Maintain | Must Not Violate |
|-------|---------------|------------------|
| INITIALIZING | Identity loaded | Execute anything |
| IDLE | No active task | Have active task |
| ANALYZING | Have valid task | Execute without plan |
| EXECUTING | Follow plan | Violate scope |
| VALIDATING | Run all checks | Skip checks |
| COMPLETED | Valid result | Have errors |
| FAILED | Error logged | Continue execution |
| SUSPENDED | Guard active | Execute while suspended |

## Portuguese

### Propósito

Define todos os estados válidos para o Agente e suas propriedades.

### Definições de Estado

| Estado | Ação de Entrada | Ação de Saída | Transições Válidas |
|--------|-----------------|---------------|-------------------|
| INITIALIZING | Carregar identidade | Definir modo | IDLE |
| IDLE | Nenhuma | Armazenar contexto | ANALYZING, SUSPENDED |
| ANALYZING | Parse tarefa | Criar plano | EXECUTING, IDLE |
| EXECUTING | Aplicar modo | Completar unidade | VALIDATING, SUSPENDED, FAILED |
| VALIDATING | Executar checks | Verificar resultado | COMPLETED, EXECUTING |
| COMPLETED | Armazenar memória | Limpar contexto | IDLE |
| FAILED | Log falha | Alertar guard | IDLE |
| SUSPENDED | Habilitar guard | Limpar flags | IDLE, EXECUTING |

## Related

- [[knowledge/md/foundation/AgentClass]]
- [[knowledge/md/foundation/Transitions]]
- [[knowledge/md/foundation/ModeInterface]]
- [[knowledge/md/control/Drift]]