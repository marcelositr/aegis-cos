---
title: Snapshot Testing
title_pt: Teste de Snapshot
layer: testing
type: concept
priority: medium
version: 1.0.0
tags:
  - Testing
  - Snapshot
  - Regression
description: Testing technique that captures output and compares against stored baselines.
description_pt: Técnica de teste que captura saída e compara contra baselines armazenados.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Snapshot Testing

## Description

Snapshot testing is a technique that captures the output of a component or function and stores it as a reference file. Subsequent test runs compare the current output against this stored "snapshot" to detect unintended changes. This approach is particularly effective for testing complex data structures, UI components, API responses, and any output that should remain consistent over time.

Snapshot testing was popularized by Jest and has become a standard practice in modern web development. The core concept is simple: instead of asserting specific values, you capture the current output and save it. On future runs, the test compares the new output against the saved snapshot. If they differ, the test fails, alerting developers to potential regressions.

The power of snapshot testing lies in its ability to handle complex, hierarchical data that would be cumbersome to assert piece by piece. A single snapshot can capture an entire component's rendered HTML, a complex JSON response, or a multi-line string output. This makes it especially valuable for:
- UI component rendering
- API response validation
- Configuration file verification
- Complex object serialization
- Generated documentation

Snapshots are typically stored as separate files alongside tests, making them easy to review in version control. When changes are intentional, developers can update snapshots using a simple command, updating the baseline for future comparisons.

## Purpose

**When snapshot testing is valuable:**
- Testing UI component rendering (React, Vue, etc.)
- Validating API responses
- Testing complex JSON/XML outputs
- Regression testing for generated content
- When output structure is complex but stable
- Documentation verification

**When to avoid snapshot testing:**
- When you need precise assertions on specific values
- Data that changes frequently by design
- When snapshots become too large or unwieldy
- Performance testing scenarios
- Security-sensitive outputs (never snapshot secrets)

## Rules

1. **Review snapshots in PRs** - Every snapshot change should be intentional
2. **Keep snapshots in version control** - Track changes over time
3. **Update intentionally** - Use --updateSnapshot only when changes are expected
4. **Test deterministically** - Ensure consistent output for same input
5. **Don't snapshot sensitive data** - Never commit secrets or PII
6. **Keep snapshots focused** - One snapshot per behavior
7. **Document snapshot purpose** - Comment what the snapshot represents

## Examples

### Good Example: API Response Snapshot

```javascript
// api.test.js
import { fetchUserProfile } from './api';
import snapshot from '@jest/snapshot';

test('user profile response matches expected format', async () => {
  const response = await fetchUserProfile('user-123');
  
  // Snapshot captures entire response structure
  expect(response).toMatchSnapshot();
});

// Generates __snapshots__/api.test.js.snap:
// exports[`user profile response matches expected format 1`] = `
// {
//   "id": "user-123",
//   "name": "John Doe",
//   "email": "john@example.com",
//   "preferences": {
//     "theme": "dark",
//     "notifications": true,
//     "language": "en"
//   },
//   "createdAt": "2024-01-15T10:30:00Z"
// }
// `;
```

### Good Example: Component Snapshot

```javascript
// Button.test.jsx
import { render } from '@testing-library/react';
import Button from './Button';

test('primary button renders correctly', () => {
  const { container } = render(
    <Button variant="primary" onClick={() => {}}>
      Click Me
    </Button>
  );
  
  // Snapshot captures full rendered HTML
  expect(container).toMatchSnapshot();
});

// Generated snapshot captures all HTML attributes
// and nested elements, making visual regressions easy to spot
```

### Bad Example: Non-Deterministic Snapshots

```javascript
// BAD: Testing with timestamps or random data
test('user profile includes creation time', async () => {
  const response = await fetchUserProfile('user-123');
  
  // This snapshot will ALWAYS differ due to timestamp
  expect(response).toMatchSnapshot();
});

