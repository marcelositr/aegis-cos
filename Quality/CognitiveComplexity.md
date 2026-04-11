---
title: Cognitive Complexity
title_pt: Complexidade Cognitiva
layer: quality
type: concept
priority: high
version: 2.0.0
tags:
  - Quality
  - Metrics
  - Complexity
  - Maintainability
description: A measure of how difficult code is for humans to understand, based on control flow nesting, breaks in linear flow, and recursive logic.
description_pt: Medida de quao dificil e o codigo para humanos entenderem, baseada em fluxo de controle aninhado, quebras no fluxo linear e logica recursiva.
prerequisites:
  - [[CyclomaticComplexity]]
  - [[StaticAnalysis]]
estimated_read_time: 15 min
difficulty: intermediate
---

# Cognitive Complexity

## Description

Cognitive Complexity, introduced by SonarSource in 2018, quantifies how hard code is for a human reader to comprehend. Unlike [[CyclomaticComplexity]], which counts decision points mechanically, Cognitive Complexity models human understanding by:

- **Incrementing** for each break in linear control flow (`if`, `else`, `switch`, loops, catch blocks, goto)
- **Adding nesting penalties** when flow-breaking structures are nested (nesting level + 1 per level)
- **Ignoring shorthand** structures that collapse complexity (ternary operators, logical AND/OR chains, null coalescing)
- **Counting recursion** as +1 since it requires mental stack tracking

The metric correlates strongly with bug density. Studies show functions with Cognitive Complexity above 15 have 2-3x more defects than those below 5.

## When to Use

- **Code review gates**: Set thresholds (e.g., max 15 per function) in [[QualityGates]] to catch complexity before merge
- **Refactoring prioritization**: Sort functions by Cognitive Complexity to identify which modules yield the highest ROI from decomposition
- **Onboarding assessments**: Use as an objective measure of codebase difficulty for new developers
- **Technical debt estimation**: Multiply complexity score by estimated cost-per-point to quantify debt in [[TechnicalDebt]] registers
- **Pre-commit hooks**: Integrate with [[Linting]] tools (e.g., `eslint-plugin-cognitive-complexity`, `sonar-scanner`) to enforce limits

## When NOT to Use

- **DSLs and query builders**: Fluent APIs like LINQ or Pandas chains naturally score high but remain readable due to domain-specific semantics
- **Generated code**: Protocol buffer serializers, GraphQL resolvers, or ORM migrations have inherent complexity that is not a maintenance concern
- **Mathematical algorithms**: Implementations of known algorithms (e.g., Dijkstra, red-black tree insertion) should be judged against the reference algorithm's complexity, not an arbitrary threshold
- **Performance-critical hot paths**: Inlining and loop unrolling intentionally increase complexity for latency gains; measure against [[Performance]] benchmarks instead
- **Test code**: Test fixtures with setup/teardown complexity are acceptable; focus complexity budgets on production code

## Tradeoffs

| Aspect | Low Cognitive Complexity | High Cognitive Complexity |
|---|---|---|
| Readability | Linear flow, easy to follow | Requires mental stack to track nested conditions |
| Method count | More, smaller functions | Fewer, larger functions |
| Call overhead | More function calls (usually negligible with inlining) | Fewer calls, marginally faster |
| Testability | Each small function independently testable | Requires complex test matrices to cover branches |
| Git conflicts | Higher chance of conflicts across many files | Lower chance, but larger conflict scope |
| Refactoring risk | Safe to change individual functions | Changes risk cascading side effects |

The key tradeoff is **abstraction overhead vs. comprehension cost**. Decomposing a 50-line function into five 10-line functions adds indirection but makes each unit independently understandable. The indirection cost is nearly zero with modern LTO and JIT inlining; the comprehension cost is paid every time a developer reads the code.

## Alternatives

