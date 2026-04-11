---
title: JWT Tokens
title_pt: Tokens JWT
layer: security
type: standard
priority: high
version: 1.0.0
tags:
  - Security
  - JWT
  - Tokens
  - Authentication
description: JSON Web Tokens for secure information transmission.
description_pt: JSON Web Tokens para transmissão segura de informações.
prerequisites:
  - Security
estimated_read_time: 12 min
difficulty: intermediate
---

# JWT Tokens

## Description

JSON Web Tokens (JWT) are a compact, URL-safe means of representing claims to be transferred between two parties. JWTs are commonly used for authentication and authorization in modern web applications and APIs.

A JWT consists of three parts separated by dots:
- **Header** - Type of token and signing algorithm
- **Payload** - Claims (statements about an entity)
- **Signature** - Verification that the token hasn't been tampered with

Example: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`

## Purpose

**When JWT is valuable:**
- Stateless authentication
- API authentication
- Information exchange between services
- Single Sign-On (SSO)

**JWT vs Sessions:**
- JWT: Self-contained, no server storage needed
- Sessions: Server-side state, easier to revoke

## Rules

1. **Sign tokens** - Always use signature for integrity
2. **Validate tokens** - Verify signature, expiration, issuer
3. **Store securely** - Don't expose in URLs
4. **Use short expiration** - Access tokens should be short-lived
5. **Use HTTPS** - Never transmit over HTTP

## Examples

### Creating JWT

```python
import jwt
from datetime import datetime, timedelta
import secrets

def create_access_token(user_id: str, roles: list) -> str:
    """Create a JWT access token"""
    
    now = datetime.utcnow()
    
    payload = {
        'sub': user_id,  # Subject (user identifier)
        'iat': now,  # Issued at
        'exp': now + timedelta(minutes=15),  # Expiration (short-lived)
        'jti': secrets.token_urlsafe(16),  # JWT ID (for revocation)
        'roles': roles,
        'type': 'access'
    }
    
    # Sign with secret key (use RS256/ES256 in production)
    token = jwt.encode(payload, 'your-secret-key', algorithm='HS256')
    
    return token

def create_refresh_token(user_id: str) -> str:
    """Create a JWT refresh token"""
    
    now = datetime.utcnow()
    
    payload = {
        'sub': user_id,
        'iat': now,
        'exp': now + timedelta(days=7),  # Longer expiration
        'type': 'refresh'
    }
    
    return jwt.encode(payload, 'your-secret-key', algorithm='HS256')

# Usage
access_token = create_access_token('user123', ['admin', 'editor'])
refresh_token = create_refresh_token('user123')

print(f"Access Token: {access_token}")
```

### Validating JWT

```python
import jwt
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError

class JWTValidator:
    def __init__(self, secret_key: str, issuer: str, audience: str):
        self.secret_key = secret_key
        self.issuer = issuer
        self.audience = audience
    
    def validate(self, token: str) -> dict:
        """Validate JWT and return claims"""
        
        try:
            # Decode with validation
            claims = jwt.decode(
                token,
                self.secret_key,
                algorithms=['HS256'],
                issuer=self.issuer,
                audience=self.audience,
                options={
                    'verify_exp': True,
                    'verify_iat': True,
                    'require': ['sub', 'exp', 'iat']
                }
            )
            
            # Additional checks
            if claims.get('type') == 'access':
                # Verify it's an access token, not refresh
                pass
            
            return claims
            
        except ExpiredSignatureError:
            raise ValueError("Token has expired")
        except InvalidTokenError as e:
            raise ValueError(f"Invalid token: {str(e)}")

# Usage
validator = JWTValidator(
    secret_key='your-secret-key',
    issuer='https://auth.example.com',
    audience='your-api'
)

try:
    claims = validator.validate(access_token)
    print(f"Valid token for user: {claims['sub']}")
except ValueError as e:
    print(f"Token validation failed: {e}")
```

### RSA Signing (Production)

```python
import jwt
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend
from datetime import datetime, timedelta

# Generate key pair (do this once, store securely)
private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048,
    backend=default_backend()
)

public_key = private_key.public_key()

def create_signed_token(user_id: str) -> str:
    """Create JWT signed with RSA"""
    
    now = datetime.utcnow()
    
    payload = {
        'sub': user_id,
        'iat': now,
        'exp': now + timedelta(minutes=15)
    }
    
    # Sign with private key using RS256
    token = jwt.encode(
        payload,
        private_key,
        algorithm='RS256',
        headers={'kid': 'key-id-1'}
    )
    
    return token

def validate_signed_token(token: str) -> dict:
    """Validate JWT signed with RSA"""
    
    # In production, fetch public key from JWKS endpoint
    claims = jwt.decode(
        token,
        public_key,
        algorithms=['RS256'],
        audience='my-api',
        issuer='https://auth.example.com'
    )
    
    return claims
```

### Using JWT in API (Flask)

```python
from flask import Flask, request, jsonify
from functools import wraps
import jwt

app = Flask(__name__)

# Authentication decorator
def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Missing or invalid token'}), 401
        
        token = auth_header.split(' ')[1]
        
        try:
            claims = jwt.decode(
                token,
                'your-secret-key',
                algorithms=['HS256'],
                audience='your-api'
            )
            request.user = claims
            
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401
        
        return f(*args, **kwargs)
    
    return decorated

