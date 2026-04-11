---
title: Type Safety
title_pt: Seguranca de Tipos
layer: quality
type: concept
priority: high
version: 2.0.0
tags:
  - Quality
  - Types
  - StaticAnalysis
  - TypeScript
  - Rust
  - Python
description: The degree to which a programming language and its usage prevent type errors at compile time and runtime -- including type system design, enforcement strategies, and common failure patterns.
description_pt: O grau em que uma linguagem de programacao e seu uso previnem erros de tipo em tempo de compilacao e execucao -- incluindo design de sistema de tipos, estrategias de enforcement e padroes comuns de falha.
prerequisites:
  - [[CodeQuality]]
  - [[StaticAnalysis]]
estimated_read_time: 15 min
difficulty: intermediate
---

# Type Safety

## Description

Type safety is the property of a program that ensures operations are performed on compatible data types, preventing a class of runtime errors by verifying type correctness either at compile time (static) or at runtime (dynamic).

Type systems exist on several axes:

| Axis | Options | Examples |
|---|---|---|
| **Checking time** | Static (compile-time) vs. Dynamic (runtime) | Rust (static) vs. Python (dynamic) |
| **Type expression** | Explicit vs. Inferred | Java (explicit) vs. Haskell (inferred) |
| **Type compatibility** | Nominal (by name) vs. Structural (by shape) | Java (nominal) vs. TypeScript (structural) |
| **Type soundness** | Sound (proven correct) vs. Unsound (practical) | Coq (sound) vs. TypeScript (unsound) |
| **Mutation** | Mutable vs. Immutable vs. Linear | C++ (mutable) vs. Rust (linear/ownership) |

A type-safe program prevents:

- **Type errors**: Calling a method on `null`, passing a string where a number is expected
- **Memory errors**: Buffer overflows, use-after-free, double-free (in languages with ownership or GC)
- **Null dereference**: Accessing a property on `null` or `undefined` (in languages with option types)
- **Exhaustiveness gaps**: Failing to handle a case in a pattern match or switch (in languages with exhaustive checking)

The business impact is measurable: a Microsoft study found that statically typed codebases have 15-50% fewer defects in production. GitHub's analysis of TypeScript adoption showed a 38% reduction in bug-fix commits after migration from JavaScript.

Type safety is not binary. A language can be "type-safe" but its usage can bypass safety (e.g., `as any` in TypeScript, `unsafe` in Rust, `@SuppressWarnings("unchecked")` in Java). The practical type safety of a codebase depends on both the language's capabilities and the team's discipline in using them.

## When to Use

- **Every new project**: Choose a language with strong static typing (Rust, Go, TypeScript, Kotlin, Zig) unless there is a specific reason not to. The type system pays dividends in refactoring confidence, IDE support, and defect prevention.
- **Large codebases with multiple contributors**: As team size grows, the type system becomes the communication layer between developers. Types document intent more precisely than comments. "This function takes `UserId` not `string`" prevents an entire class of bugs.
- **APIs and libraries**: Public interfaces should be typed. Consumers of your API get compile-time feedback if they use it incorrectly. An untyped API shifts error detection from compile time to runtime, where errors are 10-100x more expensive.
- **Refactoring**: Strong typing makes refactoring safe. Changing a function signature produces compile errors at every call site. In an untyped codebase, the same change requires manual grep-and-verify across the entire codebase.
- **Domain modeling**: Algebraic data types (sum types, product types), newtypes, and phantom types encode business rules in the type system. `type Email = Newtype<string, 'Email'>` prevents passing a username where an email is expected.
- **Safety-critical systems**: Aviation, medical, financial systems where type errors can cause harm. Languages like Ada, SPARK, and Rust provide provable type safety guarantees.

## When NOT to Use

