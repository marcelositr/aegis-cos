---
title: Monitoring
title_pt: Monitoramento
layer: devops
type: practice
priority: high
version: 1.0.0
tags:
  - DevOps
  - Monitoring
  - Observability
  - Practice
description: Systems and practices for tracking application health and performance.
description_pt: Sistemas e práticas para acompanhar a saúde e desempenho da aplicação.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Monitoring

## Description

Monitoring is the practice of collecting, analyzing, and acting on metrics from your systems and applications. It provides visibility into system behavior, helps detect issues before they impact users, and enables data-driven decision making.

Modern monitoring consists of three pillars:
1. **Metrics** - Numeric measurements over time (Prometheus, Datadog)
2. **Logs** - Timestamped event records (ELK, Loki)
3. **Traces** - Request flow through systems (Jaeger, Zipkin)

Together, these form the foundation of observability - the ability to understand system internal states from external outputs.

Key monitoring concepts:
- **Dashboards** - Visual representations of metrics
- **Alerts** - Notifications when thresholds are breached
- **SLI/SLO/SLA** - Service Level Indicators/Objectives/Agreements
- **Golden Signals** - Key metrics for system health

Effective monitoring enables:
- Proactive issue detection
- Faster troubleshooting
- Capacity planning
- Performance optimization

## Purpose

**When monitoring is essential:**
- In production systems
- For SLA compliance
- For troubleshooting
- For capacity planning

**What to monitor:**
- Application metrics
- Infrastructure metrics
- Business metrics
- Security events

## Rules

1. **Monitor the golden signals** - Latency, traffic, errors, saturation
2. **Use appropriate levels** - Infrastructure, application, business
3. **Create useful dashboards** - Actionable, not just data
4. **Set meaningful alerts** - Actionable, not noisy
5. **Track SLAs** - Measure what matters
6. **Alert on symptoms, not causes** - Focus on user impact

## Examples

### Prometheus + Grafana Setup

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

rule_files:
  - 'alerts/*.yml'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true

  - job_name: 'app-metrics'
    static_configs:
      - targets: ['app:9090']
    metrics_path: '/metrics'
```

### Application Metrics

```python
# Python metrics with Prometheus
from prometheus_client import Counter, Histogram, Gauge, generate_latest
import time
import random

# Request counter
http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

# Request duration histogram
http_request_duration_seconds = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint'],
    buckets=(0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0)
)

# Active connections gauge
active_connections = Gauge(
    'active_connections',
    'Number of active connections'
)

# Database connection pool
db_pool_size = Gauge(
    'db_pool_size',
    'Database connection pool size',
    ['db']
)

db_pool_available = Gauge(
    'db_pool_available',
    'Available connections in pool',
    ['db']
)

# Example usage in Flask
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/users/<user_id>')
def get_user(user_id):
    start_time = time.time()
    
    try:
        user = get_user_from_db(user_id)
        
        http_requests_total.labels(
            method='GET',
            endpoint='/api/users/<id>',
            status='200'
        ).inc()
        
        return jsonify(user)
        
    except Exception as e:
        http_requests_total.labels(
            method='GET',
            endpoint='/api/users/<id>',
            status='500'
        ).inc()
        raise
        
    finally:
        http_request_duration_seconds.labels(
            method='GET',
            endpoint='/api/users/<id>'
        ).observe(time.time() - start_time)

@app.route('/metrics')
def metrics():
    return generate_latest()

# Middleware for active connections
@app.before_request
def before_request():
    g.start_time = time.time()
    active_connections.inc()

@app.after_request
def after_request(response):
    active_connections.dec()
    return response
