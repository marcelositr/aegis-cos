---
title: CDN
title_pt: CDN (Content Delivery Network)
layer: network
type: concept
priority: medium
version: 1.0.0
tags:
  - Network
  - CDN
  - Performance
description: Content Delivery Networks for edge caching and global distribution.
description_pt: Redes de entrega de conteúdo para cache edge e distribuição global.
prerequisites:
  - Network
  - PerformanceOptimization
estimated_read_time: 10 min
difficulty: intermediate
---

# CDN

## Description

A [[CDN]] (Content Delivery Network) distributes content across geographically dispersed servers, serving users from the closest edge location to reduce latency.

Key concepts:
- **Edge locations** — Global server points of presence
- **Origin** — Your primary server where content is stored
- **Caching** — Storing content at edge
- **TTL** — Time to live for cached content

## Purpose

**When CDN is essential:**
- Global audience with varying latency needs
- Static assets (images, JS, CSS, videos)
- High traffic websites
- Reducing origin load

**When CDN may not help:**
- Highly dynamic content
- Localized audience
- Very low traffic
- Real-time data

**The key question:** Does your content change less frequently than it's accessed?

## CDN Configuration

### Basic Setup

```yaml
# CDN configuration
cdn:
  provider: cloudflare  # or cloudfront, fastly
  
  origin:
    host: api.example.com
    backup: backup.example.com
  
  caching:
    static:
      - "*.js"
      - "*.css"
      - "*.jpg"
      - "*.png"
      ttl: 86400  # 1 day
    
    dynamic:
      - "/api/*"
      ttl: 0  # Don't cache
    
    api:
      - "/api/users/*"
      ttl: 300  # 5 min
    
  rules:
    - path: "/api/*"
      bypass_cache: true
    - path: "/admin/*"
      deny: true
```

### Cache Invalidation

```python
# Purge CDN cache
def invalidate_cdn(paths):
    # CloudFlare API
    response = requests.post(
        "https://api.cloudflare.com/client/v4/zones/zone_id/purge_cache",
        headers={"Authorization": f"Bearer {api_token}"},
        json={"files": paths}
    )
    return response.json()
```

## Failure Modes

- **Stale content served** → Cache not invalidated → users see old content → implement proper invalidation
- **Origin shield failure** → Single origin point → global outage → use origin failover
- **Cache misses** → High origin load → slow responses → warm cache for popular content

## Anti-Patterns

### 1. Caching Dynamic Content

**Bad:** CDN caches personalized data
```python
# User sees another user's data!
response.headers["Cache-Control"] = "public, max-age=3600"
```

**Good:** Proper cache headers
```python
# Private for user-specific content
response.headers["Cache-Control"] = "private, no-cache"

# Public for static assets
response.headers["Cache-Control"] = "public, max-age=86400"
```

### 2. No Cache Versioning

**Bad:** Can't update cached content
```python
# Same URL, new content - users get old version
<script src="/app.js">
```

**Good:** Version or fingerprint
```python
# File changes = new URL
<script src="/app.a1b2c3.js">
```

## Best Practices

### 1. Set Appropriate Headers

```
Cache Headers:
├── Cache-Control: public, max-age=86400  (static)
├── Cache-Control: private, no-cache      (personalized)
├── Cache-Control: no-store               (sensitive)
└── ETag: "abc123"                        (validation)
```

### 2. Monitor Cache Hit Rate

```python
# Track CDN metrics
metrics.gauge("cdn_hit_rate", 0.95)  # 95% from CDN
metrics.gauge("cdn_bandwidth_mb", bandwidth)
```

## Related Topics

- [[PerformanceOptimization]] — Performance improvement
- [[Caching]] — Caching strategies
- [[NetworkSecurity]] — Secure CDN config

## Key Takeaways

- CDN serves content from edge locations closest to users
- Cache static content with long TTL
- Don't cache personalized or dynamic content
- Use cache busting for updates
- Monitor cache hit rate