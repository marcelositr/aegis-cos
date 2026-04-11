---
title: E2E Testing
title_pt: Teste End-to-End
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - E2E
  - End-to-End
description: Testing methodology that validates entire application flow from start to finish.
description_pt: Metodologia de teste que valida todo o fluxo da aplicação do início ao fim.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# E2E Testing

## Description

End-to-End (E2E) testing is a methodology that validates the complete flow of an application from the user's perspective. Unlike unit or integration tests, E2E tests verify that the entire system works correctly in a real environment, simulating actual user interactions with the application. This includes the UI, backend services, databases, and any third-party integrations.

E2E tests are typically written to simulate real user scenarios: clicking buttons, filling forms, navigating between pages, and verifying that the system responds correctly at each step. These tests run against a fully deployed application, using real browsers (for web apps) or real devices (for mobile apps), ensuring that the user experience works as expected.

The scope of E2E testing includes:
- Complete user workflows
- UI interactions and rendering
- API integrations
- Database operations
- Third-party service integrations
- Cross-browser compatibility
- Performance under realistic conditions

E2E tests are typically slower and more brittle than unit tests, but they provide the highest confidence that the system works correctly from the user's perspective. They are especially valuable for critical user journeys like checkout flows, authentication, and core business operations.

## Purpose

**When E2E testing is valuable:**
- For critical user journeys (checkout, login, payment)
- When user interaction spans multiple components
- For regression testing of complete flows
- When verifying cross-browser compatibility
- Before releases to production
- When testing third-party integrations
- For acceptance criteria validation

**When to avoid or limit E2E testing:**
- For unit-level functionality (use unit tests)
- During rapid development (too slow feedback)
- For edge case validation (use unit/integration)
- When tests are too brittle or flaky
- For performance testing (use dedicated tools)

## Rules

1. **Test critical user journeys** - Focus on high-value flows
2. **Keep tests independent** - Each test should run alone
3. **Use realistic data** - Test with data close to production
4. **Avoid test interdependencies** - No shared state between tests
5. **Handle async operations properly** - Wait for elements to be ready
6. **Use meaningful test names** - Describe the user scenario
7. **Clean up after tests** - Reset state to avoid pollution
8. **Run in realistic environments** - Staging or production-like

## Examples

### Good Example: Playwright E2E Test

```javascript
// tests/e2e/checkout.spec.js
import { test, expect } from '@playwright/test';

test.describe('Checkout Flow', () => {
  test('complete checkout with credit card', async ({ page }) => {
    // Navigate to the application
    await page.goto('https://shop.example.com');
    
    // Add item to cart
    await page.click('[data-testid="product-123"]');
    await page.click('[data-testid="add-to-cart"]');
    
    // Open cart
    await page.click('[data-testid="cart-icon"]');
    await expect(page.locator('.cart-items')).toContainText('Widget');
    
    // Proceed to checkout
    await page.click('[data-testid="checkout-button"]');
    
    // Fill shipping information
    await page.fill('[data-testid="shipping-name"]', 'John Doe');
    await page.fill('[data-testid="shipping-address"]', '123 Main St');
    await page.fill('[data-testid="shipping-city"]', 'San Francisco');
    await page.selectOption('[data-testid="shipping-state"]', 'CA');
    await page.fill('[data-testid="shipping-zip"]', '94102');
    
    // Continue to payment
    await page.click('[data-testid="continue-payment"]');
    
    // Fill payment information
    await page.fill('[data-testid="card-number']', '4111111111111111');
    await page.fill('[data-testid="card-expiry"]', '12/25');
    await page.fill('[data-testid="card-cvc"]', '123');
    
    // Place order
    await page.click('[data-testid="place-order"]');
    
    // Verify success
    await expect(page.locator('[data-testid="order-confirmation"]'))
      .toBeVisible();
    await expect(page.locator('.confirmation-number'))
      .toContainText('ORD-');
  });
  
  test('checkout validation prevents submission', async ({ page }) => {
    await page.goto('https://shop.example.com/checkout');
    
    // Try to submit without required fields
    await page.click('[data-testid="place-order"]');
    
    // Verify validation errors
    await expect(page.locator('[data-testid="error-name"]'))
      .toContainText('Name is required');
    await expect(page.locator('[data-testid="error-address"]'))
      .toContainText('Address is required');
  });
});
```

