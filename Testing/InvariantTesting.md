---
title: Invariant Testing
layer: testing
type: concept
priority: high
version: 2.0.0
tags:
  - Testing
  - PropertyTesting
  - Invariants
  - FormalMethods
description: Testing properties that must always hold true regardless of input, using property-based and invariant-driven techniques to uncover edge-case bugs that example-based tests miss.
---

# Invariant Testing

## Description

Invariant testing verifies that specific properties of a system remain true across all possible inputs, states, and execution orders. Unlike example-based unit tests that check specific input-output pairs, invariant tests express universal quantification: "for all inputs X, property P holds." This is typically implemented via property-based testing frameworks (Hypothesis, QuickCheck, fast-check) that generate thousands of randomized inputs, or via runtime assertions that check invariants in production.

An **invariant** is a condition that is guaranteed to be true throughout the lifetime of a system or component. Common invariants include: type safety, referential transparency, balance conservation in accounting systems, idempotency guarantees, and monotonicity of sequence numbers.

## Purpose

**When to use:**

- **Data structure invariants**: verifying that a binary search tree maintains ordering after any sequence of insertions and deletions; that a red-black tree maintains the black-height property; that a hash map never has duplicate keys.
- **Numerical/conservation properties**: in financial systems, the sum of all account balances must remain constant under transfers (money cannot be created or destroyed); in inventory systems, total stock = allocated + available.
- **Idempotency**: calling an API endpoint multiple times with the same request produces the same result as calling it once (critical for retry logic in distributed systems).
- **State machine transitions**: a workflow engine must never allow an order to transition from `shipped` back to `pending`; invariants encode the valid transition matrix.
- **Cryptographic protocols**: encryption followed by decryption must return the original plaintext for all valid keys and inputs.
- **Serialization/deserialization round-trips**: `decode(encode(x)) == x` for all valid `x`; critical for protocol buffers, JSON schemas, and wire formats.
- **Sorting and ordering**: after sorting, `output[i] <= output[i+1]` for all `i`; the output must be a permutation of the input (no elements lost or duplicated).
- **Distributed system invariants**: causal ordering (if event A happened before B, all nodes observe A before B); exactly-once processing semantics.

**When to avoid:**

- **Simple CRUD operations with no business logic** — example-based tests with boundary values (empty string, max length, null) cover the space adequately. Invariant testing adds complexity without proportional benefit.
- **UI rendering logic** — visual output is hard to express as mathematical invariants. Use [[SnapshotTesting]] or [[VisualRegressionTesting]] instead.
- **When the invariant itself is unclear or disputed** — if the team cannot agree on what "must always be true," the property-based test will encode an incorrect assumption and produce false failures.
- **When the domain model is still evolving** — invariants are contracts. If the contract changes weekly, the invariant tests become maintenance burden. Wait for model stability.

## Tradeoffs

| Dimension | Example-based tests | Invariant/property-based tests |
|---|---|---|
| Input coverage | Hand-picked (dozens of cases) | Exhaustive random (thousands of cases) |
| Edge-case discovery | Depends on tester's imagination | Automatic — finds cases you never considered |
| Debuggability | Easy — known input, known output | Harder — must use shrinking to find minimal failing case |
| Setup cost | Low | Medium-high — must learn framework, define generators |
| Maintenance | Stable — inputs rarely change | Moderate — generators may need tuning as domain evolves |
| Bug detection rate | Good for known paths | Superior for unknown edge cases |

**Alternatives:**

- **Fuzzing** — feeds random/mutated inputs to find crashes and security vulnerabilities. Broader than invariant testing (finds crashes, not property violations). Use `AFL`, `libFuzzer`, or [[Fuzzing]] for security; use property-based testing for logic correctness.
- **Formal verification** — mathematically proves invariants hold for all inputs (TLA+, Coq, Isabelle). Stronger guarantee than property-based testing but requires significantly more expertise and time. Use for safety-critical systems (consensus protocols, kernels).
- **Runtime assertions** — embed `assert` statements in production code to check invariants at runtime. Catches violations in production that tests missed. Use with `NDEBUG` awareness (assertions may be compiled out in release builds).
- **Model checking** — exhaustively explores all reachable states of a finite-state model (TLA+ model checker). Catches invariant violations that property-based tests might miss if the random generator happens not to produce the triggering input sequence.

