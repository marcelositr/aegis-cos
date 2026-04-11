---
title: Memory Models
title_pt: Modelos de Memória
layer: architecture
type: concept
priority: critical
version: 1.0.0
id: core.arch.memorymodels.v1
tags:
  - Architecture
  - MemoryModels
  - Concurrency
  - DistributedSystems
  - LowLevel
keywords:
  - memory model
  - happens-before
  - memory ordering
  - acquire-release
  - sequentially consistent
  - relaxed ordering
  - volatile
  - atomic operations
  - false sharing
  - Java Memory Model
  - C++ memory model
description: Formal specification of how threads/processes observe memory operations — defines what reorderings are allowed, when writes become visible, and how synchronization establishes ordering.
---

# Memory Models

## Description

A **memory model** defines the rules for how memory operations (reads, writes) in one thread become visible to other threads. It answers: "If thread A writes X=1 then Y=2, what can thread B observe?"

Without a memory model, concurrent programs have **undefined behavior** — the compiler and CPU are free to reorder operations for performance, potentially breaking synchronization logic.

**Key concepts:**
- **Visibility** — When does a write by one thread become readable by another?
- **Ordering** — What order do operations appear to execute in?
- **Reordering** — What reorderings are the compiler/CPU allowed to perform?
- **Atomicity** — Which operations are indivisible?
- **Happens-before** — The partial ordering relation that guarantees visibility

## Purpose

**When memory models matter critically:**
- Lock-free data structures (concurrent queues, hash maps)
- Double-checked locking patterns
- Flag-based synchronization (spinlocks, wait-free algorithms)
- Cross-thread communication without locks
- Compiler/CPU-level optimization understanding
- Language runtime implementation (JVM, V8, Swift runtime)
- Embedded/real-time systems

**When you can ignore memory models:**
- Application code using high-level concurrency primitives (locks, channels, async/await)
- Single-threaded programs
- Code where all shared state is protected by mutexes

**The key question:** Am I sharing mutable state between threads without locks? If yes, the memory model determines correctness.

## Tradeoffs

| Memory Ordering | Performance | Guarantees | When to Use |
|-----------------|------------|------------|-------------|
| **Sequentially consistent** (strongest) | Slowest (full barriers) | All threads see same order | Default, correctness-critical |
| **Acquire-Release** | Medium | Sync between specific thread pairs | Producer-consumer, lock implementations |
| **Relaxed** (weakest) | Fastest (no barriers) | Only atomicity, no ordering | Counters, statistics |
| **Relaxed + fence** | Medium-fast | Selective barriers | Fine-tuned synchronization |

## Memory Ordering Examples

### C++ — The Five Memory Orders

```cpp
#include <atomic>
#include <thread>
#include <cassert>

std::atomic<int> x{0}, y{0};
std::atomic<int> result{0};

// Sequentially consistent (default) — strongest guarantee
// All threads see operations in the same order
void thread_seq_cst() {
    x.store(1);                    // seq_cst store
    int r = y.load();              // seq_cst load
    result.store(r);               // This thread sees: x=1 before y load
}
// Guarantee: if another thread did y.store(1) before x.load(1),
// this thread sees y=1.

// Acquire-Release — synchronization between specific threads
std::atomic<bool> ready{false};
std::atomic<int> data{0};

void producer() {
    data.store(42, std::memory_order_relaxed);  // No ordering guarantee on this store alone
    ready.store(true, std::memory_order_release);  // RELEASE: all prior writes visible after this
}

void consumer() {
    while (!ready.load(std::memory_order_acquire)) {  // ACQUIRE: sees all writes before release
        std::this_thread::yield();
    }
    assert(data.load(std::memory_order_relaxed) == 42);  // Guaranteed to see 42
    // ACQUIRE on ready synchronizes with RELEASE on ready
    // → all writes before the RELEASE are visible after the ACQUIRE
}

// Relaxed — only atomicity, no ordering
std::atomic<int> counter{0};

void increment_relaxed() {
    for (int i = 0; i < 1000; i++) {
        counter.fetch_add(1, std::memory_order_relaxed);
        // No ordering guarantee — other threads may see counter values out of order
        // But each fetch_add is atomic — no lost updates
    }
}
```

### Java — Happens-Before Rules

```java
// Java Memory Model (JMM) happens-before rules:
// 1. Program order: each action hb next action in same thread
// 2. Monitor unlock hb subsequent lock on same monitor
// 3. volatile write hb subsequent volatile read on same variable
// 4. Thread start hb any action in started thread
// 5. All actions in thread hb thread join returns

// Volatile example — visibility guarantee
class SharedState {
    private volatile boolean ready = false;
    private int data;  // NOT volatile

    void producer() {
        data = 42;           // Ordinary write
        ready = true;        // Volatile write — hb edge
    }

    void consumer() {
        while (!ready) {     // Volatile read — hb edge
            Thread.yield();
        }
        // Guaranteed to see data == 42
        // Because: data=42 hb ready=true (program order)
        //          ready=true (volatile write) hb ready read (volatile rule)
        //          Therefore: data=42 hb ready read (transitivity)
        System.out.println(data);  // Always prints 42
    }
}

// Double-checked locking with volatile (correct in Java 5+)
class Singleton {
    private static volatile Singleton instance;  // volatile is REQUIRED

    static Singleton getInstance() {
        if (instance == null) {                  // First check (no lock)
            synchronized (Singleton.class) {
                if (instance == null) {          // Second check (with lock)
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
// Without volatile: another thread might see a partially constructed Singleton
// (reference assigned but fields not yet initialized)
```

