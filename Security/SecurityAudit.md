---
title: Security Audit
title_pt: Auditoria de Segurança
layer: security
type: practice
priority: high
version: 1.0.0
tags:
  - Security
  - Audit
  - Compliance
  - Review
description: Comprehensive security review and assessment process.
description_pt: Processo abrangente de revisão e avaliação de segurança.
prerequisites:
  - Security
estimated_read_time: 12 min
difficulty: advanced
---

# Security Audit

## Description

A security audit is a systematic, formal evaluation of an organization's security posture. It examines the effectiveness of security controls, compliance with policies and regulations, and identifies gaps in the security architecture. Unlike vulnerability assessments or penetration tests, security audits are comprehensive reviews that cover people, processes, and technology.

Security audits typically evaluate:
- **Technical controls** - Firewalls, encryption, access controls
- **Administrative controls** - Policies, procedures, training
- **Physical controls** - Access to facilities, hardware security
- **Compliance** - Regulatory requirements, standards adherence

Audits can be internal (conducted by internal teams) or external (conducted by third parties). External audits provide independent validation and are often required for compliance.

## Purpose

**When security audits are required:**
- Annual compliance requirements
- After security incidents
- Major infrastructure changes
- Third-party vendor assessments
- Board/management reporting

**Audit vs Assessment vs Test:**
- Audit: Formal evaluation against criteria/standards
- Assessment: Evaluation of security posture
- Test: Technical validation through scanning/exploitation

## Rules

1. **Define scope clearly** - What systems are included
2. **Use recognized frameworks** - ISO 27001, NIST, CIS
3. **Document all findings** - Evidence-based reporting
4. **Provide actionable recommendations** - Not just problems
5. **Follow up on remediation** - Track progress

## Examples

### Audit Checklist (ISO 27001 based)

```markdown
# Security Audit Checklist

## Access Control (A.9)

- [ ] User registration and de-registration process exists
- [ ] Access rights are reviewed regularly
- [ ] Password policy enforced (min length, complexity, expiration)
- [ ] Multi-factor authentication for privileged accounts
- [ ] Remote access requires encryption
- [ ] Inactive accounts disabled after 90 days

## Cryptography (A.10)

- [ ] Sensitive data encrypted at rest
- [ ] TLS 1.2+ for data in transit
- [ ] Encryption keys managed securely
- [ ] Certificates valid and not expired

## Physical Security (A.11)

- [ ] Badge/visitor controls at entrances
- [ ] Server room access restricted
- [ ] Video surveillance in place
- [ ] Equipment disposal procedures

## Operations Security (A.12)

- [ ] Change management process documented
- [ ] Backup procedures tested
- [ ] Antivirus/EDR deployed
- [ ] Logging enabled for critical systems
- [ ] Vulnerability scanning performed regularly

## Communications Security (A.13)

- [ ] Network segmentation in place
- [ ] Firewalls configured correctly
- [ ] DMZ for public-facing services
- [ ] VPN for remote access
```

### Technical Audit Script

