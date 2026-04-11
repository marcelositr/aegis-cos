---
title: Observability
title_pt: Observabilidade
layer: devops
type: concept
priority: high
version: 1.0.0
tags:
  - DevOps
  - Observability
  - Monitoring
  - Tracing
  - Metrics
  - Logs
description: Ability to understand system internal state from external outputs.
description_pt: Capacidade de entender estado interno do sistema a partir de saídas externas.
prerequisites:
  - DevOps
  - Monitoring
estimated_read_time: 15 min
difficulty: intermediate
---

# Observability

## Description

[[Observability]] is the ability to understand a system's internal state by examining its external outputs. Unlike traditional [[Monitoring]] (checking if something is broken), observability helps understand *why* something is broken and how the system behaves in production.

The three pillars of observability are:

1. **Metrics** - Numerical data measured over time (counters, gauges, histograms)
2. **Logs** - Timestamped event records describing what happened
3. **Traces** - Request flow showing how work moves through distributed systems

Observability enables:
- Debugging production issues without reproduction
- Understanding system behavior under load
- Detecting anomalies before they cause outages
- Making data-driven capacity decisions

## Purpose

**When observability is essential:**
- Distributed systems with multiple services
- Microservices architectures
- Cloud-native applications
- Systems requiring high reliability
- Troubleshooting intermittent issues
- Understanding user behavior

**When simpler monitoring may suffice:**
- Single monolithic applications
- Low-traffic internal tools
- Systems with well-understood failure modes
- Early-stage startups with limited resources

**The key question:** When something goes wrong in production, can you understand why without having to reproduce it locally?

## Rules

1. **Emit structured data** - JSON logs, trace contexts, metric labels
2. **Correlate across pillars** - Link logs to traces to metrics
3. **Instrument early** - Add observability from the start, not after
4. **Sample strategically** - Not every request needs full tracing
5. **Respect data costs** - Storage and ingestion have costs

## Examples

### Metrics (Prometheus)

```python
from prometheus_client import Counter, Gauge, Histogram

# Counters - always increasing
http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'status', 'endpoint']
)

# Gauges - current value
active_connections = Gauge(
    'active_connections',
    'Number of active connections',
    ['service']
)

# Histograms - distribution
request_duration = Histogram(
    'request_duration_seconds',
    'Request duration in seconds',
    ['endpoint'],
    buckets=[0.01, 0.05, 0.1, 0.5, 1.0, 5.0]
)

# Usage
def handle_request(request):
    start = time.time()
    try:
        result = process_request(request)
        http_requests_total.labels(method='GET', status='200', endpoint='/api').inc()
        return result
    except Exception as e:
        http_requests_total.labels(method='GET', status='500', endpoint='/api').inc()
        raise
    finally:
        request_duration.labels(endpoint='/api').observe(time.time() - start)
```

### Structured Logging

```python
import structlog
import logging

# Configure structured logging
logging.basicConfig(format="%(message)s")
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Structured logging with context
def process_order(order_id, user_id):
    logger.info("order_processing_started",
                order_id=order_id,
                user_id=user_id,
                source="checkout_service")
    
    try:
        result = validate_and_process(order_id)
        logger.info("order_processing_completed",
                    order_id=order_id,
                    duration_ms=result.duration)
        return result
    except Exception as e:
        logger.error("order_processing_failed",
                     order_id=order_id,
                     error=str(e),
                     error_type=type(e).__name__,
                     exc_info=True)
        raise
```

### Distributed Tracing (OpenTelemetry)

```python
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.trace import Status, StatusCode

# Configure tracing
trace.set_tracer_provider(TracerProvider())
jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",
    agent_port=6831,
)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

tracer = trace.get_tracer(__name__)

# Trace a request across services
def handle_user_request(request_id, user_id):
    with tracer.start_as_current_span("handle_request") as span:
        span.set_attribute("request.id", request_id)
        span.set_attribute("user.id", user_id)
        
        # Call downstream service
        with tracer.start_as_current_span("call_user_service") as child:
            child.set_attribute("service.name", "user-service")
            user = fetch_user(user_id)
            child.add_event("user_fetched", {"user_id": user.id})
        
        # Call another service
        with tracer.start_as_current_span("call_order_service") as child:
            child.set_attribute("service.name", "order-service")
            orders = fetch_orders(user.id)
            
            if not orders:
                span.set_status(Status(StatusCode.WARNING))
                span.add_event("no_orders_found")
        
        return {"user": user, "orders": orders}
```

### Correlation Across Pillars

```python
# Connecting logs, metrics, and traces
def process_payment(payment_id):
    trace_id = get_current_trace_id()
    
    logger.info("payment_started",
                payment_id=payment_id,
                trace_id=trace_id)  # Link to trace
    
    try:
        result = process(payment_id)
        
        # Emit metric
        payment_duration.observe(time.time() - start)
        payments_success.inc()
        
        logger.info("payment_completed",
                    payment_id=payment_id,
                    trace_id=trace_id,
                    result=result.id)
        
    except InsufficientFunds as e:
        payments_failed_by_type.labels(type='insufficient_funds').inc()
        logger.warning("payment_failed",
                      payment_id=payment_id,
                      trace_id=trace_id,
                      reason=str(e))
        
    except Exception as e:
        payments_failed.inc()
        logger.error("payment_error",
                     payment_id=payment_id,
                     trace_id=trace_id,
                     error=str(e))
        raise
```

## Anti-Patterns

### 1. No Context in Logs

