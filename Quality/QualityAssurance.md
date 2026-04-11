---
title: Quality Assurance
title_pt: Garantia de Qualidade
layer: quality
type: concept
priority: high
version: 2.0.0
tags:
  - Quality
  - QA
  - Testing
  - Process
  - QualityGates
description: Systematic activities ensuring that quality requirements are met through process definition, testing strategy, defect prevention, and continuous measurement.
description_pt: Atividades sistematicas garantindo que requisitos de qualidade sejam atendidos atraves de definicao de processo, estrategia de teste, prevencao de defeitos e medicao continua.
prerequisites:
  - [[Quality]]
  - [[Metrics]]
estimated_read_time: 15 min
difficulty: intermediate
---

# Quality Assurance

## Description

Quality Assurance (QA) is the **process-oriented** discipline of ensuring that software meets quality requirements. It differs from Quality Control (QC, which is product-oriented -- finding defects in the delivered artifact) and from Testing (which is one activity within QA).

QA encompasses:

| Domain | Activities | Artifacts |
|---|---|---|
| **Process definition** | Coding standards, review checklists, branching strategies, definition of done | Team working agreements, contribution guides |
| **Testing strategy** | Test pyramid design, coverage targets, risk-based testing, test data management | Test plans, coverage reports, mutation scores |
| **Static quality enforcement** | [[Linting]], [[StaticAnalysis]], [[Formatting]], [[TypeSafety]] checks in CI | Analysis reports, quality gate results |
| **Defect prevention** | Root cause analysis, blameless postmortems, pre-mortems, FMEA | Incident reports, preventive action items |
| **Quality measurement** | [[Metrics]] tracking (defect density, escape rate, MTTR), trend analysis | Dashboards, quality reports |
| **Compliance and audit** | Regulatory requirement verification (SOC 2, HIPAA, PCI-DSS), evidence collection | Audit reports, compliance certificates |

The distinction between QA and testing is critical: a team with 100% test coverage can still have poor QA if the tests validate the wrong things, if the process allows defective code to merge, or if defect patterns are never analyzed and prevented.

QA is a leading indicator: good QA processes prevent defects from being introduced. Testing is a lagging indicator: tests find defects that already exist.

## When to Use

- **Every software project**: QA is not optional. The question is not "whether" but "how much." Even a solo developer benefits from linting, type checking, and a checklist before deployment.
- **Regulated industries**: Healthcare (HIPAA, FDA), finance (SOX, PCI-DSS), aviation (DO-178C), automotive (ISO 26262) require documented QA processes with traceable evidence.
- **Team scaling**: When a team grows beyond 3-4 developers, informal quality practices break down. QA processes (code review requirements, CI gates, testing standards) provide consistency without requiring everyone to know everyone else's code.
- **High-reliability systems**: Payment processing, infrastructure tooling, security-critical code cannot afford "move fast and break things." QA processes provide the safety net.
- **After repeated production incidents**: A pattern of defects escaping to production signals a QA process gap. Root cause analysis of incidents reveals where the process failed to catch the defect.
- **Outsourcing or distributed teams**: When work is distributed across organizations, QA processes become the quality contract. Clear acceptance criteria, test requirements, and quality gates replace hallway conversations.

## When NOT to Use

- **Excessive process for simple changes**: Requiring a full test plan, risk assessment, and three code reviewers for a one-line typo fix is process overhead that breeds resentment and process evasion. Scale QA effort to change risk.
- **QA as a separate phase/gate**: A dedicated "QA phase" after "development is complete" creates handoff delays, context loss, and an adversarial developer-vs-QA dynamic. QA should be continuous and integrated into the development workflow.
- **Metrics without action**: Tracking defect density, coverage, and escape rate is useless if the numbers do not drive decisions. QA metrics should answer specific questions ("are we getting better at catching X?") and trigger actions ("escape rate increased, let us do a root cause analysis").
- **QA owned by a single role**: When "QA" is a person or team rather than a process, developers abdicate quality responsibility. The best QA model is "everyone owns quality, with QA engineers as specialists who improve the system."
- **Checklist mentality**: Treating QA as a checklist ("unit tests done, linting done, code reviewed done") misses systemic issues. The checklist items are means, not ends. Ask "is this change likely to cause a production incident?" not "did we check the boxes?"

## Tradeoffs

