---
title: Supply Chain Security
title_pt: Segurança da Cadeia de Suprimentos
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - SupplyChainSecurity
description: Securing the software supply chain from malicious components.
description_pt: Protegendo a cadeia de suprimentos de software contra componentes maliciosos.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Supply Chain Security

## Description

Supply chain security protects against:
- Malicious dependencies
- Compromised packages
- Typosquatting attacks
- Compromised build pipelines

## Purpose

**When supply chain security matters:**
- When using external dependencies
- For production software
- For compliance (SLSA, SBOM requirements)
- When attacked through dependencies has happened

**When it's less critical:**
- For simple, dependency-free projects
- For personal tools
- For fully sandboxed environments

**The key question:** Can a compromised dependency harm our users?

## Examples

```yaml
# Dependency scanning in CI
- name: Dependency Scan
  run: |
    pip-audit
    npm audit
    snyk test

# Pin dependencies
# requirements.txt
requests==2.31.0  # Exact version, not >=2.31.0
```

## Anti-Patterns

### 1. Blind Trust in Dependencies

**Bad:** Installing packages from public registries without verifying the source, checking for typosquatting, or reviewing the package's maintenance status
**Why it's bad:** Attackers publish malicious packages with names similar to popular ones (typosquatting) or compromise abandoned packages — your build silently pulls in malware
**Good:** Verify package signatures, use private registries with allowlists, and monitor dependency maintenance status

### 2. Unpinned Dependencies with Auto-Updates

**Bad:** Using `>=` or `^` version specifiers that automatically pull in new versions without review
**Why it's bad:** A compromised dependency version is automatically deployed to production — the attack happens through your normal CI/CD pipeline
**Good:** Pin exact versions (`==2.31.0`), review dependency updates before upgrading, and scan for vulnerabilities before accepting new versions

### 3. No SBOM (Software Bill of Materials)

**Bad:** Deploying applications without knowing exactly which dependencies and versions are included
**Why it's bad:** When a new CVE is announced (like Log4Shell), you cannot determine if you are affected — incident response takes days instead of hours
**Good:** Generate and maintain an SBOM for every release — use tools like Syft, CycloneDX, or SPDX to track every dependency

### 4. Development Dependencies in Production

**Bad:** Including dev dependencies (testing frameworks, linters, debug tools) in production builds
**Why it's bad:** Dev dependencies often have known vulnerabilities and are not maintained with production security in mind — they expand the attack surface unnecessarily
**Good:** Separate production and development dependencies — use `--production` flags during deployment and audit both dependency groups

## Best Practices

### 1. Pin Dependencies

```python
# Pin exact versions
requests==2.31.0
flask==3.0.0
```

### 2. Use Private Registries

```python
# Verify package sources
# Use PyPI Trusted Publishers
# Use GitHub Packages
```

### 3. Scan Dependencies

```yaml
# Regular security scans
- name: Snyk
  uses: snyk/actions/node@master
```

## Failure Modes

- **Unpinned dependencies with auto-updates** → malicious package version automatically pulled in → supply chain compromise → pin exact dependency versions and review updates before upgrading
- **No dependency vulnerability scanning** → known CVEs in dependencies go undetected → exploitable vulnerabilities in production → run automated dependency scanning in CI with fail-on-critical policy
- **Trusting packages without verification** → installing packages without checking integrity → typosquatting and malicious packages → verify package signatures and use private registries with allowlists
- **Build pipeline not secured** → CI/CD pipeline compromised to inject malicious code → all builds are compromised → secure CI/CD with least-privilege access, signed builds, and reproducible builds
- **No SBOM (Software Bill of Materials)** → cannot identify which dependencies are affected by new CVE → slow incident response → generate and maintain SBOM for every release
- **Abandoned dependencies with no replacement plan** → critical dependency no longer maintained → security patches unavailable → monitor dependency maintenance status and have migration plans for critical packages
- **Development dependencies in production** → dev dependencies with known vulnerabilities included in production → unnecessary attack surface → separate production and development dependencies and audit both

## Related Topics

- [[Security MOC]]
- [[CiCd]]
- [[Docker]]
- [[VulnerabilityAssessment]]
- [[SecurityAudit]]

## Key Takeaways

- Supply chain security protects against malicious dependencies, compromised packages, typosquatting attacks, and compromised build pipelines
- Matters when using external dependencies, for production software, compliance requirements (SLSA, SBOM), or when supply chain attacks have occurred
- Less critical for simple dependency-free projects, personal tools, or fully sandboxed environments
- Tradeoff: dependency verification and scanning overhead versus risk of silently pulling in compromised packages through normal CI/CD
- Main failure mode: unpinned dependencies with auto-updates automatically pull malicious package versions into production through the normal deployment pipeline
- Best practice: pin exact dependency versions, run automated dependency scanning in CI with fail-on-critical policy, verify package signatures, generate and maintain SBOM for every release, and secure CI/CD with least-privilege access and signed builds
- Related: CI/CD, Docker, vulnerability assessment, security audit
