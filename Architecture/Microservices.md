---
title: Microservices
title_pt: Microsserviços
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - DistributedSystems
description: Architectural style structuring an application as a collection of loosely coupled, independently deployable services.
description_pt: Estilo arquitetural que estrutura uma aplicação como uma coleção de serviços fracamente acoplados e independentemente implantáveis.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Microservices

## Description

[[Microservices]] is an architectural approach where an application is built as a collection of small, autonomous services modeled around a business domain. Each service owns its data and can be deployed independently, enabling [[CiCd]] and scaling.

Unlike [[Monoliths]] where all components share a single codebase and database, microservices promote isolation, autonomy, and decentralization of data and logic.

## Purpose

**When microservices are valuable:**
- Different parts of your system need to scale independently
- Multiple teams need to work on different features simultaneously without blocking each other
- You need continuous deployment without affecting the entire system
- Different components require different technology stacks
- You need fault isolation to prevent a single failure from cascading

**When microservices may NOT be appropriate:**
- Your application is small or simple
- Your team is small (under 5-10 developers)
- You don't have mature DevOps practices (CI/CD, monitoring, containerization)
- Low latency between components is critical
- You lack experience with distributed systems complexity

**The key question:** Does the complexity of distributed systems pay off for your specific case?

## Key Patterns

### 1. API Gateway
Single entry point for all clients. Handles routing, aggregation, authentication, and rate limiting.

```java
// Java Spring Cloud Gateway example
@Bean
public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
    return builder.routes()
        .route("user-service", r -> r
            .path("/api/users/**")
            .filters(f -> f.stripPrefix(1))
            .uri("lb://user-service"))
        .route("order-service", r -> r
            .path("/api/orders/**")
            .filters(f -> f.stripPrefix(1))
            .uri("lb://order-service"))
        .build();
}
```

### 2. Service Discovery
Services register themselves and discover others dynamically.

```yaml
# Kubernetes Service Discovery
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
```

### 3. Event-Driven Communication
Asynchronous communication via events, decoupling services further.

```python
# Python with Kafka
from kafka import KafkaProducer, KafkaConsumer

# Producer
producer = KafkaProducer(bootstrap_servers=['localhost:9092'])
producer.send('order-created', {
    'order_id': '123',
    'customer_id': '456',
    'total': 99.99,
    'timestamp': '2024-01-15T10:30:00Z'
})

# Consumer
consumer = KafkaConsumer('order-created', bootstrap_servers=['localhost:9092'])
for message in consumer:
    event = json.loads(message.value)
    # Process asynchronously
```

### 4. Circuit Breaker
Prevent cascading failures by failing fast when a service is down.

```java
// Resilience4j Circuit Breaker
@CircuitBreaker(name = "userService", fallbackMethod = "fallbackGetUser")
public User getUser(String userId) {
    return userClient.fetch(userId);
}

private User fallbackGetUser(String userId) {
    return User.cached(userId); // Return cached data
}
```

### 5. Database per Service
Each service owns its data. No shared database tables.

