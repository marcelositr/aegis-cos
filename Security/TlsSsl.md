---
title: TLS/SSL
title_pt: TLS/SSL (Transport Layer Security)
layer: security
type: standard
priority: high
version: 1.0.0
tags:
  - Security
  - TLS
  - SSL
  - Encryption
  - Standard
description: Cryptographic protocols for secure communication over networks.
description_pt: Protocolos criptográficos para comunicação segura em redes.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# TLS/SSL

## Description

Transport Layer Security (TLS) and its predecessor Secure Sockets Layer (SSL) are cryptographic protocols that provide secure communication over a computer network. TLS is the modern standard, with SSL considered deprecated due to known vulnerabilities. These protocols ensure confidentiality, integrity, and authentication in communications between clients and servers.

TLS operates between the transport and application layers, providing a secure channel over which higher-level protocols can operate. It uses a combination of symmetric encryption for data confidentiality, asymmetric cryptography for key exchange and authentication, and hash functions for message integrity.

The TLS handshake process establishes a secure connection through several steps: negotiation of cipher suites, server authentication (and optionally client authentication), key exchange, and verification of the handshake. Once established, all application data is encrypted using the negotiated keys and algorithms.

TLS is fundamental to web security, enabling HTTPS (HTTP over TLS) for secure web browsing, and is used in many other protocols including FTPS, SMTPS, and secure database connections. Proper TLS configuration is critical, as misconfigurations can expose systems to attacks like downgrade attacks, certificate spoofing, or weak cipher usage.

## Purpose

**When TLS is essential:**
- Any web application handling sensitive data
- User authentication and session management
- API communications
- Payment processing
- Data transfer between services
- Any network communication crossing untrusted networks

**When additional measures are needed:**
- For very sensitive data, consider additional application-layer encryption
- Compliance requirements (PCI-DSS, HIPAA, etc.)
- When using third-party services with varying TLS support

## Rules

1. **Use TLS 1.3 minimum** - TLS 1.2 is deprecated for new deployments
2. **Disable SSL and TLS 1.0/1.1** - These versions have known vulnerabilities
3. **Use strong cipher suites** - Disable weak ciphers like RC4, 3DES
4. **Use strong key sizes** - Minimum 2048-bit RSA, 256-bit AES
5. **Use HSTS** - Force HTTPS usage
6. **Valid certificates** - Use trusted CAs, keep certificates valid
7. **Certificate pinning** - For mobile apps and high-security applications
8. **Regular rotation** - Update certificates before expiration

## Examples

### TLS Configuration - Nginx

```nginx
# /etc/nginx/nginx.conf
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Modern TLS configuration
    ssl_protocols TLSv1.3;  # Only TLS 1.3
    
    ssl_prefer_server_ciphers off;
    
    # Strong cipher suites for TLS 1.3
    ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256';
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    
    # HSTS - Force HTTPS for 1 year
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    
    # Certificate files
    ssl_certificate /etc/ssl/certs/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
    
    # Additional security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
}
```

### TLS Configuration - Apache

```apache
# /etc/apache2/sites-enabled/default-ssl.conf
<VirtualHost *:443>
    ServerName example.com
    
    SSLEngine on
    
    # Modern TLS only
    SSLProtocol -all +TLSv1.3
    
    # Strong ciphers
    SSLCipherSuite TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256
    SSLHonorCipherOrder off
    
    # Certificate
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key
    SSLCertificateChainFile /etc/ssl/certs/ca-chain.crt
    
    # HSTS
    Header always set Strict-Transport-Security "max-age=31536000"
</VirtualHost>
```

### TLS Configuration - Java (Spring Boot)

```yaml
# application.yml
server:
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: ${KEYSTORE_PASSWORD}
    key-store-type: PKCS12
    enabled-protocols: TLSv1.3
    ciphers: TLS_AES_256_GCM_SHA384,TLS_CHACHA20_POLY1305_SHA256,TLS_AES_128_GCM_SHA256

# For outgoing connections
spring:
  ssl:
    bundle:
      jks:
        server:
          key:
            alias: server
          trust:
            alias: ca
```

### Certificate Generation

```bash
# Generate self-signed certificate for development
openssl req -x509 -newkey rsa:4096 \
  -keyout key.pem -out cert.pem \
  -days 365 -nodes \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

# Generate certificate with CSR for production
# 1. Generate private key
openssl genrsa -out server.key 4096

# 2. Generate CSR
openssl req -new -key server.key \
  -out server.csr \
  -subj "/C=US/ST=CA/L=SF/O=Org/CN=example.com"

# 3. Submit CSR to CA (Let's Encrypt, DigiCert, etc.)
# 4. CA issues certificate

# Convert to PKCS12 for Java/Glassfish
openssl pkcs12 -export \
  -in server.crt -inkey server.key \
  -out keystore.p12 \
  -name server
```

## Anti-Patterns

### 1. Using Deprecated TLS Versions

**Bad:**
- Supporting TLS 1.0 or TLS 1.1
- Allowing SSL fallback

```nginx
# BAD - supports weak protocols
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
```

**Solution:**
```nginx
# GOOD - only modern TLS
ssl_protocols TLSv1.3;
```

### 2. Weak Cipher Suites

**Bad:**
- Using 3DES, RC4, or NULL ciphers
- Allowing export-grade ciphers

```nginx
# BAD - weak ciphers
ssl_ciphers 'DEFAULT:!eNULL';
```

**Solution:**
```nginx
# GOOD - strong ciphers only
ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256';
```

### 3. Not Using HSTS

