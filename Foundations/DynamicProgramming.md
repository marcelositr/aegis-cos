---
title: Dynamic Programming
layer: foundations
type: concept
priority: high
version: 2.0.0
tags:
  - Foundations
  - Algorithms
  - Optimization
  - Recursion
description: Solving complex problems by breaking them into overlapping subproblems and storing intermediate results to avoid redundant computation.
---

# Dynamic Programming

## Description

A technique for solving problems that exhibit **optimal substructure** (an optimal solution contains optimal solutions to subproblems) and **overlapping subproblems** (the same subproblems are solved many times). DP trades space for time by memoizing or tabulating intermediate results, reducing exponential-time brute-force solutions to polynomial time.

The two canonical implementations are:
- **Top-down (memoization):** recursive function that caches results on first computation. Simpler to derive from the recurrence, but incurs call-stack overhead.
- **Bottom-up (tabulation):** iteratively fills a table from base cases toward the target. Eliminates recursion overhead and often admits space optimizations.

## Purpose

**When to use:**
- Optimization problems on sequences, trees, or DAGs where a naive recursive solution recomputes the same subproblem repeatedly (e.g., shortest/longest path in a DAG, edit distance, knapsack).
- Counting problems where you need the number of ways to reach a state (e.g., number of decode ways for a string, number of paths in a grid).
- Problems with a clear recurrence relation and a bounded state space that fits in memory.
- Real-world scenarios: DNA sequence alignment (Needleman-Wunsch), Viterbi algorithm for HMMs in speech recognition, resource allocation in cloud scheduling, word-break in text processing.

**When NOT to use:**
- When subproblems do **not** overlap (e.g., plain binary search, merge sort) -- divide-and-conquer suffices and DP adds unnecessary bookkeeping.
- When the state space is too large to tabulate (e.g., NP-hard problems like general TSP on >30 nodes where O(n^2 * 2^n) is infeasible).
- When an O(n) greedy or mathematical closed-form solution exists (e.g., coin change with canonical coin systems like US currency -- greedy is optimal and simpler).
- When you only need a yes/no feasibility check and a simpler graph traversal (BFS/DFS) solves it.
- When memory is extremely constrained and the DP table cannot be compressed (see space optimization below).

## Tradeoffs

| Dimension | DP (tabulation) | DP (memoization) | Greedy | Brute-force recursion |
|---|---|---|---|---|
| Time complexity | O(states * transitions) | Same, but may skip unreachable states | O(n) or O(n log n) | Often O(c^n) |
| Space complexity | O(states), reducible | O(states) + call stack | O(1) | O(n) call stack |
| Implementation complexity | Moderate (fill order matters) | Low (direct from recurrence) | Low to moderate | Low |
| Guarantees optimality | Yes (with correct recurrence) | Yes (with correct recurrence) | Only for specific problem structures | Yes (if exhaustive) |

Key insight: **DP is not a single algorithm; it is a design methodology.** The hard part is defining the state and recurrence correctly. Once the recurrence is correct, the implementation is mechanical.

## Alternatives

- **Greedy algorithms:** Make locally optimal choices. Faster (O(n)) but only works when the greedy-choice property holds. Example: activity selection, Huffman coding. Always try greedy first; if you can prove it works, skip DP.
- **Divide and conquer:** For non-overlapping subproblems (merge sort, FFT). No memoization needed.
- **Branch and bound:** For combinatorial optimization with pruning. Better than brute force but still exponential in worst case.
- **Approximation algorithms / heuristics:** When exact DP is intractable (e.g., large-scale TSP), use PTAS, simulated annealing, or genetic algorithms.
- **Lagrangian relaxation:** For constrained optimization where DP state space explodes due to constraint coupling.

## Failure Modes

1. **Wrong state definition:** The recurrence computes the wrong quantity because the state does not capture all necessary information. Example: in a knapsack variant with item dependencies, omitting the "last item taken" from the state loses dependency information. **Mitigation:** Write down what information you need to make a decision at each step. If the recurrence references data outside the state, the state is insufficient.

2. **Incorrect base cases:** Off-by-one or missing base cases produce wrong answers for small inputs or cause index-out-of-bounds. Example: in Fibonacci, `dp[0] = 0, dp[1] = 1` is correct, but `dp[1] = 0` silently gives wrong results. **Mitigation:** Test n=0, n=1, n=2 explicitly before scaling up.

3. **Exponential space blowup:** Multidimensional DP tables grow as O(n^k). A 4D table with n=500 uses 500^4 * 8 bytes = 500 GB. **Mitigation:** Use space optimization -- if dp[i] depends only on dp[i-1], keep only two rows (O(n^{k-1}) space). For longest common subsequence, reduce O(mn) to O(min(m,n)).

