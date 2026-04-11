---
title: Authorization
title_pt: Autorização
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - Authorization
description: Determining what an authenticated user is allowed to do.
description_pt: Determinando o que um usuário autenticado tem permissão para fazer.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Authorization

## Description

Authorization determines what an authenticated user can do. It happens after authentication.

Models:
- **DAC**: Discretionary - owners control access
- **MAC**: Mandatory - system enforces rules
- **RBAC**: Role-based - roles determine access
- **ABAC**: Attribute-based - policies based on attributes

## Purpose

**When authorization is critical:**
- Multi-tenant systems
- Systems with different user roles
- APIs with granular permissions
- Compliance requirements

**When simpler models work:**
- Single user type
- Simple permission structures
- Public systems

**The key question:** What can this authenticated user do?

## Examples

```python
# RBAC - Role-based access control
ROLES = {
    'admin': ['read', 'write', 'delete'],
    'editor': ['read', 'write'],
    'viewer': ['read']
}

def check_permission(user_role, action):
    return action in ROLES.get(user_role, [])

# Usage
@require_permission('delete')
def delete_user(user_id):
    ...
```

## Failure Modes

- **Missing authorization checks** → any authenticated user accesses any resource → data breach → enforce authorization on every endpoint
- **Insecure direct object reference** → user accesses other users' data by ID manipulation → data leakage → verify resource ownership before access
- **Role escalation** → user modifies own role → privilege escalation → make roles immutable by the user and admin-controlled
- **Missing deny-by-default** → unhandled cases grant access → unauthorized operations → default to deny, explicitly allow
- **Authorization bypass at service layer** → direct API calls skip UI checks → data exposure → enforce authorization at every layer
- **Stale permissions cache** → revoked access still active → unauthorized operations → invalidate permission caches on role changes
- **Overly broad admin roles** → excessive privileges → lateral movement → implement granular permissions with least privilege

## Anti-Patterns

### 1. Authorization Only at the UI Layer

**Bad:** Hiding buttons and menu items based on user role but not enforcing authorization at the API or service layer
**Why it's bad:** An attacker bypasses the UI entirely and calls the API directly — the hidden functionality is fully accessible without any authorization check
**Good:** Enforce authorization at every layer — UI, API, service, and database — defense in depth ensures that bypassing one layer does not grant access

### 2. Insecure Direct Object References (IDOR)

**Bad:** Using sequential IDs in URLs (`/orders/123`) without verifying that the authenticated user owns the resource
**Why it's bad:** An attacker changes the ID to access other users' data — the most common authorization bug in web applications
**Good:** Verify resource ownership on every access — check that the authenticated user has permission to access the specific resource, not just the endpoint

### 3. Overly Broad Admin Roles

**Bad:** A single "admin" role that grants access to everything — user management, billing, configuration, data export
**Why it's bad:** If an admin account is compromised, the attacker has full system access — there is no containment
**Good:** Implement granular permissions with least privilege — separate admin roles for user management, billing, configuration, and data access

### 4. Stale Permission Caches

**Bad:** Caching user permissions for performance but not invalidating the cache when roles change
**Why it's bad:** A revoked user retains access until the cache expires — the window can be hours or days depending on the TTL
**Good:** Invalidate permission caches immediately on role changes — or use short TTLs with periodic refresh for critical permissions

## Best Practices

### 1. Deny by Default

```python
# Default to deny
def can_access(user, resource):
    if user.is_admin:
        return True
    return False  # Default deny
```

### 2. Check at Every Layer

```python
# Check in API, service, database
# Defense in depth
```

## Related Topics

- [[Authentication]]
- [[OAuth2]]
- [[JWTTokens]]
- [[OpenIDConnect]]
- [[RBAC]]
- [[InputValidation]]
- [[SecurityHeaders]]
- [[APIDesign]]

## Key Takeaways

- Authorization determines what an authenticated user is allowed to do, using models like RBAC, ABAC, DAC, or MAC
- Critical for multi-tenant systems, systems with different user roles, APIs with granular permissions, and compliance requirements
- Simpler models work for single user types, simple permission structures, or public systems
- Tradeoff: granular access control versus implementation complexity and performance overhead of permission checks
- Main failure mode: missing authorization checks allows any authenticated user to access any resource, causing data breaches
- Best practice: enforce authorization at every layer (UI, API, service, database), deny by default, verify resource ownership before access (prevent IDOR), make roles immutable by users, and invalidate permission caches on role changes
- Related: authentication, OAuth2, JWT tokens, OpenID Connect, RBAC, input validation, security headers, API design
