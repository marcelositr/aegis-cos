---
title: Regular Expressions
title_pt: Expressoes Regulares
layer: quality
type: concept
priority: high
version: 2.0.0
tags:
  - Quality
  - Regex
  - Patterns
  - Parsing
  - Security
  - Validation
description: Pattern matching language for searching, validating, and transforming text -- with specific attention to correctness, performance, and security implications.
description_pt: Linguagem de correspondencia de padroes para buscar, validar e transformar texto -- com atencao especifica a correcao, desempenho e implicacoes de seguranca.
prerequisites:
  - [[CodeQuality]]
  - [[Security]]
estimated_read_time: 15 min
difficulty: intermediate
---

# Regular Expressions

## Description

Regular expressions (regex) are a domain-specific language for pattern matching in text. Despite the name, most implementations used in software engineering are **not** mathematically regular -- they support backreferences, lookahead, and other features that exceed the expressive power of regular languages.

Common regex engines:

| Engine | Languages | Algorithm | ReDoS Safe? |
|---|---|---|---|
| **PCRE** | PHP, C (libpcre), Node.js (via `pcre2`) | Backtracking (NFA) | No |
| **RE2** | Go, available for C++/Python/Java | DFA/NFA hybrid | Yes (guaranteed linear time) |
| **Python `re`** | Python | Backtracking (NFA) | No |
| **Python `regex`** | Python (third-party) | Backtracking with possessive quantifiers | No |
| **Java `java.util.regex`** | Java, Kotlin | Backtracking (NFA) | No |
| **Rust `regex`** | Rust | DFA (NFA simulation) | Yes (guaranteed linear time) |
| **JavaScript** | JavaScript/TypeScript | Backtracking (NFA) | No |

The critical distinction is **backtracking vs. DFA-based** engines. Backtracking engines (most common) can exhibit catastrophic backtracking (ReDoS) on crafted input. DFA-based engines guarantee linear-time matching but may lack features like backreferences.

Regex is simultaneously one of the most useful and most misused tools in software engineering. A well-written regex can replace 20 lines of string manipulation. A poorly-written regex can be a security vulnerability, a performance bottleneck, and a maintenance nightmare -- often all three.

## When to Use

- **Input validation**: Email format, phone number structure, URL format, UUID patterns, ISBN, postal codes. Where the pattern is well-defined and finite.
- **Log parsing and extraction**: Extract structured fields from semi-structured log lines (`^(?P<timestamp>\S+) \[(?P<level>\w+)\] (?P<message>.*)$`).
- **Search and replace across codebases**: Refactoring operations, finding usage patterns, bulk text transformations (`sed`, `grep -P`, IDE find-and-replace).
- **Tokenization in parsers**: Breaking input into tokens (keywords, identifiers, numbers, operators) as the first stage of parsing. Many parser generators (ANTLR, Lex) use regex for token definitions.
- **Routing patterns**: URL route definitions (`/users/(?P<id>\d+)`), API path matching, URL rewriting rules.
- **Data sanitization**: Stripping HTML tags, removing control characters, normalizing whitespace before processing.

## When NOT to Use

- **Parsing HTML/XML**: Regex cannot correctly parse nested structures. `/<tag>(.*?)<\/tag>/` fails on nested tags, attributes with `>` in values, CDATA sections, and comments. Use a proper parser (BeautifulSoup, DOMParser, xml.etree).
- **Email validation beyond basic format check**: The RFC 5322 spec for valid emails is so complex that a compliant regex is thousands of characters long and still misses edge cases (quoted strings, IP literals, comments). Use a basic format check (`[^@]+@[^@]+\.[^@]+`) and send a verification email.
- **Matching balanced/nested structures**: Parentheses, JSON objects, nested comments, markdown with nested formatting. Regex has no stack; it cannot count. Use a parser with a grammar.
- **When the pattern is better expressed as simple string operations**: `text.startswith("http://")` is faster, more readable, and less error-prone than `re.match(r'^https?://', text)`. Prefer string methods for simple checks.
- **Performance-critical hot paths with untrusted input**: If you are processing millions of strings per second and any one of them could be crafted to trigger catastrophic backtracking, use a DFA-based engine (RE2, Rust regex) or avoid regex entirely.
- **Patterns that will be maintained by people who do not know regex**: A regex like `^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?$` for phone numbers is unmaintainable. Use a library (libphonenumber).

## Tradeoffs

