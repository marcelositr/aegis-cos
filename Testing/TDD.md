---
title: TDD
title_pt: TDD (Desenvolvimento Guiado por Testes)
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - TDD
  - Development
description: Test-Driven Development methodology where tests are written before implementation code.
description_pt: Metodologia de desenvolvimento onde testes são escritos antes do código de implementação.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# TDD

## Description

[[TDD]] (Test-Driven Development) is a software development methodology where developers write automated tests before writing the actual implementation code. The workflow follows a short iterative cycle known as the "Red-Green-Refactor" cycle: first, write a failing test (Red), then write just enough code to make the test pass (Green), and finally, refactor the code while keeping tests passing (Refactor).

TDD was popularised by Kent Beck in the early 2000s and has become a fundamental practice in agile software development. The core principle is simple: tests drive the design, not the other way around. By writing tests first, developers are forced to think about the desired behavior and interface before implementation, resulting in more modular, testable, and maintainable code.

The methodology promotes several key benefits: it ensures code is testable from the start, provides immediate feedback on correctness, creates living documentation of intended behavior, and reduces debugging time. Studies have shown that teams practicing TDD experience 50-90% reduction in defect rates, though the initial development velocity may be slightly slower.

### The TDD Cycle

```
1. Red: Write a failing test
   - Define what you want to implement
   - Test should fail because feature doesn't exist yet

2. Green: Write minimal code to pass
   - Write only what's necessary to make test pass
   - Don't worry about perfect implementation yet

3. Refactor: Improve code while maintaining behavior
   - Clean up the implementation
   - Ensure all tests still pass
   - Remove duplication
```

## Purpose

**When TDD is valuable:**
- When building new features or components from scratch
- When working on complex business logic that requires clear specifications
- When developing APIs or libraries that will be used by others
- When working in teams where tests serve as communication
- When long-term maintainability is a priority

**When to avoid or adapt TDD:**
- When exploring or prototyping (too much overhead)
- When dealing with legacy code without existing tests
- When deadlines are extremely tight
- When working with technologies that have poor test support
- In UI development where visual validation is more important

## Rules

1. **Write the test first** - Never write implementation without a failing test
2. **One test at a time** - Focus on one small behavior per test
3. **Keep tests simple** - Tests should be easy to understand and maintain
4. **Test behavior, not implementation** - Focus on what, not how
5. **Run tests frequently** - Every few minutes, not just at the end
6. **Refactor only after Green** - Never refactor failing tests
7. **Use descriptive test names** - Test names should describe the behavior
8. **Avoid test interdependencies** - Each test should run independently

## Examples

### Good Example: TDD in Practice

```python
# First, write the test - RED
# tests/test_calculator.py
import pytest
from calculator import Calculator

def test_add_two_numbers():
    """Test that Calculator can add two numbers"""
    calc = Calculator()
    result = calc.add(2, 3)
    assert result == 5

def test_add_negative_numbers():
    """Test adding negative numbers"""
    calc = Calculator()
    result = calc.add(-5, -3)
    assert result == -8

def test_add_with_zero():
    """Test that zero doesn't affect addition"""
    calc = Calculator()
    result = calc.add(10, 0)
    assert result == 10
```

```python
# Then, write minimal implementation - GREEN
# calculator.py
class Calculator:
    def add(self, a, b):
        return a + b
```

```python
# Finally, refactor if needed - REFACTOR
# (Code is already simple, no refactoring needed)
```

### Bad Example: Test After Implementation

```python
# BAD: Writing tests after code (not TDD)
# This defeats the purpose of TDD

# First write implementation
def calculate_discount(price, discount_percent):
    if discount_percent < 0 or discount_percent > 100:
        raise ValueError("Discount must be between 0 and 100")
    return price * (1 - discount_percent / 100)

# Then write tests (these won't drive design!)
def test_discount():
    assert calculate_discount(100, 10) == 90

# Problem: You already wrote the code, so you're less likely
# to think about edge cases or design properly
# Tests become an afterthought rather than a design tool
```

### Good Example: Test Behavior, Not Implementation

