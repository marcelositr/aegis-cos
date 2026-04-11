---
title: Secure Coding
title_pt: Codificação Segura
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - SecureCoding
description: Writing code that is resistant to security vulnerabilities.
description_pt: Escrever código resistente a vulnerabilidades de segurança.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Secure Coding

## Description

Secure coding is writing code that is resistant to security vulnerabilities. It involves:
- Input validation
- Authentication/authorization
- Data protection
- Error handling

## Purpose

**When secure coding is essential:**
- For handling sensitive data
- For public-facing applications
- For compliance (PCI, HIPAA)
- When attacks are likely

**When basic coding suffices:**
- For internal tools
- For non-sensitive data
- For prototyping

**The key question:** Could vulnerabilities in this code harm users or data?

## Examples

### SQL Injection Prevention

```python
# BAD - vulnerable
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query)

# GOOD - parameterized
def get_user(user_id):
    query = "SELECT * FROM users WHERE id = %s"
    return db.execute(query, [user_id])
```

### XSS Prevention

```python
# Use template engines with auto-escaping
from markupsafe import escape

def render_comment(comment):
    return f"<p>{escape(comment)}</p>"
```

## Best Practices

```python
# Bad
def display_comment(comment):
    return f"<div>{comment}</div>"

# Good - escape output
import html

def display_comment(comment):
    return f"<div>{html.escape(comment)}</div>"
```

## Failure Modes

- **SQL injection via string concatenation** → database compromise → data theft or destruction → use parameterized queries exclusively
- **XSS via unescaped output** → script injection → session hijacking → escape all user-generated content before rendering
- **Path traversal** → file system access → sensitive file disclosure → sanitize file paths and use allow-listed directories
- **Missing error handling** → stack traces exposed → information leakage → return generic error messages, log details server-side
- **Insecure deserialization** → remote code execution → server takeover → validate and sanitize serialized data before deserialization
- **Race conditions** → concurrent access corrupts state → data integrity loss → use proper locking and atomic operations
- **Command injection** → OS command execution → full server compromise → never pass user input to system commands

## Anti-Patterns

### 1. Rolling Your Own Crypto

**Bad:** Implementing custom encryption algorithms, hashing schemes, or authentication protocols
**Why it's bad:** Cryptographic implementations have subtle requirements that are easy to get wrong — even small mistakes render the entire security model useless
**Good:** Use battle-tested libraries (cryptography, bcrypt, argon2) — never implement crypto primitives yourself

### 2. Security as an Afterthought

**Bad:** Writing all the code first and then "adding security" before release
**Why it's bad:** Security is not a layer you add — it is a property of the architecture. Retrofitting security requires rewriting core components
**Good:** Design security into the system from the start — threat model before coding, validate inputs at every boundary, and enforce least privilege

### 3. Trusting Client-Side Validation

**Bad:** Relying on JavaScript form validation or mobile app input checks as the sole security measure
**Why it's bad:** Client-side controls are trivially bypassed — an attacker sends requests directly to the API, bypassing all client validation
**Good:** Always validate and sanitize input on the server — client validation is for user experience, not security

### 4. Exposing Stack Traces in Production

**Bad:** Returning detailed error messages and stack traces to users when something goes wrong
**Why it's bad:** Stack traces reveal internal implementation details, file paths, database schemas, and library versions — information that helps attackers craft targeted exploits
**Good:** Return generic error messages to users, log detailed errors server-side with full context for debugging

## Best Practices

### 1. Validate Input

```python
def create_user(data):
    # Validate all inputs
    if not data.get('email') or '@' not in data['email']:
        raise ValueError("Invalid email")
    if len(data.get('password', '')) < 8:
        raise ValueError("Password too short")
```

### 2. Use Security Libraries

```python
# Don't roll your own crypto
from cryptography.fernet import Fernet

# Use established libraries
```

### 3. Principle of Least Privilege

```python
# Use minimal permissions needed
# Database user: only needed permissions
# API keys: minimal scope
```

## Related Topics

- [[Security MOC]]
- [[InputValidation]]
- [[ThreatModeling]]
- [[CodeQualityHandbook]]
- [[PenetrationTesting]]

## Key Takeaways

- Secure coding writes code resistant to security vulnerabilities through input validation, proper authentication/authorization, data protection, and safe error handling
- Essential for handling sensitive data, public-facing applications, compliance requirements (PCI, HIPAA), and when attacks are likely
- Basic coding may suffice for internal tools, non-sensitive data, or prototyping
- Tradeoff: security-hardened code versus development speed and complexity of security implementations
- Main failure mode: treating security as an afterthought and trying to "add it" before release requires rewriting core components since security is an architectural property not a layer
- Best practice: design security into the system from the start, validate inputs at every boundary, use parameterized queries, escape all output, enforce least privilege, and never roll your own cryptography
- Related: input validation, threat modeling, code quality, penetration testing
