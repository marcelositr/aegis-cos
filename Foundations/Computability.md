---
title: Computability
title_pt: Computabilidade
layer: foundations
type: concept
priority: high
version: 1.0.0
tags:
  - Foundations
  - Computability
description: Study of what problems can be solved by computers and how efficiently.
description_pt: Estudo de quais problemas podem ser resolvidos por computadores e quão eficientemente.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Computability

## Description

Computability studies what problems can be solved by computers and how efficiently. It answers fundamental questions about the limits of computation.

Key concepts:
- **Decidable problems**: Can be solved by algorithm
- **Undecidable problems**: No algorithm exists
- **Tractable**: Can be solved in reasonable time
- **Intractable**: No efficient solution exists (NP-hard)

## Purpose

**When computability theory is valuable:**
- Understanding problem solvability limits
- Recognizing when problems have no solution
- Making algorithmic choices
- Understanding NP vs P

**When it may not be needed:**
- For practical programming tasks
- When problem domain is well-understood
- For prototype development

**The key question:** Is this problem solvable, and if so, efficiently?
- **Undecidable problems**: No algorithm can solve them
- **Tractable**: Can be solved in reasonable time
- **Intractable**: Requires unreasonable time

Problem classifications:
- **P**: Polynomial time (solvable)
- **NP**: Non-deterministic polynomial (verifiable)
- **NP-complete**: Hardest in NP
- **NP-hard**: At least as hard as NP-complete

## P vs NP

```python
# P (Polynomial) - Can solve quickly
def find_max(arr):
    return max(arr)  # O(n)

# NP (Non-deterministic Polynomial) - Can verify quickly
def verify_tsp_solution(cities, route, max_distance):
    """Verify TSP solution is valid and under budget."""
    if len(route) != len(cities):
        return False
    
    total = sum(distance(route[i], route[i+1]) for i in range(len(route)-1))
    return total <= max_distance
```

## Undecidable Problems

```python
# Halting Problem - Cannot be solved
# Given: program + input
# Question: Will program halt?

# Proof by contradiction (sketch):
# If we could solve halting problem,
# we could create paradox program
# Therefore, unsolvable

# Practical implications:
# - Cannot automatically prove code correctness
# - Cannot determine if arbitrary program halts
# - Many properties are undecidable
```

## NP-Complete Example

```python
# Traveling Salesman Problem (TSP) - NP-complete
def brute_force_tsp(cities, distance_fn):
    """Try all permutations - O(n!)"""
    from itertools import permutations
    
    min_distance = float('inf')
    best_route = None
    
    for route in permutations(cities):
        dist = sum(distance_fn(route[i], route[i+1]) 
                   for i in range(len(route)-1))
        if dist < min_distance:
            min_distance = dist
            best_route = route
    
    return best_route, min_distance
```

## Failure Modes

- **Attempting to solve undecidable problems** → building tools that claim to detect all bugs → tool always has false positives or negatives → understand theoretical limits and design tools with appropriate expectations
- **Treating NP-hard problems as tractable** → using exact algorithms on large NP-hard inputs → exponential runtime and system hangs → use approximation algorithms or heuristics for NP-hard problems
- **Ignoring complexity class in algorithm selection** → choosing O factorial algorithm for production data → timeouts under real load → analyze input size growth and choose algorithms with appropriate complexity bounds
- **Assuming cryptographic hardness is permanent** → building systems that depend on unresolved mathematical questions → system may become obsolete if proof emerges → design defensively and plan for algorithm agility
- **Not recognizing problem reducibility** → solving a problem from scratch that reduces to known NP-complete problem → wasted effort on impossible exact solution → learn common NP-complete problems and recognize reductions
- **Over-relying on brute force for small inputs** → algorithm works for test data but fails at scale → production failures when input grows → always analyze asymptotic complexity, not just empirical performance
- **Ignoring space complexity** → algorithm is fast but uses exponential memory → out-of-memory crashes → consider both time and space complexity and trade memory for time when appropriate