@app.route('/api/protected')
@require_auth
def protected_route():
    return jsonify({
        'user': request.user['sub'],
        'roles': request.user.get('roles', [])
    })

# Token refresh endpoint
@app.route('/api/refresh', methods=['POST'])
def refresh_token():
    data = request.get_json()
    refresh_token = data.get('refresh_token')
    
    try:
        claims = jwt.decode(
            refresh_token,
            'your-secret-key',
            algorithms=['HS256']
        )
        
        if claims.get('type') != 'refresh':
            return jsonify({'error': 'Invalid token type'}), 400
        
        # Create new access token
        new_access = create_access_token(claims['sub'], [])
        
        return jsonify({'access_token': new_access})
        
    except jwt.InvalidTokenError:
        return jsonify({'error': 'Invalid refresh token'}), 401
```

### JWT in JavaScript (Frontend)

```javascript
// Store token in memory (not localStorage for security)
let accessToken = null;

async function login(username, password) {
    const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
    });
    
    const tokens = await response.json();
    accessToken = tokens.access_token;
    
    // Store refresh token in httpOnly cookie
    // (done by server, not accessible to JS)
}

// API request with token
async function fetchProtectedData() {
    const response = await fetch('/api/data', {
        headers: {
            'Authorization': `Bearer ${accessToken}`
        }
    });
    
    if (response.status === 401) {
        // Try to refresh token
        const newToken = await refreshAccessToken();
        if (newToken) {
            accessToken = newToken;
            return fetchProtectedData();
        }
        // Redirect to login
        window.location.href = '/login';
    }
    
    return response.json();
}

async function refreshAccessToken() {
    const response = await fetch('/api/auth/refresh', {
        method: 'POST',
        credentials: 'include'  // Include httpOnly cookie
    });
    
    if (response.ok) {
        const data = await response.json();
        return data.access_token;
    }
    
    return null;
}
```

## Anti-Patterns

### 1. Not Validating Signature

```python
# BAD - Trusting token without validation
def get_user(token):
    return json.loads(base64.b64decode(token.split('.')[1]))

# GOOD - Always validate
def get_user(token):
    return jwt.decode(token, 'secret', algorithms=['HS256'])
```

### 2. Storing Sensitive Data

```python
# BAD - Sensitive data in payload (visible to anyone)
payload = {
    'sub': 'user123',
    'password': 'secret123',  # Never put this in JWT!
    'ssn': '123-45-6789'      # Never put this in JWT!
}

# GOOD - Only include non-sensitive identifiers
payload = {
    'sub': 'user123'  # Use ID to look up sensitive data from DB
}
```

### 3. No Expiration

```python
# BAD - No expiration (token valid forever)
payload = {'sub': 'user123'}

# GOOD - Short-lived access tokens
payload = {
    'sub': 'user123',
    'exp': datetime.utcnow() + timedelta(minutes=15)
}
```

## Failure Modes

- **No signature validation** → forged tokens accepted → unauthorized access → always verify JWT signature with the correct algorithm
- **Storing sensitive data in payload** → base64-decodable by anyone → data exposure → only include non-sensitive identifiers in JWT claims
- **No expiration set** → token valid forever → permanent access if leaked → set short expiration (15min) for access tokens
- **Weak signing algorithm** → tokens forged via algorithm confusion → complete auth bypass → use RS256/ES256 and reject 'none' algorithm
- **Token stored in localStorage** → XSS steals token → account takeover → store in httpOnly cookies or memory, never localStorage
- **No token revocation mechanism** → compromised tokens remain valid → persistent unauthorized access → implement blocklist with Redis
- **Shared secret key exposure** → all tokens forgeable → system-wide compromise → use asymmetric keys and rotate regularly

## Best Practices

### Token Storage

```
Security Hierarchy:
1. Memory (access token) - Best for XSS protection
2. httpOnly cookies (refresh token) - Best for CSRF protection
3. localStorage - Only if using short-lived tokens with rotation

Never store in:
- URL parameters (logged in server logs)
- localStorage without additional protections
```

### Revocation Strategy

```python
# Token revocation using blocklist
class TokenRevocation:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def revoke(self, jti: str, exp: int):
        """Add token to blocklist until expiration"""
        ttl = exp - int(time.time())
        if ttl > 0:
            self.redis.setex(f"revoked:{jti}", ttl, "1")
    
    def is_revoked(self, jti: str) -> bool:
        """Check if token is revoked"""
        return self.redis.exists(f"revoked:{jti}") > 0
```

## Related Topics

- [[OAuth2]]
- [[OpenIDConnect]]
- [[TlsSsl]]
- [[SecurityHeaders]]
- [[Authentication]]
- [[Authorization]]
- [[HTTPS]]
- [[Cryptography]]

## Additional Notes

**Token Types:**
- Access token: Short-lived, for API calls
- Refresh token: Longer-lived, for obtaining new access tokens
- ID token: Contains user identity info (OIDC)

**Algorithms:**
- HS256: HMAC with SHA-256 (symmetric)
- RS256: RSA signature (asymmetric)
- ES256: ECDSA with P-256 and SHA-256

**Best Practices:**
- Use RS256 for production
- Implement token rotation
- Use nonce for replay protection
- Keep tokens small