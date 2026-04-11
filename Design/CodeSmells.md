---
title: Code Smells
title_pt: Cheiros de Código
layer: design
type: concept
priority: high
version: 1.0.0
tags:
  - Design
  - CodeSmells
description: Indicators of possible problems in code that may indicate deeper issues.
description_pt: Indicadores de problemas possíveis no código que podem indicar questões mais profundas.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Code Smells

## Description

Code smells are surface indications that usually correspond to deeper problems in the system. They're not bugs, but patterns that suggest the code might be difficult to maintain or extend.

Unlike errors, code compiles and runs. But smells make code harder to:
- Understand
- Test
- Extend
- Debug

**When code smell detection is valuable:**
- During code reviews
- Before refactoring efforts
- When investigating maintainability issues
- For establishing code quality baselines

**When code smells may be acceptable:**
- In prototypes where speed matters over quality
- For one-off scripts
- When refactoring cost exceeds benefit

**The key question:** Does this code pattern suggest a deeper problem?



## Purpose

**When this is valuable:**
- For understanding and applying the concept
- For making architectural decisions
- For team communication

**When this may not be needed:**
- For quick reference
- For simple implementations
- When basics are well understood

**The key question:** How does this concept help us build better software?

## Common Categories
- Bloaters: Code too large
- Object-Orientation Abusers: OOP misuse
- Change Preventers: Hard to change
- Dispensables: Unnecessary elements
- Couplers: Excessive coupling

## Examples

### Long Method

```python
# Smell: method too long
def process_order(order):
    # 100 lines of code
    # Hard to understand
    # Hard to test
    # Should extract smaller functions
```

### Duplicate Code

```python
# Smell: same code in multiple places
def update_user_profile(user):
    user.name = sanitize_input(user.name)
    user.email = sanitize_input(user.email)
    # ... save

def update_user_settings(user):
    user.theme = sanitize_input(user.theme)
    user.language = sanitize_input(user.language)
    # ... save

# Should extract sanitize_and_save()
```

### God Class

```python
# Smell: class does too much
class UserManager:
    def create_user(self): ...  # User logic
    def send_email(self): ...  # Email logic
    def generate_report(self): ...  # Report logic
    def backup_database(self): ...  # Backup logic
    def process_payment(self): ...  # Payment logic
```

### Feature Envy

```python
# Smell: class uses another class's data too much
class OrderPrinter:
    def print(self, order):
        # Envy for order's data
        print(order.customer.name)
        print(order.customer.email)
        print(order.customer.address)
        # Should be in Order class
```

## Anti-Patterns

### 1. Smell Hunting Without Context

**Bad:** Flagging every code smell in a codebase without understanding the business context or history
**Why it's bad:** Some smells are intentional trade-offs — a long method in a throwaway prototype is not the same as one in core business logic
**Good:** Evaluate smells in context — consider the code's importance, stability, and likelihood of future change

### 2. Fixing One Smell, Creating Another

**Bad:** Extracting a long method's parameters into a single "parameter object" that becomes a god data class
**Why it's bad:** You've replaced one smell (long parameter list) with another (god class / data clump) without improving design
**Good:** Group related parameters into cohesive value objects that represent meaningful domain concepts

### 3. Smell-Driven Development

**Bad:** Prioritizing smell remediation over delivering user value, treating every smell as an emergency
**Why it's bad:** Creates a perfectionist culture that ships nothing — some smells are acceptable in stable, well-tested code
**Good:** Address smells when they impede change or understanding, not as an end in themselves

### 4. Automated Smell Detection Without Human Review

**Bad:** Relying solely on static analysis tools to identify and fix code smells automatically
**Why it's bad:** Tools lack context and can misidentify legitimate patterns as smells, or miss subtle design issues
**Good:** Use tools as advisors, not arbiters — combine automated detection with human judgment during code review

## Best Practices

### 1. Recognize Smells

- Long methods (>20 lines)
- Too many parameters (>4)
- Duplicate code
- God classes
- Feature envy
- Tight coupling

### 2. Address Smells

- Extract methods
- Rename variables
- Break up classes
- Remove dead code

## Failure Modes

- **Ignoring code smells as not bugs** → smells accumulate until refactoring becomes impossible → codebase becomes unmaintainable → treat code smells as technical debt and address in regular refactoring cycles
- **False positive smell detection** → flagging legitimate patterns as smells → wasting time on non-issues → understand context before labeling code as smelly
- **Refactoring smells without tests** → changing code structure without safety net → introducing regressions while improving code → ensure adequate test coverage before refactoring
- **God class decomposition without understanding** → splitting large class without knowing responsibilities → creating more classes with same problems → map dependencies before breaking apart
- **Feature envy fix creating inappropriate coupling** → moving method to data-owning class violates single responsibility → new smell replaces old → evaluate both coupling and cohesion when relocating methods
- **Long parameter list fix with god parameter object** → wrapping all params in one class → parameter object becomes god class → group related parameters into cohesive value objects
- **Over-reacting to smells in prototype code** → refactoring throwaway code → wasted effort → distinguish production code from prototypes and apply smell remediation selectively

## Related Topics

- [[Design MOC]]
- [[AntiPatterns]]
- [[Refactoring]]
- [[CodeQualityHandbook]]
- [[TDD]]

## Key Takeaways

- Code smells are surface indicators of deeper design problems—not bugs, but patterns that make code harder to understand, test, and extend
- Detect smells during code reviews, before refactoring, when investigating maintainability issues, or establishing quality baselines
- Accept smells in prototypes, one-off scripts, or when refactoring cost exceeds benefit
- Tradeoff: smell remediation improves long-term maintainability versus time investment that may not deliver immediate user value
- Main failure mode: ignoring code smells as "not bugs" lets them accumulate until the codebase becomes unmaintainable
- Best practice: evaluate smells in context (importance, stability, likelihood of change), address them when they impede change, and ensure test coverage before refactoring
- Related: anti-patterns, refactoring, code quality, test-driven development

## Additional Notes
