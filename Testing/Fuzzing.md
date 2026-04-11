---
title: Fuzzing
title_pt: Fuzzing
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - Fuzzing
description: Testing by providing random/invalid input to find bugs.
description_pt: Testando fornecendo entrada aleatória/inválida para encontrar bugs.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Fuzzing

## Description

Fuzzing tests code by providing random or malformed input to discover:
- Crash bugs
- Security vulnerabilities
- Edge cases that manual tests miss

## Purpose

**When fuzzing is valuable:**
- For security-critical code (parsers, deserializers)
- When input handling is complex
- For finding unknown vulnerabilities
- For robustness testing

**When fuzzing may not be needed:**
- For simple, well-tested code
- For UI-only logic
- When performance impact is too high

**The key question:** Could unexpected input crash or exploit this code?

## Examples

```python
# Using atheris for Python
import atheris
import sys

def test_fuzzer(data):
    from mymodule import parse
    try:
        parse(data)
    except (ValueError, TypeError):
        pass  # Expected for invalid input

atheris.Setup(sys.argv, test_fuzzer)
atheris.Fuzz()

# Using hypothesis (property-based fuzzing)
from hypothesis import given, strategies as st

@given(st.text())
def test_parser(s):
    parse(s)  # Tests random strings
```

## Anti-Patterns

### 1. Fuzzing Without Crash Handling

**Bad:** Running a fuzzer that causes crashes but does not capture the input that caused them or the stack trace
**Why it's bad:** Bugs are found but cannot be reproduced — the fuzzer reports "crash detected" without the information needed to fix it
**Good:** Implement proper crash capture with input reproduction — save the failing input to a corpus and capture stack traces for debugging

### 2. No Corpus Management

**Bad:** Not saving interesting inputs between fuzzing runs, forcing the fuzzer to rediscover the same code paths every time
**Why it's bad:** Fuzzing efficiency is drastically reduced — the fuzzer wastes cycles on inputs it has already explored instead of finding new paths
**Good:** Maintain and curate a fuzzing corpus — save interesting inputs that cover new code paths and use them as seeds for future runs

### 3. Fuzzing Already Well-Tested Code

**Bad:** Fuzzing code that already has comprehensive unit tests and input validation
**Why it's bad:** Diminishing returns — the fuzzer spends cycles finding bugs that unit tests would catch faster, while the actual vulnerable code goes untested
**Good:** Focus fuzzing on parsers, deserializers, protocol handlers, and untrusted input boundaries — these are where unexpected input causes the most damage

### 4. Fuzzing in Production Without Safeguards

**Bad:** Running fuzzing inputs against production systems or shared environments
**Why it's bad:** Fuzzing generates malformed, unexpected, and potentially destructive input — service disruption, data corruption, and security incidents are likely
**Good:** Run fuzzing only in isolated test environments with resource limits — use containers, sandboxes, or dedicated fuzzing infrastructure

## Best Practices

### 1. Use Existing Fuzzers

```bash
# Python: atheris
# Go: gofuzz
# C/C++: libFuzzer, AFL
```

### 2. Cover Edge Cases

```python
# Provide various input types
@given(st.one_of(st.text(), st.none(), st.integers()))
def test_parse(value):
    parse(value)
```

## Failure Modes

- **Fuzzing without crash handling** → fuzzer causes crashes that are not captured → bugs found but not reproducible → implement proper crash capture with input reproduction and stack traces
- **Fuzzing already well-tested code** → fuzzing code with comprehensive unit tests → diminishing returns on fuzzing investment → focus fuzzing on parsers, deserializers, and untrusted input handlers
- **No corpus management** → interesting inputs not saved between runs → fuzzer re-discovers same paths → maintain and curate fuzzing corpus to guide fuzzer toward new code paths
- **Fuzzing with insufficient coverage feedback** → fuzzer does not know which inputs are interesting → random input generation with low effectiveness → use coverage-guided fuzzing with instrumentation
- **Ignoring timeout issues** → fuzzer spends too long on slow inputs → reduced fuzzing throughput → set appropriate timeouts and track slow inputs for optimization
- **Not sanitizing fuzzer input** → fuzzer generates inputs that trigger known issues → wasted cycles on already-fixed bugs → maintain blocklist of known crash patterns and skip them
- **Fuzzing in production without safeguards** → fuzzing inputs reach production systems → service disruption and data corruption → run fuzzing only in isolated test environments with resource limits

## Related Topics

- [[UnitTesting]]
- [[PropertyTesting]]
- [[MutationTesting]]
- [[SecurityHeaders]]
- [[InputValidation]]
- [[SQLInjection]]
- [[XSS]]
- [[ChaosEngineering]]
