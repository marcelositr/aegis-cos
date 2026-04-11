---
title: Mutation Testing
title_pt: Teste de Mutação
layer: testing
type: concept
priority: medium
version: 1.0.0
tags:
  - Testing
  - Mutation
  - Quality
description: Testing technique that makes small changes to code to verify test quality.
description_pt: Técnica de teste que faz pequenas mudanças no código para verificar qualidade dos testes.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Mutation Testing

## Description

Mutation testing is a quality assurance technique that evaluates the effectiveness of a test suite by introducing small, controlled changes (mutations) to the source code and verifying that the existing tests can detect these changes. The underlying principle is simple: if you deliberately introduce a bug, your tests should catch it. If they don't, your test suite is inadequate.

A mutation is a small syntactic change to the source code that should alter the program's behavior. For example:
- Changing a comparison operator (`>` to `>=`)
- Replacing a logical operator (`&&` to `||`)
- Removing a statement
- Changing a literal value
- Swapping true/false

The mutation score is calculated as: `(mutations killed / total mutations) × 100`. A high score (typically 80%+) indicates that tests effectively detect code changes. A low score means tests are missing coverage or aren't specific enough.

Mutation testing was conceived in the 1970s but gained practical traction with tools like Pitest (Java), Mutmut (Python), and Stryker (JavaScript). It's particularly valuable because it:
- Identifies gaps in test coverage
- Measures test suite thoroughness
- Finds dead code
- Validates that tests actually check behavior

## Purpose

**When mutation testing is valuable:**
- When you want to verify test quality, not just coverage
- Before release to ensure thorough testing
- When coverage numbers seem good but bugs still slip through
- To identify weak or redundant tests
- In critical codebases where quality is paramount

**When to avoid mutation testing:**
- In rapid development cycles (too slow)
- For exploratory testing or prototypes
- When test suite already has high mutation score
- For very large codebases (computationally expensive)
- In CI/CD pipelines (run occasionally, not on every commit)

## Rules

1. **Run mutation testing on critical code** - Focus on business logic
2. **Aim for 80%+ mutation score** - Lower indicates weak tests
3. **Don't mutate test files** - Only mutate source code
4. **Use meaningful mutants** - Avoid trivial equivalent mutations
5. **Run periodically, not constantly** - It's slow
6. **Investigate surviving mutants** - They reveal test gaps
7. **Don't use in every build** - Schedule strategically

## Examples

### Good Example: Mutation Testing in Action

```python
# source code
def calculate_discount(price: float, discount_percent: float) -> float:
    if discount_percent < 0:
        raise ValueError("Discount cannot be negative")
    if discount_percent > 100:
        raise ValueError("Discount cannot exceed 100%")
    return price * (1 - discount_percent / 100)

# Test
def test_discount_calculation():
    result = calculate_discount(100, 10)
    assert result == 90

# Mutation: changing > to >=
def calculate_discount(price: float, discount_percent: float) -> float:
    if discount_percent < 0:
        raise ValueError("Discount cannot be negative")
    if discount_percent >= 100:  # Changed > to >=
        raise ValueError("Discount cannot exceed 100%")
    return price * (1 - discount_percent / 100)

# This mutation is KILLED - test fails because 100% now throws
# Original: 100% discount returns 0 (valid)
# Mutant: 100% discount throws ValueError (invalid)
```

### Bad Example: Tests That Pass Mutants

```python
# Source code with weak test
def is_positive(number: int) -> bool:
    return number > 0

# Weak test - doesn't check edge cases
def test_is_positive():
    assert is_positive(5) == True

# Mutations that SURVIVE (test passes but shouldn't):
# 1. number > 0 -> number >= 0 (0 becomes valid)
# 2. number > 0 -> number != 0 (negative becomes valid)
# 3. return number > 0 -> return True (always returns True)
```

```python
# Strong test that kills mutants
def test_is_positive():
    assert is_positive(5) == True
    assert is_positive(0) == False
    assert is_positive(-1) == False

# Now all mutations above would be detected
```

### Good Example: Using Mutmut (Python)

```bash
# Install mutmut
pip install mutmut

# Run mutation testing
mutmut run --source=src --tests=tests

# Results:
# - Mutations: 150
# - Killed: 130
# - Survived: 20
# - Mutation score: 86.7%

# Show surviving mutations
mutmut show survived

# This tells you which code changes weren't caught
```

### Good Example: Using Pitest (Java)

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.pitest</groupId>
    <artifactId>pitest</artifactId>
    <version>1.15.8</version>
</dependency>

<!-- Run mutation analysis -->
mvn org.pitest:pitest-maven:mutationCoverage

<!-- Results in target/pit-reports/ -->
```

## Anti-Patterns

### 1. Running on Every Commit

**Bad:**
- Mutation testing is slow
- Adds minutes to every build
- Discourages team usage

**Solution:**
- Run weekly or before releases
- Use incremental analysis tools
- Focus on changed code only

### 2. Ignoring Surviving Mutants

**Bad:**
- Not investigating survivors
- Missing test gaps
- False sense of security

**Solution:**
- Review surviving mutants
- Add missing test cases
- Understand why mutants survive

### 3. Expecting 100% Score

**Bad:**
- 100% is rarely achievable
- Some mutations are equivalent
- Over-testing wastes time

**Solution:**
- Accept 80-90% as excellent
- Focus on critical paths
- Accept some equivalent mutants

### 4. Mutating Test Code

**Bad:**
- Tests fail when mutating tests
- Doesn't measure test effectiveness
- Confusing results

**Solution:**
- Configure tools to skip tests
- Only mutate source files
- Keep tests stable

### 5. Using for All Code

**Bad:**
- Slow on large codebases
- UI code has many equivalent mutants
- Diminishing returns

**Solution:**
- Focus on business logic
- Exclude generated code
- Use coverage data to focus

## Best Practices

### 1. Configure Mutation Operators

```python
# .mutmut configuration
[mutmut]
# Only meaningful mutations
ignore_mutations =
    # Equivalent mutations
    numbers
    # Trivial changes
    constant

