---
title: State Machines
title_pt: Máquinas de Estado
layer: architecture
type: concept
priority: critical
version: 1.0.0
id: core.arch.statemachines.v1
tags:
  - Architecture
  - StateMachines
  - DesignPatterns
  - DistributedSystems
keywords:
  - finite state machine
  - DFA
  - NFA
  - statechart
  - state transition
  - workflow engine
  - state pattern
  - sealed class
  - discriminated union
  - XState
description: Formal model of computation using states and transitions — essential for reasoning about systems with stateful behavior, protocols, workflows, and UI.
---

# State Machines

## Description

A state machine is a mathematical model of computation consisting of:
- A finite set of **states**
- A finite set of **events** (inputs)
- A **transition function** mapping (state, event) → new state
- An **initial state**
- Optionally, a set of **accepting/final states**

In engineering, state machines model anything that has memory and responds to inputs: payment processing, order fulfillment, network protocols, UI components, workflow engines, game logic.

**Variants:**
- **DFA** (Deterministic Finite Automaton) — one transition per (state, event)
- **NFA** (Nondeterministic) — multiple possible transitions per (state, event)
- **Moore machine** — output depends only on current state
- **Mealy machine** — output depends on current state AND input event
- **Statechart** — hierarchical, concurrent states with history and guards (Harel)

## Purpose

**When state machines are essential:**
- Workflow engines (order processing, approval chains, CI/CD pipelines)
- Protocol implementations (TCP handshake, OAuth2 flows, WebSocket lifecycle)
- Payment processing (pending → authorized → captured → settled → refunded)
- UI components with complex interaction patterns (loading → success → error → retry)
- Game AI (idle → patrol → chase → attack → flee)
- Device drivers and embedded systems
- Any domain where "what happens next depends on what happened before"

**When state machines are overkill:**
- Simple CRUD operations with no workflow
- Stateless request-response patterns
- Single-step processes with no branching

**The key question:** Does this system have memory — does the response to an event depend on previous events?

## Tradeoffs

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| Explicit state machine (enum + switch) | Clear, exhaustively checkable, testable | Verbose for simple flows | Small-medium state spaces |
| Statechart library (XState, Stateless) | Visual diagrams, hierarchical states, guards | Learning curve, dependency | Complex UI, workflows |
| Implicit state (boolean flags) | Simple, no abstraction | Exponential state space, easy to miss transitions | Trivial cases only |
| Database-driven state | Persistent, auditable, queryable | Slower, needs migrations | Long-running workflows |
| Event sourcing | Full history, replayable, debuggable | Complex, needs event schema discipline | Audit-critical domains |

## Alternatives

- **Flowcharts/BPMN** — visual workflow notation (good for business analysts, less precise than code)
- **Petri nets** — concurrent state modeling (good for parallel processes)
- **Process calculi** (π-calculus, CSP) — formal reasoning about concurrent communicating processes
- **Behavior trees** — hierarchical decision trees (common in game AI)

## Examples

### State Machine in TypeScript (Order Processing)

```typescript
type OrderState =
  | { status: 'created' }
  | { status: 'pending_payment'; orderId: string; expiresAt: number }
  | { status: 'paid'; orderId: string; paymentId: string }
  | { status: 'shipped'; orderId: string; trackingNumber: string }
  | { status: 'delivered'; orderId: string }
  | { status: 'cancelled'; reason: string }
  | { status: 'refunded'; orderId: string; refundId: string };

type OrderEvent =
  | { type: 'payment_initiated'; orderId: string; expiresAt: number }
  | { type: 'payment_confirmed'; orderId: string; paymentId: string }
  | { type: 'payment_failed'; orderId: string; reason: string }
  | { type: 'shipped'; orderId: string; trackingNumber: string }
  | { type: 'delivered'; orderId: string }
  | { type: 'cancel'; orderId: string; reason: string }
  | { type: 'refund'; orderId: string; refundId: string };

function transition(state: OrderState, event: OrderEvent): OrderState {
  switch (state.status) {
    case 'created':
      if (event.type === 'payment_initiated')
        return { status: 'pending_payment', orderId: event.orderId, expiresAt: event.expiresAt };
      if (event.type === 'cancel')
        return { status: 'cancelled', reason: event.reason };
      throw new InvalidTransitionError(state.status, event.type);

    case 'pending_payment':
      if (event.type === 'payment_confirmed')
        return { status: 'paid', orderId: event.orderId, paymentId: event.paymentId };
      if (event.type === 'payment_failed')
        return { status: 'cancelled', reason: event.reason };
      if (event.type === 'cancel')
        return { status: 'cancelled', reason: event.reason };
      throw new InvalidTransitionError(state.status, event.type);

    case 'paid':
      if (event.type === 'shipped')
        return { status: 'shipped', orderId: event.orderId, trackingNumber: event.trackingNumber };
      if (event.type === 'cancel')
        return { status: 'cancelled', reason: event.reason };
      throw new InvalidTransitionError(state.status, event.type);

    case 'shipped':
      if (event.type === 'delivered')
        return { status: 'delivered', orderId: event.orderId };
      throw new InvalidTransitionError(state.status, event.type);

    case 'delivered':
      if (event.type === 'refund')
        return { status: 'refunded', orderId: event.orderId, refundId: event.refundId };
      throw new InvalidTransitionError(state.status, event.type);

    case 'cancelled':
    case 'refunded':
      // Terminal states — no transitions allowed
      throw new InvalidTransitionError(state.status, event.type);

    default:
      const _exhaustive: never = state;
      return _exhaustive; // TypeScript ensures all states are handled
  }
}
```

### State Machine with XState (UI Component)