## Anti-Patterns

### 1. Brute-Forcing NP-Hard Problems

**Bad:** Using exact O(n!) or O(2^n) algorithms on production-scale inputs for NP-hard problems like TSP or knapsack
**Why it's bad:** Exponential runtime means the system will hang or timeout as soon as input size grows beyond trivial cases
**Good:** Use approximation algorithms, heuristics (genetic algorithms, simulated annealing), or accept "good enough" solutions for large inputs

### 2. Treating Undecidable Problems as Solvable

**Bad:** Building tools that claim to detect all bugs, prove all code correct, or determine if any program halts
**Why it's bad:** These are theoretically impossible — the tool will always have false positives, false negatives, or fail to terminate on some inputs
**Good:** Design tools with appropriate expectations — static analyzers find *some* bugs, not *all* bugs; document known limitations

### 3. Ignoring Space Complexity

**Bad:** Optimizing only for time while an algorithm consumes exponential memory
**Why it's bad:** Out-of-memory crashes are often harder to recover from than slow execution, and memory is a harder constraint than CPU time
**Good:** Analyze both time and space complexity — trade memory for time when appropriate, but always bound both

### 4. Assuming Cryptographic Hardness Is Permanent

**Bad:** Building systems that depend on unresolved mathematical questions like P ≠ NP or the hardness of factoring
**Why it's bad:** If a proof emerges or quantum computers mature, the entire security model collapses
**Good:** Design with algorithm agility — plan for migration paths to post-quantum cryptography and monitor mathematical breakthroughs

## Best Practices

### 1. Recognize Problem Type

```python
# Can you verify solution quickly? -> Likely NP
# Can you find solution quickly? -> Likely P
# Need approximation? -> Consider heuristics
```

### 2. Choose Right Approach

```python
# Exact solution for small n
# Heuristics for large n
# Approximations when exact not needed
```

### 3. Accept Limits

```python
# Some problems cannot be solved efficiently
# Use heuristics, approximations
# Consider if problem can be reformulated
```

## Related Topics

- [[Foundations MOC]]
- [[Complexity]]
- [[Algorithms]]
- [[InformationTheory]]
- [[SystemsThinking]]

## Key Takeaways

- Computability studies what problems can be solved by computers and how efficiently, distinguishing decidable from undecidable and tractable from intractable problems
- Valuable for understanding problem solvability limits, recognizing when no algorithm exists, and making informed algorithmic choices
- Not needed for routine practical programming tasks or when the problem domain is well-understood
- Tradeoff: theoretical understanding of limits versus practical irrelevance for most day-to-day development tasks
- Main failure mode: treating NP-hard problems as tractable and using exact algorithms on large inputs causes exponential runtime and system hangs
- Best practice: recognize problem complexity classes early, use approximation algorithms and heuristics for NP-hard problems, accept "good enough" solutions for large inputs, and design tools with realistic expectations about undecidable problems
- Related: complexity, algorithms, information theory, systems thinking

## Additional Notes

## Examples

### Recognizing Problem Types

```python
# P (solvable in polynomial time)
# Find max, sort, search - can solve quickly
sorted_list = sorted(items)  # O(n log n)

# NP (verifiable in polynomial time)
# TSP - can verify solution quickly, finding is hard
def verify_solution(route, distances):
    return sum(distances[i][i+1] for i in range(len(route)-1)) < budget

# NP-Complete
# SAT, Vertex Cover, Knapsack - all equally hard
```

### Practical Approach

```python
# For NP-hard problems:
# 1. Small inputs -> brute force
# 2. Large inputs -> heuristic/approximation
# 3. Accept "good enough" solution

def solve_knapsack_greedy(items, capacity):
    # O(n log n) greedy approximation
    sorted_items = sorted(items, key=lambda x: x.value/x.weight, reverse=True)
    # ... pack what fits
```