```python
# BAD - Missing context
logger.info("Processing order")
logger.error("Order failed")

# GOOD - Rich context
logger.info("order_processing_started",
            order_id=order.id,
            user_id=user.id,
            amount=amount,
            trace_id=trace_id)
```

### 2. Sampling Everything

```python
# BAD - No sampling, high cost
tracer.start_as_current_span("handle_request")  # All requests!

# GOOD - Intelligent sampling
def should_sample():
    # Sample 1% normally, 100% on errors
    return random.random() < 0.01 or last_error_count > 0

if should_sample():
    with tracer.start_as_current_span("handle_request") as span:
        # ... span content
```

### 3. Metrics Without Labels

```python
# BAD - No granularity
request_count = Counter("requests")  # Can't filter!

# GOOD - Rich labels
request_count = Counter("requests",
                        ['method', 'status', 'endpoint', 'region'])
```

### 4. Missing Error Context

```python
# BAD - No useful error info
except Exception as e:
    logger.error("failed", error=str(e))

# GOOD - Full context
except PaymentError as e:
    logger.error("payment_failed",
                  error_type=type(e).__name__,
                  error_code=e.code,
                  user_id=user.id,
                  amount=amount,
                  retryable=e.retryable)
```

## Best Practices

### 1. Use Open Standards

```yaml
# OpenTelemetry - vendor-neutral
traces:
  exporters:
    - otlp
    - jaeger
metrics:
  exporters:
    - prometheus
    - otlp
```

### 2. Standardize Attributes

```python
# Consistent naming across services
STANDARD_ATTRIBUTES = {
    'service.name': 'checkout-service',
    'service.version': '1.2.3',
    'deployment.environment': 'production',
    'cloud.region': 'us-east-1',
}
```

### 3. Budget for Observability

```python
# Calculate observability costs
OBSERVABILITY_BUDGET = """
- Logs: ~$0.50/GB, keep 7 days = ~$3.50/week per service
- Metrics: ~$0.10/series/month, 1000 series = $100/month
- Traces: ~$0.10/GB, 10GB/week = ~$40/week

Total per service: ~$600/month
10 services = ~$6000/month
"""
```

### 4. Create Dashboards That Help

```
# Alert-focused dashboard
- Error rate by service (should be < 0.1%)
- P99 latency by endpoint
- Active connections
- Queue depth

# Debugging dashboard  
- Recent errors with trace links
- Request distribution by status
- Service dependency health
```

## Failure Modes

- **Unstructured logs without context** → logs missing trace IDs, user IDs, or request context → impossible to correlate events across services → emit structured JSON logs with consistent context fields
- **Sampling everything or nothing** → no sampling strategy leads to budget explosion or blind spots → implement intelligent sampling with higher rates for errors and rare events
- **Metrics without labels** → counters without method, status, or endpoint labels → cannot filter or aggregate meaningfully → add rich labels to metrics for actionable filtering and alerting
- **Missing error context in logs** → error logged without request details or stack trace → cannot diagnose production issues → include full error context, stack traces, and request metadata in error logs
- **Observability not budgeted** → no cost planning for logs, metrics, and traces → unexpected cloud bills → calculate observability costs per service and set retention policies aligned with budget
- **No correlation across pillars** → logs, metrics, and traces not linked → debugging requires switching between tools → use trace IDs in logs and link metrics to trace spans for unified debugging
- **Instrumenting after problems occur** → observability added reactively → cannot debug issues that already happened → instrument from day one with standard attributes and distributed tracing

## Related Topics

- [[Monitoring]] — Monitoring fundamentals
- [[Logging]] — Logging best practices
- [[Alerting]] — Alert configuration
- [[PerformanceProfiling]] — Profiling application performance
- [[PerformanceOptimization]] — Using observability data for optimization
- [[IncidentManagement]] — Responding to observability alerts
- [[ChaosEngineering]] — Proactively testing observability
- [[DistributedSystems]] — Observability across distributed nodes
- [[Microservices]] — Observability for service meshes
- [[ContainerOrchestration]] — Observability in containerized environments
- [[ServiceMesh]] — Built-in observability features
- [[CiCd]] — Observability as deployment gate

## Additional Notes

**Tools:**
- Metrics: Prometheus, Datadog, CloudWatch
- Logs: ELK, Loki, CloudWatch Logs
- Traces: Jaeger, Zipkin, DataDog, Tempo

**OpenTelemetry:**
- Vendor-neutral standard
- Supports metrics, traces, logs
- Auto-instrumentation for many frameworks

**Costs:**
- Ingress: ~$0.10-0.50/GB
- Storage: ~$0.02-0.10/GB/month
- Adjust retention to match needs

## Key Takeaways

- Observability is the ability to understand a system's internal state by examining its external outputs: metrics, logs, and traces.
- Use in distributed systems, microservices architectures, cloud-native applications, and when debugging production issues without local reproduction.
- Do NOT use for single monolithic applications, low-traffic internal tools, or systems with well-understood failure modes where simple monitoring suffices.
- Key tradeoff: deep debugging capability and proactive anomaly detection vs. significant storage/ingestion costs and instrumentation overhead.
- Main failure mode: unstructured logs without context, missing trace correlation, or sampling everything leading to unusable data and budget explosion.
- Best practice: emit structured data, correlate across all three pillars, instrument from the start, sample strategically, and budget for observability costs.
- Related concepts: Monitoring, Distributed Tracing, Structured Logging, OpenTelemetry, Alerting, SRE, Chaos Engineering.