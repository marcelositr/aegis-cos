---
layer: foundation
type: state-transitions
priority: critical
read_order: 14
version: 1.0.0
tags:
  - oop
  - transitions
  - state-machine
---

# Transitions

## Overview

Defines valid state transitions and their triggering events.

## Transition Table

| From | To | Event | Guard Condition | Action |
|------|----|-------|-----------------|--------|
| INITIALIZING | IDLE | bootstrap_complete | identity.loaded | Set mode |
| IDLE | ANALYZING | task_received | valid_task | Store context |
| IDLE | SUSPENDED | guard_triggered | guard.active | Pause |
| ANALYZING | EXECUTING | plan_ready | valid_plan | Activate |
| ANALYZING | IDLE | task_invalid | !valid_task | Discard |
| EXECUTING | VALIDATING | unit_complete | has_result | Prepare |
| EXECUTING | SUSPENDED | anomaly_detected | guard.active | Pause |
| EXECUTING | FAILED | execution_error | error.occurred | Log |
| VALIDATING | COMPLETED | validation_passed | all_checks.ok | Finalize |
| VALIDATING | EXECUTING | validation_failed | fix_needed | Retry |
| VALIDATING | FAILED | validation_error | !recoverable | Log |
| COMPLETED | IDLE | cleanup_complete | result.stored | Reset |
| FAILED | IDLE | reset_requested | human_approved | Clear |
| SUSPENDED | IDLE | resume_signal | !guard.active | Clear |
| SUSPENDED | EXECUTING | resume_signal | guard.override | Resume |

## Transition Diagrams

### Happy Path

```
┌──────────────┐    bootstrap    ┌──────────────┐
│INITIALIZING  │───────────────►│     IDLE     │
└──────────────┘                └──────┬───────┘
                                       │ task
                                       ▼
                                ┌──────────────┐
                                │  ANALYZING   │
                                └──────┬───────┘
                                       │ plan
                                       ▼
                                ┌──────────────┐
                                │  EXECUTING   │
                                └──────┬───────┘
                                       │ done
                                       ▼
                                ┌──────────────┐
                                │ VALIDATING   │
                                └──────┬───────┘
                                       │ pass
                                       ▼
                                ┌──────────────┐
                                │  COMPLETED   │
                                └──────────────┘
```

### Error Paths

```
┌──────────────┐                ┌──────────────┐
│  EXECUTING  │──error─────────►│    FAILED    │
└──────────────┘                └──────┬───────┘
                                        │ reset
                                        ▼
                                ┌──────────────┐
                                │     IDLE     │
                                └──────────────┘

┌──────────────┐                ┌──────────────┐
│    IDLE     │──guard────────►│  SUSPENDED   │
└──────────────┘                └──────┬───────┘
                                        │ resume
                                        ▼
                                ┌──────────────┐
                                │     IDLE     │
                                └──────────────┘
```

## Transition Guards

### Guard Functions

```typescript
interface TransitionGuard {
    (context: AgentContext): boolean;
}

// Example guards:
const hasIdentity = (ctx) => ctx.identity !== null;
const hasValidTask = (ctx) => ctx.task !== null && ctx.task.valid;
const noAnomalies = (ctx) => ctx.guard.anomalies.length === 0;
const validationPassed = (ctx) => ctx.validation.results.every(r => r.passed);
```

### Guard Priority

| Priority | Guard | Applied To |
|----------|-------|------------|
| 1 | guard_triggered | ALL |
| 2 | human_approved | FAILED→IDLE |
| 3 | valid_task | IDLE→ANALYZING |
| 4 | valid_plan | ANALYZING→EXECUTING |
| 5 | all_checks.ok | VALIDATING→COMPLETED |

## Transition Actions

### Action Table

| Transition | Side Effects |
|------------|--------------|
| → IDLE | Clear execution context |
| → ANALYZING | Store task, start timer |
| → EXECUTING | Set mode, activate guard |
| → VALIDATING | Freeze changes, prepare checks |
| → COMPLETED | Store to memory, notify |
| → FAILED | Log, alert, rollback |
| → SUSPENDED | Enable watch, pause timer |

## Portuguese

### Propósito

Define transições de estado válidas e seus eventos gatilho.

### Tabela de Transição

| De | Para | Evento | Condição Guard | Ação |
|----|------|--------|----------------|------|
| INITIALIZING | IDLE | bootstrap_complete | identity.loaded | Definir modo |
| IDLE | ANALYZING | task_received | valid_task | Armazenar contexto |
| IDLE | SUSPENDED | guard_triggered | guard.active | Pausar |
| ANALYZING | EXECUTING | plan_ready | valid_plan | Ativar |
| EXECUTING | VALIDATING | unit_complete | has_result | Preparar |
| EXECUTING | FAILED | execution_error | error.occurred | Log |
| VALIDATING | COMPLETED | validation_passed | all_checks.ok | Finalizar |
| COMPLETED | IDLE | cleanup_complete | result.stored | Reset |

## Related

- [[knowledge/md/foundation/AgentClass]]
- [[knowledge/md/foundation/AgentStates]]
- [[knowledge/md/foundation/ModeInterface]]
- [[knowledge/md/control/Drift]]