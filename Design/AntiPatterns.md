---
title: Anti-Patterns
title_pt: Anti-Padrões
layer: design
type: concept
priority: high
version: 1.0.0
tags:
  - Design
  - AntiPatterns
description: Common but ineffective solutions to problems that often create more problems.
description_pt: Soluções comuns mas ineficazes que frequentemente criam mais problemas.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Anti-Patterns

## Description

Anti-patterns are common but ineffective solutions to problems that often create more problems than they solve. They're the opposite of design patterns—solutions that seem good initially but lead to trouble.

Recognizing anti-patterns helps you:
- Avoid common mistakes
- Recognize problems early
- Refactor to better solutions
- Make better architectural decisions

## Purpose

**When anti-patterns knowledge is valuable:**
- During code reviews to identify issues
- When debugging complex systems
- During refactoring efforts
- When onboarding new team members
- For teaching junior developers what to avoid

**When anti-patterns may not be relevant:**
- In well-architected greenfield projects with good practices
- For simple scripts/utility code
- When the cost of fixing exceeds the benefit

**The key question:** Is this solution creating more problems than it solves?

## Examples

### From Code Review

```python
# God Object: One class with too many responsibilities
class Manager:
    def process_payment(self): ...
    def send_email(self): ...
    def generate_report(self): ...
    def backup_database(self): ...
    # 30 more methods...

# Refactored: Separate concerns
class PaymentService: ...
class EmailService: ...
class ReportService: ...
class BackupService: ...
```

### From Architecture Decisions

```python
# Golden Hammer: Using one tool for everything
# "Let's store everything in MongoDB!"
# User profiles, shopping cart, analytics, files...

# Refactored: Right tool for each job
# Users: PostgreSQL (relational)
# Cart: Redis (fast updates)
# Analytics: ClickHouse (time series)
# Files: S3 (blob storage)
```

## Common Anti-Patterns

### 1. God Object

```python
# Anti-pattern: one class does everything
class Application:
    def __init__(self):
        self.database = Database()
        self.cache = Cache()
        self.auth = Auth()
        self.api = API()
        self.email = Email()
        self.reporting = Reporting()
        # ... 50 more responsibilities!
```

**Solution:** Single Responsibility Principle

### 2. Golden Hammer

```python
# Anti-pattern: using favorite tool for everything
# "We need a database!" -> "Everything fits in my database"
# "I love regex!" -> "Let's parse XML with regex!"
```

**Solution:** Choose right tool for the job

### 3. Spaghetti Code

```python
# Anti-pattern: no structure
def process():
    if x:
        for i in range(10):
            if y:
                # Deeply nested, no clear flow
                pass
```

**Solution:** Structure code properly

### 4. Cargo Cult Programming

```python
# Anti-pattern: copying without understanding
# "I saw this pattern in a tutorial, let's use it everywhere!"
```

**Solution:** Understand why before using

### 5. Premature Optimization

```python
# Anti-pattern: optimizing before needed
# Complex code that could be simple
# Just because "it might be slow"
```

**Solution:** Measure first, optimize when needed

### 6. Copy-Paste Programming

```python
# Anti-pattern: duplicating code
def calculate_user():
    # 50 lines
    ...

def calculate_order():
    # Same 50 lines!
    ...
```

**Solution:** DRY - Don't Repeat Yourself

### 7. Tunnel Vision

```python
# Anti-pattern: only seeing your code
# "My code is perfect, the bug must be in someone else's code"
```

**Solution:** Be humble, check your code first

## Failure Modes

- **Normalizing anti-patterns as acceptable** → team stops recognizing bad patterns → codebase quality degrades silently → maintain anti-pattern awareness through code reviews and team education
- **Applying anti-pattern fixes without understanding root cause** → symptoms addressed but underlying design issues remain → anti-patterns reappear in different forms → analyze why anti-pattern emerged before refactoring
- **Over-refactoring to eliminate all anti-patterns** → spending more time fixing than delivering → diminishing returns on quality investment → prioritize anti-patterns by impact and address incrementally
- **Misidentifying patterns as anti-patterns** → refactoring working solutions into worse designs → introducing new bugs while "fixing" → verify pattern classification against established definitions before changing
- **Anti-pattern documentation without action** → team knows anti-patterns exist but never addresses them → documentation becomes ignored noise → track anti-pattern remediation in backlog with priority
- **Golden hammer anti-pattern in tool selection** → using familiar tools for every problem regardless of fit → suboptimal solutions and technical debt → evaluate tools against problem requirements, not familiarity
- **Cargo cult programming from tutorials** → copying code patterns without understanding context → inappropriate solutions for actual problem → understand the why behind every pattern before adopting

## Anti-Patterns

### 1. Treating Anti-Patterns as Checklists

**Bad:** Using anti-pattern catalogs as rigid checklists to flag every minor deviation
**Why it's bad:** Creates analysis paralysis, slows development, and breeds a blame culture instead of a learning one
**Good:** Use anti-pattern awareness as a lens for discussion during code reviews, not as a scoring system

### 2. Refactoring Without Measuring Impact

**Bad:** Refactoring to eliminate an anti-pattern without measuring whether it actually improves the system
**Why it's bad:** Some anti-patterns are pragmatic trade-offs; removing them can introduce complexity without meaningful benefit
**Good:** Assess the real cost of the anti-pattern in your context before investing in a fix

### 3. Solutioneering Anti-Patterns

**Bad:** Applying a known refactoring pattern to fix an anti-pattern without understanding the root cause
**Why it's bad:** The anti-pattern is often a symptom of deeper issues (bad requirements, time pressure, knowledge gaps) that will cause it to reappear
**Good:** Investigate why the anti-pattern emerged — fix the process or constraint that caused it, not just the code

### 4. Anti-Pattern Documentation Without Action

**Bad:** Cataloging anti-patterns in documentation or wikis that nobody reads or acts on
**Why it's bad:** Creates an illusion of progress while the codebase continues to degrade
**Good:** Track anti-pattern remediation in the backlog with priority, and address them incrementally alongside feature work

## Best Practices

1. **Think before coding** - Choose right solution
2. **Keep it simple** - YAGNI
3. **Understand patterns** - Don't copy blindly
4. **Refactor early** - Don't let debt accumulate

## Related Topics

- [[Design MOC]]
- [[CodeSmells]]
- [[Refactoring]]
- [[DesignPatterns]]
- [[CodeQualityHandbook]]

## Key Takeaways

- Anti-patterns are common but ineffective solutions that create more problems than they solve—the opposite of design patterns
- Study them during code reviews, debugging complex systems, refactoring efforts, and when onboarding team members
- Avoid treating anti-pattern catalogs as rigid checklists; some are pragmatic trade-offs in specific contexts
- Tradeoff: awareness prevents costly mistakes versus risk of analysis paralysis and perfectionist culture
- Main failure mode: normalizing anti-patterns as acceptable causes codebase quality to degrade silently across the team
- Best practice: use anti-pattern awareness as a discussion lens in code reviews, analyze root causes before refactoring, and track remediation in the backlog with priority
- Related: code smells, refactoring, design patterns, code quality

## Additional Notes
