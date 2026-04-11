---
title: HTTPS
title_pt: HTTPS (Hypertext Transfer Protocol Secure)
layer: network
type: concept
priority: high
version: 1.0.0
tags:
  - Network
  - HTTP
  - HTTPS
  - Security
  - TLS
description: Secure HTTP protocol using TLS encryption for secure communication.
description_pt: Protocolo HTTP seguro usando criptografia TLS para comunicação segura.
prerequisites:
  - HTTP
  - TLSSSL
estimated_read_time: 8 min
difficulty: intermediate
---

# HTTPS

## Description

HTTPS (Hypertext Transfer Protocol Secure) is the secure version of HTTP that encrypts data in transit using TLS (Transport Layer Security). It provides authentication of the server, protection of data integrity, and encryption of communications between client and server.

HTTPS is essential for any application that handles sensitive data, including login credentials, personal information, payment details, or any private communication. Modern browsers now mark HTTP sites as "Not Secure," making HTTPS a requirement for credibility and trust.

The HTTPS workflow involves:
1. **Client Hello** - Client sends supported TLS versions and cipher suites
2. **Server Hello** - Server selects cipher suite and sends certificate
3. **Certificate Verification** - Client validates server's certificate
4. **Key Exchange** - Both parties derive session keys
5. **Encrypted Communication** - Data is encrypted using the established session keys

## Purpose

**When HTTPS is required:**
- For any authentication or login pages
- When handling personal or sensitive data
- For payment processing
- When API endpoints transmit private information
- For compliance with security standards (PCI-DSS, HIPAA)

**When HTTPS is critical:**
- E-commerce transactions
- Banking and financial applications
- Healthcare records
- User authentication systems

## Rules

1. **Use TLS 1.2 or higher** - Older versions have known vulnerabilities
2. **Validate certificates** - Verify chain of trust and expiration
3. **Use strong cipher suites** - Disable weak or deprecated ciphers
4. **Implement HSTS** - HTTP Strict Transport Security header
5. **Use certificate pinning** - For mobile apps and high-security apps

## Examples

### HTTPS Request Flow

```python
# Python HTTPS request with certificate verification
import urllib.request
import ssl

# Create SSL context with verification
context = ssl.create_default_context()

# This will verify the certificate
response = urllib.request.urlopen(
    'https://api.example.com/data',
    context=context
)

# For custom certificates
context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
context.load_verify_locations('/path/to/ca-bundle.crt')
context.load_cert_chain('/path/to/client.crt', '/path/to/client.key')
```

### Server Configuration (Nginx)

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    # SSL Certificate
    ssl_certificate /etc/ssl/certs/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;

    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;

    # HSTS - Force HTTPS for 1 year
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;

    # Content
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

### Certificate Validation

```python
import ssl
import socket
from cryptography import x509
from cryptography.hazmat.backends import default_backend

def validate_certificate(hostname: str, port: int = 443) -> dict:
    """Validate SSL certificate for a hostname"""
    result = {
        'valid': False,
        'issuer': None,
        'subject': None,
        'expires': None,
        'errors': []
    }
    
    try:
        # Create socket and wrap with SSL
        context = ssl.create_default_context()
        with socket.create_connection((hostname, port), timeout=10) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                cert = ssock.getpeercert(binary_form=True)
                
                # Parse certificate
                cert_obj = x509.load_der_x509_certificate(cert, default_backend())
                
                result['valid'] = True
                result['subject'] = cert_obj.subject.rfc4514_string()
                result['issuer'] = cert_obj.issuer.rfc4514_string()
                result['expires'] = cert_obj.not_valid_after_utc.isoformat()
                
    except ssl.SSLError as e:
        result['errors'].append(f"SSL Error: {str(e)}")
    except socket.timeout:
        result['errors'].append("Connection timeout")
    except Exception as e:
        result['errors'].append(f"Error: {str(e)}")
    
    return result

# Example usage
result = validate_certificate('google.com')
print(f"Valid: {result['valid']}")
print(f"Subject: {result['subject']}")
print(f"Expires: {result['expires']}")
```

### Certificate Pinning (iOS/Swift)

