---
title: BDD
title_pt: BDD (Desenvolvimento Guiado por Comportamento)
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - BDD
  - Behavior
description: Behavior-Driven Development methodology using natural language to describe behavior.
description_pt: Metodologia de desenvolvimento usando linguagem natural para descrever comportamento.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# BDD

## Description

Behavior-Driven Development (BDD) is an agile software development methodology that extends TDD by using natural language constructs to describe system behavior. BDD was created by Dan North in the early 2000s as a way to bridge the gap between technical and non-technical stakeholders in software projects.

The key innovation of BDD is the use of a ubiquitous language - a shared vocabulary between developers, testers, business analysts, and stakeholders - that describes the system behavior in terms of user stories and scenarios. This language is typically structured using the Given-When-Then (GWT) format, which provides a clear, readable way to specify behavior.

BDD tools like Cucumber, Behave, and SpecFlow allow teams to write executable specifications in natural language. These specifications serve as both documentation and automated tests, ensuring that the implemented code matches the business expectations. The approach significantly reduces misunderstandings and improves collaboration between technical and non-technical team members.

The three pillars of BDD are:
1. **Discovery**: Collaborative exploration of requirements
2. **Formulation**: Converting discoveries into Gherkin scenarios
3. **Automation**: Making scenarios executable

## Purpose

**When BDD is valuable:**
- When multiple stakeholders (devs, testers, PMs, clients) collaborate
- When requirements need to be clearly communicated
- When acceptance criteria must be explicit
- When building customer-facing features
- When regulatory compliance requires documented behavior

**When to avoid or adapt BDD:**
- Small projects with few stakeholders
- Highly technical internal tools
- When team lacks BDD training
- Rapid prototyping phases
- When natural language overhead is too high

## Rules

1. **Use Given-When-Then consistently** - Structure scenarios clearly
2. **Write scenarios from user perspective** - Focus on behavior, not implementation
3. **One scenario per behavior** - Avoid combining multiple behaviors
4. **Use realistic examples** - Scenario outlines should use real data
5. **Keep scenarios atomic** - Each scenario should be independent
6. **Collaborate on scenarios** - Business and tech should write together
7. **Scenarios should be executable** - Every scenario becomes a test
8. **Avoid implementation language** - Don't mention classes or functions

## Examples

### Good Example: BDD Scenario

```gherkin
Feature: User Authentication
  As a registered user
  I want to log in to my account
  So that I can access my personal dashboard

  Scenario: Successful login with valid credentials
    Given the user is on the login page
    And the user has a valid account with email "user@example.com" and password "SecurePass123"
    When the user enters "user@example.com" in the email field
    And the user enters "SecurePass123" in the password field
    And the user clicks the "Login" button
    Then the user should be redirected to the dashboard
    And the user should see a welcome message "Welcome back!"

  Scenario: Failed login with wrong password
    Given the user is on the login page
    And the user has a valid account with email "user@example.com" and password "CorrectPass"
    When the user enters "user@example.com" in the email field
    And the user enters "WrongPass" in the password field
    And the user clicks the "Login" button
    Then the user should stay on the login page
    And the user should see an error message "Invalid email or password"
```

### Good Example: Scenario Outline

```gherkin
Feature: Shopping Cart Discounts
  As a shopper
  I want to receive discounts based on my order total
  So that I can save money on my purchases

  Scenario Outline: Discount tiers are applied correctly
    Given the shopping cart contains the following items:
      | item_name | quantity | unit_price |
      | Widget   | 1         | 10.00      |
    And the cart total is <total>
    When the user applies the discount code
    Then the discount applied should be <discount_amount>
    And the final total should be <final_total>

    Examples:
      | total  | discount_amount | final_total |
      | 50.00 | 0.00            | 50.00       |
      | 75.00 | 5.00            | 70.00       |
      | 150.00| 22.50           | 127.50      |
```

### Bad Example: Implementation-Focused Scenario

```gherkin
# BAD: Too technical, doesn't describe behavior
Feature: User Authentication

  Scenario: Login calls authentication service
    Given the UserController.login() method is called
    When the AuthenticationService.authenticate() is invoked
    Then the JWT token should be generated
    And the token should be returned to the client
```

```gherkin
# GOOD: Describes behavior from user perspective
Feature: User Authentication

  Scenario: User receives JWT token after successful login
    Given a user with valid credentials exists in the system
    When the user submits correct email and password
    Then the system should return a valid authentication token
    And the token should be usable for subsequent API requests
```

### Bad Example: Combining Multiple Behaviors

```gherkin
# BAD: One scenario testing multiple things
Feature: User Account Management

  Scenario: Complete user workflow
    Given a new user registers with email "new@example.com"
    When the user logs in with those credentials
    And the user updates their profile
    And the user changes their password
    And the user deletes their account
    Then all operations should succeed
```

```gherkin
# GOOD: Separate scenarios for separate behaviors
Feature: User Registration
  Scenario: New user can register with valid email
  Scenario: Registration fails with invalid email format
  Scenario: Duplicate email is rejected

Feature: User Login
  Scenario: Valid credentials grant access
  Scenario: Invalid password shows error

Feature: Profile Management
  Scenario: User can update profile information
  Scenario: Empty profile fields are not allowed
```

## Anti-Patterns

### 1. Writing Scenarios in Isolation

**Bad:**
- Business writes scenarios without developer input
- Technical feasibility not considered
- Scenarios become impossible to automate

**Solution:**
- Collaborate on scenario creation
- Use three-amigo sessions (BA, Dev, Tester)
- Review scenarios for automation feasibility

### 2. Over-Abstracted Scenarios

**Bad:**
- Scenarios too vague to be useful
- "System should work correctly"
- No clear acceptance criteria