### Bad Example: Brittle E2E Test

```javascript
// BAD: Too dependent on implementation details
test('user can login', async ({ page }) => {
  await page.goto('https://app.example.com/login');
  
  // Using CSS classes instead of semantic selectors
  await page.click('.btn-primary');  // Brittle!
  await page.fill('#email-input-123', 'user@example.com');
  await page.fill('#pass-field', 'password');
  
  // Waiting for arbitrary timeout
  await page.waitForTimeout(2000);
  
  // Checking internal state, not user-visible
  expect(globalState.isLoggedIn).toBe(true);
  
  // No cleanup
});
```

```javascript
// GOOD: User-focused, robust test
test('user can login', async ({ page }) => {
  await page.goto('https://app.example.com');
  await page.click('[data-testid="login-button"]');
  
  await page.fill('[data-testid="email-input"]', 'user@example.com');
  await page.fill('[data-testid="password-input"]', 'password123');
  await page.click('[data-testid="submit-login"]');
  
  // Verify user-visible result
  await expect(page.locator('[data-testid="user-menu"]'))
    .toContainText('Welcome, User');
  
  // Proper cleanup
  await page.click('[data-testid="logout-button"]');
});
```

### Good Example: Cypress Configuration

```javascript
// cypress.config.js
module.exports = {
  e2e: {
    baseUrl: 'https://app.example.com',
    viewport: [1280, 720],
    video: true,
    screenshotOnRunFailure: true,
    defaultCommandTimeout: 10000,
    retries: {
      runMode: 2,
      openMode: 0
    },
    env: {
      apiUrl: 'https://api.example.com'
    },
    setupNodeEvents(on, config) {
      // Implement custom listeners
    }
  }
};
```

### Good Example: Page Object Pattern

```javascript
// pages/LoginPage.js
class LoginPage {
  constructor(page) {
    this.page = page;
    this.emailInput = page.locator('[data-testid="email-input"]');
    this.passwordInput = page.locator('[data-testid="password-input"]');
    this.submitButton = page.locator('[data-testid="submit-login"]');
    this.errorMessage = page.locator('[data-testid="error-message"]');
  }
  
  async navigate() {
    await this.page.goto('/login');
  }
  
  async login(email, password) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
  
  async getError() {
    return this.errorMessage.textContent();
  }
}

// tests/login.spec.js
test('invalid credentials show error', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.navigate();
  await loginPage.login('user@example.com', 'wrongpassword');
  
  expect(await loginPage.getError())
    .toContainText('Invalid credentials');
});
```

## Anti-Patterns

### 1. Testing Too Much in One Test

**Bad:**
- Testing entire application in one test
- Multiple assertions scattered
- Hard to debug failures

**Solution:**
- One primary assertion per test
- Test one flow at a time
- Keep tests focused

### 2. Using Arbitrary Waits

**Bad:**
- `waitForTimeout(5000)` everywhere
- Tests are slow and flaky
- Doesn't account for real conditions

**Solution:**
- Use built-in waiting strategies
- Wait for elements to be actionable
- Use expect with auto-waiting

### 3. Hardcoding Test Data

**Bad:**
- Using production data
- Tests fail when data changes
- Security risk

**Solution:**
- Use test fixtures
- Generate random test data
- Clean up test data after

### 4. Not Handling Async Flows

**Bad:**
- Not waiting for API calls
- Clicking before elements are ready
- Race conditions

**Solution:**
- Wait for network idle
- Use explicit waits
- Check element state before interacting

### 5. Ignoring Test Isolation

**Bad:**
- Tests depend on each other
- Shared database state
- Order-dependent failures

**Solution:**
- Each test cleans up its data
- Use database transactions
- Reset state between tests

## Failure Modes