```python
# GOOD: Test what the system should do
def test_order_total_includes_tax():
    """
    When calculating order total, tax should be included
    based on the customer's shipping address state
    """
    order = Order(customer_id=123)
    order.add_item(Product(name="Widget", price=100), quantity=2)
    
    # Test behavior, not implementation details
    total = order.calculate_total()
    
    assert total == 230  # 200 + 30 tax

# This test is behavior-focused and resilient to
# internal implementation changes
```

### Bad Example: Testing Implementation Details

```python
# BAD: Testing how, not what
def test_order_uses_tax_calculator():
    """
    Test depends on internal implementation
    This breaks encapsulation and makes refactoring hard
    """
    order = Order()
    # Directly testing internal components
    assert order.tax_calculator is not None
    assert isinstance(order.tax_calculator, TaxCalculator)
    
# This test will break if we change how tax is calculated
# TDD should test behavior, not implementation
```

## Anti-Patterns

### 1. Writing Tests After Code

**Bad:**
- Writing implementation first, then tests
- Tests become an afterthought
- Design doesn't benefit from testability concerns

**Solution:**
- Always write tests first
- Use "test lists" to plan what needs testing
- Practice the Red-Green-Refactor cycle strictly

### 2. Large Test Steps

**Bad:**
- Writing many tests at once
- Taking too long between Red and Green
- Tests become overwhelming

**Solution:**
- Take small steps
- Write one test at a time
- Keep the cycle short (minutes, not hours)

### 3. Testing Implementation

**Bad:**
- Testing private methods
- Testing internal state
- Brittle tests that break on refactoring

**Solution:**
- Test through public interfaces
- Focus on behavior, not implementation
- Treat tests as specification of behavior

### 4. Ignoring the Refactor Phase

**Bad:**
- Only doing Red-Green
- Leaving messy code because tests pass
- Technical debt accumulates

**Solution:**
- Always refactor after Green
- Keep code clean and DRY
- Use linters and formatters

### 5. Over-Mocking

**Bad:**
- Mocking too much
- Tests don't reflect real behavior
- Mocking becomes a dependency

**Solution:**
- Use real objects when feasible
- Mock external dependencies only
- Keep tests close to reality

## Best Practices

### 1. Test Naming Conventions

```python
# Use descriptive names that describe behavior
def test_user_cannot_withdraw_more_than_balance():
    """When withdrawal exceeds balance, transaction should be rejected"""
    account = BankAccount(balance=100)
    
    with pytest.raises(InsufficientFundsError):
        account.withdraw(150)

def test_order_total_includes_shipping_for_non_free_shipping_items():
    """When order doesn't qualify for free shipping,
    total should include shipping cost"""
    order = Order()
    order.add_item(Product(price=20), quantity=1)
    
    assert order.total == 29.99  # 20 + 9.99 shipping
```

### 2. Arrange-Act-Assert Pattern

```python
# Clear test structure
def test_transfer_funds_between_accounts():
    # Arrange - set up test data
    source = BankAccount(balance=500)
    destination = BankAccount(balance=100)
    
    # Act - perform the action
    source.transfer(200, destination)
    
    # Assert - verify the result
    assert source.balance == 300
    assert destination.balance == 300
```

### 3. Single Assertion per Test (when possible)

```python
# Better: separate tests for separate concerns
def test_withdrawal_decreases_balance():
    account = BankAccount(balance=100)
    account.withdraw(30)
    assert account.balance == 70

def test_withdrawal_returns_withdrawn_amount():
    account = BankAccount(balance=100)
    amount = account.withdraw(30)
    assert amount == 30
```

### 4. Use Test Doubles Wisely

```python
# Good: mock external services
class TestPaymentProcessing:
    def test_successful_payment_triggers_confirmation_email(
        self, mock_email_service
    ):
        # Mock external dependency
        mock_email_service.send = mock.MagicMock()
        
        payment = PaymentProcessor()
        result = payment.process(amount=100, card=test_card)
        
        assert result.success
        mock_email_service.send.assert_called_once()

# Bad: over-mocking
class TestOrderService:
    def test_create_order(self):
        # Too many mocks, test doesn't reflect reality
        mock_repo = mock.MagicMock()
        mock_cache = mock.MagicMock()
        mock_logger = mock.MagicMock()
        mock_event_bus = mock.MagicMock()
        # ...
```

