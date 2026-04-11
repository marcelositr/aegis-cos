---
title: HTTP
title_pt: HTTP (Hypertext Transfer Protocol)
layer: network
type: concept
priority: high
version: 1.0.0
tags:
  - Network
  - HTTP
  - Protocol
description: The foundation protocol for web communication.
description_pt: O protocolo fundamental para comunicação web.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# HTTP

## Description

HTTP (Hypertext Transfer Protocol) is the foundation of data communication on the World Wide Web. It defines how messages are formatted and transmitted between clients (browsers) and servers. HTTP is a request-response protocol where the client sends a request and the server returns a response.

HTTP operates as a stateless protocol - each request is independent and doesn't retain information from previous requests. This design makes HTTP scalable but requires additional mechanisms (like cookies or sessions) for stateful interactions.

Key HTTP concepts:
- **Methods** - GET, POST, PUT, DELETE, PATCH, etc.
- **Status Codes** - 1xx (informational), 2xx (success), 3xx (redirection), 4xx (client error), 5xx (server error)
- **Headers** - Metadata about the request/response
- **Body** - The actual content being transferred
- **Versions** - HTTP/1.1, HTTP/2, HTTP/3

HTTP/2 introduced multiplexing, header compression, and server push. HTTP/3 uses QUIC for even faster, more reliable connections, especially on mobile networks.

## Purpose

**When HTTP knowledge is essential:**
- For API development
- For web application debugging
- For understanding browser-server communication
- For performance optimization

**What to understand:**
- Request/response flow
- Headers and their uses
- Status codes
- Caching mechanisms

## Rules

1. **Use appropriate methods** - GET for reading, POST/PUT for writing
2. **Return correct status codes** - 200 for success, 404 for not found, etc.
3. **Set appropriate headers** - Content-Type, Cache-Control, etc.
4. **Use HTTPS in production** - Never send sensitive data over HTTP
5. **Version appropriately** - HTTP/2 or HTTP/3 for performance

## Examples

### HTTP Request

```http
GET /api/users/123 HTTP/1.1
Host: api.example.com
Accept: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)
Accept-Language: en-US,en;q=0.9
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
```

### HTTP Response

```http
HTTP/1.1 200 OK
Date: Mon, 15 Jan 2024 10:30:00 GMT
Content-Type: application/json
Content-Length: 256
Cache-Control: max-age=3600
Server: nginx/1.18.0
Access-Control-Allow-Origin: *

{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### POST Request with JSON Body

```http
POST /api/users HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer token

{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "age": 28
}
```

### Status Codes Reference

```python
# Common status codes
status_codes = {
    # 2xx Success
    200: "OK - Request successful",
    201: "Created - Resource created",
    204: "No Content - Successful, no response body",
    
    # 3xx Redirection
    301: "Moved Permanently - Resource moved permanently",
    302: "Found - Temporary redirect",
    304: "Not Modified - Cached version is valid",
    
    # 4xx Client Error
    400: "Bad Request - Invalid syntax",
    401: "Unauthorized - Authentication required",
    403: "Forbidden - Permission denied",
    404: "Not Found - Resource doesn't exist",
    409: "Conflict - Resource conflict",
    422: "Unprocessable Entity - Validation failed",
    429: "Too Many Requests - Rate limit exceeded",
    
    # 5xx Server Error
    500: "Internal Server Error",
    502: "Bad Gateway - Invalid response from upstream",
    503: "Service Unavailable - Server temporarily unavailable",
    504: "Gateway Timeout - Upstream timeout"
}
```

## Anti-Patterns

### 1. Not Using HTTPS

```python
# BAD
app.run()  # HTTP in production!

# GOOD
app.run(ssl_context=ssl_context)  # HTTPS
```

### 2. Missing Content-Type

```python
# BAD - No Content-Type
return json.dumps(data)

# GOOD - With Content-Type
response = json.dumps(data)
return Response(response, mimetype='application/json')
```

## Failure Modes

- **Missing Content-Type header** → client misinterprets response → rendering or parsing errors → always set correct Content-Type for responses
- **Incorrect cache headers** → stale data served → users see outdated information → configure Cache-Control appropriately per endpoint
- **No request size limits** → oversized payloads → memory exhaustion or DoS → enforce maximum request body sizes
- **HTTP in production** → data transmitted in plaintext → credential theft and MITM attacks → enforce HTTPS with HSTS
- **Missing CORS configuration** → browser blocks legitimate requests → broken cross-origin functionality → configure CORS with specific origins
- **Connection not reused** → TCP handshake overhead → increased latency → enable keep-alive and connection pooling
- **No timeout configuration** → hanging connections → resource exhaustion → set request and response timeouts

## Best Practices

### Caching Headers

```python
# Cache-Control examples
response.headers['Cache-Control'] = 'max-age=3600'  # Cache for 1 hour
response.headers['Cache-Control'] = 'no-cache'     # Always validate
response.headers['Cache-Control'] = 'no-store'      # Don't cache
response.headers['Cache-Control'] = 'public, max-age=31536000'  # Long cache
```

### Security Headers

```python
# Essential security headers
response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
response.headers['X-Content-Type-Options'] = 'nosniff'
response.headers['X-Frame-Options'] = 'DENY'
response.headers['Content-Security-Policy'] = "default-src 'self'"
```

## Related Topics

- [[HTTPS]]
- [[REST]]
- [[WebSockets]]
- [[TlsSsl]]
- [[SecurityHeaders]]
- [[APIDesign]]
- [[Caching]]
- [[Authentication]]

## Additional Notes

**HTTP Versions:**
- HTTP/1.1 - Persistent connections, chunked transfer
- HTTP/2 - Multiplexing, header compression, server push
- HTTP/3 - QUIC protocol, reduced latency

**Common Headers:**
- Request: Accept, Authorization, Content-Type, User-Agent
- Response: Content-Type, Cache-Control, Set-Cookie, Location