- **Cyclomatic Complexity**: Counts decision points but ignores nesting. Better for estimating test case count, worse for readability prediction. See [[CyclomaticComplexity]].
- **Halstead Volume**: Measures operator/operand counts to estimate implementation effort. Useful for size estimation but does not model control flow understanding.
- **Maintainability Index**: Composite metric combining cyclomatic complexity, lines of code, and Halstead volume. Good for dashboards, poor for actionable refactoring targets.
- **Code Review Heuristics**: Qualitative assessment ("this function feels too complex"). Faster for simple cases but inconsistent across reviewers and untrackable over time.
- **Function Length**: Simple lines-of-code threshold. Crude but effective as a first-pass filter; pair with Cognitive Complexity for precision.

## Failure Modes

1. **Gaming the metric by fragmenting logic**: Developers split a function into `doStep1()`, `doStep2()`, etc., reducing the score but increasing cross-function cognitive load. The reader must now understand the orchestration logic across multiple files. Mitigation: review function cohesion, not just scores. Each extracted function must have a meaningful, domain-specific name.

2. **Ignoring complexity in ternary and logical chains**: `a && b || c && d || e` scores zero in Cognitive Complexity but can be harder to read than an `if/else` chain. The metric explicitly discounts these, but human readers still struggle. Mitigation: apply judgment; rewrite complex boolean expressions as named predicate functions.

3. **Over-reliance on tool defaults**: SonarQube, CodeClimate, and ESLint use different scoring algorithms. A function scoring 12 in SonarQube might score 8 in CodeClimate. Mitigation: pick one tool, calibrate thresholds empirically against your codebase, and enforce consistently.

4. **Complexity hiding behind abstractions**: A function with score 3 that calls `processOrder()` may hide complexity inside that call. Aggregate complexity across the call graph matters more than per-function scores. Mitigation: use [[StaticAnalysis]] tools that compute aggregate complexity per module or feature.

5. **Refactoring under time pressure**: Decomposing complex functions without adequate test coverage introduces regressions. The refactoring to reduce complexity can itself create bugs. Mitigation: write characterization tests (golden master tests) before refactoring high-complexity functions. Capture current behavior, then refactor.

6. **Nesting depth as a proxy for complexity**: Deeply nested code often scores high, but a flat function with 10 independent `if` branches at the same nesting level also has high cognitive load. The nesting multiplier may underweight wide complexity. Mitigation: complement with cyclomatic complexity to catch wide-but-shallow complexity.

7. **Premature optimization of simple code**: Reducing a function from complexity 4 to 2 by extracting a single-use helper adds indirection with no comprehension benefit. The helper's name must carry semantic weight. Mitigation: only extract when the helper has a meaningful name that improves readability at the call site.

## Code Examples

### High Cognitive Complexity (needs refactoring)

```typescript
function processOrder(order: Order, user: User, inventory: Inventory): Result {
  if (user.isActive) {
    if (order.items.length > 0) {
      let total = 0;
      for (const item of order.items) {
        if (inventory.hasStock(item.sku)) {
          if (item.quantity <= inventory.getStock(item.sku)) {
            if (user.tier === 'premium') {
              total += item.price * item.quantity * 0.9;
            } else if (user.tier === 'standard') {
              total += item.price * item.quantity * 0.95;
            } else {
              total += item.price * item.quantity;
            }
            inventory.reserve(item.sku, item.quantity);
          } else {
            return Result.error(`Insufficient stock for ${item.sku}`);
          }
        } else {
          return Result.error(`Item ${item.sku} out of stock`);
        }
      }
      if (order.shipping === 'express') {
        total += 15;
      } else if (order.shipping === 'standard') {
        total += 5;
      }
      return Result.success({ total, orderId: generateId() });
    } else {
      return Result.error('Empty order');
    }
  } else {
    return Result.error('User account inactive');
  }
}
```

**Cognitive Complexity: ~28** (6 nesting levels, multiple decision points, nested pricing logic, nested stock checks). The reader must track: user state, order validity, inventory state, tier pricing, and shipping calculation simultaneously.

### Refactored (low Cognitive Complexity)

