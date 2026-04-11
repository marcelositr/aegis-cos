---
title: OpenID Connect
title_pt: OpenID Connect
layer: security
type: standard
priority: high
version: 1.0.0
tags:
  - Security
  - OpenID
  - OAuth
  - Authentication
  - Identity
description: Identity layer on top of OAuth 2.0 for authentication.
description_pt: Camada de identidade sobre OAuth 2.0 para autenticação.
prerequisites:
  - OAuth2
estimated_read_time: 12 min
difficulty: advanced
---

# OpenID Connect

## Description

OpenID Connect (OIDC) is an identity layer built on top of the OAuth 2.0 protocol. While OAuth 2.0 is primarily an authorization framework (granting permission to access resources), OIDC adds authentication capabilities, allowing applications to verify the identity of users.

OIDC enables single sign-on (SSO) across applications and provides standardized ways to:
- Authenticate users
- Obtain user profile information
- Manage user sessions
- Implement federated identity

Major identity providers supporting OIDC include Google, Microsoft, Auth0, Okta, and Azure AD.

## Purpose

**When OIDC is valuable:**
- Implementing SSO across multiple applications
- Building applications that need user identity information
- Delegating authentication to trusted identity providers
- Federating identity across organizations

**Key OIDC flows:**
- Authorization Code Flow - For server-side applications
- Implicit Flow - For client-side SPAs (deprecated in favor of PKCE)
- Hybrid Flow - Combines aspects of both

## Rules

1. **Use PKCE** - Proof Key for Code Exchange for security
2. **Validate ID tokens** - Verify signature, claims, expiration
3. **Use HTTPS** - Always required for OIDC
4. **Implement state** - Prevent CSRF attacks
5. **Support refresh tokens** - For long-lived sessions

## Examples

### Authorization Code Flow with PKCE

```python
import secrets
import hashlib
import base64
from urllib.parse import urlencode
import requests
from datetime import datetime, timedelta
import jwt

class OIDCAuth:
    def __init__(self, config: dict):
        self.config = config
        self.code_verifier = None
    
    def generate_code_verifier(self) -> str:
        """Generate PKCE code verifier"""
        return base64.urlsafe_b64encode(secrets.token_bytes(32)).decode('utf-8').rstrip('=')
    
    def generate_code_challenge(self, verifier: str) -> str:
        """Generate PKCE code challenge from verifier"""
        digest = hashlib.sha256(verifier.encode('utf-8')).digest()
        return base64.urlsafe_b64encode(digest).decode('utf-8').rstrip('=')
    
    def get_authorization_url(self, redirect_uri: str, state: str = None) -> str:
        """Build authorization URL with PKCE"""
        self.code_verifier = self.generate_code_verifier()
        code_challenge = self.generate_code_challenge(self.code_verifier)
        
        if state is None:
            state = secrets.token_urlsafe(16)
        
        params = {
            'response_type': 'code',
            'client_id': self.config['client_id'],
            'redirect_uri': redirect_uri,
            'scope': 'openid profile email',
            'state': state,
            'code_challenge': code_challenge,
            'code_challenge_method': 'S256'
        }
        
        return f"{self.config['authorization_endpoint']}?{urlencode(params)}"
    
    def exchange_code_for_tokens(self, code: str, redirect_uri: str) -> dict:
        """Exchange authorization code for tokens"""
        response = requests.post(
            self.config['token_endpoint'],
            data={
                'grant_type': 'authorization_code',
                'code': code,
                'redirect_uri': redirect_uri,
                'client_id': self.config['client_id'],
                'client_secret': self.config['client_secret'],
                'code_verifier': self.code_verifier
            }
        )
        
        response.raise_for_status()
        return response.json()
    
    def validate_id_token(self, id_token: str, nonce: str = None) -> dict:
        """Validate and decode ID token"""
        # Get JWKS from provider
        jwks_response = requests.get(self.config['jwks_uri'])
        jwks = jwks_response.json()
        
        # Decode header to get key ID
        unverified_header = jwt.get_unverified_header(id_token)
        kid = unverified_header['kid']
        
        # Find matching key
        key = None
        for jwk in jwks['keys']:
            if jwk['kid'] == kid:
                key = jwt.algorithms.RSAAlgorithm.from_jwk(jwk)
                break
        
        if not key:
            raise ValueError("No matching key found in JWKS")
        
        # Decode and validate token
        claims = jwt.decode(
            id_token,
            key=key,
            algorithms=['RS256'],
            audience=self.config['client_id'],
            issuer=self.config['issuer'],
            options={
                'verify_exp': True,
                'verify_iat': True,
                'require_exp': True,
                'require_iat': True,
                'require_nonce': nonce is not None
            }
        )
        
        return claims
    
    def refresh_access_token(self, refresh_token: str) -> dict:
        """Refresh access token"""
        response = requests.post(
            self.config['token_endpoint'],
            data={
                'grant_type': 'refresh_token',
                'refresh_token': refresh_token,
                'client_id': self.config['client_id'],
                'client_secret': self.config['client_secret']
            }
        )
        
        response.raise_for_status()
        return response.json()

# Configuration example
config = {
    'client_id': 'your-client-id',
    'client_secret': 'your-client-secret',
    'authorization_endpoint': 'https://accounts.google.com/o/oauth2/v2/auth',
    'token_endpoint': 'https://oauth2.googleapis.com/token',
    'jwks_uri': 'https://www.googleapis.com/oauth2/v3/certs',
    'issuer': 'https://accounts.google.com',
    'redirect_uri': 'https://yourapp.com/callback'
}

# Usage
auth = OIDCAuth(config)
auth_url = auth.get_authorization_url('https://yourapp.com/callback')
print(f"Authorization URL: {auth_url}")
```

