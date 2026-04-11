---
title: Load Testing
title_pt: Teste de Carga
layer: performance
type: practice
priority: medium
version: 1.0.0
tags:
  - Performance
  - Load Testing
  - Testing
  - Practice
description: Testing application behavior under load.
description_pt: Testando comportamento da aplicação sob carga.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Load Testing

## Description

Load testing evaluates application performance under expected load conditions. It measures how the system behaves when multiple users or requests access it simultaneously, identifying bottlenecks before production.

Load testing differs from:
- **Unit testing** - Tests individual components
- **Integration testing** - Tests component interactions
- **Stress testing** - Tests beyond normal capacity
- **Soak testing** - Tests over extended period

Types of load testing:
- **Load testing** - Expected concurrent users
- **Stress testing** - Beyond expected load
- **Spike testing** - Sudden large increases
- **Endurance testing** - Sustained load over time

Key metrics measured:
- Response time
- Throughput (requests/second)
- Error rate
- Resource utilization

## Purpose

**When to perform load testing:**
- Before major releases
- When scaling infrastructure
- After significant changes
- To establish performance baselines

**What to test:**
- API endpoints
- Database operations
- Authentication flows
- Critical user paths

## Rules

1. **Test production-like environment** - Dev won't show real issues
2. **Use realistic data** - Production-like volumes
3. **Measure baseline first** - Know current performance
4. **Isolate variables** - Test one thing at a time
5. **Monitor infrastructure** - CPU, memory, network

## Examples

### k6 Load Test

```javascript
// k6-script.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');

export const options = {
  stages: [
    { duration: '2m', target: 100 },  // Ramp up
    { duration: '5m', target: 100 },  // Steady
    { duration: '2m', target: 200 },  // Spike
    { duration: '5m', target: 200 },  // Steady
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% under 500ms
    errors: ['rate<0.1'],                 // Less than 10% errors
    http_req_failed: ['rate<0.01'],      // Less than 1% failures
  },
};

const BASE_URL = 'https://api.example.com';
const TOKEN = __ENV.API_TOKEN;

export default function () {
  // Test 1: List users
  const usersRes = http.get(`${BASE_URL}/users`, {
    headers: { Authorization: `Bearer ${TOKEN}` },
  });
  check(usersRes, {
    'users status 200': (r) => r.status === 200,
  }) || errorRate.add(1);
  responseTime.add(usersRes.timings.duration);
  
  // Test 2: Get user details
  const userRes = http.get(`${BASE_URL}/users/123`, {
    headers: { Authorization: `Bearer ${TOKEN}` },
  });
  check(userRes, {
    'user status 200': (r) => r.status === 200,
  }) || errorRate.add(1);
  
  // Test 3: Create order
  const orderRes = http.post(
    `${BASE_URL}/orders`,
    JSON.stringify({
      product_id: 'prod_123',
      quantity: 2,
    }),
    {
      headers: {
        Authorization: `Bearer ${TOKEN}`,
        'Content-Type': 'application/json',
      },
    }
  );
  check(orderRes, {
    'order created': (r) => r.status === 201,
  }) || errorRate.add(1);
  
  sleep(1);
}

// Run with: k6 run k6-script.js
// Or with custom threshold: k6 run --threshold http_req_duration=p(95)<500 k6-script.js
```

### Locust Load Test

```python
# locustfile.py
from locust import HttpUser, task, between, events
import random

class WebsiteUser(HttpUser):
    wait_time = between(1, 3)
    
    def on_start(self):
        # Login before starting
        response = self.client.post('/api/login', json={
            'username': 'testuser',
            'password': 'testpass'
        })
        if response.status_code == 200:
            self.token = response.json()['token']
        else:
            self.token = None
    
    @task(3)  # 3x more likely than other tasks
    def view_products(self):
        if self.token:
            self.client.get(
                '/api/products',
                headers={'Authorization': f'Bearer {self.token}'}
            )
    
    @task(2)
    def view_product_detail(self):
        if self.token:
            product_id = random.randint(1, 100)
            self.client.get(
                f'/api/products/{product_id}',
                headers={'Authorization': f'Bearer {self.token}'}
            )
    
    @task(1)
    def add_to_cart(self):
        if self.token:
            self.client.post(
                '/api/cart',
                json={'product_id': random.randint(1, 100), 'quantity': 1},
                headers={'Authorization': f'Bearer {self.token}'}
            )
    
    @task(1)
    def checkout(self):
        if self.token:
            self.client.post(
                '/api/checkout',
                json={'payment_method': 'credit_card'},
                headers={'Authorization': f'Bearer {self.token}'}
            )

# Run with: locust -f locustfile.py --host=https://api.example.com
# Then open http://localhost:8089
```

### Artillery Test