```typescript
import { createMachine, assign } from 'xstate';

const fetchMachine = createMachine({
  id: 'fetch',
  initial: 'idle',
  context: { data: null, error: null, retries: 0 },
  states: {
    idle: {
      on: { FETCH: 'loading' }
    },
    loading: {
      invoke: { src: 'fetchData', onDone: 'success', onError: 'failure' }
    },
    success: {
      type: 'final',
      entry: assign({ data: (_, event) => event.data })
    },
    failure: {
      entry: assign({ error: (_, event) => event.error }),
      after: {
        3000: { target: 'loading', cond: (ctx) => ctx.retries < 3 }
      },
      on: { RETRY: 'loading' }
    }
  }
});
```

### Guarded Transitions (Preventing Invalid State)

```python
class PaymentStateMachine:
    """Payment processing with guard conditions."""

    def __init__(self):
        self.state = 'initialized'
        self.amount = 0
        self.authorized_amount = 0

    def authorize(self, amount: float) -> bool:
        if self.state != 'initialized':
            raise InvalidTransition(self.state, 'authorize')
        if amount <= 0:
            raise ValueError("Amount must be positive")
        self.state = 'authorized'
        self.amount = amount
        self.authorized_amount = amount
        return True

    def capture(self, amount: float) -> bool:
        if self.state != 'authorized':
            raise InvalidTransition(self.state, 'capture')
        if amount > self.authorized_amount:
            raise OverCaptureError(f"Cannot capture {amount} > authorized {self.authorized_amount}")
        self.state = 'captured' if amount == self.authorized_amount else 'partially_captured'
        self.amount -= amount
        return True

    def refund(self, amount: float) -> bool:
        if self.state not in ('captured', 'partially_captured'):
            raise InvalidTransition(self.state, 'refund')
        if amount > self.authorized_amount:
            raise OverRefundError(f"Cannot refund {amount} > captured {self.authorized_amount}")
        self.state = 'refunded'
        return True
```

## Failure Modes

- **Implicit state with boolean flags** → `isPaid && !isShipped && isCancelled` is contradictory but compiles → exponential bug surface → use explicit state types (sealed classes, unions, enums)
- **Missing transition validation** → invalid event accepted silently → corrupted business state → always validate (state, event) pair and reject unknown transitions
- **No terminal state enforcement** → action on completed/cancelled workflow → duplicate charges, double shipping → throw on transitions from terminal states
- **State persistence without versioning** → schema changes break loaded state → application crash → version state schemas, provide migration functions
- **Concurrent state mutations** → two threads transition simultaneously → race condition → lost update → use single-threaded event loop or mutex around state transitions
- **Guard condition missing** → transition allowed with insufficient data → partial payment captured, item shipped before payment → encode guards as preconditions in transition function
- **State explosion** → 10 boolean flags = 1024 possible states, only 5 valid → combinatorial testing impossible → use statechart hierarchies or decompose into multiple machines
- **Event ordering dependency** → event B must follow event A but arrives first → state machine rejects or corrupts → use event sourcing with sequence numbers, buffer and reorder
- **Unmodeled edge cases** → "what about timeout?" → production incident with pending payment never expiring → enumerate all events including timeout, cancellation, retry for every state
- **Debugging difficulty** → "how did we get here?" → no audit trail → log every transition (from_state, event, to_state), consider event sourcing for critical domains

## Anti-Patterns

### 1. Boolean Flag Combinatorics

**Bad:** Tracking order state with `isPaid`, `isShipped`, `isCancelled`, `isRefunded` — 2^4 = 16 combinations, only ~5 are valid
**Why it's bad:** Impossible combinations compile without error — `isPaid && isCancelled` is meaningless but type-checks
**Good:** Use a single discriminated union/sealed class — only valid states can be represented

### 2. Silent Invalid Transition

**Bad:** Ignoring events that don't match current state — event silently dropped
**Why it's bad:** Client thinks action succeeded, server silently discarded it → inconsistent state between client and server
**Good:** Always throw/reject on invalid transitions, return error to caller, log the attempt

### 3. Distributed State Without Consensus

**Bad:** Multiple services each maintain their own view of workflow state
**Why it's bad:** Services diverge — payment service says "captured", fulfillment says "pending" → customer charged, nothing shipped
**Good:** Single source of truth for state (database with transactions), or use saga pattern with compensating transactions

## Best Practices

1. **Use sealed types / discriminated unions** — compiler enforces exhaustive state handling
2. **Make transitions pure functions** — `(state, event) → new_state` — testable, debuggable, replayable
3. **Log every transition** — `(from_state, event, to_state, timestamp, correlation_id)` — enables audit and debugging
4. **Validate at boundaries** — reject invalid events immediately, never silently ignore
5. **Enumerate timeout/cancellation events** — every state needs "what if nothing happens?" handling
6. **Use statechart libraries for complexity** — XState (TypeScript), Stateful (Python), Stateless (.NET) — visual diagrams, guard conditions, hierarchical states
7. **Version persisted state** — include schema version, provide migration functions
8. **Test all transitions** — generate (state, event) pairs, verify expected outcomes
9. **Guard conditions belong in transition function** — don't scatter business logic across callers
10. **Consider event sourcing** — if you need audit trail, replay, or temporal queries, store events not just current state

## Related Topics

- [[DistributedSystems]] — State in distributed contexts
- [[EventArchitecture]] — Events as state transitions
- [[EventSourcing]] — Persisting events instead of state
- [[SagaPattern]] — Multi-service state coordination
- [[Idempotency]] — Safe retry of state transitions
- [[Concurrency]] — Concurrent state mutation risks
- [[DesignPatterns]] — State pattern in OOP
- [[FormalVerification]] — Verifying state machine properties
- [[Idempotency]] — Making retry-safe transitions