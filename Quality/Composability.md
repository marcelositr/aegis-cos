---
title: Composability
title_pt: Composabilidade
layer: quality
type: concept
priority: high
version: 2.0.0
tags:
  - Quality
  - Design
  - Composability
  - Modularity
  - FunctionalProgramming
description: The ability to combine small, focused components into larger systems with predictable behavior and minimal integration friction.
description_pt: A capacidade de combinar componentes pequenos e focados em sistemas maiores com comportamento previsivel e minimo atrito de integracao.
prerequisites:
  - [[CodeQuality]]
  - [[Architecture]]
estimated_read_time: 15 min
difficulty: intermediate
---

# Composability

## Description

Composability is the property of system components (functions, modules, services, libraries) that allows them to be combined in novel ways without requiring modification to the components themselves. A composable component has:

- **Explicit contracts**: Well-defined inputs, outputs, and side effects that do not depend on hidden global state
- **Substitutability**: Any component satisfying the contract can replace another without breaking consumers
- **Associativity where practical**: `(a compose b) compose c` produces the same result as `a compose (b compose c)`, enabling flexible grouping
- **Orthogonality**: Components do not overlap in responsibility, avoiding redundant or conflicting behavior when combined

Composability exists on a spectrum. Unix pipes are highly composable (text in, text out). OOP inheritance hierarchies are poorly composable (fragile base class problem). REST APIs are moderately composable (HTTP verbs + resource paths combine predictably).

The payoff is exponential: `n` composable components can form `O(n!)` useful combinations. The cost is design discipline: composable components require more upfront interface design than purpose-built ones.

## When to Use

- **Plugin/extension architectures**: Systems like VS Code extensions, ESLint rules, or Webpack loaders rely on composable interfaces to allow third-party contributions
- **Data transformation pipelines**: ETL workflows, request middleware chains (Express/Connect), and stream processing (RxJS, Java Streams) compose operations like `map`, `filter`, `reduce`
- **Infrastructure as Code**: Terraform modules, Kubernetes Helm charts, and Pulumi components compose to build environments from reusable primitives
- **Functional core design**: Building business logic from pure functions that compose via function composition, monads, or effect systems
- **Design systems**: UI component libraries (React, Storybook) where primitives (`Button`, `Input`) compose into compound components (`FormField`, `Modal`)
- **API composition**: GraphQL resolvers, gRPC service composition, and BFF (Backend for Frontend) patterns that aggregate multiple data sources

## When NOT to Use

- **Performance-critical single-path code**: Composing 5 filter functions over a hot path adds call overhead vs. a single optimized loop. Use composability in cold paths; inline in hot paths after profiling.
- **Quick scripts and one-offs**: A 20-line deployment script does not benefit from a composable architecture. The interface design overhead exceeds any reuse value.
- **Tightly coupled domain operations**: If `createOrder`, `chargePayment`, and `sendConfirmation` always execute together as a saga, composing them as separate call sites adds indirection without flexibility. Encapsulate the saga.
- **When the composition space is unknown**: If you cannot predict which combinations will be useful, designing a composable interface is premature. Build concrete implementations first; extract interfaces after you see reuse patterns (Rule of Three).
- **Cross-cutting concerns with ordering dependencies**: If middleware A must always run before middleware B, the composability is illusory. Use a fixed pipeline instead.

## Tradeoffs

| Aspect | Composable Design | Monolithic Design |
|---|---|---|
| Upfront cost | Higher: interface design requires anticipating usage patterns | Lower: build exactly what is needed now |
| Reuse | High: components combine in unanticipated ways | Low: logic is entangled and context-specific |
| Testability | High: each component tested in isolation | Low: tests must set up full context |
| Performance | Potential overhead from abstraction layers | Direct execution, easier to optimize |
| Evolution | Components evolve independently; versioning required | Single unit evolves together; no versioning friction |
| Debugging | Errors surface at composition boundaries | Errors surface within the monolith |
| Team scaling | Teams own components independently | Team coordinates on shared codebase |

The fundamental tradeoff is **flexibility vs. specificity**. A composable HTTP client library (e.g., `axios` with interceptors) serves many use cases but requires the consumer to assemble the right combination. A purpose-built client for a specific API is simpler but cannot be reused.