- **Quick scripts and exploratory data analysis**: A 20-line Python script to analyze a CSV file does not benefit from type annotations. The typing overhead exceeds the script's lifetime value. Use dynamic typing for exploration, static typing for production.
- **Prototypes where requirements are unclear**: When you do not yet know what the data shapes are, enforcing types adds friction. Prototype in a dynamic language, then formalize types when the design stabilizes.
- **Metaprogramming and macro-heavy code**: Languages with powerful macros (Lisp, Elixir) or metaprogramming (Ruby) use runtime code generation that is difficult to type statically. Accept dynamic typing in these domains.
- **When the type system fights the domain model**: If representing a business concept requires 15 lines of type gymnastics (dependent types, higher-kinded types, type-level computation), the type system may be the wrong tool. Model the domain directly and validate at runtime.
- **Interfacing with untyped systems**: JSON APIs, database queries, and external service responses are inherently untyped. Static typing at these boundaries requires runtime validation, which duplicates the type information. Accept that boundaries are dynamic; type the interior.

## Tradeoffs

| Aspect | Strong Static Typing | Dynamic Typing |
|---|---|---|
| Error detection | Compile time: errors found before deployment | Runtime: errors found when code path is executed |
| Refactoring confidence | High: compiler validates all changes | Low: requires comprehensive test suite |
| Initial development speed | Slower: types must be designed and written | Faster: write logic without type ceremony |
| IDE support | Excellent: autocomplete, go-to-definition, inline docs | Limited: based on heuristics and runtime analysis |
| Runtime performance | Higher: types enable optimization, no runtime checks | Lower: type checks at runtime, less optimization |
| Learning curve | Higher: must understand type system concepts | Lower: fewer concepts to learn upfront |
| Documentation | Types as documentation: function signatures are contracts | Requires docstrings and comments for type information |
| Flexibility | Constrained: must satisfy type checker | Unconstrained: pass anything, hope for the best |

The "static vs. dynamic" framing is outdated. Modern languages offer a gradient: Python has optional type hints (mypy), JavaScript has TypeScript as a superset, Ruby has Sorbet. The pragmatic choice is **gradual typing**: start dynamic, add types where they provide value, and enforce types in critical paths.

## Alternatives

- **Runtime type validation**: Pydantic, Joi, Zod validate data at runtime. Catches type errors at the boundary (API input, database output) but does not prevent internal type errors. Complements static typing: validate at boundaries, trust types internally.
- **Design by Contract**: Preconditions, postconditions, and invariants (Eiffel, Python `icontract`) validate behavior at runtime. More expressive than types (can validate arbitrary predicates) but with runtime cost and no compile-time guarantee.
- **Property-based testing**: Hypothesis, QuickCheck, fast-check generate random inputs to verify properties. Finds edge cases that type systems cannot (e.g., "reversing a list twice returns the original list"). Complements types: types prevent category errors, properties verify behavioral correctness.
- **Formal verification**: TLA+, Coq, Isabelle prove correctness mathematically. Guarantees beyond what type systems provide but requires formal methods expertise and is impractical for most application development.
- **Comprehensive test suites**: 100% test coverage with mutation testing provides confidence comparable to static typing for behavior but does not prevent type errors in untested code paths and does not provide IDE support.

## Failure Modes

1. **Type system bypass via escape hatches**: TypeScript's `as any`, Java's raw types, Python's `# type: ignore`, Rust's `unsafe` block bypass the type system entirely. A single `as any` can propagate type errors through the entire call chain. `const config = JSON.parse(raw) as Config` asserts the type without validating it. Mitigation: lint against escape hatches (`@typescript-eslint/no-explicit-any`, `no-any` in tsconfig). Require code review comments for every escape hatch use. Use `unknown` instead of `any` in TypeScript -- it forces type narrowing before use.

2. **Type declaration drift from runtime reality**: The type says `interface User { id: number; email: string }` but the database returns `{ id: "123", email: null }` for legacy records. The type is a lie, and code trusting the type crashes. This is the most common source of "but the types said it was fine" bugs. Mitigation: validate all external data at the boundary. Use runtime validation libraries (Zod, Pydantic, io-ts) that produce both runtime validation AND static types from a single definition. Never use type assertions (`as T`) on data from external sources.

```typescript
// BAD: type assertion without validation
const user = await db.query('SELECT * FROM users WHERE id = $1', [id]);
return user as User;  // Lies to the type checker

// GOOD: runtime validation produces the type
const UserSchema = z.object({
  id: z.number(),
  email: z.string().email(),
  name: z.string().nullable(),
});
const user = UserSchema.parse(await db.query('...'));  // Runtime check + static type
```

