---
title: Security Headers
title_pt: Headers de Segurança HTTP
layer: security
type: standard
priority: high
version: 1.0.0
tags:
  - Security
  - Headers
  - HTTP
  - Standard
description: HTTP security headers that protect web applications from common attacks.
description_pt: Headers de segurança HTTP que protegem aplicações web de ataques comuns.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Security Headers

## Description

HTTP security headers are directives that servers send in HTTP responses to control browser behavior and provide security protections. These headers are a fundamental part of web application security, as they instruct browsers on how to handle various security concerns, from clickjacking prevention to strict transport security.

When properly configured, security headers can protect against numerous attack vectors including XSS, clickjacking, MIME type sniffing, and protocol downgrade attacks. Unlike application-level security measures, security headers are implemented at the server level and require minimal changes to application code.

There are several critical security headers that every web application should implement:

1. **Strict-Transport-Security (HSTS)** - Forces HTTPS connections
2. **Content-Security-Policy (CSP)** - Prevents XSS and data injection
3. **X-Frame-Options** - Prevents clickjacking
4. **X-Content-Type-Options** - Prevents MIME type sniffing
5. **Referrer-Policy** - Controls referrer information leakage
6. **Permissions-Policy** - Controls browser features and APIs
7. **Cross-Origin-Opener-Policy (COOP)** - Isolates browsing context
8. **Cross-Origin-Embedder-Policy (COEP)** - Controls cross-origin resource loading

Implementing these headers is one of the most cost-effective security measures, requiring server configuration rather than code changes. However, improper configuration can break functionality, so thorough testing is essential.

## Purpose

**When security headers are essential:**
- All public-facing web applications
- Any application handling sensitive data
- Applications using HTTPS
- APIs served over HTTP

**When additional configuration is needed:**
- For complex CSP requirements
- When third-party integrations are present
- For legacy browser support

## Rules

1. **Implement HSTS** - Enable with includeSubDomains
2. **Use CSP** - Start with report-only, then enforce
3. **Set X-Frame-Options** - Prevent clickjacking
4. **Set X-Content-Type-Options** - Prevent MIME sniffing
5. **Configure Referrer-Policy** - Control information leakage
6. **Test thoroughly** - Headers can break functionality
7. **Use report-uri/csp-report** - Monitor CSP violations
8. **Start with report-only** - Phase in CSP gradually
9. **Include preload flag** - Consider HSTS preload

## Examples

### Basic Security Headers

```nginx
# Nginx configuration
server {
    listen 443 ssl http2;
    
    # HSTS - Force HTTPS for 1 year, include subdomains, allow preload
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    
    # X-Frame-Options - Prevent clickjacking
    add_header X-Frame-Options "DENY" always;
    
    # X-Content-Type-Options - Prevent MIME sniffing
    add_header X-Content-Type-Options "nosniff" always;
    
    # Referrer-Policy - Limit referrer information
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Permissions-Policy - Control browser features
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
}
```

### Content Security Policy (CSP)

```nginx
# Basic CSP
add_header Content-Security-Policy "default-src 'self'" always;

# CSP with sources
add_header Content-Security-Policy "
    default-src 'self';
    script-src 'self' https://cdn.example.com;
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https:;
    font-src 'self';
    connect-src 'self' https://api.example.com;
    frame-ancestors 'none';
    base-uri 'self';
    form-action 'self';
" always;
```

```html
<!-- Report-only CSP for testing -->
<meta http-equiv="Content-Security-Policy-Report-Only" 
      content="default-src 'self'; report-uri https://report.example.com/csp">
```

### Advanced Headers

```nginx
# Cross-Origin-Opener-Policy (COOP)
add_header Cross-Origin-Opener-Policy "same-origin" always;

# Cross-Origin-Embedder-Policy (COEP)
add_header Cross-Origin-Embedder-Policy "require-corp" always;

# Cross-Origin-Resource-Policy (CORP)
add_header Cross-Origin-Resource-Policy "same-origin" always;

# Clear-Site-Data - Clear cached data on logout
# Note: Only use for logout endpoint
add_header Clear-Site-Data "cache, cookies, storage" always;
```

### Express.js Middleware

```javascript
// Express.js security headers middleware
const helmet = require('helmet');

const helmetConfig = {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "https://cdn.example.com"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      fontSrc: ["'self'"],
      connectSrc: ["'self'", "https://api.example.com"],
      frameAncestors: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"]
    },
    reportOnly: process.env.NODE_ENV !== 'production'
  },
  hsts: {
    maxAge: 31536000, // 1 year
    includeSubDomains: true,
    preload: true
  },
  frameguard: {
    action: 'deny'
  },
  noSniff: true,
  referrerPolicy: {
    policy: 'strict-origin-when-cross-origin'
  },
  permissionsPolicy: {
    features: {
      geolocation: [],
      microphone: [],
      camera: []
    }
  }
};

app.use(helmet(helmetConfig));
```

### Spring Boot Configuration

