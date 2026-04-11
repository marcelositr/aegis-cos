---
title: Penetration Testing
title_pt: Teste de Penetração
layer: security
type: practice
priority: high
version: 1.0.0
tags:
  - Security
  - Penetration
  - Testing
description: Simulated cyber attacks to evaluate security.
description_pt: Ataques cibernéticos simulados para avaliar segurança.
prerequisites: []
estimated_read_time: 15 min
difficulty: advanced
---

# Penetration Testing

## Description

Penetration testing (pen testing) simulates real attacks to identify vulnerabilities before malicious actors do. It goes beyond automated scanning by using human creativity and logic.

## Purpose

**When penetration testing is required:**
- Before releasing to production
- For compliance (PCI-DSS, HIPAA)
- After significant changes
- For high-value targets

**When simpler security testing suffices:**
- For low-risk internal tools
- When automated scans cover needs
- In early development stages

**The key question:** Could a real attacker find vulnerabilities that automated tools miss?

## Types
- **Black Box** - No prior knowledge
- **White Box** - Full access to code
- **Gray Box** - Limited knowledge

Phases:
1. Reconnaissance
2. Scanning
3. Enumeration
4. Exploitation
5. Reporting

## Examples

```python
# Common vulnerability checks
def check_sql_injection(url):
    payloads = ["'", "' OR '1'='1", "; DROP TABLE"]
    for payload in payloads:
        response = requests.get(f"{url}?id={payload}")
        if "error" in response.text.lower():
            return "Vulnerable to SQLi"

def check_xss(url):
    payloads = ["<script>alert(1)</script>", "<img src=x>"]
    for payload in payloads:
        response = requests.get(f"{url}?q={payload}")
        if payload in response.text:
            return "Vulnerable to XSS"

def check_weak_cipher():
    # Test SSL/TLS configuration
    results = ssl_analysis(host)
    if 'TLS 1.0' in results or 'TLS 1.1' in results:
        return "Weak TLS versions"
```

## Tools

- Nmap - Port scanning
- Burp Suite - Web testing
- Metasploit - Exploitation
- OWASP ZAP - App scanning
- Nikto - Web server scanning

## Failure Modes

- **Undefined scope** → unauthorized testing on out-of-scope systems → legal liability → document exact scope with written authorization
- **No written authorization** → pen test classified as attack → legal consequences → obtain signed authorization before any testing
- **Insufficient documentation** → findings unreproducible → unactionable results → document every step, payload, and result
- **No retesting after fixes** → assumed remediation → vulnerability persists → verify all fixes with follow-up testing
- **Testing production without safeguards** → service disruption → user impact → coordinate testing windows and use non-destructive techniques
- **Tool-only testing** → creative attack vectors missed → false sense of security → combine automated tools with manual exploitation
- **Missing threat modeling** → wrong attack paths tested → blind spots → model threats before testing to focus on realistic attack vectors

## Related Topics

- [[Security MOC]]
- [[VulnerabilityAssessment]]
- [[SecurityAudit]]
- [[Fuzzing]]
- [[SecureCoding]]

## Anti-Patterns

### 1. Tool-Only Testing

**Bad:** Running automated scanners (Nessus, OWASP ZAP) and calling it a penetration test
**Why it's bad:** Automated tools find known patterns but miss logic flaws, business logic abuse, and creative attack chains that a human tester would discover
**Good:** Combine automated tools with manual exploitation — the value of pen testing is human creativity, not tool output

### 2. No Retesting After Fixes

**Bad:** Running a penetration test, receiving the report, fixing some findings, and never verifying the fixes
**Why it's bad:** Fixes are often incomplete or introduce new vulnerabilities — you assume the issue is resolved without evidence
**Good:** Require follow-up testing for every finding — verify that the fix actually resolves the vulnerability and does not introduce new ones

### 3. Testing Production Without Safeguards

**Bad:** Running exploitation attempts against production systems during business hours without coordination
**Why it's bad:** Exploitation can cause service disruption, data corruption, or trigger incident response — real users are impacted by the test
**Good:** Coordinate testing windows, use non-destructive techniques, and have rollback plans — consider testing in staging environments that mirror production

### 4. Missing Threat Modeling Before Testing

**Bad:** Starting a penetration test without understanding the system's architecture, trust boundaries, or most valuable assets
**Why it's bad:** Testers waste time on low-value attack paths while critical vulnerabilities in high-value areas go untested
**Good:** Model threats before testing — provide testers with architecture diagrams, data flow diagrams, and business context to focus on realistic attack vectors

## Best Practices

1. **Define scope clearly** - What systems are in/out of scope
2. **Get written authorization** - Legal requirement
3. **Document everything** - For reporting and legal protection
4. **Prioritize findings** - Risk-based remediation
5. **Retest after fixes** - Verify vulnerabilities are resolved

## Key Takeaways

- Penetration testing simulates real attacks using human creativity and logic to find vulnerabilities that automated scanners miss
- Required before production releases, for compliance (PCI-DSS, HIPAA), after significant changes, or for high-value targets
- Simpler security testing suffices for low-risk internal tools, when automated scans cover needs, or in early development
- Tradeoff: discovering creative attack chains and logic flaws versus cost of skilled testers and potential service disruption
- Main failure mode: relying only on automated tools misses business logic vulnerabilities and creative attack chains, creating false sense of security
- Best practice: combine automated tools with manual exploitation, define scope clearly with written authorization, document every step, model threats before testing, and always retest after fixes to verify remediation
- Related: vulnerability assessment, security audit, fuzzing, secure coding