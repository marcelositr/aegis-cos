---
title: Contract Testing
title_pt: Teste de Contrato
layer: testing
type: concept
priority: medium
version: 1.0.0
tags:
  - Testing
  - Contract
  - Integration
description: Testing technique that verifies API compatibility between services.
description_pt: Técnica de teste que verifica compatibilidade de API entre serviços.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Contract Testing

## Description

Contract testing is a technique for verifying that two services can communicate correctly. In microservices architectures, where services are developed and deployed independently, contract testing ensures that the interface between them remains compatible without requiring full integration testing.

A contract is an agreement between a consumer (client) and a provider (server) about the format of their communication. This agreement specifies:
- The endpoints available
- The request format (headers, body, query parameters)
- The response format (status codes, body structure)
- The error scenarios

Contract testing was developed to address the challenges of distributed systems where:
- Services are developed by different teams
- Services are deployed independently
- Full integration testing is impractical
- Consumer-driven contracts empower API consumers

The two main approaches are:
1. **Consumer-Driven Contracts (CDC)**: Consumers define what they need, providers verify they can satisfy it
2. **Provider-Driven**: Providers define the contract, consumers must adapt

Popular tools include Pact (consumer-driven), Postman, and Spring Cloud Contract. These tools generate contract files that can be shared between teams and used to verify compatibility independently.

## Purpose

**When contract testing is valuable:**
- In microservices architectures with multiple services
- When services are owned by different teams
- When APIs are consumed by external clients
- When you want fast feedback without full integration
- When continuous deployment requires independent service updates

**When to avoid contract testing:**
- Monolithic applications with tight coupling
- When full integration testing is faster
- Small number of tightly coupled services
- When APIs are extremely stable

## Rules

1. **Write contracts from consumer perspective** - Define what you need, not what you have
2. **Share contracts between teams** - Use Pact broker or similar
3. **Verify contracts on both sides** - Consumer and provider must pass
4. **Keep contracts small and focused** - One contract per interaction
5. **Version contracts explicitly** - Avoid breaking changes
6. **Run contracts in CI/CD** - Verify compatibility with every change
7. **Use consumer-driven approach** - Providers should support consumer needs

## Examples

### Good Example: Pact Consumer Test

```javascript
// consumer.test.js
import { describe, it, expect } from 'vitest';
import { pactWith } from 'pact';
import { Like, Regex } from '@pact-foundation/pact-core';

pactWith({ consumer: 'UserService', provider: 'UserAPI' }, (mockServer) => {
  describe('GET /users/{id}', () => {
    it('returns user details', async () => {
      // Define the interaction
      mockServer.addInteraction({
        uponReceiving: 'a request for user details',
        withRequest: {
          method: 'GET',
          path: '/api/users/123',
          headers: { 'Authorization': Regex({ matcher: 'Bearer .*', generate: 'Bearer token' }) }
        },
        willRespondWith: {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: {
            id: '123',
            name: 'John Doe',
            email: Regex({ matcher: '.+@.+\\..+', generate: 'john@example.com' }),
            createdAt: Regex({ matcher: '\\d{4}-\\d{2}-\\d{2}.*', generate: '2024-01-15T10:30:00Z' })
          }
        }
      });

      // Execute the test
      const response = await fetch('http://localhost/api/users/123', {
        headers: { 'Authorization': 'Bearer token' }
      });

      expect(response.status).toBe(200);
      const user = await response.json();
      expect(user.id).toBe('123');
      expect(user.name).toBe('John Doe');
    });
  });
});
```

### Good Example: Provider Verification

```java
// Provider verification with Spring Cloud Contract
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
@AutoConfigureWireMock(port = 0)
class UserApiContractTest extends Object {

  @Test
  void validateUserEndpoint() throws Exception {
    // Stub is automatically generated from contracts
    // This test verifies the provider honors the contract
    mockMvc.perform(get("/api/users/123"))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.id").value("123"))
      .andExpect(jsonPath("$.name").value("John Doe"));
  }
}
```

### Bad Example: Testing Implementation Details

```javascript
// BAD: Testing internal structure, not contract
describe('User API', () => {
  it('returns user from correct database query', async () => {
    // This is implementation, not contract
    const user = await db.query('SELECT * FROM users WHERE id = ?', [123]);
    
    expect(user[0].name).toBe('John Doe');
    expect(user[0].email).toBe('john@example.com');
    // Should test API contract, not database structure
  });
});
```

```javascript
// GOOD: Testing public API contract
describe('User API', () => {
  it('returns user details via HTTP API', async () => {
    const response = await fetch('http://api/users/123');
    const user = await response.json();
    
    expect(response.status).toBe(200);
    expect(user.id).toBe('123');
    expect(user.name).toBe('John Doe');
  });
});
```

### Good Example: Pact Broker Workflow

