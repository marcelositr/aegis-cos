---
title: OWASP Top 10
title_pt: OWASP Top 10
layer: security
type: vulnerability
priority: high
version: 1.0.0
tags:
  - Security
  - OWASP
  - Vulnerability
description: The ten most critical web application security risks as defined by OWASP.
description_pt: Os dez riscos de segurança mais críticos em aplicações web conforme definido pelo OWASP.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# OWASP Top 10

## Description

The OWASP Top 10 is a standardized awareness document for developers and web application security. It represents a broad consensus about the most critical security risks to web applications. Organizations should adopt this document and start to ensure that their web applications minimize these risks. The list is updated approximately every 3-4 years, with the latest version being OWASP Top 10 2021.

The OWASP Top 10 is widely recognized as a benchmark for web application security and is used by many organizations as the foundation for their security testing programs. It serves as an educational tool to help developers understand common vulnerabilities and how to prevent them. The document is particularly valuable because it provides actionable guidance for each category, not just theoretical descriptions.

The 2021 OWASP Top 10 includes the following categories: A01:2021-Broken Access Control, A02:2021-Cryptographic Failures, A03:2021-Injection, A04:2021-Insecure Design, A05:2021-Security Misconfiguration, A06:2021-Vulnerable and Outdated Components, A07:2021-Identification and Authentication Failures, A08:2021-Software and Data Integrity Failures, A09:2021-Security Logging and Monitoring Failures, A10:2021-Server-Side Request Forgery.

Understanding and addressing these vulnerabilities is essential for any organization that develops or maintains web applications. Each category represents a significant risk that can lead to data breaches, system compromise, or regulatory penalties.

## Purpose

**When OWASP Top 10 is valuable:**
- For security assessments and audits
- When building new web applications
- During security training for developers
- For prioritizing security efforts
- In security code reviews
- When establishing security requirements

**When to consider beyond OWASP:**
- For API security (consider OWASP API Security Top 10)
- For mobile applications (consider OWASP Mobile Top 10)
- For specific industry requirements (PCI-DSS, HIPAA, etc.)
- When dealing with emerging technologies

## Rules

1. **Address all categories** - Don't pick and choose which to fix
2. **Use established frameworks** - Leverage OWASP guidance for each category
3. **Integrate into SDLC** - Security should be part of development, not an afterthought
4. **Automate where possible** - Use SAST and DAST tools for detection
5. **Test regularly** - Include OWASP testing in regular security assessments
6. **Train developers** - Ensure team understands each vulnerability
7. **Document exceptions** - When risks are accepted, document the rationale

## Examples

### A01: Broken Access Control

```java
// VULNERABLE: User can access any resource by changing ID
// URL: /api/users/123/profile
// Attacker changes to: /api/users/456/profile

@RestController
@RequestMapping("/api/users")
public class UserController {
    @GetMapping("/{userId}/profile")
    public UserProfile getProfile(@PathVariable Long userId) {
        // Missing authorization check!
        return userService.getProfile(userId);
    }
}

// SECURE: Always verify user has permission
@RestController
@RequestMapping("/api/users")
public class UserController {
    @GetMapping("/{userId}/profile")
    public UserProfile getProfile(
        @PathVariable Long userId,
        @AuthenticationPrincipal User currentUser) {
        
        // Verify current user can access this profile
        if (!userService.canAccessProfile(currentUser, userId)) {
            throw new AccessDeniedException("Access denied");
        }
        
        return userService.getProfile(userId);
    }
}
```

### A03: SQL Injection

```python
# VULNERABLE: Direct string concatenation
query = f"SELECT * FROM users WHERE email = '{user_input}'"
cursor.execute(query)

# Attack: user_input = "'; DROP TABLE users; --"
# Results in: SELECT * FROM users WHERE email = ''; DROP TABLE users; --'

# SECURE: Parameterized queries
query = "SELECT * FROM users WHERE email = %s"
cursor.execute(query, (user_input,))

# SECURE: ORM usage (SQLAlchemy)
user = session.query(User).filter(User.email == user_input).first()
```

### A07: Identification and Authentication Failures

```javascript
// VULNERABLE: No rate limiting on login
app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const user = validateLogin(email, password);
  // No attempt limiting - vulnerable to brute force
});

// SECURE: Rate limiting and secure session management
const rateLimit = require('express-rate-limit');
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: "Too many login attempts"
});

app.post('/login', loginLimiter, (req, res) => {
  const { email, password } = req.body;
  const user = validateLogin(email, password);
  
  if (!user) {
    logFailedAttempt(email);
    return res.status(401).json({ error: "Invalid credentials" });
  }
  
  // Use secure session management
  req.session.regenerate(() => {
    req.session.user = user.id;
  });
});
```

## Anti-Patterns

### 1. Only Fixing High Severity Issues

**Bad:**
- Addressing only the highest severity findings
- Ignoring "medium" or "low" vulnerabilities
- Creates false sense of security

**Solution:**
- Address all OWASP categories
- Use risk-based prioritization internally
- Consider cumulative risk of many low issues

### 2. One-Time Security Fix

