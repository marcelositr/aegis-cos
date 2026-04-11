---
title: Formal Verification
layer: foundations
type: concept
priority: high
version: 2.0.0
tags:
  - Foundations
  - Verification
  - Proofs
  - Correctness
description: Using mathematical methods to prove the correctness of algorithms, protocols, and systems -- going beyond testing to establish guarantees.
---

# Formal Verification

## Description

Formal verification uses mathematical logic to **prove** that a system satisfies a specification, as opposed to testing which can only show the **presence** of bugs, not their **absence**. The spectrum ranges from lightweight (property-based testing, model checking) to heavyweight (interactive theorem proving, verified compilation).

Key techniques:
- **Model checking:** Exhaustively explores all reachable states of a finite-state system against a temporal logic specification. Tools: TLA+, SPIN, Alloy.
- **Deductive verification:** Uses Hoare logic, weakest preconditions, or separation logic to prove correctness. Tools: Dafny, Frama-C, Why3, Coq.
- **SMT-based verification:** Encodes program properties as satisfiability modulo theories queries. Tools: Z3, CVC5, Kani.
- **Theorem proving:** Interactive proof assistants for full mathematical rigor. Tools: Coq, Isabelle/HOL, Lean.

## Purpose

**When to use:**
- Safety-critical systems where bugs cost lives or billions: avionics (DO-178C), medical devices, nuclear plant control, railway signaling.
- Cryptographic protocols and implementations: verifying constant-time execution, memory safety, and protocol correctness (e.g., HACL* verified in F*, used in Firefox and WireGuard).
- Concurrent/distributed algorithms where testing is inadequate: consensus protocols (Raft, Paxos), lock-free data structures, memory models. Leslie Lamport used TLA+ to find bugs in the Alpha storage system, Chubby lock service, and the Linux RAID driver.
- Compiler correctness: CompCert (verified in Coq) guarantees that compiled C code preserves the semantics of the source.
- Financial smart contracts: verifying invariants like "total supply is conserved" or "no reentrancy is possible" before deploying to blockchain.
- Any system where a class of bugs is **catastrophic** and cannot be caught by testing alone (e.g., an off-by-one in a buffer size that only triggers under rare timing).

**When NOT to use:**
- CRUD applications, UI components, or business logic where integration tests and property-based testing catch >99% of bugs at a fraction of the cost.
- Early-stage prototypes or rapidly iterating products where the spec changes weekly -- the verification effort becomes waste.
- When the property you care about is non-functional and hard to formalize ("the UX feels responsive", "the output looks reasonable").
- When your team lacks the expertise and budget to maintain formal specs. A stale, incorrect spec is worse than no spec (it creates false confidence).
- Performance-critical code where the overhead of using a verified-safe language or proof-carrying code is unacceptable (e.g., inner loops in game engines, HPC kernels).

## Tradeoffs

| Technique | Effort | Automation | Bugs found | Learning curve | Best for |
|---|---|---|---|---|---|
| Model checking (TLA+) | Medium | High (automatic) | Design-level concurrency bugs | Medium | Distributed algorithms, protocol design |
| SMT solving (Z3) | Low-Medium | High | Constraint satisfaction, pre/post conditions | Medium | Algorithm verification, constraint problems |
| Property-based testing (Hypothesis, QuickCheck) | Low | High | Edge cases in pure functions | Low | API contracts, serialization, parsers |
| Deductive verification (Dafny) | High | Medium | Full functional correctness | High | Algorithms, data structures |
| Interactive theorem proving (Coq) | Very High | Low | Full mathematical correctness | Very High | Compilers, crypto, mathematics |

**The ROI curve is J-shaped:** lightweight methods (property-based testing, model checking) give excellent ROI for most teams. Heavyweight methods (interactive proofs) are only justified when the cost of failure is extreme.

## Alternatives

- **Property-based testing (PBT):** Generate thousands of random inputs and check invariants. Catches most bugs at low cost. Tools: Hypothesis (Python), QuickCheck (Haskell), proptest (Rust). Often the right first step before formal verification.
- **Fuzzing:** Generate random inputs guided by code coverage. Excellent for finding crashes and memory safety bugs. Tools: AFL++, libFuzzer, honggfuzz. Complements (does not replace) formal methods.
- **Static analysis:** Sound or heuristic-based analysis without full proofs. Tools: Coverity, CodeQL, Clang static analyzer. Good for catching classes of bugs (null deref, buffer overflow) with low effort.
- **Runtime verification:** Instrument code to check invariants at runtime. Catches violations in production that were missed in testing. Lower cost than full verification.
- **Design reviews and formal inspection:** Human-driven, structured review processes (Fagan inspections). Surprisingly effective for catching logic errors without any tooling.