## Alternatives

- **Inheritance (OOP)**: Extends behavior through subclassing. Simpler for single-axis extension but fails with multiple axes (the "gorilla-banana problem": you wanted a banana, you got a gorilla holding the banana and the entire jungle). Prefer composition over inheritance.
- **Template Method Pattern**: Defines skeleton algorithm with hook methods. More structured than free composition but less flexible. Good when the algorithm structure is fixed but steps vary.
- **Event-driven architecture**: Components communicate via events rather than direct composition. Looser coupling but harder to reason about causality. See event sourcing patterns.
- **Macros/code generation**: Generate composed code at compile time (e.g., Rust macros, Go code generation). Eliminates runtime composition overhead but loses runtime flexibility.
- **Scripting/orchestration layer**: A coordinator script or workflow engine (Temporal, Airflow) sequences non-composable services. Accepts non-composable components and adds composition at the orchestration layer.

## Failure Modes

1. **Interface proliferation**: Each component defines its own configuration interface, and composing 10 components means learning 10 configuration schemas. Mitigation: establish team-wide configuration conventions (e.g., all components accept a `Context` object with standard fields). Use the Facade pattern to present a unified interface over composed components.

2. **Error propagation across composition boundaries**: When `compose(A, B, C)` fails, the error may originate in any component with context from all predecessors. A `TypeError: cannot read property 'x' of undefined` in component C could be caused by A returning `null` instead of the expected shape. Mitigation: use typed contracts ([[TypeSafety]]), validate inputs at component boundaries, and wrap errors with context (`Component B failed: input from A was {shape}`).

3. **Implicit ordering assumptions**: Component B assumes A has already sanitized input, but the composition order was `compose(C, B, A)`. The interface does not encode ordering constraints. Mitigation: document ordering requirements in the interface contract; use typed builders that enforce order at compile time (e.g., `Pipeline.create().add(A).add(B).build()` where `.add()` returns a different type preventing out-of-order calls).

4. **State leakage between compositions**: A component caches state internally and produces different results when reused in a different composition. `const parser = new Parser(); compose(parser, transformerA)` works, but `compose(parser, transformerB)` fails because `parser` retained state from the first composition. Mitigation: make components stateless or require explicit reset; document statefulness prominently.

5. **Composability mismatch between paradigms**: Trying to compose callback-based Node.js APIs with Promise-based or async/await APIs. The composition layer must bridge paradigms, adding complexity. Mitigation: normalize to a single paradigm at system boundaries (e.g., `util.promisify` all callbacks before composition).

6. **Over-composition leading to indirection hell**: `compose(map, filter, reduce, tap, memoize, retry, log)` is technically composable but the reader cannot determine behavior without tracing through 7 layers. Mitigation: name composed pipelines with domain-specific names: `const processUserEvents = compose(filterValid, aggregateByUser, enrichWithProfile)`.

7. **Version incompatibility in composed ecosystems**: Component A v2.1 and component B v3.0 each work alone but their composition breaks because A changed an implicit contract that B depended on. This is endemic to microservices and plugin ecosystems. Mitigation: contract testing (Pact), semantic versioning enforcement, and integration tests covering supported composition matrices.

## Code Examples

### Composable middleware pipeline

```typescript
// Each middleware is a pure function: Request -> Result<Request, Error>
type Middleware = (req: Request) => Result<Request, Error>;

const authenticate: Middleware = (req) => {
  const token = req.headers.authorization;
  if (!token) return Result.error(new AuthError('Missing token'));
  const user = verifyToken(token);
  if (!user) return Result.error(new AuthError('Invalid token'));
  return Result.ok({ ...req, user });
};

const rateLimit: Middleware = (req) => {
  const count = rateLimiter.get(req.user.id);
  if (count > 100) return Result.error(new RateLimitError('Too many requests'));
  return Result.ok(req);
};

const validateSchema: Middleware = (req) => {
  const validation = schema.validate(req.body);
  if (validation.error) return Result.error(new ValidationError(validation.error));
  return Result.ok(req);
};

// Composition: order matters and is explicit
const pipeline = [authenticate, rateLimit, validateSchema];

function executePipeline(req: Request, middlewares: Middleware[]): Result<Request, Error> {
  let current = Result.ok(req);
  for (const middleware of middlewares) {
    current = current.andThen(middleware);
    if (current.isError) return current; // short-circuit on first failure
  }
  return current;
}
```

