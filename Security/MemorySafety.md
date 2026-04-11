---
title: Memory Safety
title_pt: Segurança de Memória
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - MemorySafety
description: Writing code that prevents memory-related vulnerabilities.
description_pt: Escrever código que previne vulnerabilidades relacionadas à memória.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Memory Safety

## Description

Memory safety issues occur in languages like C/C++ where developers manage memory manually. Common issues:
- Buffer overflows
- Use after free
- Double free
- Null pointer dereference

Modern languages (Rust, Go, Python) provide memory safety.

## Purpose

**When memory safety is critical:**
- For security-critical code
- For systems programming
- For vulnerability-free code
- When using C/C++

**When not as critical:**
- For managed languages (Python, Java, Go)
- For interpreted languages
- For low-risk applications

**The key question:** Could memory bugs cause security vulnerabilities?

## Examples

### C — Buffer Overflow (VULNERABLE)

```c
// BAD: No bounds checking
void copy_input(char *input) {
    char buffer[64];
    strcpy(buffer, input);  // Overflow if input > 64 bytes
}

// GOOD: Bounded copy
void copy_input_safe(char *input) {
    char buffer[64];
    strncpy(buffer, input, sizeof(buffer) - 1);
    buffer[sizeof(buffer) - 1] = '\0';  // Null terminate
}
```

### C — Use After Free (VULNERABLE)

```c
// BAD: Using freed memory
char *ptr = malloc(100);
free(ptr);
printf("%s", ptr);  // Undefined behavior!

// GOOD: Nullify after free
char *ptr = malloc(100);
free(ptr);
ptr = NULL;  // Prevents use-after-free
```

### Rust — Memory Safe by Design

```rust
// Rust prevents these at compile time
fn safe_copy(input: &str) -> String {
    String::from(input)  // No buffer overflow possible
}
// No manual memory management = no use-after-free
```

## Failure Modes

- **Buffer overflow** → attacker overwrites return address → arbitrary code execution
- **Use after free** → dangling pointer → crash or data corruption
- **Double free** → heap corruption → unpredictable behavior
- **Null pointer dereference** → segfault → denial of service
- **Integer overflow in allocation** → undersized buffer → heap overflow

## Anti-Patterns

### 1. Manual Memory Management Without Tooling

**Bad:** Writing C/C++ code without AddressSanitizer, Valgrind, or static analysis in the development workflow
**Why it's bad:** Memory bugs are subtle and often do not crash immediately — they corrupt data silently and manifest as security vulnerabilities months later
**Good:** Compile with `-fsanitize=address` during development and testing, run Valgrind regularly, and use static analysis tools on every commit

### 2. Assuming Nullification After Free Is Enough

**Bad:** Setting a pointer to NULL after freeing it and assuming this prevents all use-after-free bugs
**Why it's bad:** Other copies of the pointer still exist — only one copy is nullified, and dangling references in other parts of the code still cause use-after-free
**Good:** Design ownership semantics so there is a single owner responsible for the memory — use smart pointers in C++ or move to Rust's ownership model

### 3. Integer Overflow in Size Calculations

**Bad:** Calculating buffer sizes using arithmetic that can overflow (`malloc(count * size)`) without checking for overflow
**Why it's bad:** An attacker provides values that cause the multiplication to wrap around, allocating a tiny buffer that is then overflowed with large amounts of data
**Good:** Use checked arithmetic (`__builtin_mul_overflow` in GCC, `SafeInt` in MSVC) before any size calculation used for allocation

### 4. Ignoring Memory Safety in Managed Languages

**Bad:** Assuming Python, Java, or Go are immune to memory safety issues
**Why it's bad:** Unsafe FFI calls, deserialization of untrusted data, and excessive memory allocation can still cause vulnerabilities even in managed languages
**Good:** Audit FFI boundaries, validate deserialized data, and implement memory limits even in managed languages

## Best Practices

### 1. Use Safe Languages

```python
# Prefer Rust, Go, Python over C/C++ for new code
```

### 2. If Using C/C++

```python
# Use safe functions
# strncpy instead of strcpy
# snprintf instead of sprintf
# fgets instead of gets
```

### 3. Use Static Analysis

```python
# Use tools like AddressSanitizer
# gcc -fsanitize=address -g program.c
```

## Related Topics

- [[Security MOC]]
- [[Concurrency]]
- [[CryptographyBasics]]
- [[SecureCoding]]
- [[VulnerabilityAssessment]]

## Key Takeaways

- Memory safety prevents memory-related vulnerabilities like buffer overflows, use-after-free, and double free that enable arbitrary code execution
- Critical for security-critical code, systems programming, and when using C/C++; less critical for managed languages like Python, Java, Go
- Tradeoff: manual memory control and performance versus risk of subtle vulnerabilities that corrupt data silently and manifest as security issues months later
- Main failure mode: buffer overflows allow attackers to overwrite return addresses and execute arbitrary code
- Best practice: prefer memory-safe languages (Rust, Go, Python) for new code; if using C/C++, use safe functions (strncpy, snprintf), compile with AddressSanitizer, run Valgrind regularly, and use checked arithmetic for size calculations
- Related: concurrency, cryptography basics, secure coding, vulnerability assessment
