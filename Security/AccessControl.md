---
title: Access Control
aliases:
  - Access Control
  - AccessControl
  - Authorization
  - RBAC
  - ABAC
  - Role-Based Access Control
layer: security
type: concept
priority: critical
version: 1.0.0
tags:
  - Security
  - Authorization
  - IAM
  - AccessControl
description: Mechanisms that restrict access to resources based on identity, roles, attributes, or policies. Encompasses RBAC, ABAC, DAC, and MAC models.
prerequisites:
  - "[[Authentication]]"
  - "[[IAM]]"
estimated_read_time: 8 min
difficulty: intermediate
---

# Access Control

## Description

Mechanisms that restrict access to resources based on identity, roles, attributes, or policies. The foundation of authorization systems — determining what an authenticated entity is allowed to do.

## Purpose

**When to use:**
- Multi-user systems with different permission levels
- Systems handling sensitive or regulated data
- Compliance requirements (SOC2, HIPAA, PCI-DSS)
- When least-privilege access is a security requirement

**When to avoid:**
- Single-user systems with no sensitive operations
- When all users need identical, unrestricted access
- When access control logic adds unacceptable latency to real-time operations

## Access Control Models

### RBAC (Role-Based Access Control)

Permissions assigned to roles, users assigned to roles. Simple, widely adopted.

```python
class RBACService:
    def __init__(self):
        self._role_permissions: dict[str, set[str]] = {
            "admin": {"read", "write", "delete", "manage_users"},
            "editor": {"read", "write"},
            "viewer": {"read"},
        }
        self._user_roles: dict[str, str] = {}

    def assign_role(self, user_id: str, role: str):
        if role not in self._role_permissions:
            raise ValueError(f"Unknown role: {role}")
        self._user_roles[user_id] = role

    def has_permission(self, user_id: str, permission: str) -> bool:
        role = self._user_roles.get(user_id)
        if not role:
            return False
        return permission in self._role_permissions.get(role, set())
```

**When to choose RBAC:**
- Organization has clear role hierarchy
- Permission changes affect groups, not individuals
- Simplicity and auditability are priorities

**When NOT to choose RBAC:**
- Fine-grained, context-dependent access decisions needed
- Role explosion makes management unwieldy
- Access depends on data attributes, not just user identity

### ABAC (Attribute-Based Access Control)

Access decisions based on attributes of user, resource, action, and environment.

```python
class ABACPolicy:
    def evaluate(self, subject: dict, resource: dict, action: str, environment: dict) -> bool:
        # Policy: Managers can edit documents in their department during business hours
        if action == "edit":
            return (
                subject.get("role") == "manager"
                and subject.get("department") == resource.get("department")
                and 9 <= environment.get("hour", 0) <= 17
            )
        # Policy: Owners can always delete their own resources
        if action == "delete":
            return subject.get("id") == resource.get("owner_id")
        return False
```

**When to choose ABAC:**
- Access decisions depend on context (time, location, data sensitivity)
- RBAC role explosion is unmanageable
- Regulatory compliance requires fine-grained policies

### Comparison

| Model | Granularity | Complexity | Best For |
|-------|-------------|------------|----------|
| RBAC | Coarse | Low | Organizations with clear role hierarchy |
| ABAC | Fine | High | Context-dependent, regulatory compliance |
| DAC | Variable | Medium | Collaborative environments (file systems) |
| MAC | Fine | Very High | Military, classified systems |

## Rules

1. **Deny by default** — start with no permissions, explicitly grant access
2. **Enforce least privilege** — grant minimum permissions needed for the task
3. **Centralize access control logic** — single source of truth, not scattered checks
4. **Log all authorization decisions** — audit trail for compliance and forensics
5. **Validate at every layer** — UI, API, database — defense in depth

## Examples

### Good Example — Centralized Authorization Service