### 5. Keep Tests Fast

```python
# Fast tests = frequent feedback
# Avoid:
# - Database connections in unit tests
# - Network calls
# - File I/O

# Use:
# - In-memory databases for integration tests
# - Mock external services
# - Use test databases with small datasets
```

## Failure Modes

- **Writing tests after implementation** → code written first, tests added later → tests designed to pass, not to drive design → always write failing test before implementation code
- **Large test steps between Red and Green** → too much code written before running tests → long debugging sessions when test fails → take small steps; write one assertion at a time
- **Testing implementation details** → tests assert private methods or internal state → tests break on refactoring → test through public interfaces and verify observable behavior only
- **Skipping the Refactor phase** → Red-Green only, no cleanup → technical debt accumulates → always refactor after Green while tests pass to keep code clean
- **Over-mocking in TDD** → too many mocks make tests unrealistic → tests pass but integration fails → use real objects when feasible and mock only external boundaries
- **TDD applied to unsuitable problems** → using TDD for UI, prototypes, or exploratory code → overhead without benefit → adapt TDD approach or skip for exploratory work
- **Test names not describing behavior** → generic test names like test1 or testAdd → tests do not serve as documentation → use descriptive names that explain the scenario and expected outcome

## Technology Stack

| Tool/Framework | Use Case |
|----------------|----------|
| pytest | Python testing framework |
| unittest | Python standard testing |
| Jest | JavaScript/TypeScript testing |
| JUnit | Java testing |
| RSpec | Ruby testing |
| Test::Unit | Ruby standard testing |
| Mocha | JavaScript testing |
| cypress | E2E testing (for E2E TDD) |

## Related Topics

- [[UnitTesting]] — Testing individual components in isolation
- [[IntegrationTesting]] — Testing component interactions
- [[BDD]] — Behavior-Driven Development
- [[TestArchitecture]] — Organizing tests
- [[Refactoring]] — Code refactoring after Green phase
- [[SOLID]] — Design principles that enable TDD
- [[CodeSmells]] — Code quality indicators
- [[DRY]] — Eliminating duplication in tests
- [[Mocks]] — Test doubles for isolation
- [[MutationTesting]] — Evaluating test quality
- [[CiCd]] — Automating test execution
- [[CodeQuality]] — TDD's impact on code quality

## Additional Notes

**TDD vs Test-First:**
- Test-First is broader - any testing before code
- TDD specifically follows Red-Green-Refactor cycle
- TDD emphasizes design through tests

**Common Misconceptions:**
- "TDD slows development" - True initially, but reduces bugs and rework
- "100% coverage required" - Not necessary, focus on behavior coverage
- "Tests are documentation" - They describe behavior, but need narrative too
- "TDD works for everything" - Not always suitable for prototypes or UI

**When TDD Fails:**
- Missing team buy-in
- No test automation infrastructure
- Pressure to deliver fast without quality
- Legacy code without existing tests
- Poor test skills

**TDD and Agile:**
- TDD supports iterative development
- Tests provide safety net for refactoring
- Enables continuous integration
- Supports behavior-driven development practices

## Key Takeaways

- TDD is a development methodology following the Red-Green-Refactor cycle: write a failing test, write minimal code to pass, then refactor.
- Use when building new features, working on complex business logic, developing APIs/libraries, or when long-term maintainability is a priority.
- Do NOT use when prototyping, exploring unfamiliar domains, dealing with legacy code without tests, or under extremely tight deadlines.
- Key tradeoff: slightly slower initial development velocity vs. 50-90% reduction in defect rates and better code design.
- Main failure mode: writing tests after implementation (defeating TDD's design benefits) or testing implementation details instead of behavior.
- Best practice: take small steps, test behavior not implementation, use descriptive test names, and never skip the refactor phase.
- Related concepts: Unit Testing, BDD, Refactoring, SOLID principles, Mutation Testing, CI/CD, Test Architecture.
