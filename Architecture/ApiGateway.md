---
title: API Gateway
title_pt: API Gateway
layer: architecture
type: pattern
priority: high
version: 1.0.0
tags:
  - Architecture
  - API
  - Pattern
  - Microservices
description: Single entry point that routes, aggregates, and secures requests to backend services.
description_pt: Ponto único de entrada que roteia, agrega e protege requisições para serviços backend.
prerequisites:
  - Microservices
  - REST
estimated_read_time: 12 min
difficulty: intermediate
---

# API Gateway

## Description

An API Gateway is a server that acts as a single entry point for all client requests. It routes requests to appropriate backend services, aggregates responses, and handles cross-cutting concerns like authentication, rate limiting, and logging.

Responsibilities:
- **Routing** — Direct requests to the correct backend service
- **Aggregation** — Combine responses from multiple services
- **Authentication** — Validate tokens before forwarding
- **Rate Limiting** — Protect backend services from overload
- **Load Balancing** — Distribute requests across service instances
- **SSL Termination** — Handle TLS at the gateway
- **Caching** — Cache responses to reduce backend load
- **Request/Response Transformation** — Adapt formats between client and services

## Purpose

**When an API Gateway is essential:**
- Multiple backend services with different APIs
- Mobile/web clients needing a unified interface
- Cross-cutting concerns (auth, rate limiting, logging)
- Backend for Frontend (BFF) pattern
- When you need a single point for API versioning

**When an API Gateway adds unnecessary complexity:**
- Single service or monolith
- Internal services only (use service mesh instead)
- When latency overhead is critical
- Small team managing few services

**The key question:** Do clients need a single, unified interface to multiple services?

## Patterns

### Routing

```yaml
# Kong configuration
routes:
  - name: users
    paths:
      - /api/users
    service: user-service
    strip_path: true
  
  - name: orders
    paths:
      - /api/orders
    service: order-service
    strip_path: true
  
  - name: products
    paths:
      - /api/products
    service: product-service
    strip_path: true
```

### Request Aggregation

```python
# Gateway aggregates multiple service calls
@app.get("/api/user-dashboard/{user_id}")
async def user_dashboard(user_id: str):
    # Fan-out to multiple services
    user, orders, notifications = await asyncio.gather(
        call_service("user-service", f"/users/{user_id}"),
        call_service("order-service", f"/orders?user={user_id}"),
        call_service("notification-service", f"/notifications?user={user_id}"),
    )
    
    # Aggregate response
    return {
        "user": user,
        "recent_orders": orders[:5],
        "unread_notifications": len(notifications),
    }
```

### Authentication Offloading

```python
# Gateway handles auth, backend services trust gateway
@app.middleware("http")
async def authenticate(request: Request, call_next):
    token = request.headers.get("Authorization")
    if not token:
        return JSONResponse(status_code=401, content={"error": "Missing token"})
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        request.state.user_id = payload["sub"]
        # Forward user identity to backend
        request.headers.__dict__["_list"].append(
            (b"x-user-id", payload["sub"].encode())
        )
    except jwt.InvalidTokenError:
        return JSONResponse(status_code=401, content={"error": "Invalid token"})
    
    return await call_next(request)
```

## Anti-Patterns

### 1. Gateway as God Service

**Bad:** Gateway contains business logic
**Solution:** Gateway should only route, aggregate, and handle cross-cutting concerns

### 2. Single Point of Failure

**Bad:** One gateway instance → outage if it fails
**Solution:** Deploy multiple instances behind a load balancer

### 3. Too Much Logic in Gateway

**Bad:** Gateway transforms data, applies business rules
**Solution:** Keep gateway thin — route, auth, rate limit, log

### 4. No Circuit Breaker

**Bad:** Backend service down → gateway hangs → all clients affected
**Solution:** Add circuit breakers for each backend service

### 5. Tight Coupling to Services

**Bad:** Gateway knows internal service URLs
**Solution:** Use service discovery, not hardcoded URLs

## Best Practices

1. **Keep it thin** — routing, auth, rate limiting, logging — nothing more
2. **Use service discovery** — don't hardcode backend URLs
3. **Add circuit breakers** — protect against backend failures
4. **Version APIs at the gateway** — clients call /v1/, /v2/
5. **Monitor gateway metrics** — latency, error rate, throughput per route
6. **Cache aggressively** — cache responses that don't change often
7. **Rate limit per client** — protect backends from abusive clients

## Failure Modes

- **Gateway down** → all clients lose access → need multiple instances + health checks
- **Backend slow** → gateway threads blocked → need timeouts and circuit breakers
- **Rate limit misconfigured** → legitimate traffic blocked → monitor and tune
- **Auth token expired** → gateway rejects valid requests → proper token refresh flow
- **Aggregation timeout** — one slow service delays entire response → set per-service timeouts

## Technology Stack

| Tool | Type | Use Case |
|------|------|----------|
| Kong | Gateway | Plugin ecosystem, rate limiting |
| AWS API Gateway | Managed | Serverless, AWS integration |
| Nginx | Reverse Proxy | High performance, simple routing |
| Envoy | Proxy | Service mesh, advanced routing |
| Traefik | Gateway | Kubernetes-native, auto-discovery |
| Apigee | Enterprise | Full API management platform |

## Related Topics

- [[Microservices]] — Gateway as entry point for service mesh
- [[RateLimiting]] — Gateway enforces rate limits
- [[Authentication]] — Gateway validates tokens before forwarding
- [[REST]] — Gateway exposes RESTful APIs
- [[CircuitBreaker]] — Protecting gateway-to-service calls
- [[RateLimiting]] — Distributing requests across instances
- [[ServiceMesh]] — Internal service communication vs gateway
- [[Caching]] — Gateway-level response caching
- [[Observability]] — Gateway as observability collection point

## Key Takeaways

- An API Gateway acts as a single entry point for all client requests, handling routing, aggregation, authentication, rate limiting, and cross-cutting concerns.
- Use when multiple backend services need a unified interface, for mobile/web clients, or when cross-cutting concerns (auth, rate limiting) need centralization.
- Do NOT use for single-service/monolith architectures, internal-only services (use service mesh), or when every millisecond of latency matters.
- Key tradeoff: unified client interface and centralized cross-cutting concerns vs. single point of failure and added latency hop.
- Main failure mode: gateway becoming a "god service" with business logic, or a single gateway instance going down and taking all client access with it.
- Best practice: keep the gateway thin (route, auth, rate limit, log only), use service discovery, add circuit breakers per backend, and deploy multiple instances behind a load balancer.
- Related concepts: Microservices, Backend for Frontend (BFF), Rate Limiting, Service Mesh, Circuit Breaker, Load Balancing, Caching.