## Failure Modes

1. **Specification bugs:** The most dangerous failure mode -- the proof is correct, but the specification is wrong. Example: proving "the lock is always eventually released" without specifying "within 5 seconds" misses a livelock. **Mitigation:** Independently review specs. Write specs in two different formalisms and check consistency. Use TLA+ specs to generate traces that humans can inspect.

2. **False sense of security:** A verified component interacts with unverified code (OS, network, hardware). The verified part is correct, but the system-level invariant is violated at the boundary. Example: a verified encryption library is correct, but the key is leaked through a side channel. **Mitigation:** Clearly document the verification scope and trust boundary. Verify the integration layer where possible.

3. **State space explosion in model checking:** A model with 10 processes each having 5 states has 5^10 = 9.7 million global states. Add variables and it becomes intractable. **Mitigation:** Use symmetry reduction, abstraction (prove properties on a smaller model and argue they generalize), and bounded model checking with increasing bounds.

4. **Proof maintenance burden:** As code evolves, proofs break. In Coq or Isabelle, a minor algorithm change can require rewriting hundreds of lines of proof. **Mitigation:** Structure code into small verified modules with stable interfaces. Use refinement: prove a high-level spec once, then prove that implementations refine it.

5. **Toolchain fragility:** Proof assistants are sensitive to version changes. A Coq proof that works in 8.15 may not compile in 8.18. SMT solver timeouts are non-deterministic across versions. **Mitigation:** Pin tool versions in CI. Use Docker images for reproducible verification environments. Avoid solver timeout thresholds in production verification.

6. **Abstraction gap:** The formal model simplifies reality (e.g., assumes reliable network, bounded integers, no memory limits). Real systems violate these assumptions. **Mitigation:** Explicitly list all assumptions in the verification report. Stress-test assumptions against production data. Use "weakening" theorems to prove that relaxed assumptions still preserve key properties.

7. **Over-verification:** Spending 6 months proving a sorting algorithm is correct while the actual bug is in the I/O layer. **Mitigation:** Apply the Pareto principle -- verify the 20% of code that causes 80% of critical bugs (concurrency, crypto, resource management). Use threat modeling to identify what's worth verifying.

## Code Examples

### Example 1: TLA+ -- Specifying and Checking a Lock Service

```tla
------------------------------ MODULE LockService ------------------------------
EXTENDS Integers, Sequences, TLC

CONSTANTS Clients

(* 
 * A simple mutual exclusion lock service.
 * Property to verify: at most one client holds the lock at any time.
 * Property to verify: every client that requests eventually gets the lock (liveness).
 *)

VARIABLES 
    lockHolder,   \* The client that currently holds the lock (or NULL)
    lockQueue,    \* FIFO queue of waiting clients
    lockCount     \* How many times each client has acquired the lock

TypeOK == 
    /\ lockHolder \in Clients \cup {NULL}
    /\ lockQueue \in Seq(Clients)
    /\ lockCount \in [Clients -> Nat]

Init == 
    /\ lockHolder = NULL
    /\ lockQueue = <<>>
    /\ lockCount = [c \in Clients |-> 0]

Acquire(c) ==
    /\ lockHolder = NULL
    /\ lockQueue = <<>>
    /\ lockHolder' = c
    /\ lockCount' = [lockCount EXCEPT ![c] = @ + 1]
    /\ lockQueue' = lockQueue
    UNCHANGED <<>>  \* other variables

Request(c) ==
    /\ lockHolder # NULL \* Someone else holds the lock
    /\ lockQueue' = Append(lockQueue, c)
    UNCHANGED <<lockHolder, lockCount>>

Release(c) ==
    /\ lockHolder = c
    /\ IF lockQueue = <<>>
       THEN lockHolder' = NULL
            /\ lockQueue' = <<>>
       ELSE lockHolder' = Head(lockQueue)
            /\ lockQueue' = Tail(lockQueue)
            /\ lockCount' = [lockCount EXCEPT ![Head(lockQueue)] = @ + 1]
       END IIF
    UNCHANGED <<>>

Next == \E c \in Clients : Acquire(c) \/ Request(c) \/ Release(c)

Spec == Init /\ [][Next]_<<lockHolder, lockQueue, lockCount>>

(* Safety: Mutual Exclusion -- at most one holder *)
MutualExclusion == 
    \A c1, c2 \in Clients : 
        (lockHolder = c1 /\ lockHolder = c2) => c1 = c2

(* Safety: No double grant -- a client in queue doesn't also hold the lock *)
NoDoubleGrant ==
    \A c \in Clients :
        (lockHolder = c) => (c \notin lockQueue)

(* Liveness: Every requesting client eventually gets the lock *)
(* Requires fairness assumptions *)
EventualAcquisition == 
    \A c \in Clients : 
        (c \in lockQueue) ~> (lockHolder = c)

=============================================================================
```

