---
title: Distributed Systems
title_pt: Sistemas Distribuídos
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - DistributedSystems
description: Systems that run across multiple machines, requiring understanding of networking, consistency, and fault tolerance.
description_pt: Sistemas que executam em múltiplas máquinas, requerendo compreensão de rede, consistência e tolerância a falhas.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Distributed Systems

## Description

[[DistributedSystems]] is a collection of independent computers that appears to its users as a single coherent system. The machines coordinate their actions by passing messages, and the system must handle the challenges inherent in distributing computation across [[NetworkSecurity]] boundaries.

Unlike [[Monoliths]] where everything runs in a single process, distributed systems split functionality across multiple nodes. This provides benefits like scalability, fault tolerance, and geographic distribution, but introduces complexity in areas that single-machine systems don't have to consider.

The CAP theorem states that a distributed system can provide only two of three guarantees simultaneously:
- **Consistency**: All nodes see the same data at the same time
- **Availability**: Every request receives a (non-error) response
- **Partition tolerance**: System continues to operate despite network failures

Since network partitions are inevitable in distributed systems, you must choose between consistency and availability during a partition.

## Purpose

**When distributed systems are necessary:**
- When application needs to scale horizontally beyond single machine capacity
- When requiring high availability (multiple failures can be tolerated)
- When users are geographically distributed
- When different components have different scaling needs
- When requiring fault tolerance through replication

**When to avoid:**
- When simplicity is more important than scalability
- When the team lacks expertise in distributed systems
- When latency between components is critical
- When the overhead of distribution exceeds the benefit

## Rules

1. **Design for failure** - Assume components will fail
2. **Embrace eventual consistency** - Not all data needs immediate consistency
3. **Implement observability** - You can't debug what you can't see
4. **Use idempotent operations** - Make operations safe to retry
5. **Circuit breakers** - Prevent cascading failures
6. **Backpressure** - Handle load spikes gracefully
7. **Document failure modes** - Plan for what happens when things fail

## Examples

### Good Example: Service Discovery

```python
# Service registration
from consul import Consul

class ServiceRegistry:
    def __init__(self, consul_host: str, port: int):
        self.consul = Consul(host=consul_host, port=port)
    
    def register(self, service_name: str, service_id: str, 
                 address: str, port: int, health_check: str):
        self.consul.agent.service.register(
            service_id=service_id,
            name=service_name,
            address=address,
            port=port,
            check=health_check
        )
    
    def deregister(self, service_id: str):
        self.consul.agent.service.deregister(service_id)
    
    def discover(self, service_name: str) -> list:
        _, services = self.consul.health.service(service_name)
        return [s['Service'] for s in services]

# Service discovery for clients
class LoadBalancer:
    def __init__(self, registry: ServiceRegistry):
        self.registry = registry
        self.service_map = {}
    
    def get_endpoint(self, service_name: str) -> str:
        if service_name not in self.service_map:
            instances = self.registry.discover(service_name)
            self.service_map[service_name] = instances
        # Simple round-robin
        instances = self.service_map[service_name]
        if not instances:
            raise NoServiceAvailable()
        return instances[len(instances) % len(instances)]
```

### Bad Example: Hardcoded Service URLs

```python
# BAD: Hardcoded URLs
class OrderService:
    def __init__(self):
        self.user_service_url = "http://192.168.1.10:8001"
        self.inventory_service_url = "http://192.168.1.11:8002"
    
    def get_order(self, order_id: str):
        # Hardcoded, no failover, no discovery
        response = requests.get(f"{self.user_service_url}/users/{user_id}")
```

**Problems:**
- No dynamic service discovery
- No failover when service fails
- No load balancing
- IPs in code

### Good Example: Distributed Tracing

```python
# Distributed tracing with OpenTelemetry
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

trace.set_tracer_provider(TracerProvider())
jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",
    agent_port=6831,
)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

tracer = trace.get_tracer(__name__)

def call_user_service(user_id: str):
    with tracer.start_as_current_span("call_user_service") as span:
        span.set_attribute("user_id", user_id)
        span.set_attribute("span.kind", "client")
        
        # Make HTTP call with tracing
        response = http_client.get(
            f"http://user-service/users/{user_id}",
            headers={"traceparent": get_traceparent(span)}
        )
        return response.json()
```

### Bad Example: No Tracing

```python
# No visibility into what's happening
def process_order(order_id):
    # Calls multiple services
    user = get_user(order.user_id)  # Where does this go?
    inventory = check_inventory(order.items)  # How long does it take?
    payment = process_payment(order.payment)  # Did it succeed?
    
    # If anything fails, no way to know where in the chain
    return result
```

