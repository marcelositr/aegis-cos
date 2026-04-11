---
title: Contracts
title_pt: Contratos
layer: design
type: concept
priority: high
version: 1.0.0
tags:
  - Design
  - Contracts
description: Formal agreements between components defining expected behavior and data formats.
description_pt: Acordos formais entre componentes definindo comportamento esperado e formatos de dados.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Contracts

## Description

A contract is a formal agreement between two parties (components, services, modules) that defines what each party expects from the other. It specifies the interface (methods, parameters, return types), data formats, error conditions, and behavioral guarantees.

Contracts enable:
- **Independent development** - Teams can work without constant coordination
- **Clear boundaries** - Each component has defined responsibilities
- **Testing** - Components can be tested against contracts
- **Documentation** - Contracts serve as clear documentation
- **Evolution** - Components can change without breaking consumers

Common contract mechanisms:
- **Interface definitions** (IDLs, type hints)
- **API specifications** (OpenAPI, GraphQL schema)
- **Protocol buffers** (gRPC)
- **Documentation** (README, ADRs)

## Purpose

**When contracts are essential:**
- When multiple teams build different components
- When building public APIs
- When using microservices
- When different languages/frameworks interact
- When testing against interfaces

## Rules

1. **Define contracts upfront** - Before implementation
2. **Make contracts explicit** - Written, not implied
3. **Version contracts** - Plan for evolution
4. **Document all changes** - What's different
5. **Test against contracts** - Verify compliance
6. **Be backward compatible** - When possible

## Examples

### Good Contract: API Specification

```yaml
# OpenAPI contract
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 10
            maximum: 100
      responses:
        '200':
          description: List of users
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
components:
  schemas:
    User:
      type: object
      required:
        - id
        - email
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        name:
          type: string
```

### Good Contract: Interface Definition

```python
from abc import ABC, abstractmethod
from typing import Protocol

class PaymentGateway(Protocol):
    """Contract for payment processing."""
    
    @abstractmethod
    def charge(
        self,
        amount: int,  # In cents
        currency: str,
        customer_id: str,
        payment_method_id: str
    ) -> "ChargeResult":
        """
        Charge a customer.
        
        Args:
            amount: Amount in smallest currency unit
            currency: ISO 4217 currency code
            customer_id: Customer identifier
            payment_method_id: Payment method to charge
            
        Returns:
            ChargeResult with status and transaction ID
            
        Raises:
            PaymentError: If payment fails
            ValidationError: If parameters are invalid
        """
        ...
    
    @abstractmethod
    def refund(
        self,
        charge_id: str,
        amount: int | None = None
    ) -> "RefundResult":
        """
        Refund a charge.
        
        Args:
            charge_id: ID of charge to refund
            amount: Amount to refund (None = full refund)
            
        Returns:
            RefundResult with status
            
        Raises:
            RefundError: If refund fails
        """
        ...
```

### Contract Testing

```python
# Test contract compliance
import pytest

class TestPaymentGatewayContract:
    def test_charge_returns_valid_result(self, gateway: PaymentGateway):
        # Given
        amount = 1000
        currency = "USD"
        
        # When
        result = gateway.charge(amount, currency, "cust_1", "pm_1")
        
        # Then - contract requires:
        assert result.success is True
        assert result.transaction_id is not None
        assert result.transaction_id.startswith("ch_")
    
    def test_charge_validates_amount(self, gateway: PaymentGateway):
        with pytest.raises(ValidationError):
            gateway.charge(-100, "USD", "cust_1", "pm_1")
```

## Failure Modes

- **Implicit contracts** → mismatched expectations → integration failures → make all contracts explicit and documented
- **No versioning strategy** → breaking changes → consumer breakage → version contracts and maintain backward compatibility
- **Unverified contract compliance** → drift between spec and implementation → runtime errors → test against contracts in CI/CD
- **Over-specifying contracts** → rigid interfaces → hard to evolve → specify only what consumers need, leave internals flexible
- **Missing error contracts** → undefined error behavior → unhandled client exceptions → document all error responses and status codes
- **Contract changes without notice** → consumers break unexpectedly → production outages → communicate changes with deprecation periods
- **No contract testing** → integration defects found in production → costly fixes → run contract tests on both consumer and provider sides

