---
title: Acceptance Testing
title_pt: Teste de Aceitação
layer: testing
type: concept
priority: medium
version: 1.0.0
tags:
  - Testing
  - Acceptance
  - QA
description: Testing that validates software meets business requirements.
description_pt: Testes que validam software atende requisitos de negócio.
---

# Acceptance Testing

## Description

Acceptance testing verifies that the software meets the business requirements and is ready for production. It's typically performed by QA or business stakeholders.

Types:
- **User Acceptance Testing (UAT)** - End users test the system
- **Business Acceptance Testing** - Business requirements validation
- **Contract Acceptance Testing** - Against predefined contracts

## Purpose

**When acceptance testing is required:**
- Before production deployment
- For validating business requirements
- For stakeholder sign-off
- For compliance requirements

**When acceptance testing may be simplified:**
- For internal tools
- For rapid prototyping
- When other testing is comprehensive

**The key question:** Does this software meet the business needs?

## Examples

### Gherkin Format for UAT

```gherkin
Feature: User Login
  As a registered user
  I want to log in
  So that I can access my account

  Scenario: Successful login
    Given I am on the login page
    When I enter valid credentials
    Then I should see my dashboard
```

### Automated Acceptance Tests

```python
# Selenium-based acceptance test
def test_user_can_login():
    driver.get("https://app.example.com/login")
    driver.find_element(By.ID, "email").send_keys("user@example.com")
    driver.find_element(By.ID, "password").send_keys("password123")
    driver.find_element(By.ID, "login-button").click()
    
    assert "dashboard" in driver.current_url
```

## Best Practices

1. **Involve business stakeholders** - They define acceptance criteria
2. **Use clear, executable requirements** - Gherkin, BDD format
3. **Test happy path and edge cases** - Both should pass
4. **Automate where possible** - Reduce manual testing effort
5. **Document non-functional requirements** - Performance, security

## Failure Modes

- **Acceptance criteria not defined before development** → team builds without clear acceptance criteria → delivered feature does not meet business needs → define acceptance criteria in Gherkin format before development starts
- **Business stakeholders not involved** → QA defines acceptance without business input → tests miss critical business scenarios → involve product owners and end users in acceptance criteria definition
- **Manual acceptance testing only** → all acceptance tests executed manually → slow feedback and inconsistent results → automate acceptance tests where possible with tools like Cucumber or SpecFlow
- **Acceptance tests too granular** → acceptance tests verify implementation details → tests break on UI changes → keep acceptance tests at user journey level, not implementation level
- **Not testing negative scenarios** → only happy path acceptance tested → system behavior on errors unknown → include error scenarios and edge cases in acceptance test suite
- **Acceptance tests not linked to requirements** → cannot trace which requirements are covered → gaps in test coverage → link each acceptance test to specific business requirement or user story
- **Acceptance tests becoming maintenance burden** → too many acceptance tests with fragile selectors → test suite slows delivery → focus acceptance tests on critical user journeys and use stable selectors

## Anti-Patterns

### 1. Acceptance Criteria Defined After Development

**Bad:** Writing acceptance criteria after the feature is built, retroactively fitting tests to what was implemented
**Why it's bad:** The team builds without clear goals — the delivered feature may not meet business needs, and there is no objective way to determine if it is "done"
**Good:** Define acceptance criteria in Gherkin format before development starts — the criteria become the contract between business and engineering

### 2. Business Stakeholders Not Involved

**Bad:** QA engineers or developers define acceptance criteria without input from product owners or end users
**Why it's bad:** Tests miss critical business scenarios — the technical team does not understand the business context and tests the wrong things
**Good:** Involve product owners and end users in acceptance criteria definition — the people who use the system know what "done" looks like

### 3. Acceptance Tests Too Granular

**Bad:** Acceptance tests that verify implementation details like button colors, CSS classes, or specific DOM structures
**Why it's bad:** Tests break on every UI change — a redesign or framework migration requires rewriting all acceptance tests
**Good:** Keep acceptance tests at user journey level — test what the user can do, not how the UI is implemented

### 4. Acceptance Tests Not Linked to Requirements

**Bad:** Acceptance tests exist but there is no traceability between tests and business requirements
**Why it's bad:** You cannot determine which requirements are covered and which are not — gaps in test coverage go undetected until production
**Good:** Link each acceptance test to a specific business requirement or user story — maintain a traceability matrix to verify complete coverage

## Related Topics

- [[Testing MOC]]
- [[BDD]]
- [[E2ETesting]]
- [[QualityGates]]
- [[CiCd]]