3. **Overly generic types hiding information**: `function process(data: any): any` or `function handle(event: object): Result` provide no type information to callers. The function could return anything and accept anything. This is a dynamic function in a statically-typed language. Mitigation: use generics with constraints: `function process<T extends Validatable>(data: T): ProcessedResult<T>`. The type parameters communicate what the function accepts and returns.

4. **Excessive type complexity obscuring intent**: A type like `type Handler = <T extends U, U extends Record<string, V>, V extends W | X>(input: T) => Promise<ReturnType<U> & Partial<Config>>` communicates nothing to the reader except that the author knows advanced type syntax. The actual business logic is buried in type gymnastics. Mitigation: if a type takes more than 3 lines to read, it is probably too complex. Extract intermediate types with meaningful names. Prefer simple types that model the domain over clever types that model the type system.

5. **Null/undefined in type-unsafe positions**: `user.name.length` crashes when `name` is `null`, even in a "typed" language. TypeScript's `strictNullChecks` off by default (legacy projects), Python's type hints not enforced at runtime, Java's `Optional` not used consistently. Mitigation: enable strict null checking (`strictNullChecks: true` in TypeScript, `--strict` in mypy). Use option types (`Option<T>` in Rust, `Optional<T>` in Java) and require explicit handling of the none case. Treat null as a type system concern, not a runtime surprise.

6. **Variance errors in generics**: A `List<Dog>` is not a `List<Animal>` in most type systems (invariant), but developers expect it to be (covariant). `function process(animals: List<Animal>) { animals.add(new Cat()); }` -- if `List<Dog>` were passed as `List<Animal>`, a Cat would be added to a Dog list. This is why Java uses wildcards (`List<? extends Animal>`) and TypeScript uses invariance for mutable generics. Mitigation: understand variance rules for your language. Use `out T` (covariant, read-only) and `in T` (contravariant, write-only) annotations where available. Prefer immutable collections to avoid variance issues.

7. **False sense of security from type coverage**: A codebase has 100% type coverage and still has bugs. Types prevent category errors (passing a string as a number) but do not prevent logic errors (calculating tax as `price * 0.8` instead of `price * 1.2`), race conditions, off-by-one errors, or incorrect business rules. Mitigation: types are one layer of defense. Combine with unit tests (behavioral correctness), property-based tests (edge cases), and code review (design correctness). Types answer "does this compile correctly?" not "is this the right thing to do?"

## Code Examples

### Runtime validation producing static types (TypeScript + Zod)

```typescript
import { z } from 'zod';

// Single source of truth: schema defines BOTH runtime validation AND static type
const OrderItemSchema = z.object({
  sku: z.string().min(1).max(50),
  quantity: z.number().int().positive(),
  unitPriceCents: z.number().int().nonnegative(),
});

const OrderSchema = z.object({
  id: z.string().uuid(),
  customerId: z.string().uuid(),
  items: z.array(OrderItemSchema).min(1),
  status: z.enum(['pending', 'confirmed', 'shipped', 'delivered', 'cancelled']),
  createdAt: z.string().datetime(),
  metadata: z.record(z.string()).optional(),
});

// Static type inferred from schema -- no duplication
type Order = z.infer<typeof OrderSchema>;
type OrderItem = z.infer<typeof OrderItemSchema>;

// Safe parsing: rejects invalid data, produces typed result
function parseOrder(raw: unknown): Order {
  return OrderSchema.parse(raw);
  // Throws ZodError with detailed message if invalid:
  // [
  //   { "code": "invalid_type", "expected": "number", "received": "string", "path": ["items", 0, "quantity"] }
  // ]
}

// Safe parsing with error handling
function tryParseOrder(raw: unknown): { success: true; order: Order } | { success: false; error: string } {
  const result = OrderSchema.safeParse(raw);
  if (result.success) {
    return { success: true, order: result.data };
  }
  const errors = result.error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join('; ');
  return { success: false, error: errors };
}

// Computed type: derived from base types
const OrderWithTotalSchema = OrderSchema.extend({
  totalCents: z.number().int().nonnegative(),
});
type OrderWithTotal = z.infer<typeof OrderWithTotal>;

function enrichOrderWithTotal(order: Order): OrderWithTotal {
  const totalCents = order.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPriceCents,
    0,
  );
  return OrderWithTotalSchema.parse({ ...order, totalCents });
}
```