Run with TLC model checker:
```
Model:
  Clients = {c1, c2, c3}
  Invariant: MutualExclusion
  Invariant: NoDoubleGrant
  Temporal property: EventualAcquisition (with weak fairness on Next)
```

### Example 2: Dafny -- Verified Binary Search

```dafny
// Requires: dafny verify BinarySearch.dfy

method BinarySearch(a: array<int>, key: int) returns (index: int)
  requires a != null
  requires forall i, j :: 0 <= i < j < a.Length ==> a[i] <= a[j]  // sorted
  ensures 0 <= index < a.Length ==> a[index] == key
  ensures index == -1 ==> forall i :: 0 <= i < a.Length ==> a[i] != key
  ensures -1 <= index < a.Length
{
  var low := 0;
  var high := a.Length - 1;
  index := -1;

  while low <= high
    decreases high - low + 1  // termination measure
    invariant 0 <= low <= high + 1 <= a.Length
    invariant forall i :: 0 <= i < low ==> a[i] < key
    invariant forall i :: high < i < a.Length ==> a[i] > key
    invariant index == -1 ==> forall i :: low <= i <= high ==> a[i] != key ==> true
  {
    var mid := low + (high - low) / 2;  // avoids overflow
    if a[mid] == key {
      index := mid;
      return;
    } else if a[mid] < key {
      low := mid + 1;
    } else {
      high := mid - 1;
    }
  }
}
```

Dafny verifies:
- The loop terminates (decreases measure)
- The loop invariants hold on entry, are maintained, and imply the postcondition
- No array out-of-bounds access
- The result is correct: if it returns an index, that element equals the key; if -1, the key is absent

### Example 3: Property-Based Testing with Hypothesis (Lightweight Verification)

```python
from hypothesis import given, strategies as st
from hypothesis.stateful import RuleBasedStateMachine, rule, invariant

# A simple LRUCache to verify with property-based testing
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity: int):
        assert capacity > 0
        self.capacity = capacity
        self.cache: OrderedDict[int, int] = OrderedDict()

    def get(self, key: int) -> int:
        if key not in self.cache:
            return -1
        self.cache.move_to_end(key)
        return self.cache[key]

    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = value
        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)


# Property 1: After putting a key, getting it returns the value
@gst.st.lists(st.integers()), st.integers(), st.integers())
def test_put_then_get(ops, key, value):
    cache = LRUCache(capacity=max(1, len(ops)))
    for k in ops:
        cache.put(k, value)
    cache.put(key, value)
    assert cache.get(key) == value


# Property 2: Cache size never exceeds capacity
@given(
    st.lists(st.tuples(st.integers(), st.integers())),
    st.integers(min_value=1, max_value=100)
)
def test_size_bounded(operations, capacity):
    cache = LRUCache(capacity=capacity)
    for key, value in operations:
        cache.put(key, value)
    assert len(cache.cache) <= capacity


# Property 3: LRU eviction -- least recently used is evicted first
@given(st.integers())
def test_lru_eviction(seed):
    import random
    random.seed(seed)
    capacity = 3
    cache = LRUCache(capacity)
    
    # Fill cache
    for i in range(capacity):
        cache.put(i, i * 10)
    
    # Access key 0 to make it recently used
    cache.get(0)
    
    # Insert new key -- should evict key 1 (least recently used)
    cache.put(capacity, 999)
    
    assert cache.get(0) == 0      # Still present (was accessed)
    assert cache.get(1) == -1     # Evicted (was LRU)
    assert cache.get(capacity) == 999  # New key present


# Stateful testing: random sequences of operations
class LRUCacheStateMachine(RuleBasedStateMachine):
    def __init__(self):
        super().__init__()
        self.capacity = 5
        self.cache = LRUCache(self.capacity)
        self.model = OrderedDict()  # Oracle model

    @rule(key=st.integers(), value=st.integers())
    def put(self, key, value):
        self.cache.put(key, value)
        if key in self.model:
            self.model.move_to_end(key)
        self.model[key] = value
        while len(self.model) > self.capacity:
            self.model.popitem(last=False)

    @rule(key=st.integers())
    def get(self, key):
        result = self.cache.get(key)
        expected = self.model.get(key, -1)
        assert result == expected, f"get({key}): expected {expected}, got {result}"

    @invariant()
    def size_ok(self):
        assert len(self.cache.cache) <= self.capacity


TestLRU = LRUCacheStateMachine.TestCase
```

