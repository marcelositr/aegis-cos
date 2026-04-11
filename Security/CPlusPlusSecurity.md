---
title: C/C++ Security
title_pt: Segurança C/C++
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - MemorySafety
  - Languages
  - CPlusPlus
description: Security considerations specific to C and C++: buffer overflows, use-after-free, format strings, and undefined behavior.
---

# C/C++ Security

## Description

Security considerations specific to C and C++: buffer overflows, use-after-free, format strings, and undefined behavior.

## Purpose

**When to use:**
- When building systems that require this pattern or concept
- When you need to understand tradeoffs and best practices

**When to avoid:**
- When simpler solutions adequately solve the problem

## Rules

1. Understand the concept thoroughly before applying it
2. Consider tradeoffs and alternatives
3. Document your implementation decisions
4. Test thoroughly

## Examples

### Good Example
```
# Implementation following best practices
```

### Bad Example
```
# Common mistake or anti-pattern
```

**Why it's bad:** Explain the specific risks or problems.

## Failure Modes

- **Buffer overflows** → code execution exploits when bounds not checked → use safe string functions, enable stack canaries
- **Use-after-free** → crashes and exploits when memory accessed after free → use smart pointers, enable sanitizers
- **Integer overflows** → unexpected behavior when arithmetic wraps → use saturated arithmetic, check bounds
- **Race conditions** → data corruption when concurrent access not synchronized → use mutexes, thread-safe data structures

## Best Practices

- Start simple and add complexity only when needed
- Document your decisions and tradeoffs
- Test thoroughly with realistic scenarios
- Monitor in production

## Related Topics

- [[Architecture]]
- [[Design]]
- [[Quality]]