**Solution:**
- Use concrete examples
- Specify exact inputs and outputs
- Make scenarios executable

### 3. Testing Implementation Through BDD

**Bad:**
- Writing steps that check internal state
- Mentioning classes, methods, or databases
- Scenarios that verify code structure

**Solution:**
- Focus on external behavior
- Test through user interfaces/APIs
- Keep steps implementation-agnostic

### 4. Not Automating Scenarios

**Bad:**
- Writing beautiful scenarios that never run
- Scenarios as documentation only
- Disconnect between spec and code

**Solution:**
- Make scenarios executable
- Integrate with CI/CD pipeline
- Run scenarios on every change

### 5. Too Many Scenarios

**Bad:**
- Hundreds of scenarios covering edge cases
- Maintenance becomes overwhelming
- Test suite runs slowly

**Solution:**
- Focus on critical paths
- Use scenario outlines for similar cases
- Trust developers to handle edge cases with unit tests

## Failure Modes

- **Writing scenarios in isolation** → unimplementable specs → wasted effort → collaborate with three amigos (BA, Dev, Tester)
- **Implementation-focused scenarios** → brittle to refactoring → constant test updates → describe behavior, not code structure
- **Combining multiple behaviors** → unclear failure cause → hard debugging → one scenario per behavior, keep scenarios atomic
- **Not automating scenarios** → documentation only → no regression protection → make every scenario executable and run in CI/CD
- **Too many scenarios** → maintenance overhead → slow test suite → focus on critical paths, use scenario outlines for variations
- **Over-abstracted scenarios** → vague acceptance criteria → no clear pass/fail → use concrete examples with specific inputs and outputs
- **Missing negative scenarios** → error paths untested → unhandled edge cases → include failure cases and validation scenarios

## Best Practices

### 1. Collaborative Scenario Writing

```gherkin
# Three-Amigo Session Template
# 1. Business Analyst explains the feature
# 2. Developer asks technical questions
# 3. Tester adds edge cases and negative scenarios

Feature: Shopping Cart Checkout

  # Example of well-structured scenario
  Scenario: Customer sees correct total with tax
    Given the cart contains "Premium Widget" with price $100
    When the customer proceeds to checkout with shipping to "CA"
    Then the displayed total should be $113 (100 + 13% tax)
```

### 2. Meaningful Step Definitions

```python
# Good: Reusable, business-focused steps
from behave import given, when, then

@given('the user has {count} items in cart')
def set_cart_items(context, count):
    context.cart = ShoppingCart()
    for i in range(int(count)):
        context.cart.add(Product(f"Item {i}"), quantity=1)

@when('the user applies coupon code "{code}"')
def apply_coupon(context, code):
    context.result = context.cart.apply_coupon(code)

@then('the discount should be ${amount}')
def verify_discount(context, amount):
    assert context.cart.discount == Decimal(amount)
```

### 3. Background Steps

```gherkin
Feature: User Account Management

  Background:
    Given a test database is available
    And the following users exist:
      | email           | role     | status    |
      | admin@test.com  | admin    | active    |
      | user@test.com   | standard | active    |
      | inactive@test.com | standard | inactive |

  Scenario: Admin can view all users
    Given I am logged in as "admin@test.com"
    When I navigate to the admin dashboard
    Then I should see all 3 users listed
```

### 4. Data Tables for Complex Input

```gherkin
Scenario: Bulk discount calculation
  Given the following products are in the cart:
    | product   | quantity | unit_price |
    | Widget A  | 5        | 10.00      |
    | Widget B  | 3        | 20.00      |
    | Widget C  | 2        | 15.00      |
  When the system calculates the total
  Then the subtotal should be $140.00
  And the discount should be $14.00 (10%)
  And the final total should be $126.00
```

### 5. Hooks for Setup and Teardown

```python
from behave import before, after, fixture
import os

@fixture(context)
def setup_test_user(context):
    """Create test user before each scenario"""
    user = create_test_user()
    context.test_user = user
    yield user
    cleanup_test_user(user)

@before('@slow')
def skip_slow_scenarios(context):
    """Skip scenarios tagged as slow in certain environments"""
    if os.environ.get('CI') == 'true':
        context.scenario.skip("Skipping slow tests in CI")
```

## Technology Stack

| Tool/Framework | Language | Use Case |
|----------------|----------|----------|
| Cucumber | Java, Ruby, JS | Original BDD framework |
| Behave | Python | Python BDD implementation |
| SpecFlow | .NET | BDD for .NET |
| Jest + Cucumber | JavaScript | JS BDD testing |
| Karate | Java | API BDD testing |
| Gauge | Multi-language | Executable specifications |

## Related Topics

- [[UnitTesting]]
- [[IntegrationTesting]]
- [[E2ETesting]]
- [[TDD]]
- [[APIDesign]]
- [[DomainModeling]]
- [[TestArchitecture]]
- [[ContractTesting]]

## Additional Notes

**BDD vs TDD:**
- TDD: Tests written by developers, focus on code correctness
- BDD: Scenarios written collaboratively, focus on business behavior
- BDD is an extension of TDD with focus on communication

**Gherkin Keywords:**
- Feature: High-level business capability
- Background: Steps before each scenario
- Scenario: Single behavior example
- Given: Preconditions
- When: Action or event
- Then: Expected outcome
- And/But: Continue previous step
- Scenario Outline: Parameterized scenarios
- Examples: Test data for outline

**Common Challenges:**
- Getting business stakeholders involved
- Writing scenarios that are both readable and executable
- Maintaining scenario quality over time
- Training team on BDD practices
- Avoiding scenario explosion

**BDD Success Factors:**
- Real collaboration between business and technical
- Executable specifications integrated with CI/CD
- Regular scenario reviews and refinements
- Clear definition of "done" based on scenarios