### Example 4: SMT Solving with Z3 -- Verifying a Bitwise Algorithm

```python
from z3 import *

def verify_swap_xor():
    """
    Verify the XOR swap algorithm:
      a = a ^ b
      b = a ^ b
      a = a ^ b
    correctly swaps a and b for all 32-bit integers.
    """
    a_orig = BitVec('a_orig', 32)
    b_orig = BitVec('b_orig', 32)
    
    # XOR swap steps
    a_step1 = a_orig ^ b_orig
    b_step2 = a_step1 ^ b_orig  # = (a ^ b) ^ b = a
    a_step3 = a_step1 ^ b_step2  # = (a ^ b) ^ a = b
    
    s = Solver()
    # We want to prove: a_step3 == b_orig AND b_step2 == a_orig
    s.add(Not(And(a_step3 == b_orig, b_step2 == a_orig)))
    
    if s.check() == unsat:
        print("VERIFIED: XOR swap is correct for all 32-bit inputs")
    else:
        print("BUG FOUND:", s.model())

verify_swap_xor()


def verify_no_overflow_in_avg(a, b):
    """
    Verify that (a + b) / 2 can overflow for signed 32-bit integers,
    but a + (b - a) / 2 cannot.
    """
    a = BitVec('a', 32)
    b = BitVec('b', 32)
    
    s = Solver()
    # Show that (a + b) overflows but a + (b-a)/2 does not
    # (a + b) < a when overflow occurs (wraps negative)
    s.add(a > 0, b > 0)
    s.add(a + b < 0)  # signed overflow: positive + positive = negative
    
    if s.check() == sat:
        m = s.model()
        print(f"Overflow example: a={m[a]}, b={m[b]}, a+b={m[a] + m[b]}")
        # This proves that naive (a+b)//2 is unsafe

verify_no_overflow_in_avg()
```

## Best Practices

- **Start with property-based testing.** It catches 80% of what formal verification catches at 5% of the cost. Use Hypothesis, QuickCheck, or proptest before reaching for TLA+ or Coq.
- **Model before you code.** Write a TLA+ or Alloy model of your distributed algorithm or state machine before implementing. Lamport found that TLA+ modeling catches design flaws that no amount of code review or testing would find.
- **Verify interfaces, not just implementations.** A verified implementation of an unverified spec is useless. The spec is the thing that matters.
- **Keep verification CI-integrated.** Run model checking and property tests on every PR. If verification is a manual step, it will be skipped.
- **Document the trust boundary.** Every verification effort has a Trusted Computing Base (TCB). List it explicitly: "We trust the Coq kernel, the extraction mechanism, and the FFI to C. We do not trust the runtime system."
- **Use the right tool for the level of assurance needed.** TLA+ for design, Dafny for algorithms, Coq for critical foundations. Don't use a sledgehammer to crack a nut.

## Related Topics

- [[Quality]] -- Formal verification as the highest level of quality assurance
- [[Principles/Determinism]] -- Verification depends on deterministic behavior
- [[Algorithms]] -- Algorithmic correctness proofs using formal methods
- [[Security]] -- Formal verification of cryptographic protocols and side-channel resistance
- [[BigO]] -- Verifying complexity bounds as part of formal specifications
- [[DataStructures]] -- Verifying data structure invariants (e.g., BST property, heap property)
- [[Principles/FailFast]] -- Verification catches bugs before deployment, not after
- [[Reproducibility]] -- Verified systems are reproducible by construction
