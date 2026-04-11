---
title: AI Code Review
title_pt: Revisão de Código por IA
layer: ai_engineering
type: concept
priority: high
version: 1.0.0
tags:
  - AIEngineering
  - AICodeReview
description: Using AI to analyze code and suggest improvements, automate code reviews, and enhance developer productivity.
description_pt: Usando IA para analisar código e sugerir melhorias, automatizar revisões de código e aumentar produtividade do desenvolvedor.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# AI Code Review

## Description

AI code review leverages large language models to analyze source code, identify potential issues, and suggest improvements. It automates the traditional code review process by providing instant feedback on code quality, security vulnerabilities, performance concerns, and adherence to best practices.

Unlike static analysis tools that rely on predefined rules, AI code review can understand context, intent, and business logic. It can detect nuanced issues like poor naming conventions, unclear logic, missing error handling, and architectural inconsistencies that rule-based tools often miss.

## Purpose

**When to use AI code review:**
- As a first pass before human review to catch obvious issues
- For teams lacking senior developers to perform reviews
- To maintain consistency across large codebases
- For learning opportunities - junior developers can see what to look for
- As a second opinion on complex changes
- To speed up the review process for large pull requests

**When to avoid:**
- For security-critical code requiring formal verification
- When dealing with proprietary algorithms that shouldn't be exposed
- As the only review mechanism - human oversight is essential
- For very small changes where the overhead isn't worth it

## Rules

1. **Use as assistant, not replacement** - AI augments human review, doesn't replace it
2. **Provide context** - Include PR description, related issues, business context
3. **Iterate on feedback** - Ask follow-up questions to clarify issues
4. **Verify suggestions** - Don't accept AI suggestions blindly
5. **Set appropriate expectations** - AI excels at style/patterns, struggles with business logic
6. **Combine with static analysis** - Use both AI and traditional tools for comprehensive coverage
7. **Review the AI's review** - Check for hallucinations or missed issues

## Examples

### Good Example: Providing Full Context

```
You are reviewing a PR that adds user authentication to the application.

Context:
- This is a fintech application handling sensitive financial data
- Team lead has flagged security as top priority
- Previous audit found issues with password storage

Changes in this PR:
- Added UserService with registration/login methods
- Implemented JWT token generation
- Added password hashing using bcrypt
- Created authentication middleware

Please review for:
1. Security vulnerabilities
2. Password handling best practices
3. JWT implementation correctness
4. Error handling
5. Code quality and readability

File: auth_service.py
```

### Bad Example: No Context

```
Review this code.
```

**Why it's bad:**
- AI has no understanding of the codebase
- Can't identify what's "normal" vs. unusual
- May miss domain-specific issues
- Feedback is generic and unhelpful

### Good Example: Specific Focus

```
Focus ONLY on security issues in this PR:
- SQL injection vulnerabilities
- XSS vulnerabilities
- Authentication/authorization flaws
- Hardcoded secrets

Code changes:
[insert code]
```

### Bad Example: Too Broad

```
Review this entire PR for everything that could be wrong.
```

**Why it's bad:**
- Too many potential issues to focus on
- Surface-level analysis
- May miss critical issues while covering trivial ones

### Good Example: Follow-up Iteration

```
Follow-up question: The AI suggested using bcrypt with cost factor 12. 
What would be the impact on login latency for 1000 concurrent users?
Should we consider a lower cost for the login endpoint specifically?
```

### Bad Example: Accepting Blindly

```
AI: "Replace this loop with a list comprehension"
Developer: *applies change without understanding*

The original loop had side effects (logging, caching) that would be lost.
```

## Anti-Patterns

### 1. No Human Oversight

**Bad:**
- Accepting all AI suggestions without review
- Using AI as the only review mechanism
- Not double-checking security issues

**Why it's dangerous:**
- AI can miss critical security issues
- May suggest breaking changes
- Hallucinations can introduce bugs

**Good:**
- Human reviews all AI feedback
- Security issues specifically flagged for human review
- AI used as first pass, humans do final review

### 2. Ignoring Context

**Bad:**
- Providing no PR description
- Not explaining what the code does
- Missing business context

**Why it's bad:**
- AI makes incorrect assumptions
- Misses domain-specific issues
- Feedback is generic and unhelpful

**Good:**
- Detailed PR description
- Links to related issues
- Business context provided

### 3. Using AI for All Languages/Frameworks

**Bad:**
- Expecting equal quality for all tech stacks
- Using general-purpose AI for niche technologies

**Why it's bad:**
- AI training data varies by language
- Some frameworks have unique patterns
- May not know latest framework versions

**Good:**
- Use specialized tools when available
- Verify suggestions for niche technologies
- Consider fine-tuned models for specific stacks