The composition is explicit, order is visible, and each middleware is independently testable. Adding `const cors: Middleware = ...` requires zero changes to existing components.

### Non-composable design (anti-pattern)

```typescript
// Anti-pattern: each handler embeds cross-cutting concerns
async function handleCreateUser(req, res) {
  // Auth logic duplicated here
  const token = req.headers.authorization;
  const user = verifyToken(token);
  if (!user) return res.status(401).send('Unauthorized');

  // Rate limiting logic duplicated here
  const count = rateLimiter.get(user.id);
  if (count > 100) return res.status(429).send('Too many requests');

  // Validation logic duplicated here
  if (!req.body.email || !req.body.name) {
    return res.status(400).send('Missing fields');
  }

  const created = await db.users.create(req.body);
  return res.json(created);
}

// Same duplication in handleUpdateUser, handleDeleteUser, etc.
// Cannot compose auth + rateLimit + validation separately because
// they are baked into each handler.
```

### Composable data transformation (functional style)

```python
from typing import Callable, TypeVar
from dataclasses import dataclass

T = TypeVar('T')
U = TypeVar('U')

def compose(*fns: Callable) -> Callable:
    """Right-to-left function composition."""
    def composed(x):
        for fn in reversed(fns):
            x = fn(x)
        return x
    return composed

# Small, focused transformations
def parse_json(text: str) -> dict:
    import json
    return json.loads(text)

def extract_users(data: dict) -> list[dict]:
    return [item for item in data.get('records', []) if item.get('type') == 'user']

def filter_active(users: list[dict]) -> list[dict]:
    return [u for u in users if u.get('status') == 'active']

def project_names(users: list[dict]) -> list[str]:
    return [u['name'] for u in users if 'name' in u]

# Composition: readable pipeline, independently testable parts
process_users = compose(
    project_names,
    filter_active,
    extract_users,
    parse_json,
)

# Usage: names = process_users(raw_json_string)
# Each function is testable in isolation:
# assert extract_users({'records': [{'type': 'user', 'name': 'Ana'}]}) == [{'type': 'user', 'name': 'Ana'}]
```

## Best Practices

- **Design interfaces around data, not behavior**: Composable components pass data through interfaces. If the interface requires calling methods in a specific sequence (e.g., `init()` then `configure()` then `start()`), it is not truly composable.
- **Make effects explicit**: Pure functions compose trivially. Functions with side effects require effect types (e.g., `IO`, `Task`, `Future`) to compose safely. Document side effects in the function signature where the language supports it.
- **Use the Rule of Three**: Do not design a composable interface until you have three concrete use cases. The first implementation is specific; the second reveals what varies; the third confirms the abstraction.
- **Test compositions, not just components**: Unit tests verify individual components; integration tests must verify that compositions behave correctly. Test the pipeline, not just the stages.
- **Prefer function composition over class inheritance**: `compose(auth, log, handler)` is more flexible than `class AuthLoggingHandler extends LoggingHandler extends BaseHandler`. Composition allows reordering and selective application.
- **Document composition contracts**: For each component, document: required input shape, guaranteed output shape, side effects, ordering requirements, and known incompatibilities with other components.
- **Version interfaces independently**: When components are composed across team or organizational boundaries, version the interface contract separately from the implementation. Use contract testing to detect breaking compositions.

## Related Topics

- [[CodeQuality]] -- composability as a quality attribute affecting maintainability
- [[Architecture]] -- system-level composition patterns (microservices, modular monoliths)
- [[TypeSafety]] -- type systems enable compile-time verification of composition contracts
- [[Composability]] -- this concept's role in the broader quality framework
- [[DeveloperExperience]] -- composable APIs improve DX by enabling incremental learning
- [[QualityGates]] -- enforce composability standards (e.g., no god classes, max coupling metrics)
- [[FunctionalProgramming]] -- paradigm where composability is a first-class concern
- [[Design]] -- design patterns that enable or inhibit composability
- [[TechnicalDebt]] -- poor composability as a form of structural debt
