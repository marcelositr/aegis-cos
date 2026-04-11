---
title: Code Quality
title_pt: Qualidade de Código
layer: quality
type: concept
priority: high
version: 1.0.0
tags:
  - Quality
  - CodeQuality
description: Overall measure of code's maintainability, readability, and efficiency.
description_pt: Medida geral de manutenibilidade, legibilidade e eficiência do código.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Code Quality

## Description

Code quality refers to how maintainable, readable, efficient, and reliable code is. High-quality code:
- Is easy to understand
- Is easy to modify
- Has few bugs
- Performs well
- Is well-tested

Quality dimensions:
- **Maintainability**: Easy to change
- **Readability**: Easy to understand
- **Efficiency**: Good performance
- **Testability**: Easy to test
- **Security**: Free from vulnerabilities



## Purpose

**When code quality practices are critical:**
- Long-lived projects with multiple contributors
- Codebases that need frequent changes and refactoring
- Teams with varying skill levels
- Systems where bugs have high cost (finance, healthcare)
- Open source projects with external contributors

**When code quality may be lighter:**
- Throwaway prototypes and proof-of-concepts
- Single-developer scripts with short lifespan
- Hackathons and time-boxed experiments
- Generated code that won't be manually edited

**The key question:** Will someone need to understand and modify this code in 6 months?

## Examples

### Code Quality Checklist

```python
# Before code review, check:
def check_code_quality(code):
    return {
        'naming': has_clear_names(code),
        'functions': is_small_functions(code),
        'comments': has_meaningful_comments(code),
        'tests': has_tests(code),
        'duplication': no_duplication(code)
    }
```

### Quality Metrics

```python
# Common quality metrics
class CodeQualityMetrics:
    def calculate(self, code):
        return {
            'lines': len(code.split('\n')),
            'cyclomatic_complexity': self.complexity(code),
            'maintainability_index': self.maintainability(code),
        }
```

## Metrics
        return self.metrics
    
    def complexity(self, code):
        # Count decision points
        return code.count('if') + code.count('for') + code.count('while')
    
    def maintainability(self, code):
        # Simplified maintainability index
        length_penalty = len(code.split('\n')) / 1000
        complexity_penalty = self.complexity(code) / 100
        return max(0, 100 - (length_penalty * 30 + complexity_penalty * 70))
```

## Anti-Patterns

### 1. Perfectionism Paralysis

**Bad:** Refusing to ship code until every metric is green, every function is under 10 lines, and every variable is perfectly named
**Why it's bad:** Features never ship, the team burns out on refactoring, and the codebase stagnates while competitors move forward
**Good:** Ship working code and improve iteratively — quality is a continuous journey, not a gate that must be perfect before delivery

### 2. Metric Gaming

**Bad:** Developers splitting one function into three to pass cyclomatic complexity checks, or writing meaningless assertions to boost coverage
**Why it's bad:** The numbers look good but the code is worse — you have more functions to understand and tests that verify nothing
**Good:** Use metrics as conversation starters, not pass/fail gates — review the actual code, not just the dashboard

### 3. Tool Obsession

**Bad:** Spending more time configuring linters, formatters, and quality dashboards than writing and reviewing code
**Why it's bad:** The tools become the goal — you optimize for SonarQube scores instead of actual maintainability and user value
**Good:** Configure tools once with sensible defaults, then focus on the code — tools serve developers, not the other way around

### 4. No Standards

**Bad:** Every developer writes code in their own style — different naming conventions, different error handling patterns, different architectural approaches
**Why it's bad:** Reading any file requires understanding the author's personal style — cognitive load is multiplied across the codebase
**Good:** Establish and enforce baseline standards through automated tooling (formatters, linters) and code review conventions

## Best Practices

### 1. Write Clean Code

```python
# Bad
def calc(a,b,c):
    x=a*b+c
    if x>100:
        return x*.1
    return x

# Good
def calculate_discount(price, quantity, tax_rate):
    """Calculate total with discount and tax."""
    subtotal = price * quantity
    discount = subtotal * 0.1 if subtotal > 100 else 0
    total = (subtotal - discount) * (1 + tax_rate)
    return total
```

### 2. Use Meaningful Names

```python
# Bad
def f(x):
    return x * .07

# Good
def calculate_tax(amount, tax_rate=0.07):
    """Calculate tax on amount."""
    return amount * tax_rate
```

### 3. Keep Functions Small

```python
# Bad - long function
def process_order(order):
    # 200 lines of code
    ...

# Good - small functions
def process_order(order):
    validate_order(order)
    calculate_total(order)
    apply_discounts(order)
    save_order(order)
    send_confirmation(order)
```

## Failure Modes

- **Perfectionism** → endless refactoring → no features shipped
- **No standards** → inconsistent codebase → high cognitive load for new developers
- **Tool obsession** → optimizing metrics → ignoring real quality
- **Review bottlenecks** → too strict PR process → slow delivery
- **Quality debt ignored** → compounding complexity → team velocity drops

## Tools

| Tool | Purpose |
|------|---------|
| SonarQube | Quality analysis |
| CodeClimate | Quality metrics |
| ESLint | JavaScript linting |
| Pylint | Python linting |
| Prettier | Code formatting |

## Related Topics

- [[Linting]]
- [[StaticAnalysis]]
- [[Metrics]]
- [[Refactoring]]
- [[TestCoverage]]
- [[TechnicalDebt]]
- [[CyclomaticComplexity]]
- [[CodeReview]]

## Key Takeaways

- Code quality measures maintainability, readability, efficiency, testability, and security—the degree to which code can be understood and modified without introducing defects
- Critical for long-lived multi-contributor projects, frequently changing codebases, teams with varying skill levels, and high-cost bug domains
- Lighter quality practices acceptable for throwaway prototypes, single-developer scripts, hackathons, or generated code
- Tradeoff: long-term maintainability and reduced defect rates versus upfront investment in standards, reviews, and tooling
- Main failure mode: perfectionism paralysis where endless refactoring prevents features from shipping while the team burns out on metrics
- Best practice: ship working code and improve iteratively, use metrics as conversation starters not pass/fail gates, establish baseline standards through automated tooling, and focus on the code not the dashboard
- Related: linting, static analysis, metrics, refactoring, test coverage, technical debt, cyclomatic complexity