### UserInfo Endpoint

```python
def get_user_info(access_token: str, userinfo_endpoint: str) -> dict:
    """Fetch user info from UserInfo endpoint"""
    headers = {
        'Authorization': f'Bearer {access_token}'
    }
    
    response = requests.get(userinfo_endpoint, headers=headers)
    response.raise_for_status()
    
    return response.json()

# Example response
user_info = {
    'sub': '1234567890',
    'name': 'John Doe',
    'given_name': 'John',
    'family_name': 'Doe',
    'picture': 'https://example.com/photo.jpg',
    'email': 'john@example.com',
    'email_verified': True
}
```

### SPA Implementation

```javascript
// OIDC Client for Single Page Applications
class OIDCClient {
    constructor(config) {
        this.config = config;
        this.accessToken = null;
        this.idToken = null;
        this.refreshToken = null;
        this.tokenExpiry = null;
    }

    async login() {
        // Generate PKCE values
        const codeVerifier = this.generateCodeVerifier();
        const codeChallenge = await this.generateCodeChallenge(codeVerifier);
        
        // Store verifier for later
        sessionStorage.setItem('code_verifier', codeVerifier);
        
        // Build authorization URL
        const params = new URLSearchParams({
            response_type: 'code',
            client_id: this.config.clientId,
            redirect_uri: this.config.redirectUri,
            scope: 'openid profile email',
            state: this.generateState(),
            code_challenge: codeChallenge,
            code_challenge_method: 'S256'
        });
        
        window.location.href = `${this.config.authorizationEndpoint}?${params}`;
    }

    async handleCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const code = urlParams.get('code');
        const state = urlParams.get('state');
        
        if (!code) {
            throw new Error('No authorization code received');
        }
        
        // Verify state to prevent CSRF
        const storedState = sessionStorage.getItem('oauth_state');
        if (state !== storedState) {
            throw new Error('State mismatch - possible CSRF attack');
        }
        
        const codeVerifier = sessionStorage.getItem('code_verifier');
        
        // Exchange code for tokens
        const tokens = await this.exchangeCodeForTokens(code, codeVerifier);
        
        this.setTokens(tokens);
        
        // Clear temp storage
        sessionStorage.removeItem('code_verifier');
        sessionStorage.removeItem('oauth_state');
        
        return this.validateIdToken(tokens.id_token);
    }

    async refreshToken() {
        if (!this.refreshToken) {
            throw new Error('No refresh token available');
        }
        
        const response = await fetch(this.config.tokenEndpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: new URLSearchParams({
                grant_type: 'refresh_token',
                refresh_token: this.refreshToken,
                client_id: this.config.clientId
            })
        });
        
        if (!response.ok) {
            throw new Error('Token refresh failed');
        }
        
        const tokens = await response.json();
        this.setTokens(tokens);
    }

    async getAccessToken() {
        if (!this.accessToken) {
            throw new Error('Not authenticated');
        }
        
        // Check if token is expired
        if (this.tokenExpiry && Date.now() >= this.tokenExpiry) {
            await this.refreshToken();
        }
        
        return this.accessToken;
    }

    logout() {
        this.accessToken = null;
        this.idToken = null;
        this.refreshToken = null;
        this.tokenExpiry = null;
        
        // Optionally redirect to logout endpoint
        const logoutUrl = new URL(this.config.endSessionEndpoint);
        logoutUrl.searchParams.set('id_token_hint', this.idToken);
        window.location.href = logoutUrl.toString();
    }

    generateCodeVerifier() {
        const array = new Uint8Array(32);
        crypto.getRandomValues(array);
        return this.base64UrlEncode(array);
    }

    async generateCodeChallenge(verifier) {
        const encoder = new TextEncoder();
        const data = encoder.encode(verifier);
        const digest = await crypto.subtle.digest('SHA-256', data);
        return this.base64UrlEncode(new Uint8Array(digest));
    }

    base64UrlEncode(array) {
        return btoa(String.fromCharCode(...array))
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=+$/, '');
    }

    generateState() {
        const array = new Uint8Array(16);
        crypto.getRandomValues(array);
        return this.base64UrlEncode(array);
    }

    setTokens(tokens) {
        this.accessToken = tokens.access_token;
        this.idToken = tokens.id_token;
        
        if (tokens.refresh_token) {
            this.refreshToken = tokens.refresh_token;
        }
        
        if (tokens.expires_in) {
            this.tokenExpiry = Date.now() + (tokens.expires_in * 1000);
        }
    }

    async validateIdToken(idToken) {
        // In production, validate signature and claims
        const payload = JSON.parse(atob(idToken.split('.')[1]));
        
        // Verify claims
        if (payload.iss !== this.config.issuer) {
            throw new Error('Invalid issuer');
        }
        
        if (payload.aud !== this.config.clientId) {
            throw new Error('Invalid audience');
        }
        
        return payload;
    }
}
```