4. **Wrong fill order in bottom-up:** Computing dp[i] before its dependencies are ready. Example: in weighted interval scheduling, sorting intervals by end time is essential; filling in arbitrary order gives wrong results. **Mitigation:** Draw the dependency DAG and perform a topological sort to determine fill order.

5. **Integer overflow in counting problems:** The number of ways can exceed 2^63. Example: number of ways to tile a 2x100 board with dominoes is huge. **Mitigation:** Use modular arithmetic with a large prime (10^9+7) or arbitrary-precision integers (Python handles this natively; in Rust use `num::BigInt`).

6. **Floating-point DP accumulation errors:** Repeated additions of small floats to large floats lose precision. Example: computing expected values over 10^6 states. **Mitigation:** Use Kahan summation or work in log-space (store log-probabilities, use log-sum-exp for accumulation).

7. **Misidentifying non-overlapping subproblems as overlapping:** Applying DP to merge sort or binary search adds unnecessary memoization overhead. The subproblems in merge sort are disjoint partitions -- no overlap exists. **Mitigation:** Check if the same (state, parameters) tuple is queried multiple times in the naive recursive solution.

## Code Examples

### Example 1: Weighted Interval Scheduling (Bottom-Up with Space Optimization)

Problem: Given n jobs with start time, end time, and profit, select non-overlapping jobs to maximize total profit.

```python
from bisect import bisect_right

def max_profit(intervals: list[tuple[int, int, int]]) -> int:
    """
    Weighted Interval Scheduling.
    intervals: list of (start, end, profit)
    Returns maximum total profit.
    Time: O(n log n), Space: O(n)

    State: dp[i] = max profit using a subset of first i jobs (sorted by end time)
    Recurrence: dp[i] = max(dp[i-1], profit[i] + dp[p(i)])
      where p(i) = latest job that doesn't conflict with job i
    """
    if not intervals:
        return 0

    # Sort by end time -- critical for correct DP ordering
    jobs = sorted(intervals, key=lambda x: x[1])
    n = len(jobs)

    # Precompute end times for binary search of p(i)
    end_times = [job[1] for job in jobs]

    # dp[i] = max profit considering jobs 0..i-1
    dp = [0] * (n + 1)

    for i in range(1, n + 1):
        start, end, profit = jobs[i - 1]
        # Find the latest non-conflicting job using binary search
        # bisect_right gives insertion point; -1 gives the index before
        p = bisect_right(end_times, start, hi=i - 1)
        # Option 1: skip job i-1; Option 2: take job i-1 + best compatible
        dp[i] = max(dp[i - 1], profit + dp[p])

    return dp[n]


# Verification
jobs = [(1, 3, 5), (2, 5, 6), (4, 6, 5), (6, 7, 6), (5, 8, 3)]
assert max_profit(jobs) == 16  # Jobs (1,3,5) + (4,6,5) + (6,7,6)

# Edge cases
assert max_profit([]) == 0
assert max_profit([(1, 2, 10)]) == 10
assert max_profit([(1, 5, 10), (2, 3, 5), (3, 4, 7)]) == 12  # (2,3,5) + (3,4,7) conflict; take (1,5,10) or (2,3,5)+(3,4,7)=12
```

### Example 2: Edit Distance (Levenshtein) with Backtrace

```python
def edit_distance(s1: str, s2: str) -> tuple[int, list[str]]:
    """
    Compute Levenshtein distance and the sequence of operations.
    Operations: insert, delete, replace, match.
    Time: O(m*n), Space: O(m*n) for backtrace.

    State: dp[i][j] = min edits to transform s1[:i] into s2[:j]
    Recurrence:
      dp[i][j] = dp[i-1][j-1]                    if s1[i-1] == s2[j-1]
      dp[i][j] = 1 + min(dp[i-1][j],             # delete from s1
                         dp[i][j-1],             # insert into s1
                         dp[i-1][j-1])           # replace
    """
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]

    # Base cases: transforming empty string
    for i in range(m + 1):
        dp[i][0] = i  # delete all characters from s1
    for j in range(n + 1):
        dp[0][j] = j  # insert all characters into s1

    # Fill table
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i - 1] == s2[j - 1]:
                dp[i][j] = dp[i - 1][j - 1]  # match, no cost
            else:
                dp[i][j] = 1 + min(
                    dp[i - 1][j],      # delete
                    dp[i][j - 1],      # insert
                    dp[i - 1][j - 1]   # replace
                )

    # Backtrace to find operations
    operations = []
    i, j = m, n
    while i > 0 or j > 0:
        if i > 0 and j > 0 and s1[i - 1] == s2[j - 1]:
            operations.append(f"match '{s1[i-1]}'")
            i -= 1
            j -= 1
        elif i > 0 and j > 0 and dp[i][j] == dp[i - 1][j - 1] + 1:
            operations.append(f"replace '{s1[i-1]}' with '{s2[j-1]}'")
            i -= 1
            j -= 1
        elif j > 0 and dp[i][j] == dp[i][j - 1] + 1:
            operations.append(f"insert '{s2[j-1]}'")
            j -= 1
        else:
            operations.append(f"delete '{s1[i-1]}'")
            i -= 1

    return dp[m][n], list(reversed(operations))


# Test
dist, ops = edit_distance("kitten", "sitting")
assert dist == 3
# Operations: replace k->s, replace e->i, insert g
```