## Anti-Patterns

### 1. Implicit Contracts

**Bad:** Relying on verbal agreements, tribal knowledge, or "looking at the code" to understand how components interact
**Why it's bad:** When the person who wrote the code leaves, nobody knows the real expectations — integration failures become common
**Good:** Write contracts explicitly using IDLs, OpenAPI specs, or well-documented interfaces with preconditions and postconditions

### 2. Contract Creep

**Bad:** Gradually adding fields, parameters, and behaviors to a contract without versioning or formal review
**Why it's bad:** The contract becomes a sprawling, undocumented mess where consumers don't know which fields are required vs. optional
**Good:** Treat contract changes as formal decisions — version the contract, document changes, and communicate with all consumers

### 3. Over-Specified Contracts

**Bad:** Defining contracts that specify internal implementation details, data structures, and processing algorithms
**Why it's bad:** Providers cannot optimize or refactor internals without breaking the contract, defeating the purpose of abstraction
**Good:** Specify only what consumers need: inputs, outputs, error conditions, and behavioral guarantees — leave internals flexible

### 4. Contract Without Enforcement

**Bad:** Writing detailed contract documentation that nobody checks against implementation
**Why it's bad:** Implementation drifts from the documented contract over time, and the documentation becomes a lie
**Good:** Use contract testing in CI/CD — verify that implementations satisfy their contracts on every build

### 5. Synchronous Contract Dependencies

**Bad:** Designing contracts that require all parties to be available simultaneously (e.g., synchronous RPC for every interaction)
**Why it's bad:** Creates tight coupling, cascading failures, and makes independent deployment impossible
**Good:** Use asynchronous contracts where possible — events, message queues, and eventual consistency to decouple producer and consumer

## Best Practices

### 1. Use Contract-First Design

```python
# Define first, implement later
# contracts/user_service.py

class UserServiceContract(ABC):
    @abstractmethod
    def get_user(self, user_id: str) -> User | None: ...
    
    @abstractmethod
    def create_user(self, email: str, name: str) -> User: ...

# Now implement
class PostgresUserRepository(UserServiceContract):
    def get_user(self, user_id: str) -> User | None:
        ...
```

### 2. Version Contracts

```python
# Version in contract itself
class PaymentGatewayV1(Protocol):
    def charge(self, amount: int, currency: str) -> ChargeResult: ...

class PaymentGatewayV2(Protocol):
    def charge(self, amount: int, currency: str, 
               customer_id: str) -> ChargeResult: ...  # Added param
    
    def refund(self, charge_id: str) -> RefundResult: ...  # New method
```

### 3. Document Contract Changes

```markdown
# Changelog for Payment Gateway API v2

## Added
- `customer_id` parameter to `charge()` - enables customer tracking
- New `refund()` method

## Changed
- `ChargeResult` now includes `customer_id`

## Removed
- Nothing (backward compatible)
```

## Related Topics

- [[Design MOC]]
- [[ContractTesting]]
- [[APIDesign]]
- [[Idempotency]]
- [[Microservices]]

## Key Takeaways

- Contracts are formal agreements between components defining interfaces, data formats, error conditions, and behavioral guarantees
- Essential when multiple teams build components, creating public APIs, using microservices, or when different languages interact
- Tradeoff: independent development and clear boundaries versus upfront specification effort and versioning discipline
- Main failure mode: implicit contracts lead to mismatched expectations and integration failures that surface only at runtime
- Best practice: define contracts before implementation using explicit specs (OpenAPI, IDLs), version contracts, test compliance in CI/CD, and maintain backward compatibility with deprecation periods
- Related: contract testing, API design, idempotency, microservices

## Additional Notes