| Aspect | Regex | String Methods | Parser |
|---|---|---|---|
| Expressiveness | High: complex patterns in one line | Low: only prefix, suffix, contains, split | Highest: arbitrary grammar |
| Performance | Variable: O(n) to O(2^n) depending on engine and pattern | O(n): always linear | O(n) to O(n^3) depending on grammar |
| Readability | Low: requires regex literacy | High: self-documenting | Medium: grammar is explicit |
| Maintainability | Low: small changes can break the whole pattern | High: each operation is independent | High: grammar rules are modular |
| Security | Risk of ReDoS with backtracking engines | No security risk | Depends on parser implementation |
| Error handling | Binary: match or no match | Binary: true or false | Rich: parse errors with position and context |
| Learning curve | Steep: special syntax, engine-specific behavior | Shallow: familiar methods | Moderate: grammar notation and parsing concepts |

The regex vs. parser decision is the most consequential. **Regex for tokenization, parser for structure.** Use regex to break input into tokens, then use a parser (even a simple recursive descent parser) to validate structure.

## Alternatives

- **String methods**: `startsWith`, `endsWith`, `includes`, `split`, `replace`. Always prefer these for simple pattern checks. They are faster, safer, and more readable.
- **Parsing libraries**: For structured data (JSON, XML, YAML, CSV), use dedicated parsers. They handle edge cases (escaping, encoding, nested structures) that regex cannot.
- **Parser combinators**: Build parsers from composable functions (Parsec in Haskell, nom in Rust, Lepl in Python). More readable than regex for complex patterns and produce structured output.
- **Grammar-based parsers**: ANTLR, Tree-sitter, Lark define formal grammars that generate parsers. Best for complex languages (programming languages, query languages, configuration formats).
- **Validation libraries**: Joi, Zod, Pydantic, validator.js provide typed validation with readable error messages. Better than regex for form validation because they produce human-readable error reports.
- **DFA-based regex engines**: RE2 (Go, C++, Python binding), Rust `regex` crate. Guarantee linear-time matching, immune to ReDoS. Trade: no backreferences, no lookahead in some implementations.

## Failure Modes