# Focus on logic
enable_mutations =
    conditionals
    comparisons
    boolean
    augmented_assignment
```

### 2. Incremental Analysis

```bash
# Only mutate changed files
mutmut run --source=src --tests=tests --use-coverage

# Pitest configuration
<configuration>
    <targetClasses>com.myapp.business.*</targetClasses>
    <targetTests>com.myapp.test.*</targetTests>
</configuration>
```

### 3. Threshold Configuration

```yaml
# CI configuration
mutation_test:
  fail_if_below: 80%
  warn_if_below: 85%
  # Critical code should be higher
  critical_paths:
    - payment/**
    - auth/**
    min_score: 90%
```

### 4. Focus Areas

```python
# Prioritize business logic
focus_areas = [
    "src/domain/",      # Core business rules
    "src/services/",   # Service layer
    "src/models/",     # Model validation
]

# Skip infrastructure
skip_areas = [
    "src/migrations/", # Database migrations
    "src/config/",    # Configuration
    "tests/",         # Test files
]
```

### 5. Integration with CI

```yaml
# GitHub Actions - weekly or pre-release only
name: Mutation Testing
on:
  push:
    branches: [main]
  workflow_dispatch:  # Manual trigger

jobs:
  mutation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run mutation testing
        run: |
          pip install mutmut
          mutmut run --source=src --tests=tests
      - name: Check mutation score
        run: |
          score=$(mutmut result | grep -oP '\d+%')
          if [ ${score%?} -lt 80 ]; then
            echo "Mutation score below threshold: $score"
            exit 1
          fi
```

## Failure Modes

- **Running mutation testing on every commit** → mutation testing is computationally expensive → CI pipeline becomes too slow for practical use → run mutation testing periodically or on changed code only
- **Ignoring surviving mutants** → mutants that survive indicate test gaps → false sense of test quality → investigate each surviving mutant and add tests to kill them
- **Expecting 100 percent mutation score** → some mutations are equivalent and cannot be killed → unrealistic targets and wasted effort → accept 80 to 90 percent as excellent and focus on critical paths
- **Mutating test code instead of source** → mutating tests measures nothing useful → confusing results and wasted computation → configure tools to exclude test directories from mutation
- **Not configuring mutation operators** → all mutation types enabled including trivial ones → noise from equivalent mutations → enable only meaningful mutation operators for your codebase
- **Mutation testing on UI code** → UI code has many equivalent mutants → low mutation score despite adequate tests → focus mutation testing on business logic and exclude UI layers
- **No incremental mutation analysis** → full codebase mutation on every run → hours of computation time → use coverage-guided incremental mutation to test only changed code

## Technology Stack

| Tool/Framework | Language | Features |
|-----------------|----------|----------|
| Pitest | Java | Industry standard, detailed reports |
| Mutmut | Python | Simple, fast |
| Stryker | JavaScript/TypeScript | Rich ecosystem |
| Mull | C/C++ | LLVM-based |
| Infection | PHP | PHP mutation testing |
| Pit | Kotlin/JVM | Kotlin support |

## Related Topics

- [[TestCoverage]]
- [[UnitTesting]]
- [[CodeQuality]]
- [[StaticAnalysis]]
- [[Metrics]]
- [[PropertyTesting]]
- [[Fuzzing]]
- [[Refactoring]]

## Additional Notes

**Mutation Score Interpretation:**
- 90%+ = Excellent test suite
- 80-89% = Good, some gaps
- 70-79% = Needs improvement
- Below 70% = Significant gaps

**Equivalent Mutations:**
- Some mutations don't change behavior
- `x == true` → `x` (equivalent)
- `i + 0` → `i` (equivalent)
- Tools often filter these

**Common Surviving Mutants:**
1. Dead code - never reached
2. Redundant assertions
3. Missing edge cases
4. Overly general tests

**Tools Comparison:**
- Pitest: Most feature-rich, Java standard
- Stryker: Great JS/TS ecosystem, easy setup
- Mutmut: Simple, fast for Python

## Key Takeaways

- Mutation testing evaluates test suite quality by introducing small code changes (mutants) and verifying that existing tests detect them.
- Use to verify test quality beyond code coverage, before releases, or when coverage numbers look good but bugs still slip through.
- Do NOT use in rapid development cycles, on every CI commit, for very large codebases, or when the test suite already has a high mutation score.
- Key tradeoff: thorough measurement of test effectiveness vs. computationally expensive execution that is too slow for every build.
- Main failure mode: ignoring surviving mutants which reveals gaps in test coverage or overly general assertions that don't check behavior.
- Best practice: run periodically on critical business logic, aim for 80%+ mutation score, investigate survivors, and configure meaningful mutation operators.
- Related concepts: Test Coverage, Unit Testing, Code Quality, Static Analysis, Property Testing, Fuzzing, CI/CD.
