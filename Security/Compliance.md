---
title: Compliance
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - Compliance
  - Audit
description: Adhering to regulatory requirements, industry standards, and organizational policies for security and privacy.
---

# Compliance

## Description

Adhering to regulatory requirements, industry standards, and organizational policies for security and privacy.

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

- **Compliance gaps** → audit failures when controls not documented → maintain evidence repository, automate compliance checks
- **Scope creep** → excessive effort when compliance requirements overapplied → clearly define system scope, map controls precisely
- **Outdated controls** → non-compliance when regulations change and controls not updated → monitor regulatory changes, update controls
- **Audit fatigue** → team exhaustion when too many audits → consolidate audits, use continuous compliance monitoring

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
