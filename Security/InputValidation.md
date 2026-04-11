---
title: Input Validation
title_pt: Validação de Entrada
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - InputValidation
description: Ensuring all input data meets expected criteria before processing.
description_pt: Garantindo que todos os dados de entrada atendam aos critérios esperados antes do processamento.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Input Validation

## Description

Input validation ensures data received meets expected criteria. It's the first line of defense:
- Reject invalid data early
- Fail fast on bad input
- Prevent injection attacks
- Protect against malformed data

## Purpose

**When input validation is critical:**
- For all user input
- For API parameters
- For file uploads
- When security is a concern

**When simplified validation may work:**
- For internal trusted input
- For ephemeral data
- When other controls exist

**The key question:** Can we trust this input to be what we expect?

## Examples

### Using Pydantic

```python
from pydantic import BaseModel, EmailStr, validator

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    age: int
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError('Password too short')
        return v

# Auto-validates on creation
user = UserCreate(email="test@example.com", password="password123", age=25)
```

### Custom Validation

```python
def validate_order(order_data):
    if not order_data.get('items'):
        raise ValueError("Order must have items")
    if len(order_data['items']) > 100:
        raise ValueError("Maximum 100 items")
```

## Failure Modes

- **No input validation** → malicious payloads reach business logic → injection attacks → validate all inputs at API boundaries
- **Blacklist instead of whitelist** → bypass via unknown variants → security bypass → use allow-lists for known-good values
- **Missing output encoding** → stored XSS → session hijacking → encode output based on context (HTML, JS, URL)
- **Validation only on client** → server accepts malformed data → data corruption → always validate on server regardless of client checks
- **Trusting headers** → spoofed headers → authentication bypass → never trust client-supplied headers for security decisions
- **Inconsistent validation** → different layers allow different inputs → edge case exploitation → use shared validation schemas
- **File upload without validation** → malicious file execution → server compromise → validate file type, size, and content

## Anti-Patterns

### 1. Blacklist Validation

**Bad:** Trying to block known-bad inputs (e.g., blocking `<script>`, `'`, `;`) instead of allowing only known-good inputs
**Why it's bad:** Attackers find bypasses — URL encoding, double encoding, alternate syntax — and the blacklist is always incomplete
**Good:** Use allow-lists — define exactly what valid input looks like and reject everything else

### 2. Client-Side Only Validation

**Bad:** Validating input only in JavaScript on the frontend without server-side checks
**Why it's bad:** An attacker bypasses the frontend entirely and sends malicious payloads directly to the API — the server accepts them without question
**Good:** Always validate on the server — client validation improves user experience but provides zero security

### 3. Inconsistent Validation Across Layers

**Bad:** The API layer validates with one set of rules, the service layer with another, and the database with yet another
**Why it's bad:** Attackers find the gaps between validation layers — an input rejected by the API may be accepted by a direct service call
**Good:** Use shared validation schemas (Pydantic, JSON Schema) across all layers — one source of truth for what valid input looks like

### 4. Validating Without Sanitizing Output

**Bad:** Validating input on entry but rendering it without context-aware encoding
**Why it's bad:** Stored XSS — malicious input passes validation (it is technically valid data) but becomes executable when rendered in HTML, JavaScript, or URL contexts
**Good:** Encode output based on context — HTML-encode for HTML body, attribute-encode for HTML attributes, JavaScript-encode for inline scripts

## Best Practices

### 1. Validate at Boundaries

```python
# Validate at API entry point
@app.post("/orders")
def create_order(order: OrderCreate):
    # Already validated by Pydantic
    return OrderService.create(order)
```

### 2. Whitelist Over Blacklist

```python
# Whitelist - allow known good values
ALLOWED_STATUSES = ['pending', 'confirmed', 'shipped']

def set_status(status):
    if status not in ALLOWED_STATUSES:
        raise ValueError(f"Invalid status: {status}")
```

## Related Topics

- [[XSS]]
- [[SQLInjection]]
- [[CSRF]]
- [[Authentication]]
- [[FailFast]]
- [[SecurityHeaders]]
- [[APIDesign]]
- [[REST]]

## Key Takeaways

- Input validation ensures all received data meets expected criteria before processing, serving as the first line of defense against injection attacks and malformed data
- Critical for all user input, API parameters, file uploads, and any security-sensitive context
- Simplified validation may work for internal trusted input, ephemeral data, or when other controls exist
- Tradeoff: early rejection of malicious input versus validation overhead and risk of rejecting legitimate edge cases
- Main failure mode: no input validation allows malicious payloads to reach business logic, enabling injection attacks and data corruption
- Best practice: validate at API boundaries using shared schemas (Pydantic, JSON Schema), use allow-lists over block-lists, always validate on server regardless of client checks, and encode output based on rendering context
- Related: XSS, SQL injection, CSRF, authentication, fail fast, security headers, API design