| Aspect | Heavy QA Process | Light QA Process |
|---|---|---|
| Defect escape rate | Low: multiple gates catch defects | Higher: fewer gates, more defects reach production |
| Development velocity | Slower per change: more gates to pass | Faster per change: fewer gates |
| Cost per defect found | Lower: defects found early (cheaper to fix) | Higher: defects found late (expensive to fix) |
| Team autonomy | Constrained: must follow process | High: developers decide quality level |
| Compliance readiness | High: documented processes, audit trails | Low: difficult to prove quality to auditors |
| Team morale | Can be negative if process feels bureaucratic | Can be positive if trusted, negative if incidents recur |
| New developer confidence | High: clear quality expectations | Variable: depends on team culture and mentorship |
| Incident frequency | Lower: preventive processes catch issues | Higher: fewer preventive measures |

The tradeoff is **confidence vs. speed**, but this is a false dichotomy when done well. Good QA processes automate the tedious parts (linting, type checking, unit tests in CI) and reserve human judgment for what matters (code review for design correctness, risk assessment for complex changes). The goal is high confidence AND high speed through automation.

## Alternatives

- **Testing-only approach**: Rely on test coverage as the sole quality gate. Simpler but incomplete: tests verify behavior but not design quality, security posture, performance characteristics, or operational readiness.
- **Code review as QA**: Gate all changes on thorough code review. Effective for small teams and simple systems but does not scale. Reviewers miss things that automated checks catch (typos, edge cases, security patterns).
- **Production monitoring as QA**: "Test in production" with feature flags, canary deployments, and rapid rollback. Shifts quality detection from pre-deployment to post-deployment. Works for organizations with excellent observability and fast rollback, but the defects still reach users.
- **Formal methods**: Mathematical proof of correctness (TLA+, Coq, Alloy). Extremely high confidence for critical systems (distributed consensus, cryptographic protocols) but prohibitively expensive for general application development.
- **Chaos engineering**: Intentionally inject failures in production to verify system resilience. Complements QA (which focuses on preventing defects) by verifying that the system handles the defects that do occur.

## Failure Modes

1. **Testing the wrong things with high coverage**: A codebase has 95% test coverage but the 5% untested code is the payment processing path. The tested code is the happy-path display logic. Coverage measures lines executed, not risk mitigated. Mitigation: use risk-based testing. Map business-critical paths (authentication, payments, data integrity) and ensure they have thorough test coverage regardless of the overall percentage. Complement with mutation testing to verify test quality.

2. **Green CI, broken production**: All tests pass, linting passes, code review approved, yet the deployment breaks. The tests did not cover the production environment configuration, the database migration order, the interaction with a third-party API version, or the load profile of real traffic. Mitigation: test in production-like environments. Use staging environments that mirror production configuration. Include load testing and configuration validation in the QA process.

3. **Defect recurrence without root cause analysis**: A bug is found, fixed, and the fix is deployed. Three months later, a similar bug appears. The QA process fixed the symptom but did not address the systemic cause. Mitigation: conduct root cause analysis (5 Whys, fishbone diagrams) for every production incident. Add preventive measures: new tests for the failure pattern, static analysis rules, or process changes.

4. **Quality gates as merge blockers without feedback**: A PR is blocked by a failing CI check, but the failure message is `Build failed. See logs.` The developer spends 30 minutes searching through CI logs to find the actual error. The gate enforces quality but the feedback experience is poor, leading to gate fatigue. Mitigation: every quality gate failure must produce an actionable message: what failed, why it matters, and how to fix it. Invest in error message quality for CI checks as much as for application errors.

5. **Test data that does not represent production**: Tests pass against pristine, hand-crafted test data but fail against real production data, which has null fields, encoding issues, unexpected characters, and edge cases nobody considered. Mitigation: use anonymized production data samples in test suites. Generate test data that includes edge cases (empty strings, nulls, Unicode, maximum-length values, SQL injection attempts).

6. **QA process decay over time**: The team established a thorough QA process (code review template, test requirements, security checklist) but over months, the checklist items become copy-paste approvals. "Code review: done" without actual review. "Security checklist: N/A" without justification. Mitigation: periodically audit the process. Randomly sample PRs to verify checklist items are substantive. Rotate reviewers to bring fresh eyes. Use automated enforcement where possible (CI checks instead of manual checklist items).