### Newtype pattern for domain modeling (TypeScript)

```typescript
/**
 * Newtype: wrap a primitive type in a branded type to prevent
 * mixing up values of the same underlying type.
 *
 * Prevents: passing a UserId where an OrderId is expected,
 * even though both are strings at runtime.
 */

// Branded types -- zero runtime cost, compile-time only
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };
type Email = string & { readonly __brand: 'Email' };

// Constructors enforce validation
function createUserId(raw: string): UserId {
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(raw)) {
    throw new Error(`Invalid UUID format for UserId: ${raw}`);
  }
  return raw as UserId;
}

function createEmail(raw: string): Email {
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(raw)) {
    throw new Error(`Invalid email format: ${raw}`);
  }
  return raw as Email;
}

// Usage: type system prevents mixing
function getOrder(orderId: OrderId): Promise<Order> { /* ... */ }
function getUser(userId: UserId): Promise<User> { /* ... */ }

const userId = createUserId('550e8400-e29b-41d4-a716-446655440000');
const orderId = createUserId('550e8400-e29b-41d4-a716-446655440000') as unknown as OrderId;
// Oops: used same UUID as OrderId -- runtime UUID check passes but domain is wrong

// getUser(orderId);  // TYPE ERROR: Argument of type 'OrderId' is not assignable to 'UserId'
// The type system catches the mistake even though the underlying value is a valid UUID

// Correct usage:
function createOrderId(raw: string): OrderId {
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(raw)) {
    throw new Error(`Invalid UUID format for OrderId: ${raw}`);
  }
  return raw as OrderId;
}

const correctOrderId = createOrderId('660e8400-e29b-41d4-a716-446655440001');
getOrder(correctOrderId);  // OK
// getOrder(userId);  // TYPE ERROR: UserId is not OrderId
```

### Exhaustive pattern matching (Rust)

```rust
// Rust's type system enforces exhaustive pattern matching.
// Every possible case must be handled -- the compiler verifies this.

#[derive(Debug)]
enum OrderStatus {
    Pending,
    Confirmed { payment_id: String },
    Shipped { tracking_number: String },
    Delivered { delivered_at: String },
    Cancelled { reason: String, refunded: bool },
}

fn handle_order(order: &OrderStatus) -> &'static str {
    match order {
        // If you forget any variant, the compiler errors:
        // "non-exhaustive patterns: `Cancelled` not covered"
        OrderStatus::Pending => "Order is awaiting processing",
        OrderStatus::Confirmed { payment_id } => {
            &format!("Order confirmed, payment {}", payment_id)
        }
        OrderStatus::Shipped { tracking_number } => {
            &format!("Order shipped, tracking {}", tracking_number)
        }
        OrderStatus::Delivered { delivered_at } => {
            &format!("Order delivered at {}", delivered_at)
        }
        OrderStatus::Cancelled { reason, refunded } => {
            if *refunded {
                &format!("Order cancelled: {}, refunded", reason)
            } else {
                &format!("Order cancelled: {}, NOT refunded", reason)
            }
        }
    }
}

// Adding a new variant is a compile-time event:
// enum OrderStatus { ..., Refunded { refund_id: String } }
// --> compiler error: "non-exhaustive patterns: `Refunded` not covered"
// --> you MUST update every match, or the code does not compile
// --> impossible to forget a case in production

// Contrast with TypeScript/JavaScript switch:
// Adding a case to a TypeScript enum does NOT produce a compile error
// for existing switch statements. The default branch (if present)
// silently handles the new case, often incorrectly.
```

### Gradual typing migration (Python with mypy)

