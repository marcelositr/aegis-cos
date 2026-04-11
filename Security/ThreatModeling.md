---
title: Threat Modeling
title_pt: Modelagem de Ameaças
layer: security
type: practice
priority: medium
version: 1.0.0
tags:
  - Security
  - Threat Modeling
  - Risk
description: Structured approach to identifying and prioritizing security threats.
description_pt: Abordagem estruturada para identificar e priorizar ameaças de segurança.
prerequisites:
  - Security
estimated_read_time: 8 min
difficulty: intermediate
---

# Threat Modeling

## Description

Threat modeling is a structured approach to identifying, quantifying, and addressing security risks. It helps teams understand what could go wrong and prioritize security work accordingly.

## Purpose

**When threat modeling is valuable:**
- Early in development (design phase)
- For complex systems
- For compliance requirements
- When dealing with sensitive data

**When threat modeling may be skipped:**
- Simple, low-risk applications
- When time is extremely limited
- For prototypes

**The key question:** What can go wrong, and what's the likelihood and impact?

## Examples

### STRIDE Analysis

```python
threats = [
    {'type': 'Spoofing', 'mitigation': 'Require authentication'},
    {'type': 'Tampering', 'mitigation': 'Use TLS'},
    {'type': 'Repudiation', 'mitigation': 'Log all actions'},
    {'type': 'Information Disclosure', 'mitigation': 'Encrypt sensitive data'},
    {'type': 'Denial of Service', 'mitigation': 'Rate limiting'},
    {'type': 'Elevation of Privilege', 'mitigation': 'Role-based access'},
]
```

### Data Flow Diagram

```
User → [Web Server] → [API] → [Database]
                  ↓
            [External API]
```

## Anti-Patterns

### 1. Threat Modeling as a One-Time Exercise

**Bad:** Creating a threat model during initial design and never revisiting it
**Why it's bad:** Architecture changes introduce new trust boundaries, data flows, and attack surfaces that the original model does not cover
**Good:** Revisit the threat model with every significant architecture change, new feature, or third-party integration

### 2. Analysis Without Action

**Bad:** Identifying dozens of threats in a STRIDE analysis but never prioritizing or remediating them
**Why it's bad:** The threat model becomes a documentation exercise — the team feels productive but the system remains vulnerable
**Good:** Pair each identified threat with a specific mitigation, owner, and timeline — prioritize by likelihood and impact

### 3. Missing Third-Party Threats

**Bad:** Modeling only internal components while treating external services and dependencies as trusted
**Why it's bad:** Supply chain attacks, compromised APIs, and dependency vulnerabilities are among the most common attack vectors
**Good:** Include third-party services, dependencies, and integrations in the threat model — analyze their trust boundaries and failure modes

### 4. Over-Focusing on External Threats

**Bad:** Modeling only external attackers while ignoring insider threats, accidental exposure, and misconfigurations
**Why it's bad:** Many breaches originate from insiders — whether malicious or accidental — and these attack paths are completely unmodeled
**Good:** Model both external attackers and insider threat scenarios — include accidental data exposure, misconfigured permissions, and privileged access abuse

## Best Practices

1. **Model early in design** - Cheaper to fix issues early
2. **Involve diverse team** - Security, development, operations
3. **Focus on high-risk areas** - Authentication, data handling
4. **Document and review** - Keep models up to date
5. **Iterate as needed** - Update when architecture changes

## Failure Modes

- **Threat modeling done once and never updated** → architecture changes invalidate original model → new threats go unanalyzed → revisit threat model with every significant architecture change
- **Threat modeling too theoretical** → identifying threats without prioritizing or remediating → analysis paralysis with no action → prioritize threats by likelihood and impact, assign owners for remediation
- **Missing stakeholder perspectives** → only security team participates in modeling → blind spots from lack of domain knowledge → include developers, operations, and business stakeholders in threat modeling
- **Over-focusing on external threats** → ignoring insider threats and accidental exposure → internal vulnerabilities unaddressed → model both external attackers and insider threat scenarios
- **STRIDE analysis without mitigation plans** → threats identified but no action plan → threat model becomes documentation exercise → pair each identified threat with specific mitigation and timeline
- **Threat model scope too broad or narrow** → analyzing entire system at once or only one component → missed threats or wasted effort → scope threat model to specific trust boundaries and data flows
- **No threat model for third-party integrations** → trusting external services without analysis → supply chain attacks through dependencies → include third-party services and dependencies in threat model

## Related Topics

- [[Security MOC]]
- [[SecurityAudit]]
- [[OWASPTop10]]
- [[SecureCoding]]
- [[DistributedSystems]]

## Key Takeaways

- Threat modeling is a structured approach to identifying, quantifying, and addressing security risks by analyzing what could go wrong and prioritizing mitigations
- Valuable early in development, for complex systems, compliance requirements, and when handling sensitive data
- Can be skipped for simple low-risk applications, extremely time-limited situations, or prototypes
- Tradeoff: proactive risk identification and prioritized security work versus upfront time investment and need for security expertise
- Main failure mode: threat modeling done once during initial design and never revisited leaves new trust boundaries and attack surfaces unanalyzed
- Best practice: revisit threat model with every significant architecture change, pair each identified threat with specific mitigation and owner, prioritize by likelihood and impact, and include third-party services and insider threats in scope
- Related: security audit, OWASP Top 10, secure coding, architecture