### 4. Not Providing Examples

**Bad:**
```
Review this code and suggest improvements.
```

**Why it's bad:**
- Too vague for useful feedback
- AI doesn't know what "good" looks like for this codebase

**Good:**
```
Review this code. Our team standards:
- Functions max 50 lines
- Meaningful variable names
- Type hints required
- Error handling required
```

### 5. Not Iterating

**Bad:**
- Taking first response as final
- Not asking clarifying questions
- Not requesting more detail on flagged issues

**Why it's bad:**
- First response is often surface-level
- AI can provide deeper analysis with specific prompts
- Some issues need back-and-forth to understand

**Good:**
- Ask follow-up: "Can you show an example of the refactored code?"
- Request details: "What's the security risk here in more detail?"
- Clarify: "Is this issue HIGH or LOW priority?"

## Failure Modes

- **No human oversight** → AI misses critical issues → production bugs → always have humans review AI suggestions before merging
- **Ignoring context** → generic feedback → unhelpful review → provide PR description, business context, and related issues
- **Accepting suggestions blindly** → breaking changes introduced → regression → verify every AI suggestion compiles and passes tests
- **Using AI for all languages equally** → poor quality for niche stacks → misleading feedback → verify AI accuracy per language/framework
- **Not iterating on feedback** → surface-level analysis → missed deep issues → ask follow-up questions for deeper analysis
- **No specific focus areas** → scattered review → critical issues missed → direct AI to focus on security, performance, or specific concerns
- **Feeding proprietary code to unauthorized services** → code leakage → IP theft → use enterprise-grade AI tools with data protection

## Best Practices

### 1. Pre-Review Preparation

- Write clear PR description before requesting review
- Identify specific areas to focus on
- Provide links to related PRs or issues
- List any specific concerns or areas of uncertainty

### 2. Prompt Engineering for Code Review

```
Act as a [language] senior developer with expertise in [framework].

Review the following code for [focus areas].

Context:
- What this code does: [description]
- Why it was added: [reason]
- Related code: [links]

Provide:
1. Issues found (severity: HIGH/MEDIUM/LOW)
2. Suggested fixes with code examples
3. Questions for the author
4. Positive feedback on what's good
```

### 3. Multi-Pass Review

**Pass 1:** Overall assessment, obvious issues
**Pass 2:** Security-focused review
**Pass 3:** Performance and efficiency
**Pass 4:** Code style and maintainability

### 4. Combining Tools

- AI for context-aware review
- Static analysis (SonarQube, ESLint) for rule-based checks
- Security scanners (Snyk, Dependabot) for vulnerabilities
- Linters for style compliance

### 5. Learning from AI Feedback

- Use AI comments as learning opportunities
- Ask AI to explain why something is an issue
- Build team knowledge base from AI findings

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| GitHub Copilot | Real-time code suggestions |
| Amazon CodeGuru | Security and performance review |
| CodeClimate | Code quality and maintainability |
| SonarQube | Static analysis for quality gates |
| Snyk | Security vulnerability detection |
| DeepCode | AI-powered security analysis |

## Related Topics

- [[PromptEngineering]]
- [[AIValidation]]
- [[HumanVerification]]
- [[HallucinationDetection]]
- [[AIAugmentedDevelopment]]
- [[CodeQuality]]
- [[StaticAnalysis]]
- [[Refactoring]]

## Key Takeaways

- AI code review uses LLMs to analyze source code for quality, security, performance, and best practice issues beyond what static analysis catches
- Use as a first pass before human review, for teams lacking senior reviewers, or to speed up large pull requests
- Avoid as the sole review mechanism, for security-critical code requiring formal verification, or when exposing proprietary algorithms
- Tradeoff: AI catches pattern and style issues well but struggles with business logic and domain-specific concerns
- Main failure mode: accepting AI suggestions blindly without human oversight introduces breaking changes and missed security issues
- Best practice: provide full PR context, focus areas, and team standards; iterate with follow-up questions for deeper analysis
- Related: prompt engineering, AI validation, static analysis, human verification, hallucination detection

## Additional Notes

**Common Issues to Watch For:**
- AI suggesting code that doesn't compile
- Missing edge cases in suggested fixes
- Outdated best practices based on old training data
- Overly aggressive refactoring suggestions
- Missing context-specific requirements

**Security Considerations:**
- Never feed proprietary code to unauthorized AI services
- Verify AI suggestions don't introduce new vulnerabilities
- Use enterprise-grade AI tools for sensitive code
- Check for hardcoded secrets or sensitive data in prompts

**Integration with CI/CD:**
- Add AI review as optional step in pipeline
- Use AI suggestions as optional warnings
- Don't block merges on AI feedback
- Track AI review quality over time
