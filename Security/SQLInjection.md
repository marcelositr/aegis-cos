---
title: SQL Injection
title_pt: SQL Injection (Injeção de SQL)
layer: security
type: vulnerability
priority: high
version: 1.0.0
tags:
  - Security
  - SQL
  - Injection
  - Vulnerability
description: Attack that manipulates database queries through unsanitized user input.
description_pt: Ataque que manipula consultas de banco de dados através de entrada de usuário não sanitizada.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# SQL Injection

## Description

SQL Injection is a code injection technique that exploits security vulnerabilities in an application's database layer. It occurs when user input is incorrectly filtered or not strongly typed and is passed to SQL statements. Successful SQL injection can allow attackers to read, modify, or delete database data, bypass authentication, and in some cases, execute system commands on the database server.

SQL injection is one of the oldest and most dangerous web application vulnerabilities. It consistently appears in the OWASP Top 10 and has been responsible for numerous high-profile data breaches. The vulnerability exists because SQL queries can include both data and executable commands, and user input is sometimes incorporated into queries without proper sanitization.

There are several types of SQL injection:
1. **In-band**: Attacker uses the same channel to inject and retrieve results
2. **Blind**: Server doesn't output SQL errors, attacker infers through true/false responses
3. **Out-of-band**: Attacker uses different channels for injection and retrieval
4. **Union-based**: Uses UNION to extract data from other tables

The impact of SQL injection can be catastrophic, including complete data breach, data modification or deletion, privilege escalation, and in some cases, remote code execution on the database server.

## Purpose

**When SQL injection testing is valuable:**
- In all applications using databases
- Any endpoint accepting user input
- Legacy applications with direct SQL queries

**When SQL injection is most critical:**
- Applications with sensitive data
- Systems with privileged database accounts
- Applications with database admin functionality

## Rules

1. **Use parameterized queries** - Never concatenate strings into SQL
2. **Use ORM when possible** - Most ORMs handle SQL safely
3. **Validate input** - Whitelist expected formats
4. **Least privilege** - Database users should have minimal permissions
5. **Escape special characters** - If parameterization not possible
6. **Use stored procedures** - Reduces dynamic SQL surface
7. **Regular security testing** - Include in penetration testing

## Examples

### Classic SQL Injection

```python
# VULNERABLE: String concatenation
user_input = request.form['username']
query = f"SELECT * FROM users WHERE username = '{user_input}'"
cursor.execute(query)

# Attack: username = "admin' OR '1'='1"
# Result: SELECT * FROM users WHERE username = 'admin' OR '1'='1'
# Returns all users!

# Attack: username = "admin'; DROP TABLE users; --"
# Result: SELECT * FROM users WHERE username = 'admin'; DROP TABLE users; --'
# Table deleted!

# SECURE: Parameterized query
user_input = request.form['username']
query = "SELECT * FROM users WHERE username = %s"
cursor.execute(query, (user_input,))

# Attack: username = "admin' OR '1'='1"
# Result: SELECT * FROM users WHERE username = 'admin'' OR ''1''=''1'
# Parameterized - treated as literal string, not SQL!
```

### UNION-based Injection

```python
# VULNERABLE
search = request.args.get('q', '')
query = f"SELECT id, title, content FROM articles WHERE title LIKE '%{search}%'"
cursor.execute(query)

# Attack: q = "' UNION SELECT username, password, '1' FROM users--"
# Result: SELECT id, title, content FROM articles 
#          WHERE title LIKE '%' UNION SELECT username, password, '1' FROM users--%'
# Attacker gets all usernames and passwords!
```

### Blind SQL Injection

```python
# Server doesn't output SQL errors but still vulnerable
# Application shows "User not found" for invalid username
# Shows "Welcome" for valid username

# Attacker tests: username = "admin' AND 1=1--"
# Response: "Welcome" (true)
# Attacker knows: admin exists, AND 1=1 is true

# Attacker tests: username = "admin' AND 1=2--"
# Response: "User not found" (false)
# Confirms: Vulnerability exists

# Can enumerate entire database character by character!
```

## Anti-Patterns

### 1. Blacklist Validation

**Bad:**
- Trying to filter SQL keywords
- Blocking known attack patterns
- Easily bypassed with encoding or variations

```python
# BAD: Blacklist approach
blocked = ["UNION", "SELECT", "DROP", "INSERT", "--", ";"]
if any(word in user_input.upper() for word in blocked):
    raise ValueError("Invalid input")
```

**Solution:**
- Use parameterized queries
- Whitelist valid input
- Don't try to filter SQL

### 2. String Formatting in ORM

**Bad:**
- Using raw SQL or string formatting in ORM
- Thinking ORM automatically prevents injection

```python
# BAD: Even with ORM, can be vulnerable
query = f"SELECT * FROM users WHERE name = '{user_input}'"
User.objects.raw(query)

# Also vulnerable:
User.objects.extra(where=[f"name = '{user_input}'"])
```

**Solution:**
- Use ORM properly
- Pass parameters to ORM methods

### 3. Multiple Statements

