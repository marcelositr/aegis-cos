---
title: API Design
title_pt: Design de APIs
layer: design
type: concept
priority: high
version: 1.0.0
tags:
  - Design
  - APIDesign
description: Principles and practices for designing clean, consistent, and developer-friendly APIs.
description_pt: Princípios e práticas para design de APIs limpas, consistentes e amigáveis para desenvolvedores.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# API Design

## Description

API design is the process of creating interfaces that allow different software systems to communicate. A well-designed API is intuitive, consistent, and developer-friendly. It abstracts complexity and provides clear contracts for integration.

APIs can be:
- **REST**: Resource-based, HTTP methods
- **GraphQL**: Query language for APIs
- **gRPC**: High-performance RPC
- **WebSocket**: Real-time bidirectional

Good API design reduces learning curve, minimizes errors, and makes integration enjoyable for consumers.

## Purpose

**When to focus on API design:**
- When building public APIs
- When multiple teams integrate with your service
- When you want good developer experience
- When building microservices
- When you need stable interfaces

**When simpler approaches work:**
- Internal, tightly coupled systems
- When speed is critical
- When only one consumer exists

## Rules

1. **Use nouns, not verbs** - `/users` not `/getUsers`
2. **Use plural nouns** - `/users` not `/user`
3. **Consistent naming** - Same words mean same things
4. **Version your API** - `/v1/users`
5. **Return proper status codes** - 200, 201, 400, 404, 500
6. **Support pagination** - Don't return unlimited data
7. **Document everything** - Examples, error cases

## Examples

### Good REST API Design

```python
# GET /users - List users
# GET /users/{id} - Get user by ID
# POST /users - Create user
# PUT /users/{id} - Update user
# DELETE /users/{id} - Delete user

# Nested resources
# GET /users/{user_id}/orders - Get user's orders

# Query parameters for filtering
# GET /users?status=active&limit=10

# Response format
{
    "data": [
        {"id": "1", "name": "John", "email": "john@example.com"}
    ],
    "pagination": {
        "page": 1,
        "limit": 10,
        "total": 100
    }
}
```

### Bad API Design

```
# BAD: Verb-based endpoints
POST /getUsers
POST /createNewUser
POST /updateUser
POST /deleteUser

# BAD: Inconsistent naming
POST /user (singular!)
GET /user_info (different pattern)
PUT /users/{id}/remove (action in URL)

# BAD: No versioning
GET /users  # What version?
GET /users/1 # What if we change?
```

### Good Error Handling

```python
# Consistent error format
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid input",
        "details": [
            {"field": "email", "message": "Invalid email format"}
        ]
    }
}

# HTTP status codes
200 - OK
201 - Created
204 - No Content
400 - Bad Request
401 - Unauthorized
403 - Forbidden
404 - Not Found
409 - Conflict
422 - Unprocessable Entity
500 - Internal Server Error
```

### Bad Error Handling

```python
# Inconsistent error formats
{"error": "Not found"}
{"message": "User not found"}
{"code": 404, "msg": "Missing"}
{"error": {"description": "Not found!"}}

# Wrong status codes
200 OK when error occurred
404 when validation fails
500 when client sent bad data
```

### Good Versioning

```
# URL versioning (most common)
GET /v1/users
GET /v2/users

# Header versioning
GET /users
Accept: application/vnd.myapp.v1+json

# Query parameter
GET /users?version=1
```

## Anti-Patterns

### 1. Verb-Based Endpoints

**Bad:**
```
POST /createUser
POST /updateUser
POST /deleteUser
```

**Good:**
```
POST /users
PUT /users/{id}
DELETE /users/{id}
```

### 2. Inconsistent Response Format

**Bad:**
- Different structures for similar endpoints
- Varying field names
- No standard envelope

**Good:**
- Consistent response structure
- Same field names for same data
- Use envelope when needed

### 3. No Pagination

**Bad:**
- Return all records
- No limit support
- Performance issues

**Good:**
- Default limits
- Support offset/cursor
- Return total count

### 4. Leaking Implementation Details

**Bad:**
- Database IDs in URLs
- Internal error messages
- Stack traces

**Good:**
- Use UUIDs
- Generic error messages
- Log details server-side

## Failure Modes

- **Verb-based endpoints** → inconsistent API → confusing for consumers → use nouns for resources, HTTP methods for actions
- **Inconsistent response formats** → client parsing complexity → integration failures → standardize response envelope across all endpoints
- **No pagination** → massive payloads → memory exhaustion and slow responses → implement cursor or offset pagination with defaults
- **Leaking implementation details** → tight coupling → breaking changes expose internals → use UUIDs, generic error messages, no stack traces
- **Missing versioning** → breaking changes → client breakage → version APIs from day one using URL or header versioning
- **No rate limiting** → API abuse → service degradation → implement per-client rate limits with clear 429 responses
- **Inconsistent error codes** → clients cannot handle errors → poor DX → use standard HTTP status codes with structured error bodies

## Best Practices

### 1. Resource Design

```
# Collection: /users
# Instance: /users/{id}

# Actions should be in body or method, not URL
POST /users/{id}/activate
POST /users/{id}/deactivate

# Don't use verbs for resources
GET /users/search?query=john
```

### 2. Request/Response Design

```python
# Request
{
    "name": "John",
    "email": "john@example.com",
    "password": "secure123"
}

# Response
{
    "data": {
        "id": "uuid",
        "name": "John",
        "email": "john@example.com",
        "created_at": "2024-01-15T10:00:00Z"
    }
}

# Don't return sensitive data
{
    "data": {
        "password_hash": "..."  # BAD!
    }
}
```

### 3. HATEOAS (Hypermedia)

```json
{
    "data": {
        "id": "1",
        "name": "John"
    },
    "links": {
        "self": "/users/1",
        "orders": "/users/1/orders"
    }
}
```

### 4. Filtering, Sorting, Field Selection

```
GET /users?status=active&sort=created_at desc&fields=name,email
GET /users?created_after=2024-01-01
GET /users?include=orders,addresses
```

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| OpenAPI/Swagger | API documentation |
| FastAPI | Python REST API |
| Express | Node.js REST API |
| GraphQL | GraphQL APIs |
| gRPC | High-performance APIs |

## Related Topics

- [[REST]]
- [[HTTP]]
- [[HTTPS]]
- [[Authentication]]
- [[Authorization]]
- [[SecurityHeaders]]
- [[ContractTesting]]
- [[Idempotency]]

## Key Takeaways

- API design creates interfaces that allow software systems to communicate intuitively, consistently, and with clear contracts
- Focus on API design when building public APIs, multi-team integrations, microservices, or when developer experience matters
- Use simpler approaches for internal tightly coupled systems, speed-critical projects, or single-consumer services
- Tradeoff: clean developer experience and stable interfaces versus upfront design investment and versioning overhead
- Main failure mode: missing versioning and leaking implementation details cause breaking changes that break all consumers simultaneously
- Best practice: use noun-based resource URLs, consistent response envelopes, proper HTTP status codes, pagination from day one, and version APIs using URL or header versioning
- Related: REST, HTTP, authentication, authorization, contract testing, idempotency

## Additional Notes

**GraphQL vs REST:**
- GraphQL: Flexible queries, single endpoint
- REST: Caching, clear semantics
- Choose based on use case

**Webhooks:**
- Provide webhook URLs
- Sign payloads
- Support retries
- Document event types