```java
@Configuration
public class SecurityHeadersConfig implements WebMvcConfigurer {
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SecurityHeadersInterceptor());
    }
}

@Component
public class SecurityHeadersInterceptor implements HandlerInterceptor {
    
    @Override
    public void postHandle(
            HttpServletRequest request,
            HttpServletResponse response,
            Object handler) {
        
        response.setHeader("Strict-Transport-Security", 
            "max-age=31536000; includeSubDomains; preload");
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        response.setHeader("Permissions-Policy", 
            "geolocation=(), microphone=(), camera=()");
        
        // CSP would typically be configured via filter
    }
}
```

## Anti-Patterns

### 1. Applying Headers Only to Specific Responses

**Bad:**
- Adding headers only to some responses
- Missing headers on error pages

**Solution:**
- Use middleware to apply to all responses
- Ensure error responses also include headers
- Use 'always' flag in nginx

### 2. Overly Permissive CSP

**Bad:**
- Using 'unsafe-inline' for scripts
- Using wildcard (*) sources
- Not specifying sources at all

```html
<!-- BAD - too permissive -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src *">
```

**Solution:**
- Start restrictive, add as needed
- Use nonces for inline scripts
- Remove unsafe-inline when possible

### 3. Not Testing in Staging

**Bad:**
- Deploying new CSP to production without testing
- Breaking third-party integrations
- Breaking inline styles or scripts

**Solution:**
- Use CSP report-only first
- Monitor violation reports
- Phase in changes gradually

### 4. Ignoring Report-Only Mode

**Bad:**
- Enforcing CSP immediately
- Not monitoring violations

**Solution:**
- Deploy report-only first
- Analyze violation reports
- Fix issues before enforcement

## Failure Modes

- **Headers applied selectively** → some responses unprotected → attack vector on unprotected endpoints → use middleware to apply headers to all responses
- **Overly permissive CSP** → XSS still possible → script injection → start restrictive, add sources incrementally based on violation reports
- **Missing HSTS** → protocol downgrade attacks → MITM vulnerability → enable HSTS with includeSubDomains and consider preload
- **CSP deployed without report-only testing** → broken functionality → site unusable → test with Content-Security-Policy-Report-Only first
- **X-Frame-Options missing** → clickjacking → user tricked into unintended actions → set X-Frame-Options to DENY or SAMEORIGIN
- **No header on error pages** → error responses unprotected → reflected XSS via error pages → ensure error handlers also set security headers
- **CORS misconfiguration** → cross-origin data leakage → sensitive data exposure → set specific allowed origins, never wildcard in production

## Best Practices

### 1. CSP Nonces for Dynamic Content

```python
# Flask - Generate CSP nonce
@app.after_request
def add_csp_header(response):
    nonce = base64.b64encode(os.urandom(16)).decode('utf-8')
    response.headers['Content-Security-Policy'] = (
        f"default-src 'self'; "
        f"script-src 'self' 'nonce-{nonce}'; "
        f"style-src 'self' 'unsafe-inline'"
    )
    # Make nonce available to templates
    g.csp_nonce = nonce
    return response

# Template usage
<script nonce="{{ g.csp_nonce }}">
    // Inline script allowed with nonce
</script>
```

### 2. HSTS Preload Registration

```nginx
# After testing, submit to hstspreload.org
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
```

### 3. CSP Violation Reporting

```javascript
// Report CSP violations to endpoint
// Server side
app.post('/csp-report', express.json(), (req, res) => {
    const report = req.body;
    logger.warn('CSP Violation:', report['csp-report']);
    // Store for analysis
    cspReports.push(report);
    res.status(204).end();
});

// Client side - report-uri in CSP
// Content-Security-Policy: default-src 'self'; report-uri /csp-report
```

### 4. Header Testing

```bash
# Check headers with curl
curl -I https://example.com | grep -iE '(strict-transport|x-frame|x-content-type|content-security)'

# Use securityheaders.com
# Online scanner for comprehensive check

# Use nmap
nmap -p 443 --script http-security-headers.nse example.com
```

## Technology Stack

| Tool | Use Case |
|------|----------|
| Helmet | Express.js security headers |
| SecureHeaders | Spring Boot headers |
| rack-protection | Ruby/Rails headers |
| Nginx | Server-side headers |
| Apache | Server-side headers |
| securityheaders.com | Online scanner |

## Related Topics

- [[TlsSsl]]
- [[XSS]]
- [[CSRF]]
- [[HTTPS]]
- [[HTTP]]
- [[Authentication]]
- [[JWTTokens]]
- [[APIDesign]]

## Additional Notes

**Header Priority:**
1. HSTS - Critical for HTTPS
2. CSP - Critical for XSS prevention
3. X-Frame-Options - Clickjacking prevention
4. Others - Defense in depth

**Browser Support:**
- Modern browsers support all major headers
- Some features require modern browsers
- Consider fallback for legacy browsers

**Common Issues:**
- CSP breaks inline styles
- CSP blocks third-party scripts
- HSTS breaks HTTP fallback
- Too many restrictions

**Testing Checklist:**
- Test all pages (including errors)
- Test with different browsers
- Test third-party integrations
- Monitor CSP reports
- Test after deployment