**Bad:**
- Allowing multiple SQL statements in one query
- Enables DROP, INSERT, etc.

**Solution:**
- Disable multiple statements in connection
- Use stored procedures
- Separate query execution

## Best Practices

### 1. Parameterized Queries

```python
# Python with psycopg2 (PostgreSQL)
query = "SELECT * FROM users WHERE email = %s AND active = %s"
cursor.execute(query, (user_email, True))

# Python with SQLite
query = "INSERT INTO logs (user_id, action) VALUES (?, ?)"
cursor.execute(query, (user_id, action))

# Java with JDBC
PreparedStatement stmt = connection.prepareStatement(
    "SELECT * FROM users WHERE username = ?"
);
stmt.setString(1, username);
ResultSet rs = stmt.executeQuery();
```

### 2. ORM Usage

```python
# SQLAlchemy (Python)
# Safe - ORM handles parameterization
user = session.query(User).filter(
    User.username == username
).first()

# Django ORM (Python)
user = User.objects.get(username=username)

# Spring Data (Java)
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
}
```

### 3. Least Privilege Database User

```sql
-- Application user should NOT have DDL rights
REVOKE CREATE, DROP, ALTER FROM app_user;

-- Only specific permissions
GRANT SELECT, INSERT, UPDATE ON app_db.* TO 'app_user'@'localhost';

-- Read-only for reporting
GRANT SELECT ON reporting_db.* TO 'report_user'@'%';
```

### 4. Web Application Firewall (WAF)

```yaml
# Example ModSecurity rule
SecRule ARGS:id "@rx ^\d+$" \
    "deny,status:400,msg:'Invalid ID parameter'"

# AWS WAF SQL injection rule
- Name: SQLInjectionRule
  Statement:
    SqliMatchStatement:
      FieldToMatch: 
        Body: {}
      TextTransformation: URL_DECODE
  Action:
    Block: {}
```

### 5. Error Handling

```python
# Don't expose database errors to users
try:
    result = execute_query(user_input)
except Exception as e:
    # Log detailed error internally
    logger.error(f"Database error: {e}", exc_info=True)
    
    # Show generic message to user
    return "An error occurred. Please try again later."
```

## Failure Modes

- **String concatenation in SQL queries** → user input directly embedded in SQL → complete database compromise → use parameterized queries exclusively and ban string concatenation for SQL
- **ORM raw query bypass** → using ORM but executing raw SQL with user input → ORM protection bypassed → avoid raw SQL in ORM; when necessary, use parameterized raw queries
- **Blacklist validation instead of parameterization** → trying to filter SQL keywords → easily bypassed with encoding variations → use parameterized queries, not input filtering, as primary defense
- **Insufficient database privileges** → application user has DDL rights → SQL injection can modify schema or drop tables → grant minimum required permissions and use read-only accounts where possible
- **Error messages exposing database structure** → SQL errors returned to users → attackers gain schema information → log detailed errors internally and show generic messages to users
- **Stored procedures with dynamic SQL** → stored procedures build SQL from parameters → injection through procedure parameters → use parameterized queries within stored procedures
- **Second-order SQL injection** → user input stored safely but used unsafely in later query → delayed exploitation → treat all database-stored data as potentially untrusted when used in queries

## Technology Stack

| Tool | Type | Use Case |
|------|------|----------|
| SQLAlchemy | ORM | Python database ORM |
| Hibernate | ORM | Java ORM |
| Django ORM | ORM | Python web framework ORM |
| sqlmap | Tool | Automated SQL injection |
| Burp Suite | Tool | Manual testing |
| OWASP ZAP | Tool | Automated scanning |

## Related Topics

- [[InputValidation]]
- [[XSS]]
- [[CSRF]]
- [[Authentication]]
- [[Authorization]]
- [[SecurityHeaders]]
- [[SQL]]
- [[DatabaseOptimization]]

## Key Takeaways

- SQL injection exploits security vulnerabilities in database queries by injecting malicious SQL through unsanitized user input, enabling data theft, modification, or deletion
- Testing is valuable in all database applications, any endpoint accepting user input, and especially legacy applications with direct SQL queries
- Tradeoff: parameterized query discipline versus development convenience of string concatenation
- Main failure mode: string concatenation in SQL queries embeds user input directly into executable SQL, enabling complete database compromise
- Best practice: use parameterized queries exclusively (never concatenate strings into SQL), use ORMs properly without raw SQL bypasses, grant minimum database permissions, log detailed errors internally while showing generic messages to users, and treat all database-stored data as potentially untrusted
- Related: input validation, XSS, CSRF, authentication, authorization, security headers, SQL, database optimization

## Additional Notes

**SQL Injection Impact:**
- Data exfiltration (read any data)
- Data modification (update/delete)
- Authentication bypass
- Privilege escalation
- Database takeover
- In some cases, OS command execution

**Detection Signs:**
- Unusual database errors in logs
- Unexpected data in responses
- Slow queries (time-based blind injection)
- Unusual database connections

**Prevention Priority:**
1. Parameterized queries (most effective)
2. Input validation (defense in depth)
3. Least privilege database accounts
4. Error handling (don't leak info)