```python
import subprocess
import json
from dataclasses import dataclass
from typing import List

@dataclass
class AuditFinding:
    control_id: str
    description: str
    status: str  # PASS, FAIL, NOT_APPLICABLE, NEEDS_REVIEW
    evidence: str
    recommendation: str

class SecurityAuditor:
    def __init__(self):
        self.findings: List[AuditFinding] = []
    
    def check_password_policy(self) -> AuditFinding:
        """Verify password policy configuration"""
        try:
            # Check PAM configuration
            result = subprocess.run(
                ['grep', '-E', '^password.*pam_pwquality.so', '/etc/pam.d/common-password'],
                capture_output=True, text=True
            )
            
            if 'minlen=12' in result.stdout and 'dcredit=-1' in result.stdout:
                return AuditFinding(
                    control_id='AC-1',
                    description='Password complexity policy',
                    status='PASS',
                    evidence=result.stdout,
                    recommendation=None
                )
            else:
                return AuditFinding(
                    control_id='AC-1',
                    description='Password complexity policy',
                    status='FAIL',
                    evidence='Password policy does not meet requirements',
                    recommendation='Configure minimum 12 characters with complexity requirements'
                )
        except Exception as e:
            return AuditFinding(
                control_id='AC-1',
                description='Password complexity policy',
                status='NEEDS_REVIEW',
                evidence=str(e),
                recommendation='Manual verification required'
            )
    
    def check_ssl_configuration(self, host: str, port: int = 443) -> AuditFinding:
        """Check SSL/TLS configuration"""
        import ssl
        import socket
        
        try:
            context = ssl.create_default_context()
            with socket.create_connection((host, port), timeout=5) as sock:
                with context.wrap_socket(sock, server_hostname=host) as ssock:
                    version = ssock.version()
                    
                    if version in ['TLSv1.2', 'TLSv1.3']:
                        return AuditFinding(
                            control_id='CR-1',
                            description='TLS version',
                            status='PASS',
                            evidence=f'Using {version}',
                            recommendation=None
                        )
                    else:
                        return AuditFinding(
                            control_id='CR-1',
                            description='TLS version',
                            status='FAIL',
                            evidence=f'Using outdated {version}',
                            recommendation='Upgrade to TLS 1.2 or higher'
                        )
        except Exception as e:
            return AuditFinding(
                control_id='CR-1',
                description='TLS configuration',
                status='NEEDS_REVIEW',
                evidence=str(e),
                recommendation='Manual SSL inspection required'
            )
    
    def check_open_ports(self) -> AuditFinding:
        """Check for unnecessary open ports"""
        try:
            result = subprocess.run(
                ['ss', '-tuln'],
                capture_output=True, text=True
            )
            
            # List of acceptable ports
            acceptable = {22, 80, 443, 3306, 5432}
            lines = result.stdout.strip().split('\n')[1:]
            
            issues = []
            for line in lines:
                parts = line.split()
                if len(parts) >= 5:
                    port = parts[4].split(':')[-1]
                    try:
                        port_num = int(port)
                        if port_num not in acceptable:
                            issues.append(port_num)
                    except ValueError:
                        pass
            
            if issues:
                return AuditFinding(
                    control_id='OP-1',
                    description='Open ports review',
                    status='FAIL',
                    evidence=f'Unnecessary ports open: {issues}',
                    recommendation='Close unnecessary ports or document justification'
                )
            else:
                return AuditFinding(
                    control_id='OP-1',
                    description='Open ports review',
                    status='PASS',
                    evidence='Only acceptable ports open',
                    recommendation=None
                )
        except Exception as e:
            return AuditFinding(
                control_id='OP-1',
                description='Open ports review',
                status='NEEDS_REVIEW',
                evidence=str(e),
                recommendation='Manual port review required'
            )
    
    def check_logging(self) -> AuditFinding:
        """Check if logging is enabled"""
        import os
        
        log_configs = [
            '/etc/rsyslog.conf',
            '/etc/syslog-ng/syslog-ng.conf'
        ]
        
        has_logging = any(os.path.exists(f) for f in log_configs)
        
        return AuditFinding(
            control_id='AU-1',
            description='System logging',
            status='PASS' if has_logging else 'FAIL',
            evidence=f'Logging config exists: {has_logging}',
            recommendation='Enable comprehensive logging' if not has_logging else None
        )
    
    def run_audit(self) -> List[AuditFinding]:
        """Run complete security audit"""
        print("Running security audit...")
        
        self.findings.append(self.check_password_policy())
        self.findings.append(self.check_ssl_configuration('example.com'))
        self.findings.append(self.check_open_ports())
        self.findings.append(self.check_logging())
        
        return self.findings

# Usage
auditor = SecurityAuditor()
results = auditor.run_audit()

print("\nAudit Results:")
print("-" * 80)
for finding in results:
    status_symbol = '✓' if finding.status == 'PASS' else '✗'
    print(f"{status_symbol} [{finding.control_id}] {finding.description}")
    print(f"   Status: {finding.status}")
    print(f"   Evidence: {finding.evidence}")
    if finding.recommendation:
        print(f"   Recommendation: {finding.recommendation}")
    print()
```

### Audit Report Template

```markdown
# Security Audit Report

**Organization:** Example Corp  
**Audit Date:** January 15-20, 2024  
**Auditor:** External Security Team  
**Scope:** Production infrastructure, Web applications

---

## 1. Executive Summary

The security audit identified 3 critical findings, 8 high-risk findings, and 15 medium-risk findings. Overall security posture requires immediate attention in access controls and network segmentation.

**Key Metrics:**
| Category | Count |
|----------|-------|
| Critical | 3 |
| High | 8 |
| Medium | 15 |
| Low | 22 |

---

## 2. Critical Findings

### Finding 1: Insufficient Access Controls

**Control:** AC-3  
**Risk:** Unauthorized access to sensitive data

**Observation:**  
User accounts not being disabled upon termination. Sample of 50 terminated employees showed 12 (24%) retained system access.

**Impact:**  
Former employees could access corporate systems and data.

**Recommendation:**  
Implement automated account de-provisioning tied to HR system.

**Timeline:** Immediate (30 days)

---

### Finding 2: Unpatched Systems

**Control:** OP-3  
**Risk:** Known exploits, data breach

**Observation:**  
45 production servers missing critical security patches (CVSS > 9.0).

**Recommendation:**  
Implement automated patching with 72-hour SLA for critical patches.

**Timeline:** 60 days

---

## 3. Compliance Status

| Standard | Status | Notes |
|----------|--------|-------|
| PCI-DSS | Non-Compliant | 12 of 250 controls failed |
| ISO 27001 | Partial | 3 major non-conformities |
| SOC 2 | At Risk | Access control issues |

---

## 4. Recommendations Summary

### Immediate (0-30 days)
1. Disable terminated user accounts
2. Apply critical security patches
3. Enable MFA for all privileged accounts

### Short-term (30-90 days)
1. Implement network segmentation
2. Deploy DLP solution
3. Update security policies

### Long-term (90-180 days)
1. Achieve PCI-DSS compliance
2. Implement SIEM
3. Conduct security awareness training
```