### Good Example: Circuit Breaker

```python
import asyncio
from circuitbreaker import circuit

class PaymentService:
    def __init__(self, failure_threshold: int = 5, 
                 recovery_timeout: int = 60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
    
    @circuit(failure_threshold=5, recovery_timeout=60)
    async def process_payment(self, payment: Payment) -> bool:
        # This might fail
        async with aiohttp.ClientSession() as session:
            async with session.post(
                "https://payment-gateway/process",
                json=payment.to_dict()
            ) as response:
                return response.status == 200
    
    async def fallback_process_payment(self, payment: Payment) -> bool:
        # Queue for later processing when circuit is open
        await queue.send("pending_payments", payment.to_dict())
        return True  # Assume success, will reconcile later
```

## Anti-Patterns

### 1. Ignoring Network Failures

**Bad:**
- Assuming network calls always succeed
- No retry logic
- No timeouts

**Why it's dangerous:**
- Network failures are common
- Requests will hang indefinitely
- Poor user experience

**Good:**
- Implement timeouts
- Add retry with exponential backoff
- Handle failures gracefully

### 2. Distributed Monolith

**Bad:**
- Services that must be deployed together
- Synchronous calls for everything
- Shared database

**Why it's bad:**
- Loses benefits of distribution
- No independent scaling
- Complex deployments

**Good:**
- Independent services with own databases
- Async communication when possible
- Loose coupling

### 3. Lack of Idempotency

**Bad:**
- Operations that can't be safely retried
- No deduplication
- Duplicate charges/processes

**Why it's bad:**
- Network retries cause duplicate operations
- Data inconsistency
- Financial impact

**Good:**
- Use idempotency keys
- Design operations to be idempotent
- Check before doing

### 4. No Backpressure

**Bad:**
- Accepting unlimited requests
- No queue management
- System gets overwhelmed

**Why it's bad:**
- Resource exhaustion
- Cascading failures
- System becomes unresponsive

**Good:**
- Implement rate limiting
- Use bounded queues
- Reject or queue excess load

### 5. Ignoring Latency

**Bad:**
- Multiple synchronous calls in sequence
- No caching
- Not considering network overhead

**Why it's bad:**
- Network calls are expensive
- Poor performance
- Bad user experience

**Good:**
- Parallelize independent calls
- Cache appropriately
- Consider data locality

## Best Practices

### 1. Consistency Models

Choose the right model for your use case:

**Strong Consistency:**
- All reads see most recent write
- Use for: financial transactions, inventory
- Tools: Distributed locks, consensus (Raft, Paxos)

**Eventual Consistency:**
- Writes propagate asynchronously
- Use for: social posts, analytics
- Tools: Event sourcing, CRDTs

**Causal Consistency:**
- Respect cause-effect ordering
- Use for: collaborative editing
- Tools: Version vectors

### 2. Data Replication Strategies

```python
# Leader-based replication
class LeaderReplica:
    def write(self, data):
        # Write to leader
        leader_db.write(data)
        # Async replicate to followers
        for follower in followers:
            asyncio.create_task(follower.replicate(data))
    
    def read(self, key):
        # Can read from any replica
        return random.choice([leader] + followers).read(key)

# Read-your-writes consistency
class SessionReplica:
    def __init__(self):
        self.last_write_timestamp = 0
    
    def write(self, data):
        self.last_write_timestamp = time.time()
        leader_db.write(data)
    
    def read(self, key):
        # Ensure we read our own writes
        replica = self.choose_replica()
        while replica.last_seen_timestamp < self.last_write_timestamp:
            replica = self.choose_replica()
        return replica.read(key)
```

### 3. Failure Detection

```python
import asyncio
from dataclasses import dataclass

@dataclass
class Member:
    address: str
    last_heartbeat: float
    is_alive: bool = True

class FailureDetector:
    def __init__(self, heartbeat_interval: float = 1.0,
                 timeout: float = 3.0):
        self.heartbeat_interval = heartbeat_interval
        self.timeout = timeout
        self.members = {}
    
    async def start(self):
        while True:
            self.check_member_health()
            await asyncio.sleep(0.1)
    
    def check_member_health(self):
        now = time.time()
        for member in self.members.values():
            if now - member.last_heartbeat > self.timeout:
                member.is_alive = False
                # Notify cluster of failure
                self.notify_failure(member)
    
    def record_heartbeat(self, member_id: str):
        if member_id in self.members:
            self.members[member_id].last_heartbeat = time.time()
            self.members[member_id].is_alive = True
```

### 4. Distributed Transactions

