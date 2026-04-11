---
title: IAM
title_pt: IAM (Identity and Access Management)
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - IAM
  - Access
description: Managing user identity and access permissions.
description_pt: Gerenciando identidade de usuário e permissões de acesso.
prerequisites: []
estimated_read_time: 12 min
difficulty: intermediate
---

# IAM

## Description

Identity and Access Management (IAM) controls who can access what in your systems. It includes authentication (who you are), authorization (what you can do), and audit (what you did).

Key components:
- **Identity Provider** - Manages user identities
- **Access Control** - Defines permissions
- **Authentication** - Verifies identity
- **Authorization** - Grants permissions
- **Audit** - Tracks access

## Purpose

**When IAM is essential:**
- Systems with multiple users and roles
- Regulatory compliance (SOX, HIPAA, PCI-DSS)
- Enterprise applications
- Multi-tenant systems

**When simpler authentication suffices:**
- Single-user applications
- Internal tools with limited access
- Public read-only content

**The key question:** Who can access what, and can we prove it?

## Examples

```python
# Role-based access control
class Permission:
    ADMIN = "admin"
    EDITOR = "editor"
    VIEWER = "viewer"

user = get_current_user()

def check_permission(user, resource, action):
    if user.role == Permission.ADMIN:
        return True
    if user.role == Permission.EDITOR and action in ['read', 'write']:
        return True
    if user.role == Permission.VIEWER and action == 'read':
        return True
    return False
```

## Failure Modes

- **Over-permissive roles and permissions** → users granted more access than needed → privilege escalation and data exposure → implement least privilege and regularly audit access permissions
- **No MFA for privileged accounts** → admin accounts protected only by passwords → account compromise from credential theft → require MFA for all privileged and administrative accounts
- **Stale access not revoked** → departed employees retain access → unauthorized access from former employees → implement automated access revocation on role change or departure
- **Shared accounts and credentials** → multiple people use same account → no audit trail of individual actions → assign unique accounts per person and track individual actions
- **No access review process** → permissions accumulate over time → privilege creep beyond original needs → conduct regular access reviews and recertification campaigns
- **Hardcoded credentials in code** → passwords and API keys in source code → credential exposure through version control → use secrets management systems and environment variables
- **Missing audit logging for access changes** → permission changes not tracked → cannot investigate unauthorized access → log all IAM changes with who, what, when, and why

## Related Topics

- [[Security MOC]]
- [[Authentication]]
- [[Authorization]]
- [[OAuth2]]
- [[ZeroTrust]]

## Key Takeaways

- IAM controls who can access what through identity management, authentication, authorization, and audit logging
- Essential for systems with multiple users and roles, regulatory compliance, enterprise applications, and multi-tenant systems
- Simpler authentication suffices for single-user applications, internal tools with limited access, or public read-only content
- Tradeoff: centralized identity management and granular access control versus administrative overhead and complexity of permission models
- Main failure mode: over-permissive roles and stale access not revoked after role changes lead to privilege creep and unauthorized access from departed employees
- Best practice: implement least privilege, require MFA for all privileged accounts, assign unique accounts per person, conduct regular access reviews, automate access revocation on role change, and log all IAM changes with who/what/when
- Related: authentication, authorization, OAuth2, zero trust

## Anti-Patterns

### 1. Privilege Creep

**Bad:** Users accumulating permissions over time as they change roles — old permissions are never removed
**Why it's bad:** A user who moved from engineering to management still has production database access — the principle of least privilege is violated silently over months
**Good:** Conduct regular access reviews and recertification campaigns — implement automated access revocation on role change

### 2. Shared Accounts and Credentials

**Bad:** Multiple team members using the same admin account or API key
**Why it's bad:** No audit trail of individual actions — when something goes wrong, you cannot determine who did it, and revoking access affects everyone
**Good:** Assign unique accounts per person — track individual actions and use temporary credentials for shared access needs

### 3. No MFA for Privileged Accounts

**Bad:** Admin accounts protected only by passwords — no multi-factor authentication required
**Why it's bad:** A single compromised password (phishing, credential stuffing, keylogger) gives an attacker full administrative access
**Good:** Require MFA for all privileged and administrative accounts — use hardware tokens (YubiKey) or authenticator apps, not SMS

### 4. Hardcoded Credentials in Code

**Bad:** Embedding passwords, API keys, or service account credentials directly in source code or configuration files
**Why it's bad:** Source code is widely shared, often ends up in version control, and credentials become visible to anyone with repo access
**Good:** Use secrets management systems — inject credentials via environment variables, secret managers, or IAM roles at runtime

## Best Practices

1. **Use strong password policies** - Min length, complexity, rotation
2. **Implement MFA** - Multi-factor authentication
3. **Follow least privilege** - Grant minimum needed
4. **Audit regularly** - Review access permissions
5. **Use SSO where appropriate** - Centralize identity management