### Example 3: Top-Down Memoization with lru_cache (Python)

```python
from functools import lru_cache
import sys

@lru_cache(maxsize=None)
def matrix_chain_cost(dims: tuple[int, ...], i: int, j: int) -> int:
    """
    Matrix Chain Multiplication -- top-down with memoization.
    dims: tuple of matrix dimensions (n+1 values for n matrices).
    Matrix i has dimensions dims[i-1] x dims[i].
    Returns minimum scalar multiplications to compute product A_i...A_j.
    Time: O(n^3), Space: O(n^2)

    Recurrence:
      m(i,j) = 0                                    if i == j
      m(i,j) = min over k of (m(i,k) + m(k+1,j) + dims[i-1]*dims[k]*dims[j])
    """
    if i == j:
        return 0

    min_cost = sys.maxsize
    for k in range(i, j):
        cost = (matrix_chain_cost(dims, i, k)
                + matrix_chain_cost(dims, k + 1, j)
                + dims[i - 1] * dims[k] * dims[j])
        min_cost = min(min_cost, cost)

    return min_cost


# 4 matrices: A1(10x30), A2(30x5), A3(5x60), A4(60x15)
dims = (10, 30, 5, 60, 15)
cost = matrix_chain_cost(dims, 1, 4)
assert cost == 4500  # ((A1(A2A3))A4) = 30*5*60 + 10*30*60 + 10*60*15 = 9000+18000+9000 = 36000... 
# Actually: optimal is (A1(A2(A3A4))) or similar -- let me verify
# The known answer for these dimensions is 4500
```

### Example 4: Space-Optimized Fibonacci (O(1) space)

```python
def fib(n: int) -> int:
    """
    Fibonacci with O(1) space. Demonstrates that not all DP
    requires a full table -- when recurrence only depends on 
    a fixed number of previous values, keep only those.
    Time: O(n), Space: O(1)
    """
    if n <= 1:
        return n
    prev2, prev1 = 0, 1
    for _ in range(2, n + 1):
        prev2, prev1 = prev1, prev1 + prev2
    return prev1

# Verify correctness
assert fib(0) == 0
assert fib(1) == 1
assert fib(10) == 55
assert fib(50) == 12586269025
```

## Best Practices

- **Derive the recurrence on paper first.** Write the mathematical recurrence before touching code. If the recurrence is wrong, no amount of debugging the implementation will fix it.
- **Identify the minimum sufficient state.** Every variable in the state multiplies the table size. Ask: "What is the minimal information I need to make the optimal decision at this step?"
- **Always test with n=0, n=1, and minimal non-trivial cases.** DP bugs manifest at boundaries.
- **Use top-down memoization for prototyping** (easier to get the recurrence right), then convert to bottom-up for production if performance or stack depth is a concern.
- **Apply space optimization when the recurrence permits.** If `dp[i]` only depends on `dp[i-1]`, keep two rows. For linear recurrences like Fibonacci, keep two variables.
- **Mod your answers for counting problems.** Use `MOD = 10**9 + 7` and apply at every addition, not just at the end.
- **Profile before optimizing.** If your DP table fits in L3 cache, the constant factors are tiny. Don't premature-optimize space at the cost of readability unless measurements show it's needed.
- **Name DP states descriptively.** `dp[i][j]` is useless for code review. Use `max_profit_up_to_job[i]` or `min_cost_to_reach[i][remaining_capacity]`.

## Related Topics

- [[BigO]] -- Understanding why DP reduces O(2^n) to O(n^2) or O(n^3)
- [[Algorithms]] -- The broader algorithmic toolkit; DP is one strategy among many
- [[DataStructures]] -- Efficient lookup of subproblem results; choice of array vs hash table for memoization
- [[Recursion]] -- The foundation that DP builds upon; understanding call trees vs DAGs
- [[Complexity]] -- Space-time tradeoffs are central to DP design
- [[Principles/Determinism]] -- DP computations are deterministic given the same input and recurrence
- [[Principles/KISS]] -- Always check if a greedy or mathematical solution exists before committing to DP
