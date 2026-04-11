---
title: Code Review
layer: testing
type: concept
priority: high
version: 2.0.0
tags:
  - Testing
  - Review
  - Quality
  - Process
description: Systematic examination of source code by peers to find defects, improve design, share knowledge, and enforce standards before merge.
---

# Code Review

## Description

Code review is the disciplined practice of having one or more peers examine source code changes before they are merged into a shared branch. It is the highest-ROI quality activity available to a development team, catching defects cheaper than production incidents while simultaneously transferring knowledge, enforcing standards, and improving overall design. A rigorous review examines correctness, security, performance, readability, test coverage, and architectural fit.

## Purpose

**When to use:**

- Before any merge to a shared or production branch (main, develop, release/*)
- When changes touch security-sensitive code: authentication, authorization, cryptography, input validation, secret handling
- When modifying complex distributed-systems logic: consensus, retries, idempotency, ordering guarantees
- When introducing a new dependency or upgrading an existing one
- When refactoring public APIs, database schemas, or interface contracts
- When onboarding new engineers — review is the most effective knowledge-transfer mechanism
- When performance-critical paths are modified (hot loops, database queries, network calls)

**When to avoid:**

- Emergency hotfixes where every second of downtime costs more than the risk of a skipped review — use a post-merge review within 2 hours instead
- Purely cosmetic changes in personal/solo projects where the author is also the sole maintainer and deployer
- Generated code (protoc output, OpenAPI clients, ORM migrations) — review the generator configuration, not the output
- Documentation-only changes with zero code impact (typos, formatting) — these can bypass review if the team has a fast-track policy

## Tradeoffs

| Dimension | Lightweight review (1 reviewer, 200-line limit) | Heavy review (2+ reviewers, formal checklist) |
|---|---|---|
| Cycle time | Minutes to hours | Hours to days |
| Defect detection | ~60-70% of issues | ~80-90% of issues |
| Knowledge spread | Limited to 1-2 people | Team-wide |
| Reviewer fatigue | Low | High if PRs are large |
| Best for | Feature work, bug fixes | Security changes, infra, schema migrations |

**Alternatives:**

- **Pair programming** — catches defects in real-time, eliminates review lag, but consumes two engineers simultaneously. Best for greenfield features and complex algorithms.
- **Post-merge review** — review after deploy; eliminates blocking but reduces leverage (defects reach prod). Acceptable only with feature flags and instant rollback.
- **Automated review bots** (linters, SAST, semgrep) — enforce style and known vulnerability patterns at zero human cost, but miss design-level issues. Use as a complement, not a replacement.
- **Formal inspections** (Fagan-style) — highest defect-detection rate but prohibitively expensive; reserved for safety-critical domains (avionics, medical devices).

## Rules

1. **Limit PR size to 400 lines of changed code.** Beyond this, defect-detection rate drops precipitously (Cisco study: reviewers find fewer than 50% of defects in PRs > 400 lines). Split large changes into stacked, independently-reviewable diffs.
2. **Review within 4 hours of submission.** Stale PRs create merge conflicts, context-switching overhead, and release delays. Set SLAs in team working agreements.
3. **Checklist-driven review.** Every reviewer works through the same categories: correctness, security, performance, readability, tests, and architecture. See the checklist below.
4. **Block on `Request Changes`, approve on `Approved`.** Use the platform's native gating (GitHub, GitLab). Do not merge with unresolved blocking comments.
5. **Separate concerns.** A PR should do one thing. Refactoring and feature changes belong in separate PRs. Mixing them makes it impossible to distinguish intentional changes from accidental regressions.
6. **Review the diff, not the file.** Focus on the delta. If you need to read the whole file to understand the change, the diff is too large or the change is poorly isolated.
7. **Run CI green before review.** A failing CI means the PR is not ready. Reviewers should not debug build failures — that is the author's responsibility.

### Reviewer Checklist

**Correctness:**
- Does the code do what the PR description claims?
- Are edge cases handled (null, empty, negative, overflow, concurrent access)?
- Are there off-by-one errors, race conditions, or resource leaks?
- Does error handling cover all failure paths, not just the happy path?

**Security:**
- Is user input validated and sanitized before use?
- Are secrets, tokens, and keys handled without logging or persisting?
- Is there SQL injection, XSS, SSRF, or path traversal risk?
- Are authentication/authorization checks in place on every entry point?

**Performance:**
- Are there N+1 queries, missing indexes, or unbounded loops?
- Is memory allocated in tight loops (string concatenation, unnecessary copies)?
- Are network calls batched or pipelined where possible?

**Readability:**
- Are names self-documenting? Would a new team member understand this without a walkthrough?
- Is complexity reduced where possible (early returns, extracted functions, eliminated nesting)?

**Tests:**
- Does every new code path have a corresponding test?
- Are tests asserting behavior, not implementation details?
- Are there tests for failure modes, not just the happy path?

**Architecture:**
- Does this change respect layer boundaries (domain, application, infrastructure)?
- Are dependencies injected, not constructed inline?
- Is this the right abstraction level for the change?

## Examples

### Good Example — Focused, well-described PR

```diff
// PR: Fix race condition in user session invalidation
// Problem: Concurrent logout requests could leave stale sessions in Redis.
// Solution: Use Redis MULTI/EXEC transaction to atomically delete session and update index.

- def invalidate_session(session_id):
-     redis.delete(f"session:{session_id}")
-     redis.srem("active_sessions", session_id)
+ def invalidate_session(session_id):
+     pipe = redis.pipeline(transaction=True)
+     pipe.delete(f"session:{session_id}")
+     pipe.srem("active_sessions", session_id)
+     pipe.execute()
```

**Why it's good:**
- Single responsibility: fixes one bug, nothing else
- PR description states the problem and the solution
- Diff is 6 lines changed — trivially reviewable
- Reviewer can verify: the transaction prevents the interleaving that caused stale sessions
- Test file added with a concurrent-access test using `threading.Thread` to trigger the race

### Good Example — Review comment that catches a security bug

```python
# In user_controller.py
def get_user(request):
    user_id = request.GET.get("id")
    user = db.query(User).filter_by(id=user_id).first()
    return JsonResponse(user.to_dict())
```

**Reviewer comment:** "This is a direct object reference vulnerability. Any authenticated user can pass any `id` and retrieve another user's data. Add an ownership check: `if user.org_id != request.user.org_id: return 403`. Also, `user_id` should be validated as an integer to prevent type coercion issues."

### Bad Example — Unfocused, massive PR

```
PR: "Refactor everything and add new feature X"
- 1,200 lines changed across 14 files
- Mixes: formatting changes, new feature, dependency upgrade, and database migration
- No PR description
- CI is red (linting failures)
```

**Why it's bad:**
- Impossible to review effectively — the cognitive load exceeds human capacity
- Mixing concerns means a defect in one area can hide in changes to another area
- No description means the reviewer must reverse-engineer the author's intent
- Red CI wastes reviewer time on build issues instead of logic review
- Should have been 4-5 separate PRs, each reviewable independently

## Failure Modes

1. **Rubber-stamp reviews** → reviewer approves without reading, defects slip through. Root cause: reviewers feel time pressure, trust the author blindly, or lack domain knowledge. Mitigation: require at least one substantive comment per review; rotate reviewers to prevent trust decay; measure review quality via post-merge defect rate.

2. **Review bottleneck** → PRs queue behind a single gatekeeper, release velocity collapses. Root cause: only one person has authority to approve, or that person is a bottleneck by process design. Mitigation: require 1 of N eligible reviewers, not a specific person; enforce 4-hour SLA; escalate blocked PRs in standup.

3. **Diff size exhaustion** → reviewer skim-reads a 800-line PR and misses the critical bug on line 612. Root cause: author submitted too much at once, reviewer lacks courage to request splitting. Mitigation: hard limit at 400 lines in team policy; auto-reject PRs above threshold via CI check on `git diff --stat`.

4. **Nit-picking avalanche** → 80% of review comments are about whitespace, naming conventions, or stylistic preferences, drowning out substantive issues. Root cause: no automated linter/formatter, or reviewers lack prioritization discipline. Mitigation: run `prettier`, `black`, `eslint`, or equivalent in CI; mandate that style comments are `nit:` prefixed and non-blocking.

5. **Context-loss reviews** → reviewer comments "why not use Strategy pattern here?" on code that already does use it, but the pattern lives in a separate file not included in the diff. Root cause: diff-only reading without checking dependencies. Mitigation: link to related files in the PR description; reviewers should `git checkout` the branch and run locally for complex changes.

6. **Review theater without tests** → PR approved because the code "looks correct," but there are zero tests for the new behavior, so a regression 3 months later is undetected. Root cause: review checklist does not require test coverage verification. Mitigation: block merge if test coverage delta is negative (enforced via CI); require tests for every new code path.

7. **Adversarial review culture** → author perceives review comments as personal attacks, becomes defensive, stops submitting PRs, leaves the team. Root cause: no psychological safety, feedback phrasing is accusatory ("you did this wrong" vs "this could be improved by"). Mitigation: train reviewers in constructive feedback language; use passive voice and focus on code ("this function could be extracted" not "you made this too complex"); establish team norms in a written code review guide.

8. **Stale branch syndrome** → PR sits unreviewed for 5 days, accumulates 47 merge conflicts with main, author gives up and force-pushes, history is rewritten, bisect is broken. Root cause: no review SLA, no automated rebase reminders. Mitigation: auto-comment on PRs older than 24h; rebase daily as part of author responsibility; use merge queues (GitHub) to avoid conflict accumulation.

## Best Practices

- **Write the PR description as a design doc.** Include: problem statement, approach, alternatives considered, testing strategy, and rollout plan. If the description is "fixes stuff," the PR is not ready.
- **Use stacked PRs for large changes.** Build on top of unmerged branches (PR A → PR B branched from A → PR C branched from B). Each is independently reviewable; merge in order.
- **Automate everything that can be automated.** Linters, formatters, SAST, dependency scanning, and test runners belong in CI. Human reviewers should focus on design, logic, and correctness — not semicolons.
- **Review on a second monitor or split view.** Read the diff alongside the relevant context files. Do not rely on GitHub's inline view alone for complex changes.
- **Leave comments at the line of code, not in Slack.** Every concern must be traceable to a specific diff hunk. Use `git diff` comments, not chat, so the resolution is recorded in the PR.
- **Approve with conditions.** "Approved pending: add null check on line 42 and test for empty list." This unblocks the author while ensuring fixes are made.
- **Measure and improve.** Track metrics: average review time, comments per PR, PR size distribution, and post-merge defect rate. Use data to calibrate the process.
- **Pair-review for critical changes.** For security or infra PRs, schedule a 30-minute synchronous review session. Real-time discussion catches issues that async comments miss.

## Related Topics

- [[Testing MOC]] — Navigation hub for all testing methodologies
- [[TDD]] — Writing tests before code; review benefits enormously from TDDed codebases because the tests express intent
- [[UnitTesting]] — Unit tests are the first thing a reviewer should check; good tests make review faster
- [[MutationTesting]] — Validates whether your test suite (and thus the PR's tests) actually catch bugs
- [[TestCoverage]] — Use coverage delta as a review gate; never allow coverage to drop
- [[RegressionTesting]] — After review and merge, regression tests ensure the reviewed behavior is preserved
- [[ContractTesting]] — Review API changes against consumer contracts to prevent breaking changes
- [[IntegrationTesting]] — Review should verify that integration points are tested, not just unit logic
- [[SecureCoding]] — Security review checklist overlaps heavily with general code review
- [[OWASPTop10]] — Reference for common vulnerability patterns to check during review
- [[Refactoring]] — Review often involves refactoring suggestions; separate refactoring PRs from feature PRs
- [[Design Patterns]] — Recognizing patterns during review helps suggest appropriate abstractions
- [[Code Smells]] — Identifying code smells is a core review skill
- [[CiCd]] — Code review is a gate in the CI/CD pipeline; automate what you can, review what you cannot
- [[PreCommitHooks]] — Catch style and formatting issues before the PR is even submitted
- [[Architecture]] — Review against architectural boundaries; ensure layers and dependencies are respected
- [[Quality]] — Code review is the primary quality activity; complement with testing and monitoring
- [[Design]] — Review for design consistency; new code should follow established patterns
- [[Programming Concurrency]] — Review concurrent code for races, deadlocks, and memory visibility issues
- [[Performance]] — Review for performance regressions in hot paths
- [[AI Code Review]] — AI-assisted review tools can supplement human reviewers but cannot replace them
- [[Error Handling]] — Review error paths thoroughly; most bugs are in error handling, not the happy path
