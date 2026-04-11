---
title: REST
title_pt: REST (Representational State Transfer)
layer: network
type: pattern
priority: high
version: 1.0.0
tags:
  - Network
  - REST
  - API
  - Pattern
description: Architectural style for designing networked applications.
description_pt: Estilo arquitetural para projetar aplicações em rede.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# REST

## Description

REST (Representational State Transfer) is an architectural style for designing networked applications. It uses HTTP methods to perform CRUD operations and relies on a stateless, client-server communication model. RESTful APIs are the standard for web services, providing a uniform interface for interacting with resources.

REST is based on several principles:
- **Client-Server** - Separation of concerns
- **Stateless** - Each request contains all needed information
- **Cacheable** - Responses can be cached
- **Uniform Interface** - Resource-based endpoints
- **Layered System** - Scalable architecture

Resources are identified by URIs, and HTTP methods map to operations:
- **GET** - Retrieve resources
- **POST** - Create new resources
- **PUT** - Update (replace) resources
- **PATCH** - Partial update
- **DELETE** - Remove resources

REST is widely used for:
- Public APIs (Twitter, GitHub, Stripe)
- Internal microservices
- Mobile backends
- Single Page Applications (SPAs)

## Purpose

**When REST is appropriate:**
- For resource-oriented APIs
- When standard HTTP semantics work
- For public or internal APIs
- When caching is important

**When alternatives are better:**
- For operations not CRUD-based (consider RPC)
- When real-time updates are needed (consider WebSockets)
- For complex queries (consider GraphQL)

## Rules

1. **Use nouns for resources** - `/users`, `/orders`, not `/getUsers`
2. **Use HTTP methods correctly** - GET for reading, POST for creating
3. **Return appropriate status codes** - 200, 201, 404, etc.
4. **Version your API** - `/api/v1/users`
5. **Use plural nouns** - `/users` not `/user`
6. **Be consistent** - Same patterns across all endpoints

## Examples

### Resource Endpoints

```http
# Collection endpoints
GET    /api/users          # List users
POST   /api/users          # Create user

# Single resource
GET    /api/users/123      # Get user
PUT    /api/users/123      # Update user (replace)
PATCH  /api/users/123      # Partial update
DELETE /api/users/123      # Delete user

# Nested resources
GET    /api/users/123/orders      # User's orders
POST   /api/users/123/orders       # Create order for user

# Query parameters
GET /api/users?page=2&limit=20&sort=name&order=asc
GET /api/users?status=active&role=admin
```

### Response Formats

```json
// Single resource
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2024-01-15T10:30:00Z"
}

// Collection with pagination
{
  "data": [
    { "id": 1, "name": "Alice" },
    { "id": 2, "name": "Bob" }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}

// Error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      { "field": "email", "message": "Must be valid email" }
    ]
  }
}

// Created response (201)
{
  "id": 456,
  "name": "Jane",
  "createdAt": "2024-01-15T10:30:00Z",
  "links": {
    "self": "/api/users/456",
    "orders": "/api/users/456/orders"
  }
}
```

### REST with Flask

```python
from flask import Flask, jsonify, request
from flask_restful import Api, Resource

app = Flask(__name__)
api = Api(app)

# Resource-based endpoints
class UserList(Resource):
    def get(self):
        page = request.args.get('page', 1, type=int)
        limit = request.args.get('limit', 20, type=int)
        
        users = get_users(page=page, limit=limit)
        total = count_users()
        
        return {
            'data': users,
            'pagination': {
                'page': page,
                'limit': limit,
                'total': total,
                'pages': (total + limit - 1) // limit
            }
        }
    
    def post(self):
        data = request.get_json()
        
        # Validation
        if 'email' not in data:
            return {'error': 'Email required'}, 400
        
        user = create_user(data)
        return user, 201

class UserDetail(Resource):
    def get(self, user_id):
        user = get_user(user_id)
        if not user:
            return {'error': 'User not found'}, 404
        return user
    
    def put(self, user_id):
        data = request.get_json()
        user = update_user(user_id, data)
        return user
    
    def delete(self, user_id):
        delete_user(user_id)
        return '', 204

# Register routes
api.add_resource(UserList, '/api/users')
api.add_resource(UserDetail, '/api/users/<int:user_id>')

# Nested resource
api.add_resource(UserOrders, '/api/users/<int:user_id>/orders')
```

### HATEOAS Example

```json
{
  "id": 123,
  "name": "John Doe",
  "links": {
    "self": "/api/users/123",
    "orders": "/api/users/123/orders",
    "profile": "/api/users/123/profile",
    "avatar": "/api/users/123/avatar"
  }
}
```

## Anti-Patterns

### 1. Using Verbs Instead of Nouns

```http
# BAD
POST /api/createUser
GET /api/getUserById
POST /api/deleteUser

# GOOD
POST /api/users
GET /api/users/123
DELETE /api/users/123
```

### 2. Wrong HTTP Methods

```http
# BAD - Using GET for mutations
GET /api/deleteUser/123

# GOOD - Use appropriate method
DELETE /api/users/123
```

### 3. No Versioning

```http
# BAD - No version
GET /api/users

# GOOD
GET /api/v1/users
```

## Failure Modes

- **Missing input validation** → malformed requests cause errors → server crashes or data corruption → validate all request parameters and body fields
- **Inconsistent error responses** → clients cannot handle errors gracefully → poor developer experience → standardize error format across all endpoints
- **No rate limiting** → API abuse → service degradation for all users → implement per-client rate limits with 429 responses
- **Breaking changes without versioning** → existing clients break → production outages → version APIs and maintain backward compatibility
- **Over-fetching resources** → excessive data transfer → slow responses and wasted bandwidth → support field selection and pagination
- **Missing authentication on endpoints** → unauthorized data access → data breach → enforce auth on all non-public endpoints
- **N+1 query patterns** → database overload → slow API responses → use eager loading and query optimization

## Best Practices

### Filtering and Sorting

```http
# Filtering
GET /api/products?category=electronics&price_min=100&price_max=500

# Sorting
GET /api/users?sort=created_at&order=desc

# Field selection
GET /api/users?fields=id,name,email

# Embedded resources
GET /api/orders?include=user,items
```

### Content Negotiation

```http
# Request different formats
Accept: application/json
Accept: application/xml

# Or via query
GET /api/users?format=json
GET /api/users?format=xml
```

## Related Topics

- [[HTTP]]
- [[HTTPS]]
- [[APIDesign]]
- [[Authentication]]
- [[Authorization]]
- [[Idempotency]]
- [[WebSockets]]
- [[GraphQLArchitecture]]

## Additional Notes

**Best Practices:**
- Use plural nouns
- Version your API
- Use proper status codes
- Implement pagination
- Add HATEOAS links

**Status Codes:**
- 200 - OK
- 201 - Created
- 204 - No Content
- 400 - Bad Request
- 401 - Unauthorized
- 404 - Not Found
- 500 - Server Error