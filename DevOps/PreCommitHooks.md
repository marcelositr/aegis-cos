---
title: Pre-Commit Hooks
layer: devops
type: concept
priority: high
version: 1.0.0
tags:
  - DevOps
  - CI
  - Quality
description: Automated checks that run before code is committed: linting, formatting, tests, and security scans.
---

# Pre-Commit Hooks

## Description

Automated checks that run before code is committed: linting, formatting, tests, and security scans.

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

- **Slow hooks** → developer frustration and bypassed hooks when execution time too long → optimize with parallel execution and caching
- **Bypassed hooks** → code quality issues when developers skip hooks → keep hooks fast, warn but don't block for minor issues
- **Inconsistent environments** → hook failures across different developer machines → containerize hook dependencies
- **Security vulnerabilities** → exposed secrets when hooks run on untrusted code → avoid logging sensitive data, use secure credential handling

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