```swift
import Security
import Foundation

class CertificatePinner {
    private let pinnedPublicKeys: [SecKey]
    private let host: String
    
    init(host: String, pinnedKeyHashes: [String]) {
        self.host = host
        // In production, extract public keys from certificates
        self.pinnedPublicKeys = []
    }
    
    func validate(serverTrust: SecTrust, domain: String) -> Bool {
        // Create SSL policy for the domain
        let policy = SecPolicyCreateSSL(true, domain as CFString)
        SecTrustSetPolicies(serverTrust, policy)
        
        // Evaluate the trust
        var error: CFError?
        let isValid = SecTrustEvaluateWithError(serverTrust, &error)
        
        guard isValid else { return false }
        
        // Pin the leaf certificate's public key
        guard let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return false
        }
        
        let serverKey = SecCertificateCopyKey(serverCert)
        return pinnedPublicKeys.contains { key in
            SecKeyEqual(serverKey, key)
        }
    }
}

// Usage in URLSession
let pinner = CertificatePinner(host: "api.example.com", pinnedKeyHashes: [])
let delegate = CertificatePinningDelegate(pinner: pinner)
let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
```

## Anti-Patterns

### 1. Using Self-Signed Certificates in Production

```python
# BAD - Self-signed certs not trusted by clients
import ssl
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain('self-signed.crt', 'private.key')

# GOOD - Use proper CA-signed certificate
# Let's Encrypt provides free certificates
# Or purchase from DigiCert, Comodo, etc.
```

### 2. Not Validating Certificates

```python
# BAD - Disabling verification (dangerous!)
import urllib.request
response = urllib.request.urlopen(
    'https://api.example.com',
    context=urllib.request.unverified_context  # DANGER!
)

# GOOD - Always verify
import urllib.request
context = ssl.create_default_context()  # Verifies by default
response = urllib.request.urlopen('https://api.example.com', context=context)
```

### 3. Using Weak TLS Configurations

```nginx
# BAD - Weak configuration
ssl_protocols SSLv3 TLSv1;  # Vulnerable to POODLE, BEAST
ssl_ciphers LOW;  # Weak ciphers

# GOOD - Strong configuration  
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
```

### 4. Mixed Content

```html
<!-- BAD - HTTP resources on HTTPS page -->
<img src="http://cdn.example.com/image.png">
<script src="http://analytics.example.com/tracker.js">

<!-- GOOD - All resources via HTTPS -->
<img src="https://cdn.example.com/image.png">
<script src="https://analytics.example.com/tracker.js">
```

## Failure Modes

- **Expired certificates** → browsers block access → complete service outage → automate certificate renewal with monitoring alerts
- **Weak cipher suites** → encryption broken → data interception → disable deprecated ciphers and enforce TLS 1.2+
- **Missing HSTS header** → protocol downgrade attacks → MITM vulnerability → enable HSTS with includeSubDomains and preload
- **Mixed content** → insecure resources on HTTPS page → browser warnings and blocked resources → audit and fix all HTTP references
- **Self-signed certs in production** → trust failures → users cannot access service → use CA-signed certificates from trusted authorities
- **Certificate pinning misconfiguration** → legitimate updates blocked → app becomes unusable → implement pin backup and rotation strategy
- **OCSP stapling failure** → slow TLS handshake → degraded connection times → configure OCSP stapling with fallback

## Best Practices

### HSTS Configuration

```nginx
# Enable HSTS with subdomains
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

# After first visit, browsers will:
# 1. Redirect HTTP to HTTPS automatically
# 2. Refuse to connect if certificate is invalid
# 3. Apply this to all subdomains
```

### TLS Certificate Automation (Let's Encrypt)

```yaml
# docker-compose.yml with Certbot
version: '3'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot

  certbot:
    image: certbot/certbot
    command: certonly --webroot -w /var/www/certbot -d example.com --agree-tos --email admin@example.com
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
```

### Certificate Renewal Script

```bash
#!/bin/bash
# renew-cert.sh - Renew Let's Encrypt certificates

DOMAIN="example.com"
EMAIL="admin@example.com"

# Test renewal first (dry run)
docker run --rm \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  -v /var/log/letsencrypt:/var/log/letsencrypt \
  certbot/certbot renew --dry-run

# If successful, do actual renewal
docker run --rm \
  --volumes-from nginx \
  certbot/certbot renew --webroot -w /var/www/certbot

# Reload nginx to pick up new certificates
docker exec nginx nginx -s reload
```

## Related Topics

- [[HTTP]]
- [[TlsSsl]]
- [[SecurityHeaders]]
- [[WebSockets]]
- [[REST]]
- [[Authentication]]
- [[JWTTokens]]
- [[APIDesign]]

## Additional Notes

**Certificate Types:**
- DV (Domain Validation) - Basic validation
- OV (Organization Validation) - More thorough
- EV (Extended Validation) - Highest trust, green bar

**Let's Encrypt:**
- Free certificates valid for 90 days
- Automated renewal recommended
- Use Certbot for easy setup

**Modern Requirements:**
- TLS 1.3 preferred
- HTTP/2 or HTTP/3
- Certificate transparency logs