7. **Over-reliance on QA to catch what development should prevent**: The QA process is designed to catch as many defects as possible, but the development process does not invest in defect prevention (TDD, pair programming, design reviews). This is like having an excellent emergency room but no preventive medicine. Mitigation: shift quality efforts left. Invest in TDD, design reviews, threat modeling, and static analysis that catches defects before they are committed. QA should be the last line of defense, not the only one.

## Code Examples

### Risk-based test prioritization (Python)

```python
"""
Risk-based testing: prioritize tests by the risk they cover,
not by the code they execute.

Risk = Probability of failure * Impact of failure
"""
from dataclasses import dataclass
from enum import Enum

class Impact(Enum):
    LOW = 1        # Cosmetic, easy workaround
    MEDIUM = 5     # Feature broken, workaround exists
    HIGH = 10      # Data loss, security issue, revenue impact
    CRITICAL = 25  # System down, compliance violation

class Probability(Enum):
    UNLIKELY = 1   # Well-tested, simple logic
    POSSIBLE = 3   # Moderate complexity, some edge cases
    LIKELY = 7     # Complex logic, many dependencies
    ALMOST_CERTAIN = 15  # Known flaky area, recent changes

@dataclass
class TestScenario:
    name: str
    impact: Impact
    probability: Probability
    test_path: str

    @property
    def risk_score(self) -> int:
        return self.impact.value * self.probability.value

# Define scenarios by risk, not by code coverage
scenarios = [
    TestScenario(
        "Payment processing with valid card",
        Impact.CRITICAL,  # Revenue impact if broken
        Probability.LIKELY,  # Integrates with external API
        "tests/payments/test_process.py",
    ),
    TestScenario(
        "User login with correct credentials",
        Impact.HIGH,  # Core feature
        Probability.POSSIBLE,
        "tests/auth/test_login.py",
    ),
    TestScenario(
        "Password reset with expired token",
        Impact.MEDIUM,  # Workaround: request new token
        Probability.POSSIBLE,
        "tests/auth/test_reset.py",
    ),
    TestScenario(
        "Profile page dark mode toggle",
        Impact.LOW,  # Cosmetic
        Probability.UNLIKELY,  # Simple state change
        "tests/ui/test_profile.py",
    ),
]

# Sort by risk: run highest-risk tests first
scenarios.sort(key=lambda s: s.risk_score, reverse=True)

# In CI: run CRITICAL and HIGH risk tests in the fast path (< 3 min)
# Run MEDIUM and LOW risk tests in the full path (asynchronous)
fast_path = [s for s in scenarios if s.risk_score >= Impact.HIGH.value * Probability.POSSIBLE.value]
full_path = [s for s in scenarios if s not in fast_path]

print("Fast path tests (run on every PR):")
for s in fast_path:
    print(f"  [{s.risk_score}] {s.name} -> {s.test_path}")

print("\nFull path tests (run asynchronously):")
for s in full_path:
    print(f"  [{s.risk_score}] {s.name} -> {s.test_path}")
```

### Quality gate configuration (GitHub Actions + required checks)

```yaml
# .github/workflows/quality-gates.yml
# These gates are REQUIRED for merge -- enforced by branch protection rules

name: Quality Gates

on:
  pull_request:
    branches: [main]

jobs:
  # Gate 1: Code must compile and type-check
  type-safety:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx tsc --noEmit  # Zero type errors required

  # Gate 2: No linting violations
  linting:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx eslint . --max-warnings 0  # Zero warnings allowed

  # Gate 3: Critical tests pass
  critical-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env: { POSTGRES_USER: postgres, POSTGRES_PASSWORD: postgres, POSTGRES_DB: test }
        ports: ['5432:5432']
        options: >-
          --health-cmd pg_isready --health-interval 5s --health-timeout 3s --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test -- --selectProjects critical  # Risk-based critical path tests

  # Gate 4: No security vulnerabilities
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=high  # Fail on high/critical vulnerabilities
      - uses: advanced-security/secret-scanning@v1  # Detect committed secrets

  # Gate 5: Code coverage threshold (for new/changed code only)
  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test -- --coverage --changedSince=main
      # Fail if new/changed code has < 80% coverage
      # (not overall coverage, only the code introduced in this PR)

# Branch protection rules (configured in repository settings):
# - Require all above checks to pass before merging
# - Require at least 1 approving review
# - Dismiss stale reviews when new commits are pushed
# - Require conversation resolution before merging
```

### Defect root cause analysis template (markdown)

