---
title: CSRF
title_pt: CSRF (Cross-Site Request Forgery)
layer: security
type: vulnerability
priority: high
version: 1.0.0
tags:
  - Security
  - CSRF
  - Vulnerability
description: Attack that forces authenticated users to submit unwanted requests.
description_pt: Ataque que força usuários autenticados a enviar requisições não desejadas.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# CSRF

## Description

Cross-Site Request Forgery (CSRF) is an attack that forces authenticated users to perform unwanted actions on a web application. When users are logged in, attackers can exploit the trust the application has in the user's browser to perform actions without the user's knowledge or consent.

CSRF attacks work because web browsers automatically include cookies, including session cookies, with every request to a domain. If a user is authenticated to a vulnerable site, an attacker can send requests that the application cannot distinguish from legitimate requests made by the user.

The attack relies on several factors:
1. The user must be authenticated to the target site
2. The attacker must know the structure of valid requests
3. The session cookies must persist in the browser
4. The application must not have CSRF protection

Common CSRF attacks include changing email addresses, making fund transfers, modifying account settings, or deleting data. The impact depends on the action being performed and the attacker's goals.

## Purpose

**When CSRF testing is valuable:**
- In all state-changing operations
- When using session-based authentication
- For any action that modifies user data
- In applications with user-specific functionality

**When CSRF is most critical:**
- Financial applications
- Admin interfaces
- User settings and profile changes
- Any action with side effects

## Rules

1. **Use anti-CSRF tokens** - Generate unique tokens for each request
2. **Verify Origin header** - Check request origin matches expected
3. **Use SameSite cookies** - Set SameSite=Strict or Lax
4. **Implement re-authentication** - For sensitive actions
5. **Check Referer header** - Additional validation layer
6. **Use framework built-ins** - Most frameworks have CSRF protection
7. **Never use GET for state-changing operations** - GET should be idempotent

## Examples

### Classic CSRF Attack

```html
<!-- Attacker's malicious page -->
<html>
  <body>
    <!-- Hidden form that submits automatically -->
    <form action="https://bank.com/transfer" method="POST" id="csrf-form">
      <input type="hidden" name="to" value="attacker-account">
      <input type="hidden" name="amount" value="10000">
    </form>
    
    <script>
      // Auto-submit when user visits
      document.getElementById('csrf-form').submit();
    </script>
  </body>
</html>

<!-- If user is logged into bank, the transfer happens automatically! -->
```

### CSRF with Image Tag

```html
<!-- Even simpler: using image tag (GET request) -->
<!-- User visits attacker's site -->
<img src="https://bank.com/transfer?to=attacker&amount=10000" width="0" height="0">

<!-- Browser automatically makes GET request -->
<!-- If user is logged in, transfer happens! -->
```

### Proper CSRF Protection

```python
# Flask with CSRF protection
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

class TransferForm(FlaskForm):
    to_account = StringField('To Account', validators=[DataRequired()])
    amount = FloatField('Amount', validators=[DataRequired()])
    submit = SubmitField('Transfer')

@app.route('/transfer', methods=['GET', 'POST'])
@login_required
def transfer():
    form = TransferForm()
    if form.validate_on_submit():
        # CSRF token automatically validated!
        account = form.to_account.data
        amount = form.amount.data
        execute_transfer(current_user, account, amount)
        flash('Transfer complete!')
        return redirect('/account')
    
    return render_template('transfer.html', form=form)
```

```html
<!-- Template automatically includes CSRF token -->
<form method="POST">
  {{ form.hidden_tag() }}  <!-- CSRF token here -->
  {{ form.to_account.label }}
  {{ form.to_account() }}
  {{ form.amount.label }}
  {{ form.amount() }}
  {{ form.submit() }}
</form>
```

### SameSite Cookies

```python
# Python Flask - Set SameSite cookie
@app.route('/')
def index():
    response = make_response(render_template('index.html'))
    response.set_cookie(
        'session',
        session_id,
        httponly=True,      # Can't be accessed by JS
        secure=True,        # HTTPS only
        samesite='Strict'   # CSRF protection
    )
    return response

# SameSite=Strict: Cookie not sent in any cross-site request
# SameSite=Lax: Cookie sent only for top-level navigations
# SameSite=None: Allows cross-site (requires Secure)
```

## Anti-Patterns

### 1. Only Checking Referer

**Bad:**
- Relying solely on Referer header
- Referer can be stripped or spoofed in some cases

**Solution:**
- Use multiple layers (token + SameSite + Referer)
- Don't rely on single protection mechanism

### 2. Using GET for State Changes

**Bad:**
- Using GET for actions that modify data
- GET requests can be triggered by images, links

**Solution:**
- Use POST/PUT/DELETE for state-changing operations
- Keep GET for reads only

### 3. Token in URL

**Bad:**
- Putting CSRF token in URL query string
- Tokens may be logged in server logs

**Solution:**
- Use POST body or headers for CSRF token
- Store in session cookie or header

## Best Practices

