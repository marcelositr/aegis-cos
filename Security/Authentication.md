---
title: Authentication
title_pt: Autenticação
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - Authentication
description: Verifying the identity of users, systems, or entities.
description_pt: Verificando a identidade de usuários, sistemas ou entidades.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Authentication

## Description

Authentication verifies identity of users/systems. Methods include:
- **Password-based**: Username/password
- **Multi-factor**: Something you know/have/are
- **Token-based**: JWT, OAuth, session tokens
- **Biometric**: Fingerprint, face

## Purpose

**When authentication is required:**
- Any system with user accounts
- APIs that need to identify callers
- Systems with sensitive data
- Compliance requirements (PCI, HIPAA)

**When authentication may be simplified:**
- Public read-only content
- Internal tools with limited exposure
- Public APIs with rate limiting only

**The key question:** Who is requesting access, and can we verify their identity?

## Examples

```python
# Password hashing - NEVER store plain text
import bcrypt

def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt())

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed)

# JWT tokens
import jwt

def create_token(user_id):
    return jwt.encode(
        {'user_id': user_id},
        SECRET_KEY,
        algorithm='HS256'
    )

def verify_token(token):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
    except jwt.ExpiredSignatureError:
        return None
```

## Failure Modes

- **Plain text password storage** → database breach → all accounts compromised → always hash with bcrypt or argon2
- **Weak hashing algorithm** → rainbow table attacks → password recovery → never use MD5 or SHA1 for passwords
- **No rate limiting on login** → brute force attacks → account takeover → implement progressive delays and account lockout
- **Missing MFA** → single factor breach → unauthorized access → require multi-factor for sensitive operations
- **Session fixation** → attacker hijacks session → account takeover → regenerate session ID after authentication
- **Password reset token leakage** → reset tokens in URLs → account takeover → use expiring single-use tokens sent via secure channels
- **No credential rotation policy** → stale credentials → undetected compromise → enforce periodic password changes for privileged accounts

## Anti-Patterns

### 1. Plain Text or Weak Password Storage

**Bad:** Storing passwords in plain text, or using fast hash functions like MD5 or SHA-1
**Why it's bad:** A database breach exposes all passwords immediately — fast hashes can be brute-forced at billions per second on commodity hardware
**Good:** Always use password-specific hashing (bcrypt, argon2, scrypt) — these are intentionally slow and memory-hard to resist brute force

### 2. No Rate Limiting on Login

**Bad:** Allowing unlimited login attempts without delays, lockouts, or CAPTCHAs
**Why it's bad:** Attackers can brute force passwords at high speed — even strong passwords are vulnerable to automated dictionary attacks
**Good:** Implement progressive delays, account lockout after repeated failures, and CAPTCHAs for suspicious login patterns

### 3. Session Fixation

**Bad:** Not regenerating the session ID after successful authentication
**Why it's bad:** An attacker can set a known session ID before the victim logs in, then use that same session ID after authentication to hijack the account
**Good:** Always regenerate session IDs after authentication — invalidate the old session and create a new one with a fresh identifier

### 4. Password Reset Token Leakage

**Bad:** Sending password reset tokens in URLs that are logged by browsers, proxies, and email servers
**Why it's bad:** Reset tokens in URLs appear in browser history, server logs, and referer headers — an attacker can recover the token and take over the account
**Good:** Use expiring single-use tokens sent via secure channels — tokens should be in the email body (not URL), expire quickly, and be invalidated after use

## Best Practices

### 1. Use Strong Hashing

```python
# Use bcrypt/argon2, not MD5/SHA1
import argon2

hashing = argon2.PasswordHasher()
```

### 2. Implement MFA

```python
# Multi-factor authentication
# Something you know (password)
# Something you have (phone)
# Something you are (biometric)
```

### 3. Handle Sessions Securely

```python
# Secure session management
session_config = {
    'cookie_secure': True,
    'cookie_httponly': True,
    'cookie_samesite': 'Lax',
}
```

## Related Topics

- [[Authorization]]
- [[JWTTokens]]
- [[OAuth2]]
- [[OpenIDConnect]]
- [[HTTPS]]
- [[TlsSsl]]
- [[SecurityHeaders]]
- [[InputValidation]]

## Key Takeaways

- Authentication verifies the identity of users, systems, or entities through passwords, multi-factor authentication, tokens, or biometrics
- Required for any system with user accounts, APIs needing caller identification, systems with sensitive data, or compliance requirements
- Simplified for public read-only content, internal tools with limited exposure, or public APIs with rate limiting only
- Tradeoff: strong identity verification versus user friction from MFA and password complexity requirements
- Main failure mode: storing passwords in plain text or using weak hashing (MD5, SHA1) means a database breach immediately compromises all accounts
- Best practice: always hash passwords with bcrypt or argon2, implement MFA for sensitive operations, rate limit login attempts with progressive delays, regenerate session IDs after authentication, use expiring single-use tokens for password resets, and secure sessions with HttpOnly/Secure/SameSite cookies
- Related: authorization, JWT tokens, OAuth2, OpenID Connect, HTTPS, TLS/SSL, security headers, input validation
