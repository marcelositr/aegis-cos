---
title: OAuth 2.0
title_pt: OAuth 2.0
layer: security
type: standard
priority: high
version: 1.0.0
tags:
  - Security
  - OAuth
  - Authentication
  - Standard
description: Authorization framework for secure API access.
description_pt: Framework de autorização para acesso seguro a APIs.
prerequisites: []
estimated_read_time: 18 min
difficulty: advanced
---

# OAuth 2.0

## Description

OAuth 2.0 is the industry-standard authorization framework that enables applications to obtain limited access to user accounts on third-party services. It works by delegating user authentication to the service hosting the account and authorizing third-party applications to access the user account.

OAuth 2.0 is used by major companies like Google, Facebook, and GitHub to allow users to share their identity and data with other applications without exposing credentials.

## Purpose

**When OAuth 2.0 is valuable:**
- For third-party app access (social login, API access)
- When implementing SSO (Single Sign-On)
- For API authorization without password sharing
- For delegated access to user resources

**When simpler auth suffices:**
- Single application without third-party access
- When you control all clients
- For simple username/password systems

**The key question:** Does an external party need access to user resources without seeing credentials?

## Examples

### Authorization Code Flow

```python
# 1. Redirect user to authorization server
auth_url = "https://auth.example.com/authorize?client_id=ID&response_type=code&scope=read"

# 2. Exchange code for tokens
def get_tokens(code):
    response = requests.post("https://auth.example.com/token", data={
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "code": code,
        "grant_type": "authorization_code"
    })
    return response.json()  # {access_token, refresh_token, expires_in}
```

### Client Credentials Flow (M2M)

```python
def get_service_token():
    response = requests.post("https://auth.example.com/token", data={
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "client_credentials",
        "scope": "admin"
    })
    return response.json()['access_token']
```

## The OAuth Flow

### Authorization Code Flow (Most Secure)

```python
# 1. User clicks "Login with Google"
# Redirect to authorization server
auth_url = (
    "https://accounts.google.com/o/oauth2/v2/auth?"
    "client_id=YOUR_CLIENT_ID&"
    "redirect_uri=YOUR_REDIRECT_URI&"
    "response_type=code&"
    "scope=openid profile email&"
    "state=random_state_string"
)

# 2. User authorizes application
# 3. Authorization server redirects with code

# 4. Exchange code for tokens
def exchange_code_for_tokens(code):
    response = requests.post(
        "https://oauth2.googleapis.com/token",
        data={
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": REDIRECT_URI
        }
    )
    return response.json()
    # Returns: {access_token, refresh_token, expires_in, token_type}

# 5. Use access token
def get_user_profile(access_token):
    response = requests.get(
        "https://www.googleapis.com/oauth2/v2/userinfo",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    return response.json()
```

### Client Credentials Flow (Server-to-Server)

```python
# For server-to-server communication
def get_service_token():
    response = requests.post(
        "https://oauth2.googleapis.com/token",
        data={
            "client_id": SERVICE_CLIENT_ID,
            "client_secret": SERVICE_CLIENT_SECRET,
            "grant_type": "client_credentials",
            "scope": "https://www.googleapis.com/auth/cloud-platform"
        }
    )
    return response.json()
```

### PKCE Flow (For Mobile/SPA)

```python
import hashlib
import secrets

# 1. Generate code_verifier and code_challenge
def generate_pkce_codes():
    code_verifier = secrets.token_urlsafe(64)
    code_challenge = hashlib.sha256(code_verifier.encode()).digest()
    code_challenge_b64 = base64.urlsafe_b64encode(code_challenge).decode().rstrip('=')
    return code_verifier, code_challenge_b64

# 2. Use in authorization request
auth_url = (
    f"https://accounts.google.com/o/oauth2/v2/auth?"
    f"client_id={CLIENT_ID}&"
    f"redirect_uri={REDIRECT_URI}&"
    f"response_type=code&"
    f"scope=openid profile email&"
    f"code_challenge={code_challenge_b64}&"
    f"code_challenge_method=S256"
)

# 3. Verify with code_verifier when exchanging
def exchange_with_pkce(code, code_verifier):
    response = requests.post(
        "https://oauth2.googleapis.com/token",
        data={
            "client_id": CLIENT_ID,
            "code": code,
            "code_verifier": code_verifier,
            "grant_type": "authorization_code",
            "redirect_uri": REDIRECT_URI
        }
    )
    return response.json()
```

## Scopes

```python
# Common Google scopes
scopes = {
    "openid": "Authenticate user",
    "profile": "Access basic profile info",
    "email": "Access email address",
    "https://www.googleapis.com/auth/drive": "Access Google Drive",
    "https://www.googleapis.com/auth/calendar": "Access Calendar"
}

# Request minimal necessary scopes
minimal_scopes = ["openid", "profile", "email"]  # Don't request drive unless needed
```

## Token Management