1. **Catastrophic backtracking (ReDoS)**: The pattern `(a+)+` matching against `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!` (30 a's followed by `!`) takes 2^30 = 1 billion steps. With 50 a's, it takes 2^50 steps -- effectively infinite. The thread is pinned at 100% CPU, causing denial of service. This is CVE-worthy: Cloudflare, Express.js, and many others have had ReDoS vulnerabilities. Mitigation: use DFA-based engines (RE2, Rust regex) for untrusted input. Test patterns with tools like `regex-static-analysis` or `recheck`. Avoid nested quantifiers (`(a+)+`, `(a*)*`, `(a+)*`). Use atomic grouping `(?>...)` or possessive quantifiers (`a++`) where available.

2. **Catastrophic backtracking with lookahead**: `^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$` (password validation) backtracks exponentially on inputs that partially match. On a 100-character input with no digits, the engine tries every position for each lookahead. Mitigation: replace regex password validation with explicit checks: `len >= 8 and any(c.isdigit()) and any(c.isupper())`. It is faster, more readable, and immune to backtracking.

3. **False positives from overly permissive patterns**: `.*\.com$` matches `evil.com.malicious-site.com` and `not-a-domain.com\nmalicious.com` (multiline bypass). The regex `^https?://.*\.google\.com/.*` matches `http://evil.com.google.com/phishing/` because it checks for `.google.com/` anywhere in the path. Mitigation: anchor patterns with `^` and `$`. Use word boundaries `\b`. Be specific about what each component matches. Test against known malicious inputs.

4. **False negatives from overly restrictive patterns**: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` rejects valid emails like `user@localhost` (no dot in domain), `user@sub.domain.museum` (TLD longer than 2 chars is fine), and `test+tag@example.com` (some implementations miss the `+`). Mitigation: use a permissive regex for format checking and verify by sending an email. Do not reject potentially valid inputs based on regex alone.

5. **Unicode and encoding surprises**: `\w` matches `[a-zA-Z0-9_]` in ASCII mode but matches thousands of Unicode characters (including letters from all scripts) in Unicode mode. `[a-z]` may or may not match accented characters depending on locale. `.` does not match newlines by default but matches them with the `s` flag. The string `café` has length 4 in NFC but length 5 in NFD (the `é` is decomposed to `e` + combining accent). Mitigation: always use Unicode-aware patterns. Normalize input to NFC before matching. Test with non-ASCII inputs. Explicitly set regex flags (`re.UNICODE`, `re.DOTALL`).

6. **Regex injection (ReDoS via user input)**: An application builds a regex from user input: `new RegExp(userInput)` where `userInput` is a search filter. An attacker provides `(a+)+` as input, causing the server to spend exponential time matching. Mitigation: never build regex from user input without escaping. Use `re.escape()` (Python), `Regex.escape()` (C#), or equivalent. If user-provided patterns are required, use a DFA-based engine that guarantees linear time.

7. **Maintenance debt of complex patterns**: A regex written six months ago that validates a configuration format needs modification. The original author is gone. The regex has no comments, no tests, and no documentation. Adding a new field breaks existing matches in an unexpected way. Mitigation: use verbose/raw string mode with comments (`re.VERBOSE` in Python, `(?x)` flag). Break complex patterns into named groups. Write unit tests for every valid and invalid input case. Document the pattern's purpose and limitations.

## Code Examples

### ReDoS vulnerability and fix

```python
import re
import time

# VULNERABLE: nested quantifiers cause catastrophic backtracking
# Pattern: match a comma-separated list of words
VULNERABLE_PATTERN = re.compile(r'^(\w+,)*\w+$')

# Test with a crafted input that almost matches but fails at the end
malicious_input = 'a,' * 30 + '!'  # 60 characters

start = time.time()
result = VULNERABLE_PATTERN.match(malicious_input)
elapsed = time.time() - start
print(f"Vulnerable: {'match' if result else 'no match'} in {elapsed:.3f}s")
# On many systems: no match in 15.234s (effectively DoS)

# FIX: use a DFA-based engine or restructure the pattern
# Option 1: Use RE2 via the `re2` Python package (if available)
# import re2
# safe_pattern = re2.compile(r'^(\w+,)*\w+$')  # Guaranteed linear time

# Option 2: Avoid regex entirely
def is_valid_csv(text: str) -> bool:
    """Check if text is a comma-separated list of word characters."""
    if not text:
        return False
    parts = text.split(',')
    return all(part.isalnum() or '_' in part for part in parts if part)

start = time.time()
result = is_valid_csv(malicious_input)
elapsed = time.time() - start
print(f"Safe (string methods): {'match' if result else 'no match'} in {elapsed:.6f}s")
# No match in 0.000012s -- 1,000,000x faster

# Option 3: Use possessive quantifiers (if engine supports them)
# In Python, use the `regex` module with possessive quantifiers
# SAFE_PATTERN = regex.compile(r'^(\w++,)*\w+$')
# The ++ means "match as many as possible, never give back" -- no backtracking
```

### Production-ready email validation

```python
import re
from email_validator import validate_email, EmailNotValidError

# BAD: trying to validate email with regex alone
# This regex is already incomplete (rejects valid emails)
# and the RFC 5322 compliant version is thousands of chars long
BASIC_EMAIL_REGEX = re.compile(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')

def naive_email_check(email: str) -> bool:
    return bool(BASIC_EMAIL_REGEX.match(email))

# Problems:
# - Accepts: "test@domain" (no TLD validation)
# - Rejects: "user+tag@example.com" (plus sign in local part is valid)
# - Accepts: "test@example.c" (single-char TLD may be invalid)
# - Does not check: does the domain actually exist?

# GOOD: use a validation library that does format + DNS check
def validate_email_proper(email: str) -> tuple[bool, str]:
    """
    Validate email format and optionally check domain exists.
    Returns (is_valid, error_message).
    """
    try:
        # Checks format AND verifies domain has MX record
        validated = validate_email(email, check_deliverability=True)
        normalized = validated.normalized  # Normalized form
        return True, f"Valid: {normalized}"
    except EmailNotValidError as e:
        return False, str(e)

# If you MUST use regex (no dependencies allowed), use a permissive check
# and verify by sending a confirmation email
def basic_email_format_check(email: str) -> bool:
    """
    Only checks basic format. Does NOT guarantee the email is deliverable.
    Always verify by sending a confirmation email.
    """
    # Permissive: allows most valid emails, may allow some invalid ones
    # This is intentional -- better to accept and verify than to reject valid input
    pattern = re.compile(r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
    return bool(pattern.match(email)) and len(email) <= 254
```

### Well-documented complex regex (log parsing)

```python
import re
from datetime import datetime

# Apache Combined Log Format parser
# Example line:
# 192.168.1.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /api/users HTTP/1.1" 200 2326 "http://www.example.com" "Mozilla/5.0"

LOG_PATTERN = re.compile(r'''
    ^(?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})  # Client IP address
    \s+
    (?P<ident>\S+)                                  # RFC 1413 identity (usually -)
    \s+
    (?P<user>\S+)                                   # Authenticated user (or -)
    \s+
    \[(?P<timestamp>[^\]]+)\]                       # Request timestamp in brackets
    \s+
    "(?P<method>[A-Z]+)                             # HTTP method
    \s+
    (?P<path>\S+)                                   # Request path
    \s+
    (?P<protocol>HTTP/\d\.\d)"                      # HTTP protocol version
    \s+
    (?P<status>\d{3})                               # Response status code
    \s+
    (?P<size>\d+|-)                                 # Response size (or - for 0)
    (?:\s+"(?P<referer>[^"]*)")?                    # Referer header (optional)
    (?:\s+"(?P<user_agent>[^"]*)")?                 # User-Agent header (optional)
    $
''', re.VERBOSE)

def parse_log_line(line: str) -> dict | None:
    """Parse a single Apache Combined Log Format line.

    Returns a dict with typed fields, or None if the line does not match.

    Tested formats:
    - Apache 2.4 Combined Log Format
    - Nginx default log format (equivalent to Apache Combined)

    Known limitations:
    - Does not handle multi-line log entries
    - Does not parse the timestamp into a datetime (use dateutil for that)
    - User-Agent and Referer may be None if absent from the log line
    """
    match = LOG_PATTERN.match(line.strip())
    if not match:
        return None

    data = match.groupdict()
    # Convert typed fields
    data['status'] = int(data['status'])
    data['size'] = 0 if data['size'] == '-' else int(data['size'])
    data['ip'] = tuple(int(octet) for octet in data['ip'].split('.'))
    return data

# Unit tests for the parser:
# assert parse_log_line('192.168.1.1 - - [10/Oct/2000:13:55:36 -0700] "GET /index.html HTTP/1.1" 200 1234 "-" "Mozilla/5.0"') == {...}
# assert parse_log_line('invalid log line') is None
# assert parse_log_line('...')['status'] == 404  # Test various status codes
```

### Regex injection prevention

```python
import re

def search_user_filter(user_query: str, documents: list[str]) -> list[str]:
    """
    Search documents matching a user-provided pattern.

    SECURITY: User input is escaped before use in regex to prevent
    ReDoS attacks via crafted patterns like (a+)+.
    """
    # ESCAPE: treat user input as literal text, not regex syntax
    escaped_query = re.escape(user_query)

    # Build safe pattern
    pattern = re.compile(escaped_query, re.IGNORECASE)

    return [doc for doc in documents if pattern.search(doc)]

# Alternative: use DFA-based engine for untrusted input
# pip install google-re2
# import re2
# def search_safe(user_query: str, documents: list[str]) -> list[str]:
#     # RE2 guarantees linear-time matching, immune to ReDoS
#     pattern = re2.compile(user_query)
#     return [doc for doc in documents if pattern.search(doc)]

# Alternative 2: if you do not need regex at all, use substring matching
def search_simple(query: str, documents: list[str]) -> list[str]:
    """Simple substring search -- no regex, no ReDoS risk."""
    query_lower = query.lower()
    return [doc for doc in documents if query_lower in doc.lower()]
```

## Best Practices

- **Prefer string methods over regex for simple checks**: If you can express the check with `startsWith`, `endsWith`, `includes`, `split`, or `replace`, do so. It is faster, safer, and more readable.
- **Always anchor validation patterns**: Use `^` and `$` (or `\A` and `\Z` in some engines) to ensure the entire input matches, not just a substring. A pattern intended to validate emails should not match a substring within a longer string.
- **Test with adversarial inputs**: Include long strings (10,000+ characters), strings with repeated characters (`aaaa...`), and strings that almost match but fail at the end. Use ReDoS testing tools like `recheck` or `safe-regex`.
- **Use named groups for readability**: `(?P<email>[^@]+@[^@]+\.[^@]+)` is self-documenting; `([^@]+@[^@]+\.[^@]+)` requires the reader to parse the pattern to understand what it captures.
- **Write tests for every regex pattern**: Test valid inputs (expect match), invalid inputs (expect no match), edge cases (empty string, maximum length, Unicode), and adversarial inputs (ReDoS attempts).
- **Use verbose mode for complex patterns**: The `re.VERBOSE` flag (Python), `(?x)` flag (many engines), or `#` comments (PCRE) allow you to document what each part of the pattern does. A 200-character regex without comments is a time bomb.
- **Choose the right engine for the threat model**: If the regex processes untrusted input, use a DFA-based engine (RE2, Rust regex). The feature limitations (no backreferences) are a worthwhile tradeoff for ReDoS immunity.
- **Never build regex from user input without escaping**: User-provided patterns are a ReDoS vector. Use `re.escape()` or equivalent, or use a DFA-based engine that guarantees linear-time matching regardless of pattern.

## Related Topics

- [[Security]] -- ReDoS as an attack vector, regex injection, input validation security
- [[CodeQuality]] -- regex readability, documentation, and maintainability
- [[StaticAnalysis]] -- tools that detect ReDoS-vulnerable patterns in code
- [[Linting]] -- eslint rules for regex safety (e.g., `no-useless-escape`, `no-unsafe-regex`)
- [[Performance]] -- regex engine performance characteristics, backtracking complexity
- [[DataProcessing]] -- regex for log parsing, data extraction, and text transformation
- [[TypeSafety]] -- typed regex libraries that validate patterns at compile time
- [[Parsing]] -- when to use regex vs. when to use a proper parser
- [[QualityGates]] -- static analysis gates for regex safety in CI/CD