## Rules

1. **Identify invariants from the domain, not the code.** Invariants are business rules or mathematical properties, not implementation details. "Total balance is conserved" is a domain invariant. "The hash map uses chaining for collision resolution" is an implementation detail — test it via behavior, not structure.

2. **Test the inverse/round-trip.** For every encoding operation, test that decoding recovers the original. For every state transition, test that the inverse transition is either valid or correctly rejected.

3. **Use shrinking to find minimal counterexamples.** When a property fails, the framework should shrink the input to the smallest value that still triggers the failure. This is the difference between "failed on `[-42, 17, 0, 99, -1, ...]`" and "failed on `[0, 0]`."

4. **Define generators that cover the input space meaningfully.** Random strings from `a-z` will not exercise Unicode edge cases. Generate inputs that include: empty values, boundary values, Unicode surrogate pairs, null bytes, and domain-specific malformed data.

5. **Test invariants at state boundaries, not just steady state.** Many invariants hold during normal operation but break during initialization, shutdown, or error recovery. Test the transition, not just the endpoint.

6. **Combine invariants with example-based tests.** Property-based tests find edge cases; example-based tests document known scenarios and serve as regression tests. They are complementary, not substitutable.

7. **Seed your random generator for reproducibility.** Every property-based test run must be reproducible. Log the seed on failure so the exact test can be re-run. Most frameworks do this automatically, but verify.

## Examples

### Example 1: Serialization round-trip invariant

```python
# Hypothesis test: encode then decode must return the original value
from hypothesis import given, strategies as st
from my_protocol import encode_message, decode_message
from my_protocol import Message

@given(
    st.builds(
        Message,
        id=st.integers(min_value=0, max_value=2**63 - 1),
        payload=st.text(alphabet=st.characters(min_codepoint=32, max_codepoint=126)),
        timestamp=st.integers(min_value=0, max_value=2**32 - 1),
    )
)
def test_encode_decode_round_trip(msg: Message):
    encoded = encode_message(msg)
    decoded = decode_message(encoded)
    assert decoded == msg, f"Round-trip failed: {msg!r} -> {encoded!r} -> {decoded!r}"
```

This test catches bugs like: encoding truncates large integers, decoding misinterprets UTF-8 sequences, or field ordering mismatches between encoder and decoder.

### Example 2: Balance conservation in a banking system

```python
from hypothesis import given, settings, strategies as st
from banking import Account, transfer, get_total_balance

@given(
    initial_balances=st.lists(
        st.integers(min_value=0, max_value=10_000_000),
        min_size=2,
        max_size=10,
    ),
    transfers=st.lists(
        st.tuples(
            st.integers(min_value=0, max_value=9),  # from_index
            st.integers(min_value=0, max_value=9),  # to_index
            st.integers(min_value=1, max_value=1_000),  # amount
        ),
        min_size=1,
        max_size=50,
    ),
)
@settings(max_examples=200)
def test_balance_conservation(initial_balances, transfers):
    accounts = [Account(balance=b) for b in initial_balances]
    initial_total = sum(initial_balances)

    for from_idx, to_idx, amount in transfers:
        try:
            transfer(accounts[from_idx], accounts[to_idx], amount)
        except InsufficientFundsError:
            pass  # Legitimate rejection

    final_total = sum(a.balance for a in accounts)
    assert final_total == initial_total, (
        f"Balance conservation violated: "
        f"initial={initial_total}, final={final_total}, delta={final_total - initial_total}"
    )
```

This catches bugs like: double-debiting, missing credits on error rollback, floating-point precision loss in fractional transfers, or race conditions in concurrent transfers.

### Example 3: Idempotency invariant for API endpoints

