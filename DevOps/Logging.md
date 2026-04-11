---
title: Logging
title_pt: Logging (Registros)
layer: devops
type: practice
priority: medium
version: 1.0.0
tags:
  - DevOps
  - Logging
  - Observability
  - Practice
description: Practices for capturing and managing application logs.
description_pt: Práticas para capturar e gerenciar logs de aplicação.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Logging

## Description

Logging is the practice of recording events that occur during application execution. Logs provide a historical record of what happened, when, and in what context, making them essential for debugging, auditing, and understanding system behavior.

Effective logging requires balancing several concerns:
- **Detail level** - Not too verbose, not too sparse
- **Structured format** - JSON for machine parsing
- **Correlation** - Trace requests across services
- **Performance** - Logging shouldn't slow the app
- **Storage** - Log retention and rotation

Modern logging differs from traditional file-based logging:
- **Centralized** - All logs in one place (ELK, Loki)
- **Structured** - JSON with consistent fields
- **Correlated** - Trace IDs link related logs
- **Real-time** - Search and alerting on the fly

Key log fields:
- **Timestamp** - When it happened
- **Level** - DEBUG, INFO, WARN, ERROR, FATAL
- **Message** - What happened
- **Context** - Who, where, metadata
- **Trace ID** - For correlation

## Purpose

**When logging is essential:**
- For debugging production issues
- For audit trails
- For security monitoring
- For performance analysis

**What to log:**
- Errors and exceptions
- Key business events
- Security events
- Performance metrics

## Rules

1. **Use structured logging** - JSON format
2. **Include correlation IDs** - Trace across services
3. **Log appropriate levels** - Not too much, not too little
4. **Include context** - Who, what, where
5. **Don't log sensitive data** - PII, passwords, secrets
6. **Use semantic logging** - Business events, not technical
7. **Centralize logs** - One place for searching
8. **Plan retention** - How long to keep logs

## Examples

### Structured Logging

```python
# Python structured logging
import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno
        }
        
        # Add exception info if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
        
        # Add extra fields
        if hasattr(record, "user_id"):
            log_data["user_id"] = record.user_id
        if hasattr(record, "request_id"):
            log_data["request_id"] = record.request_id
        if hasattr(record, "extra"):
            log_data.update(record.extra)
        
        return json.dumps(log_data)

# Configure logger
logger = logging.getLogger("myapp")
logger.setLevel(logging.INFO)

handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)

# Usage
logger.info("User logged in", extra={"user_id": "123", "request_id": "abc"})

# Output:
# {"timestamp": "2024-01-15T10:30:00.000Z", "level": "INFO", "logger": "myapp", 
#  "message": "User logged in", "module": "app", "function": "login", 
#  "line": 42, "user_id": "123", "request_id": "abc"}
```

### Python with Context

```python
# Using contextvars for request tracking
import contextvars
from datetime import datetime
import logging
import json

request_id_var = contextvars.ContextVar('request_id', default='')
user_id_var = contextvars.ContextVar('user_id', default='')

class ContextFilter(logging.Filter):
    def filter(self, record):
        record.request_id = request_id_var.get()
        record.user_id = user_id_var.get()
        return True

# Logger configuration
logger = logging.getLogger("myapp")
logger.addFilter(ContextFilter())

# In request handler
def handle_request(request):
    request_id = generate_request_id()
    request_id_var.set(request_id)
    
    if request.user:
        user_id_var.set(request.user.id)
    
    try:
        process_request(request)
    except Exception as e:
        logger.error("Request failed", exc_info=True)
        raise
```

### Node.js Logging

```javascript
// Node.js with Winston
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'myapp' },
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Add request context
const childLogger = logger.child({
  requestId: req.headers['x-request-id'],
  userId: req.user?.id
});

// Usage
logger.info('Request processed', {
  method: req.method,
  path: req.path,
  duration: duration,
  statusCode: res.statusCode
});

logger.error('Database connection failed', {
  error: error.message,
  host: dbHost,
  database: dbName
});
```

### Logging Best Practices by Level

```python
# DEBUG - Detailed information for debugging
logger.debug("Entering function", extra={
    "function": "process_payment",
    "args": {"order_id": "123"},
    "state": "initial"
})

# INFO - General operational events
logger.info("Order placed", extra={
    "order_id": "123",
    "user_id": "456",
    "total": 99.99,
    "items_count": 3
})

# WARNING - Something unexpected but handled
logger.warning("Retry attempt", extra={
    "attempt": 2,
    "max_attempts": 3,
    "reason": "connection_timeout"
})

# ERROR - Error that affected one request
logger.error("Payment failed", extra={
    "order_id": "123",
    "error": str(e),
    "error_code": "PAYMENT_DECLINED"
})

# CRITICAL - System-level failure
logger.critical("Database connection lost", extra={
    "host": "db.example.com",
    "error": str(e)
})
```