```yaml
# artillery-config.yml
config:
  target: "https://api.example.com"
  phases:
    - duration: 120
      arrivalRate: 5
      name: "Warm up"
    - duration: 300
      arrivalRate: 20
      name: "Sustained load"
    - duration: 60
      arrivalRate: 50
      name: "Stress test"
  
  plugins:
    expect: {}
  
  defaults:
    - headers:
        Authorization: "Bearer {{ $env.API_TOKEN }}"

scenarios:
  - name: "User flow"
    flow:
      - get:
          url: "/api/users"
          capture:
            - json: "$.users[0].id"
              as: "userId"
      
      - get:
          url: "/api/users/{{ userId }}"
      
      - post:
          url: "/api/orders"
          json:
            product_id: "prod_123"
            quantity: 1
      
      - get:
          url: "/api/orders"
```

### JMeter Test Plan

```xml
<!-- test-plan.xml -->
<jmeterTestPlan>
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan">
      <stringProp name="TestPlan.comments">Load test plan</stringProp>
      <boolProp name="TestPlan.functional_mode">false</boolProp>
      <boolProp name="TestPlan.serialize_threadgroups">true</boolProp>
      <stringProp name="TestPlan.user_define_classpath"></stringProp>
    </TestPlan>
    
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup">
        <stringProp name="ThreadGroup.num_threads">100</stringProp>
        <stringProp name="ThreadGroup.ramp_time">60</stringProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
      </ThreadGroup>
      
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy">
          <stringProp name="HTTPSampler.domain">api.example.com</stringProp>
          <stringProp name="HTTPSampler.protocol">https</stringProp>
          <stringProp name="HTTPSampler.path">/api/users</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
        </HTTPSamplerProxy>
      </hashTree>
      
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy">
          <stringProp name="HTTPSampler.domain">api.example.com</stringProp>
          <stringProp name="HTTPSampler.protocol">https</stringProp>
          <stringProp name="HTTPSampler.path">/api/orders</stringProp>
          <stringProp name="HTTPSampler.method">POST</stringProp>
          <elementProp name="HTTPsampler.Arguments" guiclass="HTTPArgumentsPanel" testclass="Arguments">
            <collectionProp name="Arguments.arguments">
              <elementProp name="" guiclass="HTTPArgument">
                <stringProp name="Argument.value">{"product_id":"123"}</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
            </collectionProp>
          </elementProp>
        </HTTPSamplerProxy>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
```

## Anti-Patterns

### 1. Testing Without Baseline

```yaml
# BAD - Can't measure improvement
load_test()  # Just runs, no baseline

# GOOD - Establish baseline first
baseline = measure_baseline()
load_test()
improvement = compare(baseline, current)
```

### 2. Testing Dev Environment

```yaml
# BAD - Dev won't show production issues
target: http://dev-api.example.com

# GOOD - Production-like environment
target: https://staging-api.example.com
```

## Failure Modes

- **Testing without baseline** → cannot measure improvement → unknown performance impact → establish baseline metrics before load testing
- **Testing dev environment** → results don't reflect production → false confidence → test against production-like infrastructure and data
- **Unrealistic load patterns** → wrong bottlenecks found → missed production issues → model real user behavior with think times and varied flows
- **No monitoring during test** → cannot identify bottleneck root cause → blind to failure source → monitor CPU, memory, DB, and network during tests
- **Ignoring error rates** → high throughput masks failures → degraded user experience → track error rates alongside response times
- **Single-point load generator** → generator becomes bottleneck → inaccurate results → distribute load generation across multiple machines
- **Not testing failure scenarios** → system behavior unknown under stress → unexpected outages → test degradation, recovery, and circuit breaker behavior

## Best Practices

### Metrics to Track

```javascript
// Key metrics to collect
const metrics = {
  // Response time
  p50_response_time: 0,
  p95_response_time: 0,
  p99_response_time: 0,
  
  // Throughput
  requests_per_second: 0,
  
  // Error rates
  error_rate: 0,
  timeout_rate: 0,
  
  // Resources
  cpu_usage: 0,
  memory_usage: 0,
  db_connections: 0,
};
```

## Technology Stack

| Tool | Use Case |
|------|----------|
| k6 | Modern load testing |
| Locust | Python-based |
| Artillery | Node.js |
| JMeter | Enterprise Java |
| Gatling | Scala-based |

## Related Topics

- [[PerformanceProfiling]]
- [[Monitoring]]
- [[PerformanceOptimization]]
- [[ChaosEngineering]]
- [[CiCd]]
- [[Alerting]]
- [[Caching]]
- [[DatabaseOptimization]]

## Additional Notes

**Load Test Types:**
- Load: Expected concurrent users
- Stress: Beyond capacity
- Spike: Sudden increases
- Endurance: Long duration

**Key Metrics:**
- Response time (p50, p95, p99)
- Throughput
- Error rate
- Resource utilization

**Test Environment:**
- Match production
- Realistic data
- Isolate from users