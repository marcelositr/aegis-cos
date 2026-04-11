---
title: Linting
title_pt: Linting
layer: quality
type: concept
priority: high
version: 1.0.0
tags:
  - Quality
  - Linting
description: Automated analysis of source code to find potential errors and style issues.
description_pt: Análise automatizada de código fonte para encontrar potenciais erros e problemas de estilo.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Linting

## Description

Linting is the automated analysis of source code to find potential errors, bugs, stylistic issues, and suspicious constructs. Linters improve code quality by:
- Catching common errors early
- Enforcing coding standards
- Improving code consistency
- Reducing code review burden

## Purpose

**When linting is valuable:**
- For enforcing team coding standards
- For catching syntax/style issues early
- For CI/CD pipelines
- For maintaining consistency

**When linting may cause friction:**
- When rules are too strict
- When not integrated into workflow
- When custom rules are confusing

**The key question:** Can linting catch issues before code review?

## Examples

```python
# .pylintrc configuration
[MASTER]
ignore=CVS,.git,__pycache__
jobs=4

[MESSAGES CONTROL]
disable=C0111,C0103,R0903,R0913

[FORMAT]
max-line-length=100
indent-string='    '

# Run pylint
# pylint mymodule.py

# Output:
# ************* Module mymodule
# mymodule.py:10:0: C0111: Missing docstring
# mymodule.py:15:0: C0103: Function name "doStuff" should be lowercase
```

```javascript
// .eslintrc.json
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": "eslint:recommended",
  "rules": {
    "indent": ["error", 2],
    "quotes": ["error", "single"],
    "semi": ["error", "always"],
    "no-unused-vars": "warn",
    "no-console": "off"
  }
}
```

## Anti-Patterns

### 1. Overly Strict Lint Rules from Day One

**Bad:** Enabling every lint rule on a legacy codebase, resulting in thousands of failures that block all development
**Why it's bad:** The team either disables linting entirely or spends weeks fixing cosmetic issues instead of delivering value — both outcomes destroy trust in the tool
**Good:** Start with essential rules (unused imports, undefined variables, syntax errors) and gradually add style rules as the codebase improves

### 2. Linting Only in CI

**Bad:** Developers discover lint errors only after pushing to CI, wasting the feedback loop
**Why it's bad:** Context switching — the developer has moved on to other work by the time CI fails, and fixing the lint error requires reloading mental context
**Good:** Integrate linting in the editor with real-time feedback and use pre-commit hooks as a safety net

### 3. One-Size-Fits-All Rules

**Bad:** Applying the same lint rules to production code, test code, configuration files, and generated code
**Why it's bad:** Tests have different conventions (long names, relaxed style), and generated code should not be linted at all — uniform rules produce false positives
**Good:** Use different rule sets for different file types and directories — exclude generated code, relax rules for tests, and enforce strict rules for production code

### 4. Custom Rules Without Documentation

**Bad:** Adding organization-specific lint rules that nobody understands and nobody can justify
**Why it's bad:** Developers disable the rules or work around them without understanding the intent — the rule loses its purpose
**Good:** Document every custom rule with rationale and examples — if you cannot explain why a rule exists, it probably should not exist

## Best Practices

### 1. Integrate in CI/CD

```yaml
# GitHub Actions
- name: Run linters
  run: |
    pylint mymodule.py
    eslint src/
    flake8 .
```

### 2. Use Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pycqa/pylint
    rev: v3.0.0
    hooks:
      - id: pylint
  
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.0.0
    hooks:
      - id: eslint
```

### 3. Choose Appropriate Rules

```python
# Don't over-configure
# Focus on high-value rules

# Important:
- unused-imports
- undefined-variables
- syntax-errors

# Nice to have:
- max-line-length
- naming-conventions
```

## Failure Modes

- **Overly strict lint rules blocking development** → every minor style issue fails CI → developer frustration → start with essential rules and gradually add style rules
- **Inconsistent lint configuration across projects** → different rules per project → cognitive load switching contexts → standardize lint config and share as organization template
- **Lint rules not updated with language changes** → new language features flagged as errors → developers disable rules → keep lint tools updated and review rule compatibility
- **Ignoring lint warnings as noise** → warnings accumulate and are ignored → real issues buried → maintain zero-warning policy and fix warnings as they appear
- **Custom rules without documentation** → team-specific rules nobody understands → confusion and rule violations → document every custom rule with rationale and examples
- **Linting only in CI, not locally** → issues discovered only after push → wasted time and context switching → integrate linting in editor and pre-commit hooks
- **One-size-fits-all lint rules** → same rules for tests, production, and config files → inappropriate checks for context → use different rule sets for different file types and directories

## Related Topics

- [[StaticAnalysis]]
- [[CodeQuality]]
- [[CiCd]]
- [[TypeScript]]
- [[QualityGates]]
- [[PreCommitHooks]]
- [[TechnicalDebt]]
- [[Metrics]]

## Key Takeaways

- Linting automates analysis of source code to find potential errors, bugs, stylistic issues, and suspicious constructs before code review
- Valuable for enforcing team coding standards, catching syntax and style issues early, CI/CD pipelines, and maintaining consistency
- Causes friction when rules are too strict, not integrated into workflow, or custom rules are confusing and undocumented
- Tradeoff: early error detection and consistent style versus risk of overly strict rules blocking development and false positives from one-size-fits-all configurations
- Main failure mode: enabling every lint rule on a legacy codebase produces thousands of failures that block all development, destroying trust in the tool
- Best practice: start with essential rules (unused imports, undefined variables) and gradually add style rules, integrate linting in the editor for real-time feedback, use different rule sets for different file types, and document every custom rule with rationale
- Related: static analysis, code quality, CI/CD, TypeScript, quality gates, technical debt, metrics