### 1. Synchronizer Token Pattern

```java
// Generate unique CSRF token per session
public class CsrfTokenService {
    
    public String generateToken(HttpSession session) {
        String token = UUID.randomUUID().toString();
        session.setAttribute("csrf_token", token);
        return token;
    }
    
    public boolean validateToken(HttpSession session, String token) {
        String storedToken = (String) session.getAttribute("csrf_token");
        return token != null && token.equals(storedToken);
    }
}

// Use in controllers
@PostMapping("/transfer")
public String transfer(
    @RequestParam String toAccount,
    @RequestParam double amount,
    @RequestParam String csrfToken,
    HttpSession session) {
    
    if (!csrfService.validateToken(session, csrfToken)) {
        return "error:invalid_csrf";
    }
    
    // Process transfer
}
```

### 2. Double Submit Cookie

```javascript
// Alternative: Cookie-based CSRF (without server state)
// Set cookie with CSRF token
document.cookie = "csrf-token=abc123; SameSite=Strict";

// Include in request header
fetch('/api/transfer', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': getCookie('csrf-token')
  },
  body: JSON.stringify({ to: 'account', amount: 100 })
});

// Server compares cookie value with header
```

### 3. Custom Header Verification

```javascript
// Require custom header for API calls
// Frontend adds header
const apiClient = axios.create();
apiClient.interceptors.request.use(config => {
  config.headers['X-Requested-With'] = 'XMLHttpRequest';
  config.headers['X-CSRF-Token'] = getCsrfToken();
  return config;
});

// Server allows only requests with this header
app.use((req, res, next) => {
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }
  
  if (req.headers['x-requested-with'] !== 'XMLHttpRequest') {
    return res.status(403).json({ error: 'Invalid request' });
  }
  
  next();
});
```

## Failure Modes

- **Missing CSRF tokens on state-changing endpoints** → forms and APIs accept cross-site requests → unauthorized actions performed on behalf of users → implement CSRF tokens for all state-changing operations
- **CSRF token in URL query string** → tokens logged in server logs and browser history → token leakage and replay attacks → send CSRF tokens in POST body or custom headers, never in URLs
- **SameSite cookie not set** → cookies sent with cross-site requests → CSRF protection bypassed → set SameSite=Strict or Lax on all session cookies as defense in depth
- **Using GET for state-changing operations** → GET requests triggered by images or links → CSRF via simple HTML → never use GET for operations that modify state
- **CSRF token validation skipped for APIs** → assuming APIs are safe from CSRF → API endpoints vulnerable to cross-site requests → apply CSRF protection to all authenticated endpoints regardless of type
- **Token not rotated after authentication** → same CSRF token used before and after login → session fixation attacks → regenerate CSRF tokens after authentication state changes
- **Relying only on Referer header** → Referer can be stripped or spoofed → insufficient CSRF protection → use multiple layers: CSRF tokens, SameSite cookies, and origin verification

## Technology Stack

| Tool | Type | Use Case |
|------|------|----------|
| Flask-WTF | Library | Python CSRF protection |
| Spring Security | Framework | Java CSRF tokens |
| Django | Framework | Built-in CSRF |
| OWASP CSRFGuard | Library | Java servlet CSRF |
| SameSite cookies | Feature | Browser CSRF protection |

## Related Topics

- [[XSS]]
- [[Authentication]]
- [[Authorization]]
- [[SecurityHeaders]]
- [[JWTTokens]]
- [[OAuth2]]
- [[HTTPS]]
- [[InputValidation]]

## Key Takeaways

- CSRF forces authenticated users to perform unwanted actions by exploiting the trust a web application has in the user's browser, leveraging automatic cookie inclusion with every request
- Testing is valuable for all state-changing operations, session-based authentication, and any action that modifies user data
- Critical for financial applications, admin interfaces, user settings changes, and any action with side effects
- Tradeoff: CSRF protection overhead (tokens, validation) versus risk of unauthorized actions performed on behalf of authenticated users
- Main failure mode: missing CSRF tokens on state-changing endpoints allows attackers to submit cross-site requests that the application cannot distinguish from legitimate user actions
- Best practice: use anti-CSRF tokens for all state-changing operations, set SameSite=Strict or Lax on session cookies, never use GET for state-changing operations, use framework built-in CSRF protection, and regenerate CSRF tokens after authentication state changes
- Related: XSS, authentication, authorization, security headers, JWT tokens, OAuth2, HTTPS, input validation

## Additional Notes

**CSRF vs XSS:**
- CSRF: Attacker exploits user's trust in site
- XSS: Attacker executes code in user's browser
- XSS can bypass CSRF tokens if tokens in page

**SameSite Cookie Browser Support:**
- Supported by modern browsers
- Fallback to traditional CSRF tokens for older browsers
- Chrome, Firefox, Safari, Edge all support

**Testing for CSRF:**
- Check form submissions for CSRF tokens
- Verify SameSite cookie attributes
- Test state-changing GET endpoints
- Check API endpoints for CSRF protection