```python
"""
Gradual typing strategy: add types incrementally to an existing
Python codebase, enforcing stricter checking over time.

Phase 1: Type hints without enforcement (documentation only)
Phase 2: mypy in CI with permissive settings
Phase 3: mypy strict mode for new files
Phase 4: mypy strict mode for entire codebase
"""

from __future__ import annotations
from typing import Protocol, runtime_checkable
from dataclasses import dataclass
from datetime import datetime


# Phase 1: Add types to public interfaces (highest value)
@dataclass
class Customer:
    id: str
    email: str
    name: str | None  # Explicit: name can be None
    created_at: datetime
    order_count: int = 0


# Phase 2: Use Protocol for structural subtyping (duck typing with types)
@runtime_checkable
class Notifiable(Protocol):
    def notify(self, message: str) -> bool:
        ...


def send_notification(recipient: Notifiable, message: str) -> bool:
    """Any object with a notify(message) -> bool method is acceptable."""
    return recipient.notify(message)


# Phase 3: Use generics for type-safe collections
from typing import TypeVar, Generic

T = TypeVar('T')


class Repository(Generic[T]):
    """Type-safe repository -- the type parameter propagates through all methods."""

    def __init__(self) -> None:
        self._store: dict[str, T] = {}

    def get(self, id: str) -> T | None:
        return self._store.get(id)

    def save(self, id: str, entity: T) -> None:
        self._store[id] = entity

    def delete(self, id: str) -> T | None:
        return self._store.pop(id, None)


# Usage: type system enforces correct repository type
customer_repo: Repository[Customer] = Repository()
customer_repo.save('cust-1', Customer(
    id='cust-1',
    email='ana@example.com',
    name='Ana',
    created_at=datetime.now(),
))

# customer_repo.save('cust-2', 'not a customer')  # mypy error
# customer_repo.get('cust-1').order_count  # OK: mypy knows this returns Customer | None

# Phase 4: mypy strict mode configuration (mypy.ini)
# [mypy]
# strict = true
# warn_return_any = true
# disallow_untyped_defs = true
# disallow_incomplete_defs = true
# check_untyped_calls = true
# no_implicit_optional = true
# warn_unreachable = true
# strict_equality = true
```

## Best Practices

- **Validate at boundaries, trust internally**: All external data (API requests, database rows, file contents, environment variables) must be validated at the point of entry. Once validated, trust the types internally. This creates a "typed core" with a "dynamic shell" at the boundaries.
- **Use the strictest type checking available**: Enable `strict: true` in TypeScript, `--strict` in mypy, `#![deny(warnings)]` in Rust. Loosen specific rules with explicit justification, not by default.
- **Prefer specific types over general types**: `type Email = string & { readonly __brand: 'Email' }` is better than `string`. `type UserId = number` is better than `number`. The type system should encode domain semantics, not just data representation.
- **Avoid `any`/`Object`/`interface{}` as a matter of policy**: These types disable type checking. Use `unknown` (TypeScript) which requires type narrowing, or generics with constraints. If you must use an escape hatch, document why and add a TODO for eventual removal.
- **Model impossible states as unrepresentable**: If a user cannot be both `active` and `suspended`, use a sum type: `type UserStatus = Active | Suspended { reason: string }`. The type system prevents creating a user in an invalid state. This is the "make illegal states unrepresentable" principle.
- **Keep types close to their use**: Define types in the module that uses them, not in a shared `types.ts` file. Types are implementation details; export only the public interface. Shared type files become dumping grounds that couple unrelated modules.
- **Use types for API contracts**: Define API request/response types and generate client code from them (OpenAPI, GraphQL codegen). The type system ensures the client and server agree on the contract. Mismatches are compile errors, not runtime surprises.
- **Treat type errors as documentation**: When the type checker rejects code, it is telling you something about your design. "This function expects X but you are passing Y" is often a design flaw, not a typing error. Listen to the type checker.

## Related Topics

- [[StaticAnalysis]] -- type checking as a form of static analysis
- [[CodeQuality]] -- type safety as a quality attribute reducing defect rates
- [[QualityGates]] -- type checking as a mandatory gate in CI/CD
- [[Security]] -- type safety preventing injection and memory safety vulnerabilities
- [[Composability]] -- type systems enabling safe composition of components
- [[DeveloperExperience]] -- type systems enabling IDE autocomplete, go-to-definition, inline documentation
- [[DataProcessing]] -- typed data pipelines vs. untyped data processing
- [[Portability]] -- type systems as a portability mechanism (compile-time guarantees across platforms)
- [[Programming]] -- language-specific type system design choices
- [[CognitiveComplexity]] -- type annotations as documentation reducing cognitive load
