---
title: Big-O Notation
layer: foundations
type: concept
priority: high
version: 1.0.0
tags:
  - Foundations
  - Algorithms
  - Complexity
description: Mathematical notation describing the upper bound of an algorithm time or space complexity as input grows.
---

# Big-O Notation

## Description

Mathematical notation describing the upper bound of an algorithm time or space complexity as input grows.

## Purpose

**When to use:**
- When building systems that require this pattern or concept
- When you need to understand tradeoffs and best practices

**When to avoid:**
- When simpler solutions adequately solve the problem
- When the complexity overhead is not justified

## Rules

1. Understand the concept thoroughly before applying it
2. Consider tradeoffs and alternatives
3. Document your implementation decisions
4. Test thoroughly, especially edge cases
5. Monitor in production for unexpected behavior

## Examples

### Good Example

```
# Implementation following best practices
# Clear, well-documented approach
```

### Bad Example

```
# Common mistake or anti-pattern
# Leads to problems down the line
```

**Why it's bad:** Explain the specific risks or problems with this approach.

## Failure Modes

- **Ignoring constants** → slow code when O(1) algorithm has high constant factor → benchmark actual performance, consider constants
- **Worst-case confusion** → poor UX when average case differs from worst case → analyze average case, use amortized analysis
- **Space complexity ignored** → OOM when memory not considered → track memory alongside time
- **Premature optimization** → wasted effort when optimizing non-bottlenecks → profile first, optimize hotspots only

## Best Practices

- Start simple and add complexity only when needed
- Document your decisions and tradeoffs
- Test thoroughly with realistic scenarios
- Monitor in production and alert on anomalies
- Review periodically as requirements evolve

## Related Topics

- [[Architecture]]
- [[Design]]
- [[Quality]]