```typescript
function processOrder(order: Order, user: User, inventory: Inventory): Result {
  if (!user.isActive) return Result.error('User account inactive');
  if (order.items.length === 0) return Result.error('Empty order');

  const lineItems = validateStock(order.items, inventory);
  if (lineItems.isError) return lineItems;

  const subtotal = calculatePricing(lineItems.value, user.tier);
  const total = subtotal + calculateShipping(order.shipping);

  reserveInventory(lineItems.value, inventory);
  return Result.success({ total, orderId: generateId() });
}

function validateStock(items: OrderItem[], inventory: Inventory): Result<OrderItem[]> {
  for (const item of items) {
    const stock = inventory.getStock(item.sku);
    if (stock === 0) return Result.error(`Item ${item.sku} out of stock`);
    if (item.quantity > stock) return Result.error(`Insufficient stock for ${item.sku}`);
  }
  return Result.ok(items);
}

function calculatePricing(items: OrderItem[], tier: UserTier): number {
  const discount = { premium: 0.9, standard: 0.95, basic: 1.0 }[tier];
  return items.reduce((sum, item) => sum + item.price * item.quantity * discount, 0);
}

function calculateShipping(method: ShippingMethod): number {
  return { express: 15, standard: 5, economy: 0 }[method];
}
```

**Cognitive Complexity per function: 3, 5, 1, 1**. Each function has a single responsibility. The main function reads like a narrative: validate, price, ship, reserve.

### Boolean complexity hidden in logical chains

```python
# Bad: zero cognitive complexity score but hard to parse
def should_send_notification(user, settings, order):
    return (user.is_active and
            settings.notifications_enabled and
            (order.total > settings.min_order_threshold or
             user.tier == 'premium') and
            not (settings.quiet_hours and
                 is_within_quiet_hours(user.timezone)) and
            (order.status == 'confirmed' or
             (order.status == 'pending' and order.is_priority)))

# Good: named predicates carry semantic weight
def should_send_notification(user, settings, order):
    meets_order_criteria = (
        order.total > settings.min_order_threshold or
        user.tier == 'premium'
    )
    outside_quiet_hours = not (settings.quiet_hours and is_within_quiet_hours(user.timezone))
    valid_order_status = (
        order.status == 'confirmed' or
        (order.status == 'pending' and order.is_priority)
    )

    return (user.is_active and
            settings.notifications_enabled and
            meets_order_criteria and
            outside_quiet_hours and
            valid_order_status)
```

## Best Practices

- **Set team-agreed thresholds**: Start with 15 per function (SonarQube default) and adjust based on your codebase's distribution. Use `[[Metrics]]` dashboards to track.
- **Extract named predicates**: Replace complex boolean expressions with functions whose names describe the business rule.
- **Use guard clauses**: Early returns flatten nesting and reduce cognitive load more effectively than refactoring to patterns.
- **Prefer data-driven logic**: Replace nested `if/else` pricing or shipping logic with lookup tables or strategy maps, as shown in the refactored example.
- **Measure aggregate complexity**: Track total Cognitive Complexity per module, not just per function. A module with 50 functions scoring 3 each may be harder to understand than one with 5 functions scoring 10 each.
- **Integrate with CI**: Add cognitive complexity checks to [[QualityGates]] alongside [[Linting]] and [[StaticAnalysis]]. Fail builds when new code exceeds thresholds.
- **Pair with code review**: Metrics catch structural complexity; human reviewers catch semantic complexity (e.g., a simple function implementing the wrong business rule).

## Related Topics

- [[CyclomaticComplexity]] -- complementary metric counting decision paths; pair both for complete complexity picture
- [[StaticAnalysis]] -- automated detection of complexity violations in CI/CD pipelines
- [[QualityGates]] -- enforce complexity thresholds before merge
- [[TechnicalDebt]] -- complexity as quantifiable debt; track reduction over time
- [[Metrics]] -- broader context of code quality measurement
- [[Linting]] -- tooling integration for complexity enforcement
- [[Composability]] -- decomposition as a strategy to reduce per-unit complexity
- [[CodeQuality]] -- overarching quality attributes including readability and maintainability
- [[Refactoring]] -- techniques for reducing complexity without changing behavior
