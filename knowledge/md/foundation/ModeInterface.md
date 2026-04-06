---
layer: foundation
type: mode-interface
priority: critical
read_order: 15
version: 1.0.0
tags:
  - oop
  - interface
  - modes
---

# Mode Interface

## Overview

Defines the AgentMode interface and concrete implementations.

## Interface Definition

### IAgentMode

```typescript
interface IAgentMode {
    // Properties
    readonly name: ModeName;
    readonly priority: number;
    
    // Core methods
    analyze(task: Task): AnalysisResult;
    plan(task: Task): Plan;
    execute(context: ExecutionContext): ExecutionResult;
    validate(result: Result): ValidationResult;
    
    // Lifecycle
    onEnter(): void;
    onExit(): void;
    
    // Checks
    checkScope(action: Action): boolean;
    checkComplexity(item: Item): boolean;
}
```

### Mode Contracts

All modes MUST implement:

| Contract | Description | Required |
|----------|-------------|----------|
| analyze() | Parse and understand task | ✓ |
| execute() | Perform work | ✓ |
| validate() | Self-check result | ✓ |
| checkScope() | Enforce boundaries | ✓ |
| onEnter/onExit() | Lifecycle hooks | ✓ |

## Mode Implementations

### STRICT Mode

```typescript
class StrictMode implements IAgentMode {
    readonly name: 'STRICT' = 'STRICT';
    readonly priority: 4;
    
    analyze(task: Task): AnalysisResult {
        return {
            minimal: true,
            scope: task.exactScope,
            constraints: task.statedConstraints
        };
    }
    
    checkScope(action: Action): boolean {
        return action.withinOriginalScope;
    }
    
    checkComplexity(item: Item): boolean {
        return item.additions <= 0;
    }
}
```

### MINIMAL Mode

```typescript
class MinimalMode implements IAgentMode {
    readonly name: 'MINIMAL' = 'MINIMAL';
    readonly priority: 2;
    
    execute(context: ExecutionContext): ExecutionResult {
        return context.task.oneLineSolution;
    }
}
```

### ANALYSIS Mode

```typescript
class AnalysisMode implements IAgentMode {
    readonly name: 'ANALYSIS' = 'ANALYSIS';
    readonly priority: 3;
    
    analyze(task: Task): AnalysisResult {
        return {
            rootCauses: identify(task.problem),
            alternatives: explore(task),
            risks: assess(task)
        };
    }
}
```

### CREATIVE Mode

```typescript
class CreativeMode implements IAgentMode {
    readonly name: 'CREATIVE' = 'CREATIVE';
    readonly priority: 1;
    
    execute(context: ExecutionContext): ExecutionResult {
        return {
            options: brainstorm(context),
            ranked: rankByInnovation(options)
        };
    }
    
    // Forbidden in CREATIVE:
    // - Security validation
    // - Production checks
}
```

### PARANOID Mode

```typescript
class ParanoidMode implements IAgentMode {
    readonly name: 'PARANOID' = 'PARANOID';
    readonly priority: 5;
    
    validate(result: Result): ValidationResult {
        return {
            checks: runAllSecurityChecks(result),
            failures: findAllFailureModes(result),
            edgeCases: testAllEdgeCases(result)
        };
    }
}
```

## Mode Selection Matrix

| Task Type | Default Mode | Mode Priority |
|-----------|--------------|----------------|
| Quick fix | MINIMAL | 2 |
| Analysis | ANALYSIS | 3 |
| Engineering | STRICT | 4 |
| Security | PARANOID | 5 |
| Naming | CREATIVE | 1 |

## Portuguese

### Propósito

Define a interface AgentMode e implementações concretas.

### Contratos de Modo

Todos os modos DEVEM implementar:

| Contrato | Descrição | Requerido |
|----------|-----------|-----------|
| analyze() | Parse e entenda tarefa | ✓ |
| execute() | Execute trabalho | ✓ |
| validate() | Auto-verificação | ✓ |
| checkScope() | enforcement de limites | ✓ |
| onEnter/onExit() | ganchos de ciclo de vida | ✓ |

## Related

- [[knowledge/md/foundation/AgentClass]]
- [[knowledge/md/foundation/AgentStates]]
- [[knowledge/md/foundation/LSP]]
- [[knowledge/md/foundation/OCP]]