```python
# Saga pattern for distributed transactions
class OrderSaga:
    def __init__(self):
        self.steps = [
            ReserveInventoryStep(),
            ProcessPaymentStep(),
            CreateShippingLabelStep(),
            NotifyCustomerStep()
        ]
    
    async def execute(self, order: Order) -> SagaResult:
        completed_steps = []
        
        for step in self.steps:
            try:
                await step.execute(order)
                completed_steps.append(step)
            except StepFailed as e:
                # Compensate completed steps
                for completed in reversed(completed_steps):
                    await completed.compensate(order)
                return SagaResult(success=False, error=str(e))
        
        return SagaResult(success=True)

class ReserveInventoryStep:
    async def execute(self, order: Order):
        await inventory_api.reserve(order.items)
    
    async def compensate(self, order: Order):
        await inventory_api.release(order.items)
```

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| Kubernetes | Container orchestration |
| etcd / Consul | Service discovery |
| Jaeger / Zipkin | Distributed tracing |
| Prometheus / Grafana | Metrics |
| Kafka / RabbitMQ | Message brokers |
| etcd / ZooKeeper | Consensus |
| Envoy / Istio | Service mesh |

## Failure Modes

- **Ignoring network fallacies** → assuming reliable networks, zero latency, infinite bandwidth → cascading failures during partitions → design for failure with timeouts, retries, and circuit breakers
- **Split-brain scenarios** → network partition causes multiple nodes to believe they are the leader → data corruption and inconsistency → implement proper consensus algorithms with quorum requirements
- **Clock skew causing ordering issues** → distributed nodes have different system times → events processed out of order → use logical clocks or hybrid logical timestamps for ordering
- **Resource exhaustion from unbounded queues** → backpressure not implemented → memory overflow and cascading OOM kills → use bounded queues with rejection policies and backpressure signals
- **Non-idempotent operations with retries** → network timeout triggers duplicate operations → double charges or duplicate records → design all operations to be idempotent with unique request IDs
- **Partial failures leaving system inconsistent** → some nodes succeed while others fail → data divergence across the cluster → implement saga pattern with compensating transactions
- **Missing observability in distributed flows** → cannot trace requests across nodes → impossible to debug production issues → implement distributed tracing with correlation IDs from the start

## Related Topics

- [[Microservices]] — Distributed services architecture
- [[EventArchitecture]] — Async communication
- [[EventSourcing]] — Persisting state as events
- [[CQRS]] — Command/Query separation in distributed systems
- [[Coupling]] — Managing dependencies between nodes
- [[Cohesion]] — Ensuring focused node responsibilities
- [[Modularity]] — Modular design across nodes
- [[Idempotency]] — Making operations safe to retry
- [[RateLimiting]] — Protecting nodes from overload
- [[Observability]] — Understanding distributed system state
- [[Monitoring]] — Detecting node failures
- [[Logging]] — Distributed log correlation
- [[ContractTesting]] — Verifying service interfaces
- [[ChaosEngineering]] — Testing distributed system resilience
- [[Concurrency]] — Concurrent operations across nodes
- [[Caching]] — Distributed cache strategies
- [[ServiceMesh]] — Managing service-to-service communication
- [[ContainerOrchestration]] — Deploying distributed systems

## Additional Notes

**Network is Reliable Myth:**
- Packets get lost
- Latency varies wildly
- Order not guaranteed
- Network partitions happen

**Fallacies of Distributed Computing:**
1. The network is reliable
2. Latency is zero
3. Bandwidth is infinite
4. The network is secure
5. Topology doesn't change
6. There is one administrator
7. Transport cost is zero
8. The network is homogeneous

**Monitoring Essentials:**
- Latency distributions (not just averages)
- Error rates
- Resource utilization
- Distributed trace analysis
- Dependency health

**Common Challenges:**
- Distributed transactions
- Data consistency
- Network latency
- Partial failures
- Debugging across services

## Key Takeaways

- Distributed systems are collections of independent computers that appear to users as a single coherent system, coordinating via message passing.
- Use when horizontal scaling beyond single-machine capacity, high availability, or geographic distribution is required.
- Do NOT use when simplicity matters more than scalability or when inter-component latency is critical.
- Key tradeoff: scalability and fault tolerance vs. inherent complexity of network failures, partial failures, and consistency challenges.
- Main failure mode: ignoring network fallacies leading to cascading failures from unhandled timeouts, retries, and partition events.
- Best practice: design for failure, embrace eventual consistency where possible, use idempotent operations, and implement full observability.
- Related concepts: CAP theorem, Saga Pattern, Circuit Breaker, Backpressure, Consensus algorithms (Raft/Paxos), Eventual Consistency.
