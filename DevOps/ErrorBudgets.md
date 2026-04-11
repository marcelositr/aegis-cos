---
title: Error Budgets
layer: devops
type: concept
priority: high
version: 1.0.0
tags:
  - DevOps
  - SRE
  - SLO
description: The acceptable amount of downtime or errors before a service violates its SLO, used to balance reliability and feature velocity.
---

# Error Budgets

## Description

The acceptable amount of downtime or errors before a service violates its SLO, used to balance reliability and feature velocity.

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

- **Overly tight SLOs** → team burnout when error budget depleted too quickly → set realistic SLOs based on historical data
- **Gaming the metrics** → false sense of security when error budget artificially preserved → monitor customer-impacting metrics only
- **Feature freeze loops** → blocked releases when teams fear budget exhaustion → use error budget policies that balance velocity and reliability
- **Metric drift** → SLO violations when definitions change without notice → document SLO definitions clearly, version control them

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