**Bad:**
- Not setting Strict-Transport-Security header
- Allows protocol downgrade attacks

**Solution:**
```nginx
# GOOD - HSTS enabled
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

### 4. Ignoring Certificate Validation

**Bad:**
- Disabling certificate verification
- Not checking certificate validity

```javascript
// BAD - disable verification
const https = require('https');
const req = https.request({
  hostname: 'api.example.com',
  port: 443,
  rejectUnauthorized: false  // DANGEROUS!
}, (res) => { ... });
```

```javascript
// GOOD - proper verification
const https = require('https');
const req = https.request({
  hostname: 'api.example.com',
  port: 443,
  ca: trustedCACert  // Provide CA certificate
}, (res) => { ... });
```

## Best Practices

### 1. Certificate Management

```bash
# Use certbot for automated Let's Encrypt certificates
sudo apt-get install certbot python3-certbot-nginx

# Generate certificate
sudo certbot --nginx -d example.com -d www.example.com

# Auto-renewal (certbot sets up automatically)
sudo certbot renew --dry-run
```

### 2. TLS in Microservices

```yaml
# Kubernetes TLS configuration
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  # Base64 encoded cert and key
  tls.crt: LS0tLS1CRUdJTi...
  tls.key: LS0tLS1CRUdJTi...

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  tls:
    - hosts:
        - example.com
      secretName: tls-secret
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

### 3. Mutual TLS (mTLS)

```java
// Java SSLContext with client certificates
SSLContext sslContext = SSLContextBuilder.create()
    .loadKeyMaterial(
        new FileInputStream("client.p12"),
        "password".toCharArray(),
        "password".toCharArray()
    )
    .loadTrustMaterial(
        new FileInputStream("truststore.jks"),
        "password".toCharArray()
    )
    .setProtocol("TLSv1.3")
    .build();

// Use for service-to-service communication
```

### 4. TLS Testing

```bash
# Test TLS configuration
nmap --script ssl-enum-ciphers -p 443 example.com

# Test with testssl.sh
./testssl.sh --fast example.com

# Test with openssl
openssl s_client -connect example.com:443 -tls1_3
openssl s_client -connect example.com:443 -tls1_2

# Check certificate
openssl x509 -in cert.pem -text -noout
```

## Technology Stack

| Tool | Use Case |
|------|----------|
| OpenSSL | Library and CLI for TLS |
| Certbot | Automated certificate management |
| Let's Encrypt | Free certificate authority |
| nginx | Reverse proxy with TLS |
| Apache | Web server with TLS |
| traefik | Modern ingress with TLS |
| istio | Service mesh with mTLS |

## Failure Modes

- **Using deprecated TLS versions** → TLS 1.0 or 1.1 still enabled → known vulnerabilities exploitable → disable all TLS versions below 1.2 and prefer TLS 1.3 exclusively
- **Weak cipher suites enabled** → RC4, 3DES, or export ciphers allowed → encrypted traffic can be decrypted → configure strong cipher suites only and disable weak algorithms
- **Certificate expiration not monitored** → certificates expire without renewal → service outage and security warnings → implement automated certificate monitoring and renewal with alerts before expiration
- **Certificate validation disabled in code** → rejectUnauthorized set to false → man-in-the-middle attacks succeed → always validate certificates and provide proper CA certificates
- **Missing HSTS header** → users can connect via HTTP → protocol downgrade attacks → set Strict-Transport-Security header with long max-age and includeSubDomains
- **Self-signed certificates in production** → no chain of trust verification → vulnerable to impersonation → use certificates from trusted CAs or internal PKI with proper chain distribution
- **Not using OCSP stapling** → certificate revocation not checked → revoked certificates still accepted → enable OCSP stapling for efficient certificate revocation checking

## Related Topics

- [[HTTPS]]
- [[HTTP]]
- [[SecurityHeaders]]
- [[Authentication]]
- [[JWTTokens]]
- [[OAuth2]]
- [[XSS]]
- [[Docker]]

## Key Takeaways

- TLS provides encrypted, authenticated communication over networks using symmetric encryption for data, asymmetric cryptography for key exchange, and hash functions for integrity
- Essential for any web application handling sensitive data, user authentication, API communications, payment processing, or data crossing untrusted networks
- Tradeoff: communication security and data confidentiality versus configuration complexity and certificate management overhead
- Main failure mode: using deprecated TLS versions (1.0, 1.1) or weak cipher suites exposes encrypted traffic to known decryption attacks
- Best practice: use TLS 1.3 minimum, disable all older versions, configure strong cipher suites only, enable HSTS to prevent downgrade attacks, automate certificate management with Let's Encrypt, validate certificates in code (never disable verification), and enable OCSP stapling
- Related: HTTPS, HTTP, security headers, authentication, JWT tokens, OAuth2, XSS

## Additional Notes

**TLS Version History:**
- SSL 1.0: Never publicly released
- SSL 2.0: Deprecated (1995)
- SSL 3.0: Deprecated (1996)
- TLS 1.0: Deprecated (2020)
- TLS 1.1: Deprecated (2020)
- TLS 1.2: Still secure, widely supported
- TLS 1.3: Latest, most secure (2018)

**Key Differences TLS 1.3:**
- Removed insecure features (static RSA, MD5)
- Faster handshake (1-RTT, 0-RTT mode)
- Simplified cipher suite selection
- Built-in forward secrecy

**Certificate Types:**
- DV: Domain Validation (basic)
- OV: Organization Validation
- EV: Extended Validation (green bar)
- Wildcard: *.example.com
- SAN: Multiple names in one cert