### Log Correlation

```python
# Distributed tracing integration
import logging

class TracingFilter(logging.Filter):
    def filter(self, record):
        # Get trace ID from context
        trace_id = get_current_trace_id() or 'unknown'
        record.trace_id = trace_id
        
        # Add span ID if available
        span_id = get_current_span_id()
        if span_id:
            record.span_id = span_id
        
        return True

# In Flask/Express middleware
class RequestLoggingMiddleware:
    def __init__(self, app):
        self.app = app
    
    def __call__(self, environ, start_response):
        request_id = environ.get('HTTP_X_REQUEST_ID', generate_id())
        environ['REQUEST_ID'] = request_id
        
        start_time = time.time()
        
        def start_response(status, headers):
            duration = time.time() - start_time
            logging.info("Request completed", extra={
                "request_id": request_id,
                "method": environ['REQUEST_METHOD'],
                "path": environ['PATH_INFO'],
                "status": int(status.split()[0]),
                "duration_ms": int(duration * 1000)
            })
            return start_response(status, headers)
        
        return self.app(environ, start_response)
```

## Anti-Patterns

### 1. Logging Everything

```python
# BAD - Too verbose
for item in items:
    logger.debug(f"Processing item {item.id}")
    logger.debug(f"Item name: {item.name}")
    logger.debug(f"Item price: {item.price}")
    # ... more debug logs

# GOOD - Appropriate level
logger.info(f"Processing {len(items)} items")
```

### 2. Logging Sensitive Data

```python
# BAD - Never log this!
logger.info("User login", extra={
    "email": user.email,
    "password": password,  # NEVER!
    "credit_card": card_number  # NEVER!
})

# GOOD - Log safely
logger.info("User login attempt", extra={
    "user_id": user.id,
    "login_method": "password"
})
```

### 3. Non-Structured Logging

```python
# BAD - Hard to parse
logger.info(f"[{timestamp}] User {user_id} performed {action}")

# GOOD - Easy to query
logger.info("User performed action", extra={
    "timestamp": timestamp,
    "user_id": user_id,
    "action": action
})
```

## Failure Modes

- **Logging sensitive data** → PII/secrets exposed → compliance violations → implement log sanitization and allow-lists
- **Unstructured logging** → unparseable logs → slow debugging → enforce JSON structured logging with consistent schemas
- **Excessive log volume** → storage exhaustion → lost logs → set appropriate log levels and implement sampling for debug
- **Missing correlation IDs** → untraceable requests → impossible debugging → propagate trace IDs across all service boundaries
- **No log retention policy** → regulatory non-compliance → legal risk → define retention tiers by log level and data type
- **Synchronous logging I/O** → application slowdown → degraded performance → use async log writers with bounded buffers
- **Centralized logging outage** → no visibility during incidents → blind troubleshooting → implement local log buffering with backfill

## Best Practices

### Log Aggregation Stack

```yaml
# docker-compose.yml for ELK Stack
version: '3'

services:
  elasticsearch:
    image: elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  kibana:
    image: kibana:8.11.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch

  logstash:
    image: logstash:8.11.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    ports:
      - "5044:5044"
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:
```

### Log Shipping Configuration

```yaml
# Filebeat configuration
filebeat.inputs:
  - type: container
    paths:
      - /var/lib/docker/containers/*/*.log
    processors:
      - add_docker_metadata: ~
      - add_kubernetes_metadata: ~

output.logstash:
  hosts: ["logstash:5044"]

processors:
  - decode_json_fields:
      fields: ["message"]
      target: ""
```

## Technology Stack

| Tool | Use Case |
|------|----------|
| ELK Stack | Log aggregation |
| Loki | Log aggregation (Prometheus) |
| Splunk | Commercial logging |
| Datadog | Commercial logging |
| CloudWatch | AWS logging |
| Stackdriver | GCP logging |

## Related Topics

- [[Monitoring]]
- [[Alerting]]
- [[IncidentManagement]]
- [[Tracing]]
- [[SecurityHeaders]]
- [[Authentication]]
- [[TlsSsl]]
- [[CiCd]]

## Additional Notes

**Log Levels:**
- DEBUG: Detailed debug info
- INFO: General events
- WARNING: Unexpected but handled
- ERROR: Request-level failure
- CRITICAL: System-level failure

**Key Fields:**
- timestamp, level, message
- request_id, user_id
- service, host
- error details

**Retention:**
- Debug: 24-72 hours
- Info/Warn: 7-30 days
- Error: 30-90 days
- Audit: Years