```

### Alert Rules

```yaml
# alerts/app-alerts.yml
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) 
          / 
          sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }} (threshold: 5%)"
          
      - alert: HighLatency
        expr: |
          histogram_quantile(0.95, 
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint)
          ) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High p95 latency"
          description: "p95 latency for {{ $labels.endpoint }} is {{ $value }}s"
          
      - alert: DatabaseConnectionPoolExhausted
        expr: db_pool_available / db_pool_size < 0.1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Database pool nearly exhausted"
          description: "{{ $labels.db }} has only {{ $value | humanizePercentage }} available"
          
      - alert: ServiceDown
        expr: up{job="app-metrics"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "Service {{ $labels.instance }} has been down for 1 minute"
```

### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "Application Overview",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (method)",
            "legendFormat": "{{ method }}"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~'5..'}[5m])) / sum(rate(http_requests_total[5m]))",
            "format": "percentunit"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {"value": 0, "color": "green"},
                {"value": 0.01, "color": "yellow"},
                {"value": 0.05, "color": "red"}
              ]
            }
          }
        }
      },
      {
        "title": "p95 Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
            "legendFormat": "p95"
          },
          {
            "expr": "histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
            "legendFormat": "p50"
          }
        ]
      }
    ]
  }
}
```

### Distributed Tracing

```python
# OpenTelemetry instrumentation
from opentelemetry import trace
from opentelemetry.exporter.jaeger import JaegerSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Configure tracing
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Configure exporter
exporter = JaegerSpanExporter(
    service_name="myapp",
    agent_host_name="jaeger",
    agent_port=6831,
)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(exporter)
)

# Use in code
def process_order(order_id):
    with tracer.start_as_current_span("process_order") as span:
        span.set_attribute("order.id", order_id)
        
        # Validate order
        with tracer.start_as_current_span("validate_order") as validate_span:
            validate_order(order_id)
        
        # Process payment
        with tracer.start_as_current_span("process_payment") as payment_span:
            result = process_payment(order_id)
            payment_span.set_attribute("payment.result", result)
        
        # Ship order
        with tracer.start_as_current_span("ship_order") as ship_span:
            ship_order(order_id)
        
        return result
```

## Anti-Patterns

### 1. Alerting on Everything

**Bad:**
- Alerting on every metric
- Low thresholds causing noise

**Solution:**
- Alert on actionable items
- Set meaningful thresholds
- Use severity levels

### 2. Dashboards Without Action

**Bad:**
- Showing raw data
- No context or thresholds

**Solution:**
- Focus on decision-making
- Add thresholds and comparisons
- Make it scannable

### 3. No Error Tracking

**Bad:**
- Only tracking metrics
- Missing error details

**Solution:**
- Integrate error tracking
- Include stack traces
- Track error rates

## Failure Modes

- **Alerting on everything** → alert fatigue → critical alerts ignored → alert only on actionable, user-impacting symptoms
- **Missing error tracking** → silent failures accumulate → unnoticed degradation → integrate error tracking with alerting
- **Dashboard without context** → raw data without meaning → slow incident response → add thresholds, baselines, and annotations
- **No monitoring coverage gaps** → blind spots in system → undetected failures → map all critical paths and ensure coverage
- **Stale dashboards** → outdated metrics → wrong decisions → automate dashboard updates and review relevance regularly
- **Incorrect threshold tuning** → false positives/negatives → wasted time or missed incidents → use percentile-based thresholds
- **Single monitoring tool dependency** → tool outage → zero visibility → implement redundant monitoring for critical signals

## Best Practices

### SLI Selection

```yaml
# Key SLIs for different services
web_service:
  - availability: requests_successful / requests_total
  - latency: request_duration_p95
  - quality: errors / requests

data_service:
  - availability: queries_successful / queries_total
  - latency: query_duration_p99
  - freshness: data_age

streaming_service:
  - availability: messages_processed / messages_received
  - latency: processing_duration_p99
  - quality: failed_messages / total_messages
```

### On-Call Best Practices

```yaml
# Runbook structure
runbooks:
  - alert: HighErrorRate
    steps:
      1. Check error logs in Kibana for recent errors
      2. Identify if error is in new deployment
      3. Check if external service is down
      4. Roll back if related to deployment
      5. Page incident lead if unresolved
    escalation:
      - 15 min: On-call engineer
      - 30 min: Engineering lead
      - 1 hour: Engineering manager
```

## Technology Stack

| Tool | Type | Use Case |
|------|------|----------|
| Prometheus | Metrics | Time series |
| Grafana | Visualization | Dashboards |
| ELK Stack | Logs | Log aggregation |
| Loki | Logs | Log aggregation |
| Jaeger | Traces | Distributed tracing |
| Datadog | All-in-one | Commercial monitoring |

## Related Topics

- [[Logging]]
- [[Alerting]]
- [[IncidentManagement]]
- [[CiCd]]
- [[Kubernetes]]
- [[PerformanceProfiling]]
- [[LoadTesting]]
- [[ChaosEngineering]]

## Additional Notes

**Golden Signals:**
- Latency
- Traffic
- Errors
- Saturation

**SLI/SLO/SLA:**
- SLI: Measurement (e.g., 99.9% availability)
- SLO: Target (e.g., 99.9% availability)
- SLA: Commitment (e.g., 99.9% availability guarantee)

**Alert Best Practices:**
- Actionable
- Timely
- Contextual
- Prioritized