## Anti-Patterns

### 1. No Clear Scope

```python
# BAD - Vague scope leads to incomplete audit
audit_scope = "Check security"  # Too vague!

# GOOD - Clear, documented scope
audit_scope = {
    'systems': ['prod-web-1', 'prod-web-2', 'prod-api-1'],
    'networks': ['10.0.0.0/24', '10.0.1.0/24'],
    'applications': ['customer-portal', 'admin-dashboard'],
    'exclusions': ['development', 'staging']
}
```

### 2. Not Using Framework

```python
# BAD - Ad-hoc questions without structure
questions = [
    "Is data secure?",
    "Are systems protected?",
    "Are people trained?"  # Too vague!

# GOOD - Structured against framework
audit_checks = {
    'ISO27001': ['A.9.1', 'A.9.2', 'A.9.3', 'A.9.4'],
    'NIST': ['AC-1', 'AC-2', 'AC-3', 'AU-1'],
    'CIS': ['1.1', '1.2', '2.1', '2.2']
}
```

## Failure Modes

- **Undefined audit scope** → critical systems excluded → undetected vulnerabilities → document explicit in-scope and out-of-scope systems
- **Ad-hoc audit without framework** → inconsistent coverage → missed controls → use recognized frameworks (ISO 27001, NIST, CIS)
- **No evidence documentation** → findings unverifiable → audit rejected → collect and preserve evidence for every finding
- **Unactionable recommendations** → remediation stalled → persistent risk → provide specific, prioritized, and assignable recommendations
- **No follow-up on remediation** → findings unaddressed → recurring risk → track remediation progress with deadlines and owners
- **Internal-only audits** → blind spots → undetected systemic issues → include external auditors for independent validation
- **Ignoring compliance requirements** → regulatory penalties → legal and financial consequences → map audit controls to applicable regulations

## Best Practices

### Audit Framework

```
┌─────────────────────────────────────────────────┐
│              Security Audit Process             │
├─────────────────────────────────────────────────┤
│  1. Planning                                   │
│     - Define scope                             │
│     - Select framework                         │
│     - Gather documentation                     │
├─────────────────────────────────────────────────┤
│  2. Evidence Collection                       │
│     - Technical testing                        │
│     - Document review                          │
│     - Interviews                                │
├─────────────────────────────────────────────────┤
│  3. Analysis                                   │
│     - Compare to controls                      │
│     - Identify gaps                            │
│     - Assess risk                              │
├─────────────────────────────────────────────────┤
│  4. Reporting                                  │
│     - Document findings                        │
│     - Prioritize risks                         │
│     - Recommend actions                        │
├─────────────────────────────────────────────────┤
│  5. Follow-up                                  │
│     - Track remediation                        │
│     - Verify fixes                             │
│     - Schedule re-audit                       │
└─────────────────────────────────────────────────┘
```

## Related Topics

- [[Security MOC]]
- [[VulnerabilityAssessment]] — Finding vulnerabilities
- [[PenetrationTesting]] — Exploitation testing
- [[IAM]] — Identity and access management
- [[TlsSsl]] — Transport security
- [[ThreatModeling]] — Proactive threat identification
- [[OWASPTop10]] — Common vulnerability categories
- [[Compliance]] — Regulatory frameworks
- [[SecureCoding]] — Code-level security
- [[SupplyChainSecurity]]

## Key Takeaways

- Security audits are formal, comprehensive evaluations of security posture covering people, processes, and technology against recognized frameworks
- Required for annual compliance, after security incidents, major infrastructure changes, third-party assessments, or board reporting
- Differs from assessments and tests: audits evaluate against standards, assessments evaluate posture, tests validate through exploitation
- Tradeoff: comprehensive compliance visibility and independent validation versus significant time investment and potential operational disruption
- Main failure mode: undefined audit scope excludes critical systems, leaving vulnerabilities undetected while creating false confidence
- Best practice: define scope clearly with explicit in/out systems, use recognized frameworks (ISO 27001, NIST, CIS), document evidence for every finding, provide actionable prioritized recommendations, and track remediation with deadlines and owners
- Related: vulnerability assessment, penetration testing, IAM, TLS/SSL, threat modeling, OWASP Top 10, secure coding, supply chain security — Third-party risk

## Additional Notes

**Common Frameworks:**
- ISO 27001 - International security standard
- NIST CSF - US government framework
- CIS Controls - Practical security measures
- PCI-DSS - Payment card security
- SOC 2 - Service organization controls

**Audit Types:**
- Internal - Self-assessment
- External - Third-party evaluation
- Certification - Formal certification (ISO 27001)
- Compliance - Regulatory check