**Bad:**
- Running security scan once and fixing findings
- Not addressing root causes
- Vulnerabilities re-enter through new code

**Solution:**
- Integrate security into development process
- Use SAST in CI/CD pipeline
- Regular security training for developers

### 3. Relying Only on Automated Tools

**Bad:**
- Assuming tools catch all vulnerabilities
- Not doing manual penetration testing
- Tools have false positives and negatives

**Solution:**
- Combine automated and manual testing
- Regular penetration testing by experts
- Code review with security focus

## Best Practices

### 1. Access Control Implementation

```java
// Use a security framework
@Configuration
@EnableMethodSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .requestMatchers("/user/**").hasAnyRole("USER", "ADMIN")
                .anyRequest().authenticated()
            )
            .csrf(csrf -> csrf.disable()) // API use case
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            );
        return http.build();
    }
}
```

### 2. Input Validation

```typescript
// Use validation libraries
import { z } from 'zod';

const UserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(100),
  age: z.number().int().min(0).max(150)
});

function createUser(data: unknown) {
  const result = UserSchema.safeParse(data);
  if (!result.success) {
    throw new ValidationError(result.error);
  }
  // Process validated data
}
```

### 3. Security Logging

```java
// Log security-relevant events
@Service
public class AuthService {
    
    private final Logger securityLogger = LoggerFactory.getLogger("SECURITY");
    
    public void login(String email, boolean success) {
        securityLogger.info(
            "Login attempt: email={}, success={}, ip={}, timestamp={}",
            email, success, getClientIP(), Instant.now()
        );
    }
    
    public void logAccessDenied(String userId, String resource) {
        securityLogger.warn(
            "Access denied: user={}, resource={}, ip={}",
            userId, resource, getClientIP()
        );
    }
}
```

### 4. Dependency Management

```xml
<!-- Maven: Check for vulnerabilities -->
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>8.4.5</version>
    <configuration>
        <failBuildOnCVSS>7.0</failBuildOnCVSS>
    </configuration>
</plugin>
```

## Failure Modes

- **Only fixing high severity OWASP issues** → medium and low vulnerabilities ignored → cumulative risk from many small issues → address all OWASP categories with risk-based prioritization
- **One-time security fix without process change** → vulnerabilities re-enter through new code → recurring security issues → integrate security into development process with SAST in CI/CD pipeline
- **Relying only on automated tools** → assuming scanners catch all vulnerabilities → false sense of security → combine automated scanning with manual penetration testing and code review
- **Not training developers on OWASP** → team does not understand vulnerabilities → same mistakes repeated → provide regular security training with OWASP examples relevant to your stack
- **Ignoring OWASP API Security Top 10** → focusing only on web app vulnerabilities → API-specific attacks succeed → address both OWASP Top 10 and API Security Top 10 for API-heavy applications
- **Security testing only in production** → vulnerabilities discovered too late → expensive fixes and delayed releases → shift security testing left into development and CI pipeline
- **Not documenting security exceptions** → accepted risks not recorded → future developers unaware of known vulnerabilities → document all accepted risks with rationale and review dates

## Technology Stack

| Tool | Category | Use Case |
|------|----------|----------|
| OWASP ZAP | DAST | Dynamic application scanning |
| SonarQube | SAST | Static analysis with security rules |
| Snyk | Dependency | Vulnerability scanning |
| Burp Suite | Manual | Penetration testing |
| Checkmarx | SAST | Enterprise static analysis |
| Nuclei | Vulnerability | Template-based scanning |

## Related Topics

- [[Security MOC]]
- [[XSS]]
- [[SQLInjection]]
- [[CSRF]]
- [[InputValidation]]
- [[ThreatModeling]]

## Key Takeaways

- OWASP Top 10 identifies the ten most critical web application security risks, providing a standardized benchmark for security testing and developer education
- Valuable for security assessments, building new web applications, developer training, prioritizing security efforts, and establishing security requirements
- Consider beyond OWASP for API security, mobile applications, specific industry requirements, or emerging technologies
- Tradeoff: comprehensive vulnerability awareness versus risk of treating it as a checklist rather than integrating security into the development process
- Main failure mode: doing a one-time security fix without process change allows vulnerabilities to re-enter through new code, creating recurring security issues
- Best practice: integrate security into SDLC with SAST in CI/CD, combine automated scanning with manual penetration testing, train developers regularly on OWASP categories, and address both OWASP Top 10 and API Security Top 10 for API-heavy applications
- Related: XSS, SQL injection, CSRF, input validation, threat modeling

## Additional Notes

**OWASP Top 10 2021 Changes:**
- New category: A04-Insecure Design
- New category: A08-Software and Data Integrity Failures
- New category: A09-Security Logging and Monitoring Failures
- New category: A10-Server-Side Request Forgery
- Combined A4-A10 from 2017 into new categories

**Beyond OWASP Top 10:**
- OWASP API Security Top 10
- OWASP Mobile Top 10
- OWASP Top 10 for Large Language Model Applications

**Compliance Mapping:**
- OWASP maps to many compliance frameworks
- PCI-DSS references OWASP for web security
- SOC 2 includes OWASP considerations