```bash
# 1. Consumer publishes contract
npx pact-broker publish --broker-base-url=https://pact.example.com \
  --consumer-app-version=1.0.0 \
  --contract-dir=./pacts

# 2. Provider verifies contract
npx pact-provider-verifier --provider-base-url=http://localhost:3000 \
  --broker-url=https://pact.example.com \
  --provider=UserAPI

# 3. Check compatibility in CI
# Both sides must pass for build to succeed
```

## Anti-Patterns

### 1. Testing Only Happy Path

**Bad:**
- Only testing successful responses
- Ignoring error cases
- Missing validation scenarios

**Solution:**
- Include error responses in contracts
- Test edge cases
- Document all status codes

### 2. Hardcoding Values in Contracts

**Bad:**
- Using specific IDs that might change
- Embedding timestamps
- Not using matchers for variable data

**Solution:**
- Use Pact matchers for dynamic data
- Use generators for random data
- Keep contracts flexible

### 3. Not Sharing Contracts

**Bad:**
- Each team writes own contracts
- No shared understanding
- Integration failures in production

**Solution:**
- Use Pact Broker or similar
- Share contracts early
- Validate in both directions

### 4. Ignoring Contract Testing in CI

**Bad:**
- Only running contract tests locally
- Breaking changes go undetected
- Integration fails in staging/production

**Solution:**
- Run contract tests in CI pipeline
- Block deployment on contract failures
- Use canary deployments

### 5. Over-Complex Contracts

**Bad:**
- Testing entire API surface
- Too many interactions
- Hard to maintain

**Solution:**
- Focus on consumer needs
- Keep contracts small
- Separate contracts by use case

## Failure Modes

- **Testing only happy path** → error scenarios unverified → production failures → include error responses and edge cases in contracts
- **Hardcoded values in contracts** → false failures → flaky tests → use matchers and generators for dynamic data
- **Not sharing contracts between teams** → integration surprises → breaking changes in production → use Pact Broker or similar sharing mechanism
- **Ignoring contract tests in CI** → breaking changes undetected → consumer failures → block deployment on contract test failures
- **Over-complex contracts** → hard to maintain → test suite abandonment → keep contracts small, focused on consumer needs
- **Provider-driven only** → consumer needs ignored → unnecessary fields → use consumer-driven approach to define requirements
- **No contract versioning** → breaking changes → consumer incompatibility → version contracts explicitly and support multiple versions

## Best Practices

### 1. Consumer-Driven Contracts

```javascript
// Consumer defines what they need
const userContract = {
  consumer: { name: 'NotificationService' },
  provider: { name: 'UserAPI' },
  interactions: [
    {
      description: 'Get user email for notifications',
      request: {
        method: 'GET',
        path: '/api/users/123',
      },
      response: {
        status: 200,
        body: {
          id: '123',
          email: 'john@example.com'  // Only what consumer needs
        }
      }
    }
  ]
};
```

### 2. Use Matchers for Flexibility

```javascript
// Allow provider some flexibility
{
  id: like('123'),           // Any string is OK
  name: regex('.{1,100}'),   // Any name up to 100 chars
  email: email(),            // Valid email format
  createdAt: date()          // Any date
}
```

### 3. Organize by Use Case

```javascript
// Separate contracts for different use cases
// user-get-contract.js - Getting user
// user-create-contract.js - Creating user
// user-update-contract.js - Updating user

// Each contract is focused and maintainable
```

### 4. Version Contracts

```yaml
# Use semantic versioning
contracts/
├── v1/
│   ├── user-api.json
│   └── order-api.json
├── v2/
│   ├── user-api.json
│   └── order-api.json
└── latest -> v2/
```

### 5. Fail Fast in CI

```yaml
# .github/workflows/contract-test.yml
- name: Consumer Contract Tests
  run: npm run test:contracts:consumer
  
- name: Verify Provider Contracts
  run: npm run test:contracts:provider
  
# Fail build if contracts don't match
# Prevents breaking changes from reaching production
```

## Technology Stack

| Tool/Framework | Language | Approach |
|----------------|----------|----------|
| Pact | Multi-language | Consumer-driven |
| Spring Cloud Contract | Java | Provider-driven |
| Postman | Multi-language | API testing |
| WireMock | Multi-language | Service stubbing |
| Dredd | Multi-language | API testing |

## Related Topics

- [[IntegrationTesting]]
- [[E2ETesting]]
- [[APIDesign]]
- [[REST]]
- [[UnitTesting]]
- [[CiCd]]
- [[BDD]]
- [[TestArchitecture]]

## Additional Notes

**Contract vs Integration Testing:**
- Contract: Fast, focused, independent verification
- Integration: Slow, full system, real interactions
- Use both for comprehensive coverage

**Pact Flow:**
1. Consumer writes test and generates contract
2. Contract published to Pact Broker
3. Provider pulls contract and verifies
4. Both teams see results

**Common Challenges:**
- Getting teams to share contracts
- Managing contract versions
- Balancing flexibility vs strictness
- Setting up infrastructure

**Best Practices:**
- Start with new APIs
- Use consumer-driven approach
- Integrate into CI/CD
- Share responsibility between teams
