---
title: Code Formatting
title_pt: Formatação de Código
layer: quality
type: concept
priority: high
version: 1.0.0
tags:
  - Quality
  - Formatting
description: Automated code formatting for consistency across a codebase.
description_pt: Formatação automatizada de código para consistência em toda a base de código.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Code Formatting

## Description

Code formatting ensures consistent style across codebase. Formatters:
- Handle indentation
- Manage line length
- Add/remove whitespace
- Sort imports

## Purpose

**When automated formatting is valuable:**
- For consistent code style
- For reducing bike-shedding in reviews
- For automatic formatting in CI
- For multiple contributors

**When manual formatting may suffice:**
- For small projects with one maintainer
- When specific style is needed
- When tools don't support language

**The key question:** Should code formatting be automatic?

## Examples

```python
# Black formatting
# Before
x=1
def foo(
        a,
        b,
):
    return a+b

# After (Black default)
x = 1


def foo(a, b):
    return a + b
```

```javascript
// Prettier
// Before
const foo = function(a,
b) {return a+b;}

// After
const foo = function (a, b) {
  return a + b;
};
```

## Anti-Patterns

### 1. Formatter Version Drift

**Bad:** Team members running different versions of the formatter, each producing slightly different output
**Why it's bad:** Every commit reformats code that was already formatted by a different version — commit history becomes noise and merge conflicts multiply
**Good:** Pin the formatter version in project configuration and enforce it in CI — everyone runs the exact same version

### 2. Massive Formatting Churn on Legacy Code

**Bad:** Running the formatter on an entire legacy codebase in one commit, generating a 10,000-line diff
**Why it's bad:** The diff is unreviewable, git blame becomes useless, and every open PR gets merge conflicts
**Good:** Format incrementally by directory, or use `git blame --ignore-revs-file` to exclude formatting commits from blame

### 3. Formatting Standards as Religious Debate

**Bad:** The team spends 30 minutes in a meeting arguing tabs vs. spaces, brace placement, or trailing commas
**Why it's bad:** Zero value is created — the choice is purely subjective, and the debate will repeat every time a new member joins
**Good:** Adopt formatter defaults and stop debating — the best style is the one that is automatic and consistent

### 4. Formatter Breaking Intentional Formatting

**Bad:** Auto-formatter destroying carefully aligned tables, ASCII diagrams, or comment blocks that aid readability
**Why it's bad:** The code is technically correct but harder to read — the formatter optimized for consistency at the cost of clarity
**Good:** Use formatter disable comments (`# fmt: off` / `// prettier-ignore`) for intentional formatting that aids understanding

## Best Practices

### 1. Add to Pre-commit

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.0.0
    hooks:
      - id: black
```

### 2. Configure in Editor

```json
// VS Code settings.json
{
  "editor.formatOnSave": true,
  "[python]": {
    "editor.defaultFormatter": "ms-python.black"
  }
}
```

## Failure Modes

- **Formatter conflicts between team members** → different formatter versions produce different output → constant reformatting in commits → pin formatter version in project config and enforce via CI
- **Formatter breaking intentional formatting** → auto-formatter destroys carefully aligned code or comments → readability regression → use formatter disable comments for intentional formatting and review formatter output
- **Pre-commit hook slowing development** → formatting check adds seconds to every commit → developer frustration and hook bypassing → use editor auto-format-on-save instead of blocking pre-commit hooks
- **Inconsistent formatter configuration** → different projects use different rules → cognitive load switching between codebases → standardize formatter config across organization and share as template
- **Formatter not supporting language features** → new language syntax causes formatter errors → code cannot be formatted → keep formatter updated and have fallback manual formatting process
- **Large codebase formatting churn** → running formatter on legacy code produces massive diff → review noise and merge conflicts → format incrementally by directory or use git blame ignore-revs-file
- **Formatting standards becoming religious debate** → team argues over tabs vs spaces → wasted time on subjective preferences → adopt formatter defaults and stop debating style choices

## Related Topics

- [[Quality MOC]]
- [[Linting]]
- [[CodeQualityHandbook]]
- [[CiCd]]
- [[StaticAnalysis]]

## Key Takeaways

- Code formatting automates consistent style across a codebase, handling indentation, line length, whitespace, and import sorting to eliminate style debates
- Valuable for consistent code style, reducing bike-shedding in reviews, CI automation, and multi-contributor projects
- Manual formatting may suffice for small single-maintainer projects or when tools don't support the language
- Tradeoff: automatic consistency and eliminated style debates versus occasional formatter breakage of intentional formatting and version drift between team members
- Main failure mode: massive formatting churn on legacy code generates unreviewable diffs, breaks git blame, and creates merge conflicts across all open PRs
- Best practice: pin formatter version in project config and enforce in CI, format incrementally by directory for legacy code, use formatter disable comments for intentional formatting, and adopt formatter defaults without debating style choices
- Related: linting, code quality, CI/CD, static analysis
