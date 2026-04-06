---
layer: foundation
type: complexity-rules
priority: critical
read_order: 8
version: 1.0.0
tags:
  - complexity
  - metrics
  - cognitive-load
  - control
---

# Complexity

## Overview

Defines complexity thresholds to maintain code quality.

## Cyclomatic Complexity

### Definition

> Number of linearly independent paths through code.

### Thresholds

| Complexity | Level | Risk |
|------------|-------|------|
| 1-5 | Simple | Low |
| 6-10 | Moderate | Medium |
| 11-20 | Complex | High |
| 21+ | Untestable | Very High |

### How to Calculate

```
CC = E - N + 2P

Where:
E = Edges in graph
N = Nodes in graph  
P = Connected components (usually 1)
```

### Simple = Good

| Code | CC | Assessment |
|------|-----|-------------|
| Sequential | 1 | ✓ Excellent |
| One if | 2 | ✓ Good |
| Two ifs (and) | 2 | ✓ Good |
| Two ifs (or) | 3 | ✓ Good |
| Loop | 2 | ✓ Good |
| Nested ifs | N | ✗ Complex |

## Cognitive Load

### Definition

> Mental effort required to understand code.

### Load Limits

| Factor | Maximum | Rationale |
|--------|---------|-----------|
| Variables in scope | 7 | Miller's law |
| Indentation levels | 4 | Readability |
| Parameters | 4 | Memory limit |
| Dependencies visible | 5 | Cognitive limit |

### Reduction Strategies

```
✗ BEFORE (High cognitive load):
if (user && user.isActive && user.hasPermission && !user.isExpired) {
    process(user);
}

✓ AFTER (Low cognitive load):
const canProcess = userValidator.canProcess(user);
if (canProcess) {
    process(user);
}
```

## Abstraction Levels

### Level Table

| Level | Description | Example |
|-------|-------------|---------|
| 1 | Constants | `MAX_SIZE = 100` |
| 2 | Simple functions | `isValid(input)` |
| 3 | Operations | `calculateTotal(items)` |
| 4 | Workflow | `processOrder(order)` |
| 5 | Business logic | `handleCustomer(customer)` |

### Rule

> Functions should operate at ONE level of abstraction.

```typescript
// ✗ MIXED LEVELS
function checkout(cart: Cart) {
    const total = cart.items.reduce((sum, item) => {  // Level 2
        return sum + item.price;                        // Level 2
    });                                                 // Level 2
    validatePayment(total);                             // Level 3
    sendEmail();                                        // Level 4
    updateInventory();                                  // Level 4
}

// ✓ SINGLE LEVEL
function checkout(cart: Cart) {
    const total = calculateTotal(cart);     // Level 3
    processPayment(total);                  // Level 3
    notifyCustomer(cart.customer);           // Level 4
}
```

## Coupling Metrics

### Afferent Coupling (Ca)

> Classes that depend on this class.

| Ca | Assessment |
|----|------------|
| 0 | Isolated |
| 1-3 | Low |
| 4-7 | Medium |
| 8+ | High (hub) |

### Efferent Coupling (Ce)

> Classes this depends on.

| Ce | Assessment |
|----|------------|
| 0 | Self-contained |
| 1-3 | Low |
| 4-7 | Medium |
| 8+ | High (fragile) |

### Instability

```
I = Ce / (Ca + Ce)

I = 0 → Perfectly stable (no dependencies)
I = 1 → Perfectly unstable (only dependencies)
Target: I between 0.3 and 0.7
```

## Portuguese

### Visão Geral

Define limites de complexidade para manter qualidade de código.

### Complexidade Ciclomática

| Complexidade | Nível | Risco |
|--------------|-------|-------|
| 1-5 | Simples | Baixo |
| 6-10 | Moderado | Médio |
| 11-20 | Complexo | Alto |
| 21+ | Intestável | Muito Alto |

### Limites de Carga Cognitiva

| Fator | Máximo | Fundamento |
|--------|--------|------------|
| Variáveis em escopo | 7 | Lei de Miller |
| Níveis de indentação | 4 | Legibilidade |
| Parâmetros | 4 | Limite de memória |
| Dependências visíveis | 5 | Limite cognitivo |

## Related

- [[knowledge/md/foundation/Size]]
- [[knowledge/md/foundation/Naming]]
- [[knowledge/md/failure/Overengineering]]
- [[knowledge/md/foundation/SRP]]