```sql
-- User Service Database
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Order Service Database (separate!)
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    status VARCHAR(50) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Anti-Patterns

### 1. Chatty Services
Services that communicate too frequently, increasing latency.

**Bad:**
```java
// Multiple round trips
User user = userService.get(userId);
List<Order> orders = orderService.getByUser(userId);
for (Order order : orders) {
    List<Item> items = itemService.getByOrder(order.getId());
}
```

**Good:**
```java
// Single aggregated response
UserOrderDTO dto = orderService.getUserOrderWithItems(userId);
```

### 2. God Service
A single service that does everything.

**Bad:**
- One service handling users, orders, payments, inventory, notifications
- Thousands of endpoints
- Multiple responsibilities

**Good:**
- Split into: UserService, OrderService, PaymentService, InventoryService, NotificationService

### 3. Tight Coupling
Services depending on internal details of other services.

**Bad:**
```java
// Direct dependency on another service's database
@Service
public class OrderService {
    @Autowired
    private DataSource userServiceDataSource;
}
```

**Good:**
```java
// Communication via well-defined API
@Service
public class OrderService {
    @Autowired
    private UserClient userClient;
}
```

### 4. Distributed Monolith
Microservices that must be deployed together, losing independence.

**Bad:**
- Shared database transactions across services
- Synchronous calls for everything
- One service update requires all to update

**Good:**
- Event-driven where possible
- Independent deployments
- Clear contract between services

## Best Practices

1. **Start with a monolith, extract when needed** - Most applications don't need microservices from day one.

2. **Define clear bounded contexts** - Each service should map to a business domain.

3. **Design for failure** - Implement proper error handling, retries, circuit breakers.

4. **Centralized logging and monitoring** - Use distributed tracing (Jaeger, Zipkin), centralized logs (ELK), and metrics (Prometheus).

5. **API versioning** - Always version your APIs to allow evolution without breaking clients.

6. **Keep services small but not too small** - A service should have enough functionality to be useful but not do everything.

7. **Automate everything** - CI/CD is essential for managing multiple services.

8. **Documentation** - OpenAPI/Swagger specs for each service, with clear contract definitions.

## Failure Modes

- **Distributed monolith emergence** → services become tightly coupled through synchronous calls and shared databases → lose all microservice benefits while keeping distributed complexity → enforce service autonomy with independent databases and async communication
- **Cascading failures from missing circuit breakers** → one service failure propagates through call chain → entire system goes down → implement circuit breakers, bulkheads, and fallback strategies per service
- **Network latency accumulation** → synchronous service-to-service calls compound latency → user-facing response times become unacceptable → use async communication, caching, and aggregate data at API gateway
- **Data inconsistency across services** → no distributed transactions leads to stale or conflicting data → business logic produces incorrect results → implement saga pattern with compensating transactions for cross-service operations
- **Service discovery failures** → services cannot locate each other after deployment → complete communication breakdown → use health checks, retry logic, and fallback service registries
- **Observability gaps** → cannot trace requests across service boundaries → impossible to debug production issues → implement distributed tracing, centralized logging, and correlation IDs from day one
- **Team coordination overhead** → too many services owned by too few teams → deployment bottlenecks and integration hell → align service boundaries with team structure (Conway's Law)

## Examples

### Service-to-Service Communication

```python
# Python with Kafka
from kafka import KafkaProducer, KafkaConsumer
```

### Technology Stack

| Component | Technologies |
|-----------|--------------|
| Container Orchestration | Kubernetes, Docker Swarm |
| Service Mesh | Istio, Linkerd, Consul |
| API Gateway | Kong, AWS API Gateway, Nginx |
| Service Discovery | Eureka, Consul, Kubernetes DNS |
| Message Broker | Kafka, RabbitMQ, NATS |
| Monitoring | Prometheus, Grafana, Datadog |
| Tracing | Jaeger, Zipkin, AWS X-Ray |

## Related Topics

- [[DistributedSystems]] — Microservices are distributed systems
- [[EventArchitecture]] — Event-driven communication
- [[Hexagonal]] — Each service follows hexagonal architecture
- [[Layering]] — Internal service layering
- [[Coupling]] — Avoiding tight coupling between services
- [[Cohesion]] — Ensuring services have focused responsibilities
- [[DDD]] — Bounded contexts map to service boundaries
- [[ContractTesting]] — Verifying service interfaces
- [[IntegrationTesting]] — Testing service interactions
- [[Observability]] — Logging, metrics, tracing across services
- [[ContainerOrchestration]] — Deploying and managing services
- [[Docker]] — Containerizing individual services
- [[APIDesign]] — Designing service APIs
- [[RateLimiting]] — Protecting services from overload
- [[CircuitBreaker]] — Preventing cascading failures
- [[ServiceMesh]] — Managing service-to-service communication

## Additional Notes

**Migration from Monolith:**
1. Strangler Fig pattern - gradually replace pieces
2. Branch by abstraction - create abstraction layer
3. Feature flags - toggle between old and new

**Team Structure:**
- Each service owned by a single team
- Team can do full-stack development
- Team responsible for entire lifecycle (dev to production)

**Common Challenges:**
- Distributed transactions (saga pattern)
- Data consistency across services
- Network latency and failures
- Testing distributed systems
- Operational complexity

## Key Takeaways

- Microservices structure an application as a collection of loosely coupled, independently deployable services each owning its own data.
- Use when different parts need independent scaling, multiple teams work concurrently, or fault isolation is critical.
- Do NOT use for simple applications, small teams, or when mature DevOps practices are absent.
- Key tradeoff: deployment flexibility and fault isolation vs. distributed systems complexity and operational overhead.
- Main failure mode: distributed monolith where services must be deployed together, losing all microservice benefits.
- Best practice: start with a modular monolith and extract services only when clear boundaries and scaling needs emerge.
- Related concepts: API Gateway, Service Discovery, Circuit Breaker, Saga Pattern, Event-Driven Architecture, DDD bounded contexts.
