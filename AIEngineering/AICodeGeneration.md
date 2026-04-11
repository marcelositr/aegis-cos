---
title: AI Code Generation
title_pt: Geração de Código com IA
layer: ai_engineering
type: practice
priority: high
version: 1.0.0
tags:
  - AIEngineering
  - CodeGeneration
  - Productivity
description: Using AI to generate code as a starting point for human refinement and validation.
description_pt: Usando IA para gerar código como ponto de partida para refinamento e validação humana.
prerequisites:
  - Prompt Engineering
  - AI-Augmented Development
estimated_read_time: 10 min
difficulty: intermediate
---

# AI Code Generation

## Description

AI code generation uses language models to produce code from natural language descriptions. The key principle: AI generates drafts, humans refine. AI is a starting point, not a finished product.

Effective code generation requires:
- Clear context and requirements in prompts
- Understanding of generated code before acceptance
- Testing and validation of all AI output
- Integration with existing codebase patterns

## Purpose

**When AI code generation is valuable:**
- Boilerplate code (CRUD, models, serializers)
- Exploring unfamiliar frameworks or APIs
- Generating test scaffolds
- Creating initial implementations for refinement
- Converting between languages or frameworks

**When AI code generation is risky:**
- Security-critical code (auth, crypto, payments)
- Complex business logic requiring domain expertise
- Performance-critical paths
- Novel algorithms without reference implementations

**The key question:** Can I understand and validate every line of AI-generated code before shipping it?

## Workflow

```
1. Define task clearly — what, why, constraints
2. Provide context — existing code, patterns, standards
3. AI generates initial implementation
4. Developer reads and understands every line
5. Developer modifies to fit codebase
6. Developer adds tests and edge cases
7. Code review (human, not just AI)
8. Commit and monitor in production
```

## Prompt Structure for Code Generation

```
[Context]
What you're working on and why
- Working on: user authentication module
- Existing code: uses SQLAlchemy, has User model
- Team standards: type hints required, async preferred

[Task]
Specific request
- Generate login function that:
  - Validates email/password
  - Returns JWT token
  - Handles incorrect password attempts

[Constraints]
What to consider
- Use bcrypt for password hashing
- Token expiration: 24 hours
- Rate limit: 5 attempts per minute

[Output Format]
How you want the response
- Provide code with comments
- Include docstrings
- Show example usage
```

## Anti-Patterns

### 1. Blind Adoption

**Bad:** Copying AI code without understanding → security vulnerabilities, architecture mismatch
**Solution:** Read every line, understand every line, test every path

### 2. No Context

**Bad:** "Write a function to process data" → generic, unusable output
**Solution:** Provide framework, existing patterns, constraints, requirements

### 3. Skipping Validation

**Bad:** AI generates tests → added directly → tests verify wrong behavior
**Solution:** Review AI tests against requirements, add missing edge cases

### 4. Security Code Generation

**Bad:** AI generates authentication or crypto code → subtle vulnerabilities
**Solution:** Use well-audited libraries, have security experts review

## Failure Modes

- **Incorrect logic** → AI produces plausible-looking but wrong code → bug in production
- **Outdated patterns** → AI uses deprecated APIs → runtime errors
- **Security gaps** → missing input validation, weak crypto → vulnerabilities
- **Architecture mismatch** → AI doesn't know your patterns → inconsistent codebase
- **License issues** → AI trained on GPL code → potential license violations

## Best Practices

1. **Treat AI output as a first draft** — always refine
2. **Understand before accepting** — if you can't explain it, don't ship it
3. **Add tests immediately** — verify AI code works correctly
4. **Check for security** — input validation, auth, crypto need extra scrutiny
5. **Match existing patterns** — adapt AI output to your codebase conventions
6. **Iterate on prompts** — first response is rarely the best

## Related Topics

- [[PromptEngineering]] — Writing effective prompts for code generation
- [[AIAugmentedDevelopment]] — Overall AI-assisted workflow
- [[AIValidation]] — Verifying AI-generated code correctness
- [[AICodeReview]] — Using AI to review human-written code
- [[HallucinationDetection]] — Identifying fabricated or incorrect AI output
- [[HumanVerification]] — Human-in-the-loop validation
- [[CodeQuality]] — Maintaining quality standards with AI-generated code
- [[Testing]] — Testing AI-generated implementations

## Key Takeaways

- AI code generation produces code drafts from natural language prompts; the core principle is AI generates, humans refine
- Use for boilerplate (CRUD, models), exploring unfamiliar frameworks, generating test scaffolds, and language conversion
- Avoid for security-critical code (auth, crypto, payments), complex business logic, performance-critical paths, or novel algorithms
- Tradeoff: rapid initial implementation speed versus the mandatory cost of understanding, testing, and adapting every generated line
- Main failure mode: blind adoption without understanding ships plausible-looking but incorrect or insecure code to production
- Best practice: provide structured prompts with context, task, constraints, and output format; read every line, test every path, match existing patterns
- Related: prompt engineering, AI-augmented development, AI validation, AI code review, hallucination detection