- **Testing too much in one test** → hard to debug failures → slow triage → test one primary flow per test case
- **Arbitrary waits (sleep)** → flaky and slow tests → unreliable CI → use explicit waits for element states instead of fixed timeouts
- **Hardcoded test data** → tests fail when data changes → brittle test suite → generate test data dynamically with cleanup
- **No test isolation** → tests depend on each other → order-dependent failures → each test should set up and clean up its own state
- **Brittle selectors (CSS classes)** → UI changes break tests → high maintenance → use data-testid attributes and semantic selectors
- **Testing in dev environment** → missing production issues → false confidence → run E2E tests against staging or production-like env
- **No parallel execution** → slow test suite → delayed feedback → design tests to run in parallel without shared state

## Best Practices

### 1. Test Critical User Journeys First

```javascript
// Priority: Critical paths first
test.describe('Priority 1: Critical Paths', () => {
  test('user can complete purchase', ...);
  test('user can login', ...);
  test('payment processing works', ...);
});

test.describe('Priority 2: Secondary Paths', () => {
  test('user can update profile', ...);
  test('search returns results', ...);
});
```

### 2. Use Semantic Selectors

```javascript
// Priority: semantic > data-testid > aria > role > text > CSS
// Good
await page.click('[data-testid="submit-button"]');
await page.fill('[aria-label="Email address"]', 'user@example.com');

// Avoid when possible
await page.click('.btn-primary.submit-form');
await page.click('div.container > form > button:nth-child(2)');
```

### 3. Environment Configuration

```javascript
// config/environments.js
const environments = {
  staging: {
    baseUrl: 'https://staging.example.com',
    apiUrl: 'https://api-staging.example.com',
    database: 'staging_db'
  },
  production: {
    baseUrl: 'https://example.com',
    apiUrl: 'https://api.example.com',
    database: 'production_db'
  }
};
```

### 4. Parallel Execution

```yaml
# cypress.config.js
module.exports = {
  e2e: {
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'cypress/support/e2e.js',
    videosFolder: 'cypress/videos',
    videos压缩: true,
    viewportWidth: 1280,
    viewportHeight: 720,
    // Run up to 4 tests in parallel
    numTestsKeptInMemory: 4
  }
};
```

### 5. CI Integration

```yaml
# .github/workflows/e2e.yml
name: E2E Tests
on: [push, pull_request]

jobs:
  e2e:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        # Run against multiple browsers
        browser: [chromium, firefox, webkit]
    steps:
      - uses: actions/checkout@v4
      - name: Run E2E tests
        run: |
          npm ci
          npx playwright install --with-deps ${{ matrix.browser }}
          npx playwright test --browser=${{ matrix.browser }}
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

## Technology Stack

| Tool/Framework | Type | Best For |
|-----------------|------|----------|
| Playwright | Cross-browser | Modern web apps |
| Cypress | All-in-one | JavaScript teams |
| Selenium | Cross-browser | Legacy support |
| Puppeteer | Chrome/Firefox | Lightweight |
| TestCafe | Cross-browser | Easy setup |
| Nightwatch | Cross-browser | Node.js projects |

## Related Topics

- [[UnitTesting]]
- [[IntegrationTesting]]
- [[TestArchitecture]]
- [[BDD]]
- [[CiCd]]
- [[Monitoring]]
- [[PerformanceOptimization]]
- [[ContractTesting]]

## Additional Notes

**E2E vs Integration Tests:**
- Integration: Multiple components, in-memory or stubbed
- E2E: Full application, real environment
- Use both for comprehensive coverage

**Flaky Test Management:**
- Use automatic retries
- Add intelligent waits
- Clean up test data
- Monitor test stability

**When E2E Tests Fail:**
1. Is it a real bug or test issue?
2. What's the actual error?
3. Can you reproduce locally?
4. Is it environment-related?
5. Check logs and screenshots

**Test Execution Strategy:**
- Run smoke tests on every commit
- Run full suite on release
- Run in parallel when possible
- Use staging environment

**Best Practices:**
- Focus on critical user journeys
- Keep tests independent and isolated
- Use realistic test data
- Monitor and reduce flakiness
- Integrate with CI/CD pipeline
