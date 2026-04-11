---
title: YAGNI Principle
title_pt: Princípio YAGNI
layer: principles
type: concept
priority: high
version: 1.0.0
tags:
  - Principles
  - YAGNI
description: You Aren't Gonna Need It - don't add functionality until it's necessary.
description_pt: Você Não Vai Precisar - não adicione funcionalidade até que seja necessário.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# YAGNI Principle

## Description

YAGNI (You Aren't Gonna Need It) advises against adding functionality until it's actually needed. Adding features "just in case":
- Creates waste
- Increases complexity
- Takes time away from real needs
- Makes code harder to maintain

## Purpose

**When YAGNI is valuable:**
- When building MVPs or prototypes
- When requirements are unclear or evolving
- When facing tight deadlines
- When working on side projects with minimal scope
- When team has limited capacity

**When YAGNI may NOT be appropriate:**
- When building foundational infrastructure (databases, auth, core APIs)
- When API contracts are already established and stable
- When changing cost is high (changing public APIs later is expensive)
- When dealing with security-critical systems where retrofitting is risky
- When working with external integrations that have long lead times

**The key question:** Is the cost of adding this feature NOW less than the cost of adding it LATER when we actually need it?

## Rules

1. **Add code only when needed** - Not "just in case", only when "right now"
2. **Trust refactoring** - Modern tools make changes easier
3. **Delete unused code** - Don't keep "potential" code
4. **Measure YAGNI costs** - Track time spent on unused features
5. **Distinguish speculation from certainty** - "We definitely need X" vs "We might need X"

## Examples

### Bad - Over-Engineering

```python
# Adding "flexibility" that never gets used
class UserService:
    def __init__(self, db, cache=None, queue=None, 
                 webhook=None, analytics=None, logger=None):
        # All these parameters added "for future use"
        # Never used!
        self.db = db
        self.cache = cache
        self.queue = queue
        self.webhook = webhook
        self.analytics = analytics
        self.logger = logger
```

### Good - Start Simple

```python
# Start with what you need
class UserService:
    def __init__(self, db):
        self.db = db
    
    def get_user(self, user_id):
        return self.db.query("SELECT * FROM users WHERE id = ?", [user_id])

# Add features when needed
class UserService:
    def __init__(self, db, cache=None):  # Add cache when needed
        self.db = db
        self.cache = cache
```

### Bad - Framework Before Need

```python
# "What if we need to support different databases?"
# Adding abstraction for hypothetical future

class UserRepository:
    def save(self, user):
        # Complex abstraction layer
        if self.db_type == 'mysql':
            self._save_mysql(user)
        elif self.db_type == 'postgres':
            self._save_postgres(user)
        elif self.db_type == 'mongo':
            self._save_mongo(user)
        # All this code for databases you don't use!
```

### Good - Solve Current Problem

```python
# Use what you need now
class UserRepository:
    def save(self, user):
        self.db.insert('users', user.to_dict())
    
    def find(self, user_id):
        return self.db.select_one('users', {'id': user_id})

# Add abstraction when actually needed
# Refactor later when requirement appears
```

## Anti-Patterns

### 1. YAGNI Used to Skip Essential Infrastructure

**Bad:** Avoiding authentication, logging, error handling, or input validation because "we don't need it yet"
**Why it's bad:** When the system goes live, these are not optional — retrofitting them is far more expensive than building them from the start
**Good:** Distinguish speculative features from essential infrastructure — security, observability, and error handling are not YAGNI candidates

### 2. YAGNI Preventing API Versioning

**Bad:** Not planning for API evolution because "we'll cross that bridge when we get there"
**Why it's bad:** Breaking API changes force coordinated deployments across all consumers — the cost of retrofitting versioning is enormous
**Good:** Design APIs with versioning from the start — API contracts are expensive to change, and versioning is cheap to add early

### 3. Framework Selection Without Growth in Mind

**Bad:** Choosing the simplest possible framework that cannot scale, then facing a complete migration when the project grows
**Why it's bad:** Framework migrations are among the most expensive changes — they touch every file and require retesting everything
**Good:** Choose frameworks that can grow with the project — simplicity now should not preclude scalability later

### 4. Avoiding Abstractions at Boundaries

**Bad:** No interfaces or abstractions at system boundaries because "we only have one implementation right now"
**Why it's bad:** Makes the system impossible to test in isolation and locks you into a single implementation — swapping becomes a rewrite
**Good:** Use abstractions at boundaries even with a single implementation — it enables testing, future flexibility, and clear contracts

## Best Practices

### 1. Solve Today's Problem

```python
# Don't build for hypothetical future
# Build for current requirements
# Refactor when needs change
```

### 2. Trust That You Can Refactor

```python
# Don't over-engineer "just in case"
# Modern tools make refactoring easy
# It's okay to add abstraction when needed
```

### 3. Remove Dead Code

```python
# Don't keep unused code
# If you need it later, you can recover from git
# Keep codebase clean
```

## Failure Modes

- **YAGNI used to skip essential infrastructure** → avoiding auth, logging, or error handling as not needed yet → production incidents when system goes live → distinguish speculative features from essential infrastructure
- **Misjudging what is gonna be needed** → underestimating requirements leads to costly rework → delayed delivery and technical debt → use domain knowledge to distinguish speculation from certainty
- **YAGNI preventing API versioning** → not planning for API evolution → breaking changes force coordinated deployments → design APIs with versioning from start; API contracts are expensive to change
- **Dead code kept just in case** → commented-out code or unused features accumulate → codebase becomes confusing → delete unused code; version control preserves it if needed later
- **YAGNI applied to non-functional requirements** → skipping performance, security, or scalability considerations → system fails under real load → non-functional requirements are not YAGNI candidates
- **Framework selection without future needs** → choosing simplest framework that cannot scale → complete framework migration when growth happens → choose frameworks that can grow with the project
- **Avoiding abstraction for current simplicity** → no interfaces or abstractions because we only have one implementation → impossible to test or swap implementations → use abstractions at boundaries even with single implementation

## Related Topics

- [[KISS]]
- [[DRY]]
- [[Refactoring]]
- [[TechnicalDebt]]
- [[CodeQuality]]
- [[Modularity]]
- [[SOLID]]
- [[Cohesion]]

## Key Takeaways

- YAGNI advises against adding functionality until actually needed, avoiding waste and complexity from speculative features
- Valuable for MVPs, evolving requirements, tight deadlines, and side projects with minimal scope
- Not appropriate for foundational infrastructure, established API contracts, security-critical systems, or external integrations with long lead times
- Tradeoff: avoiding wasted effort on unused features versus risk of costly rework when underestimated requirements materialize
- Main failure mode: using YAGNI to skip essential infrastructure like auth, logging, or error handling causes production incidents when system goes live
- Best practice: distinguish speculative features from essential infrastructure, design APIs with versioning from start, use abstractions at boundaries even with single implementations, and delete unused code relying on version control for recovery
- Related: KISS, DRY, refactoring, technical debt, code quality, modularity, SOLID