```python
class TokenManager:
    def __init__(self, client_id, client_secret):
        self.client_id = client_id
        self.client_secret = client_secret
        self.tokens = {}
    
    def get_valid_token(self, user_id):
        if user_id in self.tokens:
            token = self.tokens[user_id]
            if not self.is_expired(token):
                return token["access_token"]
            if "refresh_token" in token:
                return self.refresh_token(token["refresh_token"], user_id)
        return None
    
    def is_expired(self, token):
        import time
        return time.time() > token["expires_at"]
    
    def refresh_token(self, refresh_token, user_id):
        response = requests.post(
            "https://oauth2.googleapis.com/token",
            data={
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "refresh_token": refresh_token,
                "grant_type": "refresh_token"
            }
        )
        new_token = response.json()
        new_token["expires_at"] = time.time() + new_token["expires_in"]
        self.tokens[user_id] = new_token
        return new_token["access_token"]
```

## Failure Modes

- **Missing state parameter** → CSRF attack → unauthorized account access → always generate and validate state parameter
- **No PKCE for public clients** → authorization code interception → token theft → implement PKCE for SPAs and mobile apps
- **Exposed client secret** → attacker impersonates application → full account compromise → never embed client secrets in frontend code
- **Overly broad scopes** → excessive permissions → data overexposure → request minimum required scopes per OAuth principle
- **Token exposed in URL** → logged in browser history → credential theft → use Authorization header, never URL parameters
- **No token rotation** → refresh token reuse undetected → persistent breach → implement refresh token rotation with detection
- **Incorrect redirect URI validation** → open redirect → token leakage → validate redirect URIs with exact string matching

## Anti-Patterns

### 1. Missing State Parameter

**Bad:** Initiating the OAuth flow without generating and validating a state parameter
**Why it's bad:** An attacker can perform a CSRF attack — tricking a user into linking their account to the attacker's identity, gaining access to the victim's data
**Good:** Always generate a cryptographically random state parameter, store it in the session, and validate it on callback

### 2. Exposing Client Secrets in Frontend Code

**Bad:** Embedding OAuth client secrets in JavaScript, mobile apps, or any code that runs on the user's device
**Why it's bad:** Client secrets are trivially extracted from frontend code — an attacker uses the secret to impersonate your application and steal user tokens
**Good:** Never embed client secrets in frontend code — use PKCE for public clients and keep client secrets only on the server

### 3. Incorrect Redirect URI Validation

**Bad:** Using partial or regex-based redirect URI validation instead of exact string matching
**Why it's bad:** An attacker registers a redirect URI like `https://evil.com?redirect=https://yourapp.com/callback` and receives the authorization code
**Good:** Validate redirect URIs with exact string matching — the registered URI must match the callback URI character for character

### 4. Overly Broad Scopes

**Bad:** Requesting all available scopes (`drive`, `calendar`, `contacts`) when the application only needs basic profile information
**Why it's bad:** Users are deterred by excessive permission requests, and if the token is compromised, the attacker has access to far more data than necessary
**Good:** Request the minimum required scopes — ask for additional scopes only when the user initiates an action that requires them

## Best Practices

1. **Use authorization code flow** - Most secure for web apps
2. **Use PKCE for mobile/SPA** - Adds security for public clients
3. **Validate state parameter** - Prevents CSRF attacks
4. **Use short-lived tokens** - Access tokens: minutes to hours
5. **Never expose tokens in URLs** - Use Authorization header

## Security Best Practices

```python
# ALWAYS validate state parameter to prevent CSRF
def initiate_auth():
    state = secrets.token_urlsafe(32)
    # Store state in session
    session['oauth_state'] = state
    return f"https://...&state={state}"

def handle_callback(code, state):
    # Verify state matches
    if state != session.get('oauth_state'):
        raise SecurityError("Invalid state - possible CSRF")
    
    # Proceed with token exchange
    ...

# NEVER expose access tokens in URLs
# BAD: https://api.example.com/user?token=xxx
# GOOD: Authorization: Bearer xxx

# Use short-lived access tokens
# Access token: 1 hour
# Refresh token: long-lived, can revoke

# Implement token revocation
def revoke_token(token):
    requests.post(
        "https://oauth2.googleapis.com/revoke",
        params={"token": token}
    )
```

## Refresh Token Rotation

```python
# Implement refresh token rotation for security
def handle_token_response(response):
    tokens = response.json()
    
    # New access token
    access_token = tokens["access_token"]
    
    # New refresh token (rotate!)
    if "refresh_token" in tokens:
        new_refresh_token = tokens["refresh_token"]
        store_refresh_token(user_id, new_refresh_token)
    
    # Store access token with expiration
    expires_at = time.time() + tokens["expires_in"]
    store_access_token(user_id, access_token, expires_at)
```

## Related Topics

- [[OpenIDConnect]]
- [[JWTTokens]]
- [[Authentication]]
- [[Authorization]]
- [[TlsSsl]]
- [[HTTPS]]
- [[SecurityHeaders]]
- [[CSRF]]

## Additional Notes

**Grant Types:**
- Authorization Code - Web apps
- PKCE - Mobile/SPA
- Client Credentials - Server-to-server
- Device Code - IoT/TV
- Password - Legacy (avoid)

**Security Checklist:**
- Always use state parameter
- Use PKCE for public clients
- Validate redirect URIs exactly
- Use HTTPS always
- Implement token rotation
- Set appropriate token lifetimes
- Store tokens securely