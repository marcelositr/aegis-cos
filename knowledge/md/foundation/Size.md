---
layer: foundation
type: size-limits
priority: critical
read_order: 7
version: 1.0.0
tags:
  - size
  - limits
  - metrics
  - thresholds
---

# Size

## Overview

Defines maximum sizes to prevent complexity accumulation.

## File Size Limits

| Type | Maximum | Reason |
|------|---------|--------|
| Source file | 200 lines | Single responsibility |
| Test file | 300 lines | Focus per test |
| Markdown doc | 500 lines | Single topic |
| Configuration | 100 lines | Single purpose |
| Script | 150 lines | Single task |

### Size Categories

| Lines | Category | Action |
|-------|----------|--------|
| 1-50 | Optimal | Green |
| 51-100 | Acceptable | Green |
| 101-150 | Warning | Yellow |
| 151-200 | Critical | Red |
| 200+ | Refactor | Required |

## Function/Method Limits

| Type | Maximum | Reason |
|------|---------|--------|
| Function | 20 lines | Single purpose |
| Method | 30 lines | Per-class method |
| Constructor | 10 lines | Setup only |
| Callback | 5 lines | Delegate pattern |

### Line Count Best Practices

```
✓ GOOD:
function validateInput(input) {
    if (!input) return false;
    if (typeof input !== 'string') return false;
    return input.length > 0;
}

✗ BAD (Too long):
function processUserData(data, options, config) {
    // 50+ lines of processing
}
```

## Class Limits

| Type | Maximum | Reason |
|------|---------|--------|
| Class methods | 10 | Single responsibility |
| Class properties | 10 | Cohesion |
| Constructor params | 5 | Too many dependencies |
| Inherited methods | 5 | Prefer composition |

## Scope Metrics

| Metric | Maximum | Warning |
|--------|---------|---------|
| Files modified per task | 3 | > 1 file |
| New files per task | 2 | > 1 file |
| Directories touched | 2 | > 1 directory |
| Dependencies added | 0 | Strict |

## Diff Limits

| Metric | Maximum | Reason |
|-------|---------|--------|
| Lines added per PR | 100 | Review overhead |
| Lines deleted per PR | 100 | History clarity |
| Files changed per PR | 5 | Scope control |

## Complexity Metrics

| Metric | Good | Warning | Bad |
|--------|------|---------|-----|
| Cyclomatic complexity | 1-5 | 6-10 | 10+ |
| Nested conditionals | 1-2 | 3 | 4+ |
| Function parameters | 0-3 | 4 | 5+ |
| Import count | 0-5 | 6-10 | 10+ |

## Portuguese

### Visão Geral

Define tamanhos máximos para prevenir acumulação de complexidade.

### Limites de Tamanho

| Tipo | Máximo | Razão |
|------|--------|-------|
| Arquivo fonte | 200 linhas | Responsabilidade única |
| Arquivo de teste | 300 linhas | Foco por teste |
| Documento markdown | 500 linhas | Tópico único |
| Configuração | 100 linhas | Propósito único |
| Script | 150 linhas | Tarefa única |

### Métricas de Complexidade

| Métrica | Bom | Aviso | Ruim |
|---------|-----|-------|------|
| Complexidade ciclomática | 1-5 | 6-10 | 10+ |
| Condicionais aninhados | 1-2 | 3 | 4+ |
| Parâmetros de função | 0-3 | 4 | 5+ |
| Contagem de imports | 0-5 | 6-10 | 10+ |

## Related

- [[knowledge/md/foundation/Naming]]
- [[knowledge/md/foundation/Complexity]]
- [[knowledge/md/failure/Overengineering]]
- [[knowledge/md/foundation/DesignLaws]]