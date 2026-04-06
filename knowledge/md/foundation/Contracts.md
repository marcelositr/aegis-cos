---
layer: foundation
type: validation-contracts
priority: critical
read_order: 16
version: 1.0.0
tags:
  - oop
  - contracts
  - validation
  - interface
---

# Contracts

## Purpose

Defines validation contracts for agent behavior. Ensures interfaces are respected.

## Contract Types

### Behavioral Contract

| Aspect | Requirement |
|--------|-------------|
| Pre-conditions | Must be met before execution |
| Post-conditions | Must be met after execution |
| Invariants | Must remain true during execution |

### Validation Rules

| Rule | Description |
|------|-------------|
| Input validation | All inputs must be validated |
| Output validation | All outputs must be verified |
| State validation | State transitions must be valid |

## Contract Enforcement

### Before Execution

```
1. Verify pre-conditions
2. Validate inputs
3. Check state readiness
```

### After Execution

```
1. Verify post-conditions
2. Validate outputs
3. Confirm state transition
```

## Agent Contracts

### Identity Contract

| Requirement | Validation |
|-------------|------------|
| Directives loaded | All directives present |
| Constraints active | No violations allowed |
| Identity consistent | Same identity across sessions |

### Mode Contract

| Requirement | Validation |
|-------------|------------|
| Mode defined | Current mode identified |
| Mode valid | Mode in allowed set |
| Mode transition valid | Transition follows rules |

### State Contract

| Requirement | Validation |
|-------------|------------|
| State defined | Current state identified |
| State valid | State in allowed set |
| State transition valid | Transition follows state machine |

## Contract Violations

| Violation | Response |
|-----------|----------|
| Pre-condition fail | Abort execution |
| Post-condition fail | Rollback changes |
| Invariant fail | Enter error state |

## Portuguese

### Propósito

Define contratos de validação para comportamento do agente. Garante que interfaces sejam respeitadas.

### Tipos de Contrato

| Tipo | Descrição |
|------|-----------|
| Pré-condições | Devem ser atendidas antes da execução |
| Pós-condições | Devem ser atendidas após execução |
| Invariantes | Devem permanecer verdadeiras durante execução |

### Aplicação de Contratos

**Antes da Execução:**

1. Verificar pré-condições
2. Validar entradas
3. Verificar prontidão do estado

**Após a Execução:**

1. Verificar pós-condições
2. Validar saídas
3. Confirmar transição de estado

## Related

- [[knowledge/md/foundation/ModeInterface]]
- [[knowledge/md/foundation/AgentStates]]
- [[knowledge/md/agent/Contract]]
- [[knowledge/md/control/SelfCheck]]