```python
from enum import Enum
from dataclasses import dataclass

class Permission(Enum):
    READ = "read"
    WRITE = "write"
    DELETE = "delete"
    ADMIN = "admin"

@dataclass
class AuthContext:
    user_id: str
    role: str
    department: str
    is_owner: bool

class AuthorizationService:
    def __init__(self):
        self._role_permissions = {
            "admin": {Permission.READ, Permission.WRITE, Permission.DELETE, Permission.ADMIN},
            "editor": {Permission.READ, Permission.WRITE},
            "viewer": {Permission.READ},
        }

    def authorize(self, ctx: AuthContext, resource: dict, permission: Permission) -> bool:
        # Owner always gets read access
        if ctx.is_owner and permission == Permission.READ:
            return True

        # Check role-based permissions
        role_perms = self._role_permissions.get(ctx.role, set())
        if permission not in role_perms:
            return False

        # Department-scoped access for write/delete
        if permission in (Permission.WRITE, Permission.DELETE):
            if ctx.department != resource.get("department"):
                return False

        return True
```

### Bad Example — Scattered Authorization Checks

```python
# Authorization logic scattered across route handlers
@app.route("/document/<doc_id>", methods=["DELETE"])
def delete_document(doc_id):
    user = get_current_user()
    doc = get_document(doc_id)

    # Inconsistent check — only checks ownership, ignores admin role
    if doc["owner_id"] != user["id"]:
        return 403  # No check for admin, no department scope, no audit log
    delete_document(doc_id)
    return 200
```

**Why it's bad:** Authorization logic is duplicated and inconsistent across route handlers. Admin users can't delete documents, no department scoping, no audit logging. Changes require touching every handler, leading to security gaps.

## Anti-Patterns

### Privilege Creep

Users accumulate roles over time without periodic review.

**Why it's bad:** Former employees retain access, departments merge without role cleanup, compliance audits fail. Implement role review cycles and automated deprovisioning.

### Role Explosion

Creating one role per permission combination (e.g., `editor_with_delete`, `editor_without_delete`, `viewer_with_export`).

**Why it's bad:** Unmanageable number of roles defeats the simplicity benefit of RBAC. Use ABAC or permission hierarchies instead.

### Incomplete Enforcement

Checking authorization at the UI layer but not at the API or database layer.

**Why it's bad:** Direct API access bypasses UI checks. Always enforce at the server layer, regardless of UI restrictions.

## Failure Modes

- **Privilege escalation** → unauthorized access when access controls bypassed or misconfigured → implement defense in depth, validate at every layer, use deny-by-default
- **Broken access control** → data breaches when paths not properly restricted → centralize authorization logic, use deny-by-default, audit permissions regularly, test with unauthorized users
- **Role explosion** → administrative complexity when too many roles created → use role hierarchy, consolidate similar permissions, consider ABAC for fine-grained needs
- **Privilege creep** → excessive access when users accumulate roles over time → enforce role review cycles, implement least privilege, automate deprovisioning on role change
- **Broken inheritance** → access violations when role hierarchy misconfigured → test role assignments thoroughly, audit regularly, document hierarchy
- **Default role abuse** → unauthorized access when default roles too permissive → deny by default, explicitly assign roles, never grant admin on registration
- **Incomplete enforcement** → vulnerabilities when authorization only at UI layer → enforce at API and database layer, implement middleware, test with direct API calls

## Best Practices

- **Deny by default** — start with zero permissions, grant explicitly
- **Centralize authorization** — single policy engine, not scattered `if` statements
- **Log every decision** — who accessed what, when, and whether it was allowed or denied
- **Test authorization** — include unauthorized access attempts in test suites
- **Implement hierarchical permissions** — `admin` implies `editor` implies `viewer`
- **Automate deprovisioning** — remove access on role change, termination, or inactivity
- **Use established frameworks** — OPA (Open Policy Agent), Casbin, AWS IAM Policies
- **Review periodically** — quarterly access audits, remove stale permissions

## Related Topics

- [[Authentication]]
- [[IAM]]
- [[OAuth2]]
- [[JWT]]
- [[ZeroTrust]]
- [[SecurityArchitecture]]
- [[SessionManagement]]

## Key Takeaways

- Access control determines what authenticated entities can do
- RBAC for simple role hierarchies, ABAC for context-dependent decisions
- Always deny by default, enforce at every layer
- Primary failure mode: scattered, inconsistent authorization checks
- Log all decisions for audit and forensic analysis
- Avoid role explosion — consolidate or switch to ABAC
- Test unauthorized access attempts as part of security testing