### Rust — Atomic Ordering

```rust
use std::sync::atomic::{AtomicBool, AtomicI32, Ordering};
use std::sync::Arc;
use std::thread;

static READY: AtomicBool = AtomicBool::new(false);
static DATA: AtomicI32 = AtomicI32::new(0);

fn producer() {
    DATA.store(42, Ordering::Relaxed);
    READY.store(true, Ordering::Release);  // All prior writes visible after this
}

fn consumer() {
    while !READY.load(Ordering::Acquire) {
        thread::yield_now();
    }
    // Acquire synchronizes with Release → sees DATA = 42
    assert_eq!(DATA.load(Ordering::Relaxed), 42);
}

fn main() {
    let p = thread::spawn(producer);
    let c = thread::spawn(consumer);
    p.join().unwrap();
    c.join().unwrap();
}
```

## Failure Modes

- **Assuming program order is preserved** → compiler reorders operations → another thread sees writes in wrong order → data corruption → use memory barriers (acquire/release, volatile, atomic)
- **Double-checked locking without volatile** → partially constructed object visible → NullPointerException or garbage data → mark the instance field volatile
- **Mixing atomic and non-atomic access** → some threads use atomics, others use plain reads → torn reads, data races → ALL accesses to shared mutable state must use atomics or be protected by locks
- **Relaxed ordering for synchronization** → using `memory_order_relaxed` for flag-based sync → consumer sees flag but not the data → use acquire-release for cross-thread synchronization
- **Assuming cache coherency = ordering** → x86 is strongly ordered, ARM is weakly ordered → code works on x86 but breaks on ARM → don't rely on hardware ordering, use language-level memory ordering
- **Compiler reordering across barriers** → compiler moves operations across what you think is a barrier → use language-specific atomic primitives, not manual barrier instructions
- **False sharing** → two atomic variables on same cache line → cache line bounces between cores → performance degradation → pad atomics to cache line boundary (64 bytes)
- **ABA problem** → value changes from A to B to A, observer thinks nothing changed → use tagged pointers, version numbers, or hazard pointers
- **Lock-free doesn't mean wait-free** → CAS loop may spin indefinitely under contention → implement backoff, consider lock-based approach for high-contention scenarios
- **Platform-specific atomics** → `int` is atomic on x86 but not on all architectures → use language-provided atomics (`std::atomic`, `AtomicInteger`, `AtomicBool`), not assumptions about primitive atomicity

## Anti-Patterns

### 1. Volatile as Synchronization

**Bad:** Using `volatile` (Java/C#) or `volatile` keyword as a substitute for locks or atomics
**Why it's bad:** Volatile only guarantees visibility, not atomicity — `volatile int counter; counter++` is still a data race (read-modify-write is not atomic)
**Good:** Use `AtomicInteger`, `AtomicLong`, or proper locks for compound operations

### 2. Assuming Single-Threaded Reasoning in Multithreaded Code

**Bad:** "I write x, then I write y, so the reader must see x before y"
**Why it's bad:** Without happens-before edges, the compiler and CPU can reorder — reader may see y before x, or see x without y
**Good:** Establish explicit happens-before edges: locks, atomics with acquire/release, volatile writes/reads

### 3. Mixing Lock-Free and Lock-Based Access

**Bad:** Some threads use CAS on an atomic, others use a mutex to access the same variable
**Why it's bad:** Mutex provides sequential consistency, CAS may use relaxed ordering → inconsistent visibility
**Good:** Pick one synchronization strategy per variable — all lock-based OR all lock-free, never both

## Best Practices

1. **Default to locks or high-level primitives** — channels, mutexes, semaphores — before reaching for atomics
2. **Use sequentially consistent ordering by default** — only weaken when profiling shows it's a bottleneck
3. **Always pair Acquire with Release** — acquire on the reading side, release on the writing side
4. **Use Relaxed only for counters** — statistics, sequence numbers where ordering doesn't matter
5. **Mark all shared mutable state** — every access to shared mutable state must use atomics or locks
6. **Document the memory model** — if writing lock-free code, document why each ordering choice is correct
7. **Test on weakly-ordered architectures** — code that works on x86 may fail on ARM, RISC-V — test in CI if possible
8. **Use thread sanitizers** — TSan (ThreadSanitizer), Helgrind, Java's jcstress — detect data races at runtime
9. **Understand your language's happens-before rules** — JLS §17.4.5, C++ §33.5, Rust std::sync::atomic docs
10. **Prefer message passing over shared memory** — channels, actors — eliminate shared mutable state entirely

## Related Topics

- [[Concurrency]] — Concurrency fundamentals
- [[StateMachines]] — Concurrent state transitions
- [[DistributedSystems]] — Memory models as analogy for distributed consistency
- [[LeaderElection]] — Leader election with atomic operations
- [[Consensus]] — Consensus and ordering guarantees
- [[Idempotency]] — Safe retry in concurrent systems
- [[Performance]] — False sharing and cache-line performance