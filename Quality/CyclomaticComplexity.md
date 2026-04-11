---
title: Cyclomatic Complexity
title_pt: Complexidade Ciclomática
layer: quality
type: concept
priority: high
version: 1.0.0
tags:
  - Quality
  - CyclomaticComplexity
description: Measure of code complexity based on decision points in a program.
description_pt: Medida de complexidade de código baseada em pontos de decisão em um programa.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Cyclomatic Complexity

## Description

Cyclomatic complexity measures the number of linearly independent paths through a program's source code. It indicates how complex a function/module is:
- **1-10**: Low complexity, easy to test
- **11-20**: Moderate complexity
- **21+**: High complexity, hard to test
- **50+**: Very high, likely needs refactoring

## Purpose

**When complexity metrics are useful:**
- For identifying functions needing refactoring
- For prioritizing code review
- For setting complexity thresholds
- For understanding test difficulty

**When complexity may be acceptable:**
- When complexity is unavoidable
- When performance depends on it
- For one-off utility code

**The key question:** Is this complexity necessary or can it be simplified?

## Examples

### Simple vs Complex Functions

```python
# Low complexity (CC = 1)
def greet(name):
    return f"Hello, {name}"

# Medium complexity (CC = 4)
def process(value):
    if value > 10:
        return "big"
    elif value > 5:
        return "medium"
    return "small"

# High complexity (CC = 10+) - needs refactoring
def complex_calculate(order, customer, config):
    # Many branches and conditions
```
def complex_function(data):
    result = 0
    for item in data:
        if item.active:
            if item.value > 100:
                if item.category == "A":
                    result += item.value * 0.9
                elif item.category == "B":
                    result += item.value * 0.8
            elif item.value > 50:
                result += item.value * 0.95
    return result
```

## Anti-Patterns

### 1. Complexity Reduction by Method Fragmentation

**Bad:** Splitting one complex function into many small functions that call each other in a confusing web, just to reduce per-function complexity scores
**Why it's bad:** The overall complexity is unchanged — you have the same number of paths, just spread across more functions with hidden dependencies between them
**Good:** Reduce actual complexity by simplifying the algorithm — use lookup tables, polymorphism, or early returns instead of fragmenting code

### 2. Ignoring Cognitive Complexity

**Bad:** Passing cyclomatic complexity checks while having deeply nested conditionals that are hard for humans to follow
**Why it's bad:** CC counts decision points but does not penalize nesting — a function with CC=5 can be far harder to read than one with CC=10 if the nesting is deep
**Good:** Use cognitive complexity alongside cyclomatic complexity — cognitive complexity penalizes nesting and gives a better picture of human readability

### 3. Complexity Threshold Too Strict

**Bad:** Setting CC threshold to 5 and rejecting legitimate algorithms like parsers, state machines, or validation chains
**Why it's bad:** Developers write convoluted workarounds to pass the check — the code becomes harder to understand, not easier
**Good:** Set realistic thresholds (10-15) and allow documented exceptions for inherently complex algorithms

### 4. Not Addressing Root Cause

**Bad:** Refactoring a complex function without understanding why it grew complex in the first place
**Why it's bad:** The complexity returns — new requirements add more branches, and within months the function is complex again
**Good:** Analyze why the code became complex — is it missing abstractions, mixing concerns, or lacking domain modeling? Fix the architecture, not just the function

## Best Practices

### 1. Keep Functions Simple

```python
# Split complex functions
def process_order(order):
    # Instead of one complex function:
    order = validate_order(order)
    order = calculate_totals(order)
    order = apply_discounts(order)
    return save_order(order)
```

### 2. Refactor Decision Points

```python
# Replace conditionals with polymorphism
# Before
def get_rate(customer):
    if customer.tier == 'gold':
        return 0.1
    elif customer.tier == 'silver':
        return 0.05
    else:
        return 0

# After - dictionary lookup
RATES = {'gold': 0.1, 'silver': 0.05, 'bronze': 0}
def get_rate(customer):
    return RATES.get(customer.tier, 0)
```

## Failure Modes

- **Complexity threshold too strict** → legitimate algorithms flagged as violations → developers write convoluted code to reduce complexity → set realistic thresholds and allow documented exceptions
- **Complexity threshold too lenient** → highly complex code passes without review → unmaintainable functions accumulate → lower thresholds gradually and enforce through code review
- **Reducing complexity by extracting methods poorly** → one complex method becomes many complex methods with hidden dependencies → no real improvement → extract cohesive methods with clear single responsibilities
- **Ignoring cognitive complexity** → cyclomatic complexity misses nested conditionals → code is hard to read despite low CC → use cognitive complexity alongside cyclomatic complexity
- **Complexity metrics on generated code** → auto-generated code flagged as complex → noise in reports → exclude generated code from complexity analysis
- **Complexity focus ignoring other quality aspects** → reducing complexity while introducing coupling → trading one problem for another → balance complexity with coupling, cohesion, and testability metrics
- **Not addressing root cause of complexity** → refactoring complex code without understanding why it grew → complexity returns → analyze why code became complex and address architectural causes

## Related Topics

- [[Metrics]]
- [[Refactoring]]
- [[CodeQuality]]
- [[StaticAnalysis]]
- [[TechnicalDebt]]
- [[Algorithms]]
- [[Complexity]]
- [[Testing]]

## Key Takeaways

- Cyclomatic complexity counts linearly independent paths through code, indicating test difficulty and maintenance risk (1-10 low, 11-20 moderate, 21+ high, 50+ needs refactoring)
- Useful for identifying functions needing refactoring, prioritizing code review, setting complexity thresholds, and understanding test difficulty
- Acceptable when complexity is unavoidable (parsers, state machines), performance-dependent, or in one-off utility code
- Tradeoff: identifying overly complex code versus risk of overly strict thresholds forcing developers to write convoluted workarounds
- Main failure mode: reducing complexity by fragmenting one complex function into many small functions that call each other—the overall complexity is unchanged but spread across hidden dependencies
- Best practice: reduce actual complexity using lookup tables, polymorphism, or early returns instead of method fragmentation; set realistic thresholds (10-15); use cognitive complexity alongside cyclomatic complexity; and address root architectural causes not just the function
- Related: metrics, refactoring, code quality, static analysis, technical debt, algorithms, complexity