// Result: Snapshot will fail every time
// "createdAt": "2024-01-15T10:30:00Z" vs "2024-01-16T08:45:00Z"
```

```javascript
// GOOD: Use matchers for dynamic values
test('user profile includes creation time', async () => {
  const response = await fetchUserProfile('user-123');
  
  // Snapshot with dynamic value handled
  expect(response).toMatchSnapshot({
    createdAt: expect.any(String),
    expiresAt: expect.any(Date)
  });
});
```

### Good Example: Inline Snapshots

```javascript
// Using toMatchInlineSnapshot for smaller snapshots
test('parse configuration correctly', () => {
  const config = parseConfig(`
    database: postgres
    host: localhost
    port: 5432
  `);
  
  // Snapshot is stored directly in test file
  expect(config).toMatchInlineSnapshot(`
    {
      "database": "postgres",
      "host": "localhost",
      "port": 5432
    }
  `);
});
```

## Anti-Patterns

### 1. Not Reviewing Snapshot Changes

**Bad:**
- Accepting all snapshot updates without review
- Allowing snapshot creep
- No visibility into what changed

**Solution:**
- Review every snapshot diff in PRs
- Use git diff to see exact changes
- Add comments explaining intentional changes

### 2. Snapshotting Sensitive Data

**Bad:**
- Snapshotting API responses with credentials
- Including user PII in snapshots
- Committing secrets to version control

**Solution:**
- Sanitize data before snapshotting
- Use test fixtures with fake data
- Never snapshot authentication tokens

### 3. Too Many Assertions in One Snapshot

**Bad:**
- One snapshot capturing entire component tree
- Hard to identify what actually changed
- Brittle tests

**Solution:**
- Split into multiple focused snapshots
- Test specific behaviors separately
- Use clear snapshot names

### 4. Testing Random or Time-Based Data

**Bad:**
- Snapshotting data with timestamps
- Including random IDs or UUIDs
- Testing anything that changes on each run

**Solution:**
- Use matchers for dynamic values
- Seed random number generators
- Use fixed test data

### 5. Ignoring Snapshot Failures

**Bad:**
- Auto-updating snapshots in CI
- Allowing failures to go unnoticed
- Not distinguishing intentional from unintended changes

**Solution:**
- Fail CI on snapshot mismatches
- Require manual snapshot updates
- Review all changes before accepting

## Best Practices

### 1. Snapshot Naming

```javascript
// Use descriptive names for clarity
test('renders user card with all information', () => {
  expect(render(<UserCard user={testUser} />)).toMatchSnapshot();
});

test('renders user card with minimum data', () => {
  expect(render(<UserCard user={minimalUser} />)).toMatchSnapshot('minimal-fields');
});

test('renders user card loading state', () => {
  expect(render(<UserCard loading={true} />)).toMatchSnapshot('loading');
});
```

### 2. Handling Dynamic Values

```javascript
test('API response snapshot with dynamic values', () => {
  const response = {
    id: 'user-123',
    name: 'John Doe',
    createdAt: new Date().toISOString(),  // Dynamic
    expiresIn: 3600,  // Dynamic but predictable
  };
  
  expect(response).toMatchSnapshot({
    createdAt: expect.any(String),  // Any string is OK
    expiresIn: expect.any(Number),  // Any number is OK
  });
});
```

### 3. Snapshot Update Workflow

```bash
# Run tests and see failures
npm test

# After reviewing changes, update intentionally
npm test -- --updateSnapshot

# Or update only changed files
npm test -- --updateSnapshot --onlyChanged
```

### 4. CI/CD Integration

```yaml
# .github/workflows/test.yml
- name: Test
  run: npm test -- --ci

# Fail on snapshot mismatches (don't auto-update in CI)
# Developers must update locally and commit
```

### 5. Snapshot Organization

```
tests/
├── __snapshots__/
│   ├── api.test.js.snap
│   ├── components.test.js.snap
│   └── utils.test.js.snap
├── api.test.js
├── components.test.js
└── utils.test.js
```

## Failure Modes

- **Not reviewing snapshot changes** → snapshot updates accepted without review → unintended changes become new baseline → review every snapshot diff in pull requests before accepting
- **Snapshotting sensitive data** → API responses with credentials or PII committed → secrets exposed in version control → sanitize data before snapshotting and use test fixtures with fake data
- **Non-deterministic snapshots** → timestamps, random IDs, or dates in snapshots → snapshots fail on every run → use matchers for dynamic values and seed random generators for reproducibility
- **Too large snapshots** → single snapshot captures entire component tree → impossible to identify what changed → split into focused snapshots testing specific behaviors separately
- **Auto-updating snapshots in CI** → CI automatically updates failing snapshots → regressions silently accepted → fail CI on snapshot mismatches and require manual local updates
- **Snapshotting everything** → using snapshots for simple assertions → over-reliance on snapshots masks missing behavioral tests → use snapshots for complex output structure, assertions for specific behavior
- **Snapshot files not in version control** → snapshots generated at test time → no baseline comparison possible → commit snapshot files to version control alongside test code

## Technology Stack

| Tool/Framework | Language | Use Case |
|----------------|----------|----------|
| Jest | JavaScript | Popular snapshot testing |
| AVA | JavaScript | Snapshot assertions |
| Swift Snapshot Testing | Swift | iOS snapshot testing |
| Insta | Rust | Rust snapshot testing |
| pytest-snapshottest | Python | Python snapshots |
| Pisto | Elixir | Elixir snapshots |

## Related Topics

- [[UnitTesting]]
- [[IntegrationTesting]]
- [[TestCoverage]]
- [[E2ETesting]]
- [[RegressionTesting]]
- [[VisualRegressionTesting]]
- [[CiCd]]
- [[CodeQuality]]

## Additional Notes

**Snapshot vs Visual Regression:**
- Snapshots: Compare data/HTML structure
- Visual regression: Compare rendered pixels
- Use both for comprehensive testing

**When Snapshots Change:**
1. Did you intentionally change the code?
2. Is the change correct behavior?
3. Does the snapshot represent the new expected output?
4. If yes, update snapshot
5. If no, fix the code

**Snapshot Best Practices:**
- Keep snapshots in version control
- Review diffs carefully
- Use inline snapshots for small data
- Name snapshots descriptively
- Handle dynamic values with matchers