```python
from hypothesis import given, settings
import requests
import uuid

@given(
    amount=st.integers(min_value=1, max_value=10000),
    recipient=st.text(min_size=1, max_size=50, alphabet="abcdefghijklmnopqrstuvwxyz"),
)
@settings(max_examples=100)
def test_payment_idempotency(amount, recipient):
    idempotency_key = str(uuid.uuid4())
    headers = {"Idempotency-Key": idempotency_key}
    payload = {"amount": amount, "recipient": recipient}

    # First call
    resp1 = requests.post("/api/payments", json=payload, headers=headers)

    # Second call with same key must return same result
    resp2 = requests.post("/api/payments", json=payload, headers=headers)

    assert resp1.status_code == resp2.status_code, (
        f"Status mismatch: {resp1.status_code} vs {resp2.status_code}"
    )
    if resp1.status_code == 200:
        assert resp1.json()["payment_id"] == resp2.json()["payment_id"], (
            "Duplicate payment created — idempotency invariant violated"
        )
```

### Example 4: BST ordering invariant

```python
from hypothesis import given, strategies as st
from bst import BinarySearchTree, insert, delete

def is_valid_bst(node, min_val=float("-inf"), max_val=float("inf")):
    if node is None:
        return True
    if node.value <= min_val or node.value >= max_val:
        return False
    return is_valid_bst(node.left, min_val, node.value) and \
           is_valid_bst(node.right, node.value, max_val)

@given(
    operations=st.lists(
        st.one_of(
            st.tuples(st.just("insert"), st.integers()),
            st.tuples(st.just("delete"), st.integers()),
        ),
        min_size=1,
        max_size=200,
    )
)
def test_bst_ordering_invariant(operations):
    tree = BinarySearchTree()
    for op, value in operations:
        if op == "insert":
            insert(tree, value)
        else:
            delete(tree, value)
        assert is_valid_bst(tree.root), (
            f"BST ordering invariant violated after {op}({value}). "
            f"Operations: {operations[:operations.index((op, value)) + 1]}"
        )
```

### Bad Example: Testing an implementation detail, not an invariant

```python
# BAD: This tests the internal structure of a hash map, not a behavioral invariant
def test_hash_map_uses_open_addressing():
    hm = HashMap()
    hm.put("key", "value")
    assert hm._probing_sequence is not None  # Tests implementation, not behavior

# GOOD: Test the behavioral invariant — unique keys map to unique values
@given(
    pairs=st.lists(st.tuples(st.text(), st.integers()), min_size=1, max_size=100),
)
def test_hash_map_unique_keys(pairs):
    hm = HashMap()
    for key, value in pairs:
        hm.put(key, value)
    for key, value in pairs:
        assert hm.get(key) == value  # Last write wins, regardless of internal structure
```

**Why it's bad:** Testing internal structure (`_probing_sequence`) couples the test to a specific implementation. If the hash map switches from open addressing to chaining, the test breaks even though the behavior is correct. Invariants should hold regardless of implementation.

## Failure Modes

1. **Misdefined invariants** → the test encodes a property that is not actually invariant, producing false failures. Example: testing "list length is preserved after sorting" when the sort implementation correctly deduplicates. Root cause: confusing implementation behavior with domain guarantees. Mitigation: validate every invariant against the specification or domain expert before encoding it as a test.

2. **Generator bias** → the random generator does not produce certain classes of inputs, so bugs in those regions are never triggered. Example: a string generator that only produces ASCII never exercises Unicode normalization bugs. Mitigation: audit generators against the full input domain; use composite strategies that explicitly include edge cases (empty, null, boundary, malformed).

3. **Non-deterministic tests** → property fails intermittently due to time-dependent code, random seeds, or external state. Root cause: the code under test reads `datetime.now()`, calls a random number generator, or depends on network state. Mitigation: inject time and randomness as dependencies; use `hypothesis.extra.datetime` strategies to control the clock.

4. **Shrinker produces unhelpful minimal cases** → the framework shrinks to `[0]` but the real bug requires `[-1, 0, 1]` to manifest. Root cause: the shrinker's ordering does not match the property's sensitivity. Mitigation: write custom shrinkers; use `@example()` decorators to force specific inputs alongside random generation.

5. **Combinatorial explosion in stateful invariants** → testing all sequences of 20 operations on 10 accounts generates 10^40 possible sequences; the property test runs 100 and claims coverage. Root cause: stateful property testing cannot exhaustively cover the space. Mitigation: use model-based testing (Hypothesis state machines); focus on operation sequences known to stress the system (insert-then-delete, concurrent writes, boundary transitions).

