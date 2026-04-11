---
title: Cryptography
aliases:
  - Cryptography
  - Encryption
  - Crypto
  - DataEncryption
layer: security
type: concept
priority: critical
version: 1.0.0
tags:
  - Security
  - Cryptography
  - Encryption
  - DataProtection
description: The practice and study of techniques for secure communication, including encryption algorithms, key management, and cryptographic protocols.
prerequisites:
  - "[[SecurityArchitecture]]"
  - "[[SecureCoding]]"
estimated_read_time: 8 min
difficulty: advanced
---

# Cryptography

## Description

The practice and study of techniques for secure communication in the presence of adversaries. Encompasses encryption (symmetric and asymmetric), hashing, digital signatures, and key management.

## Purpose

**When to use:**
- Protecting data at rest (database encryption, file encryption)
- Protecting data in transit (TLS, encrypted channels)
- Ensuring data integrity (hashing, digital signatures)
- Authentication and non-repudiation (digital certificates)

**When to avoid:**
- When access controls alone provide adequate protection
- When encryption creates a false sense of security without proper key management
- When performance requirements cannot tolerate cryptographic overhead

## Rules

1. **Never roll your own crypto** — use well-vetted libraries (libsodium, Bouncy Castle, OpenSSL)
2. **Use modern algorithms** — AES-256-GCM, ChaCha20-Poly1305, Ed25519, Argon2
3. **Manage keys separately from data** — use KMS, HSM, or secrets management tools
4. **Encrypt at rest AND in transit** — defense in depth, not either/or
5. **Rotate keys on a schedule** — limit blast radius of key compromise

## Examples

### Good Example — Authenticated Encryption (AES-GCM)

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

class EncryptionService:
    def __init__(self):
        # Generate a fresh 256-bit key
        self.key = AESGCM.generate_key(bit_length=256)
        self.aesgcm = AESGCM(self.key)

    def encrypt(self, plaintext: bytes, associated_data: bytes = None) -> tuple:
        nonce = os.urandom(12)  # 96-bit nonce for GCM
        ct = self.aesgcm.encrypt(nonce, plaintext, associated_data)
        return (nonce, ct)

    def decrypt(self, nonce: bytes, ciphertext: bytes, associated_data: bytes = None) -> bytes:
        return self.aesgcm.decrypt(nonce, ciphertext, associated_data)
```

### Bad Example — ECB Mode (Pattern Preservation)

```python
from Crypto.Cipher import AES

# ECB mode preserves patterns — identical blocks produce identical ciphertext
cipher = AES.new(key, AES.MODE_ECB)
ciphertext = cipher.encrypt(plaintext)
```

**Why it's bad:** ECB mode does not hide data patterns — identical plaintext blocks produce identical ciphertext blocks. This leaked the famous "ECB penguin" image. Always use authenticated encryption modes (GCM, ChaCha20-Poly1305).

## Anti-Patterns

### Rolling Your Own Crypto

Creating custom encryption algorithms, hash functions, or random number generators.

**Why it's bad:** Cryptographic algorithms require years of peer review and cryptanalysis. Custom algorithms have unknown weaknesses and are almost certainly breakable by skilled attackers.

### Key Hardcoding

Embedding encryption keys in source code or configuration files.

**Why it's bad:** Keys in code are visible to anyone with repository access and are often committed to version control. Use KMS, environment variables, or hardware security modules.

### Insufficient Randomness

Using `random()` or `Math.random()` instead of cryptographically secure RNGs.

**Why it's bad:** Predictable randomness means predictable keys, nonces, and salts. Always use `os.urandom()`, `secrets` module, or `/dev/urandom`.

## Failure Modes

- **Custom crypto** → broken security when homemade algorithms used → use well-vetted libraries, avoid rolling your own
- **Key reuse** → compromised data when same key used for multiple purposes → use unique keys per context, implement key derivation (HKDF)
- **Insufficient randomness** → predictable keys when weak RNG used → use cryptographically secure RNG (`os.urandom`, `secrets`), seed from entropy sources
- **Mode misuse** → insecure implementations when wrong mode selected → use GCM for authenticated encryption, avoid ECB, CTR without authentication
- **Weak algorithms** → compromised data when deprecated ciphers used → use AES-256-GCM, ChaCha20-Poly1305, disable DES, RC4, MD5, SHA1
- **Key management failures** → data loss when keys lost or compromised → implement key rotation, separate key storage (KMS/HSM), backup key material securely
- **Nonce reuse** → complete encryption breakdown when nonce reused with same key → generate unique nonces per encryption operation, use counter-based nonces
- **Side-channel attacks** → key extraction via timing, power analysis → use constant-time implementations, hardware security modules for high-value keys
- **Incomplete encryption** → data exposure when some fields not encrypted → identify all sensitive data fields, encrypt consistently, use field-level encryption for databases

## Encryption Algorithms Reference

| Algorithm | Type | Use Case | Status |
|-----------|------|----------|--------|
| AES-256-GCM | Symmetric | Data at rest, general purpose | ✅ Recommended |
| ChaCha20-Poly1305 | Symmetric | Mobile/low-power, no AES-NI | ✅ Recommended |
| Ed25519 | Asymmetric | Digital signatures | ✅ Recommended |
| RSA-4096 | Asymmetric | Key exchange, signatures | ⚠️ Use Ed25519 when possible |
| Argon2id | Hash | Password hashing | ✅ Recommended |
| bcrypt | Hash | Password hashing | ✅ Recommended |
| DES/3DES | Symmetric | Legacy systems | ❌ Deprecated |
| MD5/SHA1 | Hash | Legacy systems | ❌ Broken |
| RC4 | Symmetric | Legacy systems | ❌ Broken |

## Best Practices

- Use **authenticated encryption** (AES-GCM, ChaCha20-Poly1305) — provides confidentiality + integrity
- Implement **key rotation** on a schedule (90 days for symmetric, immediately on compromise)
- Store keys in **dedicated KMS** (AWS KMS, HashiCorp Vault, GCP KMS) — never in code
- Use **envelope encryption** — encrypt data keys with master keys, rotate master keys independently
- Hash passwords with **Argon2id or bcrypt** — never store plaintext passwords
- **Validate cryptographic configurations** with automated tools (SSL Labs, test vectors)
- Document **cryptographic choices** in architecture decision records
- Plan for **cryptographic agility** — design systems to swap algorithms when current ones are broken

## Related Topics

- [[TLS]]
- [[SecretsManagement]]
- [[SecurityHeaders]]
- [[JWT]]
- [[ZeroTrust]]
- [[SecureCoding]]
- [[Hashing]]

## Key Takeaways

- Cryptography protects confidentiality, integrity, and authenticity of data
- Use AES-256-GCM or ChaCha20-Poly1305 for symmetric encryption
- Never roll your own crypto — use battle-tested libraries
- Key management is harder than algorithm selection — invest in KMS/HSM
- Primary failure mode: weak algorithms or poor key management
- Encrypt both at rest and in transit — defense in depth
- Rotate keys on schedule and immediately on suspected compromise
