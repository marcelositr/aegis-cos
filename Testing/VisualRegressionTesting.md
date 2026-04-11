---
title: Visual Regression Testing
title_pt: Teste de Regressão Visual
layer: testing
type: concept
priority: medium
version: 1.0.0
tags:
  - Testing
  - Visual
  - Regression
description: Testing technique that detects visual changes in UI.
description_pt: Técnica de teste que detecta mudanças visuais na interface.
prerequisites:
  - E2ETesting
---

# Visual Regression Testing

## Description

Visual regression testing captures screenshots of UI components and compares them against baseline images to detect unintended visual changes.

Tools:
- Percy
- Chromatic
- BackstopJS
- Applitools

## Purpose

**When visual regression testing is valuable:**
- Complex UIs with many components
- Design systems with many states
- Cross-browser testing requirements
- Preventing layout regressions

**When it may not be needed:**
- Simple text-based interfaces
- Frequent UI changes (high churn)
- When functional tests suffice

**The key question:** Did our code change break the visual appearance?

## Examples

### Basic Chromatic Setup

```yaml
# .chromatic.yml
projectId: project-id
buildScriptName: build
exitZeroChanges: true
exitOnceUploaded: false
```

### Percy Configuration

```javascript
// percy.config.js
module.exports = {
  version: 2,
  snapshot: {
    widths: [375, 1280],
    minHeight: 1024
  },
  storybookOptions: {
    url: 'http://localhost:6006'
  }
}
```

## Failure Modes

- **Dynamic content causing false positives** → timestamps, animations, or ads change between captures → tests fail on every run → use ignore regions, freeze time, and disable animations for visual tests
- **Baseline images not reviewed** → new baselines accepted without verification → visual regressions become new baseline → require manual review and approval of all baseline changes
- **Testing at single viewport only** → visual regression only checked at one resolution → responsive design bugs missed → test at multiple viewport widths including mobile, tablet, and desktop
- **Visual tests in CI without approval workflow** → CI auto-approves visual changes → regressions silently accepted → require explicit approval for visual changes before CI passes
- **Not ignoring expected variations** → anti-aliasing differences between environments → consistent false positives → configure tolerance thresholds and ignore regions for expected rendering differences
- **Visual tests too slow for CI** → capturing and comparing many screenshots → CI pipeline too slow → run visual tests on PR only, not every commit, and use incremental comparison
- **Missing cross-browser visual testing** → visual tests run only in one browser → browser-specific rendering bugs → test across target browsers with visual comparison per browser

## Anti-Patterns

### 1. Dynamic Content Causing False Positives

**Bad:** Visual tests that capture screenshots with timestamps, animations, ads, or personalized content
**Why it's bad:** Every run produces a different screenshot — tests fail constantly on expected variations, and the team learns to ignore visual test failures
**Good:** Use ignore regions, freeze time, and disable animations for visual tests — only test the static visual elements that matter

### 2. Baseline Images Not Reviewed

**Bad:** Auto-accepting new baseline images without manual verification of what changed
**Why it's bad:** Visual regressions become the new baseline — a broken layout is silently accepted and the regression goes undetected until users report it
**Good:** Require manual review and approval of all baseline changes — every visual diff should be examined by a human before acceptance

### 3. Testing at Single Viewport Only

**Bad:** Visual regression tests that only capture screenshots at one resolution (e.g., desktop 1920x1080)
**Why it's bad:** Responsive design bugs on mobile and tablet go undetected — the layout works on desktop but is broken on the devices most users actually use
**Good:** Test at multiple viewport widths — mobile (375px), tablet (768px), and desktop (1280px) at minimum

### 4. Visual Tests Too Slow for CI

**Bad:** Capturing and comparing hundreds of screenshots on every commit, adding 20+ minutes to the CI pipeline
**Why it's bad:** Developers skip the visual tests or the CI becomes a bottleneck — the feedback loop is too slow for productive development
**Good:** Run visual tests on PR only, not every commit — use incremental comparison (only test changed components) and parallelize screenshot capture

## Related Topics

- [[Testing MOC]]
- [[RegressionTesting]]
- [[E2ETesting]]
- [[CiCd]]
- [[CodeQuality]]

## Best Practices

1. **Test responsive layouts** - Multiple viewport widths
2. **Use ignore rules** - Exclude dynamic content (timestamps)
3. **Review changes carefully** - Don't approve without review
4. **Integrate in CI** - Catch regressions before merge
5. **Update baselines intentionally** - Document design changes