## Anti-Patterns

### 1. Not Using PKCE

```javascript
// BAD - Without PKCE (vulnerable to authorization code interception)
const authUrl = `https://auth.example.com/authorize?
    response_type=code&
    client_id=client123&
    redirect_uri=https://app.com/callback`;

// GOOD - With PKCE
const codeVerifier = generateCodeVerifier();
const codeChallenge = await generateCodeChallenge(codeVerifier);

const authUrl = `https://auth.example.com/authorize?
    response_type=code&
    client_id=client123&
    redirect_uri=https://app.com/callback&
    code_challenge=${codeChallenge}&
    code_challenge_method=S256`;
```

### 2. Not Validating Tokens

```python
# BAD - Trusting tokens without validation
def get_user(request):
    token = request.headers.get('Authorization')
    # No validation!
    user = decode(token)  # Don't do this!
    return user

# GOOD - Proper validation
def get_user(request):
    token = request.headers.get('Authorization').split(' ')[1]
    
    # Always validate
    claims = jwt.decode(
        token,
        key=get_signing_key(),
        algorithms=['RS256'],
        audience='my-client-id',
        issuer='https://auth.example.com'
    )
    
    return claims
```

### 3. Using Implicit Flow for SPAs

```javascript
// BAD - Implicit flow returns tokens in URL (exposed to browser history)
const hash = window.location.hash;
const token = hash.access_token;  // Dangerous!

// GOOD - Authorization Code with PKCE
// Tokens returned via back-channel, not in URL
const tokens = await exchangeCodeForTokens(code, codeVerifier);
```

## Best Practices

### Token Storage

```javascript
// For SPAs: use memory for access token, httpOnly cookie for refresh
class SecureTokenStore {
    async getAccessToken() {
        // Access token in memory (not in localStorage)
        return this.accessToken;
    }

    async getRefreshToken() {
        // Refresh token should be in httpOnly cookie
        const response = await fetch('/api/auth/refresh', {
            credentials: 'include'
        });
        return response.json();
    }
}
```

### Session Management

```python
# Server-side session management
class OIDCSession:
    def create_session(self, user_id: str, tokens: dict) -> str:
        session_id = secrets.token_urlsafe(32)
        
        # Store session server-side
        self.redis.setex(
            f"session:{session_id}",
            3600,  # 1 hour
            json.dumps({
                'user_id': user_id,
                'access_token': tokens['access_token'],
                'id_token': tokens['id_token'],
                'refresh_token': tokens.get('refresh_token')
            })
        )
        
        return session_id
```

## Failure Modes

- **Not using PKCE for authorization code flow** → authorization code interception attacks → stolen tokens used for unauthorized access → always use PKCE even for confidential clients
- **ID token not validated properly** → accepting tokens without verifying signature or claims → forged tokens accepted → validate signature, issuer, audience, expiration, and nonce on every ID token
- **Implicit flow used for SPAs** → tokens exposed in browser history and URL → token theft → use authorization code flow with PKCE instead of implicit flow for SPAs
- **Access tokens stored in localStorage** → XSS can steal tokens from localStorage → token theft and account takeover → store access tokens in memory and refresh tokens in httpOnly cookies
- **State parameter not used** → no CSRF protection in OAuth flow → attacker can forge authentication → always generate and validate state parameter in authorization requests
- **Token refresh without rotation** → same refresh token reused indefinitely → stolen refresh token provides permanent access → implement refresh token rotation and detect reuse as compromise indicator
- **Not handling token expiration gracefully** → expired tokens cause abrupt logout → poor user experience → implement silent token refresh before expiration and graceful re-authentication flow

## Related Topics

- [[OAuth2]]
- [[JWTTokens]]
- [[Authentication]]
- [[Authorization]]
- [[TlsSsl]]
- [[SecurityHeaders]]
- [[HTTPS]]
- [[InputValidation]]

## Additional Notes

**OIDC Claims:**
- sub (subject) - User identifier
- iss (issuer) - Identity provider
- aud (audience) - Intended recipient
- exp (expiration) - Token expiry
- iat (issued at) - Token creation time
- nonce - Prevents replay attacks

**Discovery:**
- OIDC Discovery endpoint at `/.well-known/openid-configuration`
- Returns authorization, token, userinfo endpoints
- JWKS URI for token validation