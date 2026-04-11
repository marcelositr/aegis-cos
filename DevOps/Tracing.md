---
title: Distributed Tracing
title_pt: Rastreamento Distribuído
layer: devops
type: concept
priority: critical
version: 1.0.0
tags:
  - DevOps
  - Observability
  - Tracing
description: Tracking requests as they flow through distributed services to understand latency and failure paths.
description_pt: Rastreando requisições através de serviços distribuídos para entender latência e caminhos de falha.
prerequisites:
  - Observability
  - Microservices
estimated_read_time: 15 min
difficulty: advanced
---

# Distributed Tracing

## Description

[[DistributedTracing]] tracks individual requests across service boundaries, enabling you to understand the full path a request takes through your system. Each request creates a "trace" composed of "spans" representing each service or operation involved.

Key concepts:
- **Trace** — Complete end-to-end journey of a request
- **Span** — Single operation within a trace (service call, DB query, etc.)
- **Span Context** — Trace ID and span ID passed between services
- **Parent-Child** — Hierarchical relationship between spans

## Purpose

**When distributed tracing is essential:**
- Debugging production issues in microservices
- Understanding latency bottlenecks across services
- Identifying which service causes slow requests
- Analyzing error propagation paths
- Capacity planning and performance tuning

**When simpler approaches work:**
- Single monolithic application
- Low number of services (2-3)
- Issues that can be reproduced locally
- Performance issues at database level only

**The key question:** When a request fails or is slow, can you quickly identify which service and operation is responsible?

## Core Concepts

### Trace Structure

```
Trace: abc123 (user request to complete checkout)
│
├── Span: api-gateway (45ms)
│   │
│   └── Span: checkout-service (30ms)
│       │
│       ├── Span: inventory-service call (10ms)
│       │
│       ├── Span: payment-service call (15ms)
│       │   │
│       │   └── Span: stripe-api (12ms)
│       │
│       └── Span: database query (5ms)
│
└── Span: response-time (45ms)
```

### Trace Context Propagation

```python
# Propagating trace context via HTTP headers
from opentelemetry import trace

def call_downstream_service(url, span_context):
    headers = {
        'traceparent': f'00-{span_context.trace_id}-{span_context.span_id}-01',
        'tracestate': 'vendor=aws,congestion=low'
    }
    return requests.get(url, headers=headers)

# Extracting trace context from incoming request
def handle_request(request):
    context = extract_trace_context(request.headers)
    with tracer.start_as_current_span("handle", context=context) as span:
        # Process request
        pass
```

## Failure Modes

- **Missing trace context propagation** → trace breaks at service boundary → can't see full path → always inject/extract trace headers
- **High cardinality span names** → explosion of metrics → billing spike → use low-cardinality names: "db.query" not "db.query.users.select"
- **Sampling too aggressively** → rare errors never captured → sample 100% on errors
- **Trace context corruption** → invalid headers crash processing → validate and sanitize incoming context
- **Performance overhead** → tracing adds latency → use async export, sampling
- **Storage costs** → traces consume significant storage → configure retention, sample appropriately
- **Incomplete instrumentation** → some services not traced → blind spots → instrument all services consistently

## Anti-Patterns

### 1. No Context Propagation

**Bad:** Each service starts new trace
```python
# Trace lost at each service
def handle_request(request):
    with tracer.start_as_new_span("process"):  # New trace!
        process(request)
```

**Good:** Extract and use incoming context
```python
# Continue existing trace
def handle_request(request):
    context = extract_context(request.headers)
    with tracer.start_as_current_span("process", context=context):
        process(request)
```

### 2. Too Many Spans

**Bad:** Span for every tiny operation
```python
# Too granular - noise
with tracer.start_as_current_span("process"):
    for item in items:
        with tracer.start_as_current_span("process_item"):  # Too much!
            process(item)
```

**Good:** Meaningful spans
```python
# Appropriate granularity
with tracer.start_as_current_span("process_items"):
    for item in items:
        process(item)  # No span per item
```

### 3. Storing Sensitive Data in Spans

**Bad:** PII in trace context
```python
span.set_attribute("user_email", user.email)  # GDPR violation!
span.set_attribute("password", password)  # Security risk!
```

**Good:** Only non-sensitive identifiers
```span
span.set_attribute("user_id", user.id)  # Safe
span.set_attribute("order_id", order.id)  # Safe
```

## Best Practices

### 1. Use OpenTelemetry

```yaml
# Vendor-neutral instrumentation
opentelemetry:
  service:
    name: checkout-service
  trace:
    exporter:
      otlp:
        endpoint: collector:4317
    propagate:
      inject:
        - tracecontext
        - baggage
```

### 2. Name Spans Meaningfully

```python
# Good: operation-oriented names
span.name = "db.query"
span.name = "http.get"
span.name = "process.checkout"

# Bad: endpoint-oriented names
span.name = "GET /api/users"  # Changes with code!
```

### 3. Add Relevant Attributes

```python
# Useful for debugging
span.set_attribute("db.statement", "SELECT * FROM orders")  # For slow queries
span.set_attribute("http.method", "POST")
span.set_attribute("http.url", "/checkout")
span.set_attribute("error.type", type(e).__name__)  # For errors
```

### 4. Use Semantic Conventions

```python
# Standard attribute names
from opentelemetry import trace, attributes

span.set_attribute(trace.SpanAttributes.DB_SYSTEM, "postgresql")
span.set_attribute(trace.SpanAttributes.DB_STATEMENT, query)
span.set_attribute(trace.SpanAttributes.HTTP_METHOD, "GET")
span.set_attribute(trace.SpanAttributes.HTTP_URL, url)
```

## Technology Stack

| Tool | Type | Use Case |
|------|------|----------|
| Jaeger | Storage/UI | Open source tracing |
| Zipkin | Storage/UI | Twitter's tracing system |
| Tempo | Storage | Grafana's tracing backend |
| Datadog | SaaS | Full APM |
| AWS X-Ray | SaaS | AWS-native |
| OpenTelemetry | SDK | Vendor-neutral instrumentation |

## Related Topics

- [[Observability]] — Tracing as third pillar
- [[Microservices]] — Tracing across services
- [[Logging]] — Structured logs linked to traces
- [[Monitoring]] — Metrics from traces
- [[IncidentManagement]] — Debugging with traces

## Key Takeaways

- Distributed tracing tracks requests end-to-end across service boundaries
- Each trace consists of spans in parent-child relationship
- Always propagate trace context via HTTP headers
- Use OpenTelemetry for vendor-neutral instrumentation
- Span names should be operation-oriented, not endpoint-oriented
- Avoid high cardinality attributes and sensitive data in traces
- Sample 100% of errors, use head-based or tail-based sampling for production