6. **Invariant masks a deeper design flaw** → the test passes because the invariant is trivially true (e.g., testing "the list is sorted" on a list that is always empty). Root cause: the generator does not produce inputs that exercise the interesting behavior. Mitigation: add coverage assertions; verify that the generator produces inputs that trigger both true and false branches in the code.

7. **Performance degradation from excessive examples** → running 10,000 examples per property makes the test suite take 45 minutes instead of 4. Root cause: over-testing for properties that stabilize after a few hundred examples. Mitigation: use `@settings(max_examples=...)` per property; reduce examples for simple properties, increase for complex ones; run full property suite nightly, smoke version on every commit.

8. **False confidence from passing property tests** → all properties pass, but the code has a bug in a scenario the property does not cover. Example: testing `encode(decode(x)) == x` but not testing that `encode(x)` produces valid output for the wire protocol. Root cause: invariants are necessary but not sufficient conditions for correctness. Mitigation: combine invariant testing with example-based regression tests, fuzzing, and [[IntegrationTesting]].

## Best Practices

- **Start with the invariants you can state in plain English.** If you cannot articulate the invariant without referencing code, you do not yet understand the domain well enough to test it.
- **Use `@example()` to document known bugs and edge cases.** `@example([])`, `@example([0, 0])`, `@example([1, -1])` serve as both regression tests and documentation of the kinds of inputs that have caused bugs before.
- **Test invariants at the boundary of trust.** Code that receives data from untrusted sources (network, user input, files) should have the strongest invariants. Internal utility functions may not need property-based tests.
- **Run property tests in CI with a reduced example count.** Run 50 examples per property on every commit, 500 examples nightly. This balances feedback speed with coverage.
- **Use stateful testing for protocols and state machines.** Hypothesis's `RuleBasedStateMachine` models the system as a state machine with preconditions and invariants. This is the right tool for APIs, databases, and workflow engines.
- **Log the seed on failure and commit reproducing examples.** When a property test fails, the seed and minimal example are gold. Add them as `@example()` decorators so they are tested on every run.
- **Do not test properties that are enforced by the type system.** If the compiler guarantees `int + int -> int`, you do not need a property test for it. Reserve invariant testing for logic that the type system cannot express (business rules, state transitions, conservation laws).
- **Combine with [[MutationTesting]].** If mutation testing shows that your property tests do not kill mutants, the invariants are too weak. Add more properties or refine generators.

## Related Topics

- [[Testing MOC]] — Navigation hub for all testing methodologies
- [[PropertyTesting]] — The broader category; invariant testing is a subset focused on always-true properties
- [[Fuzzing]] — Random input generation to find crashes; complements invariant testing which finds logic bugs
- [[UnitTesting]] — Example-based unit tests document known scenarios; invariant tests discover unknown edge cases
- [[IntegrationTesting]] — Invariant testing across component boundaries catches integration bugs
- [[TestDoubles]] — Use test doubles to isolate the system under test from non-deterministic dependencies (time, network, random)
- [[MutationTesting]] — Validates whether invariant tests are strong enough to catch injected faults
- [[TDD]] — Write the invariant test first, then implement the code that satisfies it
- [[Design/Invariants]] — Design-level discussion of invariants as a modeling tool
- [[Programming/Concurrency]] — Concurrent code is a primary target for invariant testing (race conditions, visibility, ordering)
- [[Architecture/DistributedSystems]] — Distributed systems rely on invariants (causal ordering, exactly-once, consensus) that are hard to test with examples alone
- [[Architecture/Consistency]] — Consistency models are expressed as invariants; property-based testing validates them
- [[Architecture/DistributedTransactions]] — ACID properties are invariants; test that transactions maintain them under failure
- [[Design/Contracts]] — Preconditions and postconditions are invariants; Design by Contract formalizes the relationship
- [[SecurityTesting]] — Security invariants (no privilege escalation, no data leakage) can be tested with property-based techniques
- [[RegressionTesting]] — Convert every production bug into an `@example()` in the relevant property test
- [[TestArchitecture]] — Organize property-based tests separately from example-based tests; they serve different purposes
- [[TestCoverage]] — Property tests may show high coverage but miss specific paths; combine with branch coverage analysis
- [[AIValidation]] — AI-generated code often violates invariants; property-based tests are an effective validation tool