```markdown
# Root Cause Analysis: [Incident Title]

**Date:** 2024-03-15
**Severity:** P1 (Payment processing downtime, 45 minutes)
**Detected by:** Customer reports (not monitoring)
**Resolved by:** Rollback to previous version

## Timeline
- 14:32 UTC: Deploy v2.15.0
- 14:35 UTC: First payment failures (not detected by monitoring)
- 14:47 UTC: Customer support receives first tickets
- 15:02 UTC: Engineering team identifies root cause
- 15:17 UTC: Rollback to v2.14.0 complete
- 15:20 UTC: Payment processing resumes

## 5 Whys
1. **Why did payments fail?** The payment processor API endpoint changed from `/v1/charge` to `/v2/charge`.
2. **Why did the code use the old endpoint?** The API client library was updated to v3.0, which uses the new endpoint, but the configuration was not updated.
3. **Why was the configuration not updated?** The library upgrade PR did not include a configuration migration step.
4. **Why did tests not catch this?** The payment integration tests use a mock server that accepts any endpoint path.
5. **Why does the mock accept any path?** The mock was configured to validate request body, not URL path.

## Root Cause
The QA process had a gap: integration tests mocked the API server at too low a level, validating request serialization but not the actual endpoint URL. The mock server did not reflect the real API contract.

## Preventive Actions
| Action | Type | Owner | Due |
|---|---|---|---|
| Replace mock payment server with WireMock using real API contract | Test improvement | @engineer1 | 2024-03-22 |
| Add API endpoint validation to integration tests | Test improvement | @engineer2 | 2024-03-20 |
| Add dependency upgrade checklist including configuration migration | Process | @tech-lead | 2024-03-18 |
| Add payment failure alerting (detect > 1% failure rate) | Monitoring | @sre1 | 2024-03-19 |
| Add contract testing (Pact) for payment API | Test improvement | @engineer1 | 2024-04-01 |

## QA Process Improvements
- Mock servers must validate request paths against the real API specification
- Dependency upgrades require a configuration audit checklist
- Critical path integrations require contract testing, not just mock-based tests
- Alerting must be configured for business metrics (payment success rate), not just system metrics (CPU, memory)
```

## Best Practices

- **Shift quality left**: Catch defects as early as possible. A defect found during design review costs 1x to fix. Found in code review: 3x. Found in testing: 10x. Found in production: 30-100x (including incident response, customer impact, and reputation damage).
- **Automate enforceable quality checks**: If a quality requirement can be checked by a machine (linting, type checking, unit tests, security scans), automate it in CI. Reserve human judgment for what automation cannot assess (design quality, business logic correctness, UX appropriateness).
- **Use the test pyramid, not the test iceberg**: Many small unit tests, fewer integration tests, even fewer end-to-end tests. The iceberg anti-pattern (many slow E2E tests, few unit tests) gives a false sense of security with slow, flaky test suites.
- **Measure defect escape rate**: Track how many defects reach production per release. This is the single most important QA metric. It tells you whether your QA process is actually working.
- **Conduct root cause analysis for every production defect**: Not to assign blame, but to identify process gaps. If the same category of defect escapes twice, the QA process has a systemic gap that must be addressed.
- **Define "done" with quality criteria**: A change is not "done" when the code is written. It is done when: tests pass, code is reviewed, documentation is updated, monitoring is configured (for new features), and rollback procedures are documented.
- **Treat test code as production code**: Test code is the specification of expected behavior. It deserves the same code review, style standards, and architectural thoughtfulness as production code. Poor test code leads to flaky tests, which lead to ignored test failures.
- **Invest in test data management**: Good tests require good data. Maintain a test data strategy that includes edge cases, production-like data (anonymized), and data generation tools. Test data should be versioned alongside test code.

## Related Topics

- [[QualityGates]] -- automated quality enforcement in CI/CD pipelines
- [[Metrics]] -- measuring QA effectiveness (defect density, escape rate, coverage)
- [[StaticAnalysis]] -- automated defect detection without execution
- [[Linting]] -- style and pattern enforcement as a QA baseline
- [[TypeSafety]] -- type systems as a preventive quality mechanism
- [[TechnicalDebt]] -- poor QA as a source of quality debt
- [[CodeQuality]] -- relationship between QA processes and code quality outcomes
- [[DeveloperExperience]] -- QA tooling as part of the developer experience
- [[CyclomaticComplexity]] -- complexity metrics as a QA input
- [[Formatting]] -- automated style enforcement freeing code review for substantive issues
