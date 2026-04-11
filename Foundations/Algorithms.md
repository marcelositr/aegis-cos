---
title: Algorithms
title_pt: Algoritmos
layer: foundations
type: concept
priority: high
version: 1.0.0
tags:
  - Foundations
  - Algorithms
description: Step-by-step procedures for solving problems, with focus on efficiency and complexity.
description_pt: Procedimentos passo a passo para resolver problemas, com foco em eficiência e complexidade.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Algorithms

## Description

An algorithm is a finite sequence of well-defined instructions used to solve a class of problems or perform a computation. Understanding algorithms is fundamental to software engineering—they're the building blocks of all software.

Key aspects of algorithm study:
- **Correctness** - Does the algorithm solve the problem?
- **Efficiency** - How fast is it? How much memory does it use?
- **Trade-offs** - Time vs space, simplicity vs performance
- **Applicability** - When to use which algorithm

Algorithm categories:
- **Searching** - Finding elements in data structures
- **Sorting** - Organizing data in order
- **Graph** - Traversing networks, finding paths
- **Dynamic Programming** - Optimizing subproblems
- **Greedy** - Making locally optimal choices
- **Divide and Conquer** - Splitting problems into smaller parts

## Purpose

**When algorithm knowledge matters:**
- Choosing the right data structure
- Optimizing performance
- Solving new problems
- Technical interviews
- Understanding system behavior

**When simpler approaches work:**
- Small datasets where optimization doesn't matter
- When built-in functions suffice

## Rules

1. **Understand the problem** - Before choosing algorithm
2. **Consider data size** - Different scales need different solutions
3. **Measure, don't assume** - Profile before optimizing
4. **Prefer clarity over cleverness** - Maintainable code wins
5. **Use appropriate data structures** - Algorithm + data structure

## Examples

### Binary Search

```python
def binary_search(arr: list[int], target: int) -> int:
    """
    Find target in sorted array.
    Time: O(log n)
    Space: O(1)
    """
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = (left + right) // 2
        
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1  # Not found

# Usage
numbers = [1, 3, 5, 7, 9, 11, 13, 15]
result = binary_search(numbers, 7)  # Returns 3
```

### Quick Sort

```python
def quicksort(arr: list[int]) -> list[int]:
    """
    Sort array using quicksort.
    Time: O(n log n) average, O(n²) worst
    Space: O(log n)
    """
    if len(arr) <= 1:
        return arr
    
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    
    return quicksort(left) + middle + quicksort(right)

# Usage
numbers = [64, 34, 25, 12, 22, 11, 90]
sorted_numbers = quicksort(numbers)  # [11, 12, 22, 25, 34, 64, 90]
```

### Breadth-First Search (BFS)

```python
from collections import deque

def bfs(graph: dict, start: str) -> list[str]:
    """
    Breadth-first search traversal.
    Time: O(V + E)
    Space: O(V)
    """
    visited = set()
    queue = deque([start])
    result = []
    
    while queue:
        node = queue.popleft()
        
        if node not in visited:
            visited.add(node)
            result.append(node)
            
            # Add unvisited neighbors
            for neighbor in graph.get(node, []):
                if neighbor not in visited:
                    queue.append(neighbor)
    
    return result

# Usage
graph = {
    'A': ['B', 'C'],
    'B': ['D', 'E'],
    'C': ['F'],
    'D': [],
    'E': ['F'],
    'F': []
}
print(bfs(graph, 'A'))  # ['A', 'B', 'C', 'D', 'E', 'F']
```

### Dynamic Programming - Fibonacci

```python
# Naive recursive (exponential time)
def fib_naive(n: int) -> int:
    if n <= 1:
        return n
    return fib_naive(n - 1) + fib_naive(n - 2)

# Memoization (top-down DP)
def fib_memo(n: int, memo: dict = None) -> int:
    if memo is None:
        memo = {}
    
    if n in memo:
        return memo[n]
    if n <= 1:
        return n
    
    memo[n] = fib_memo(n - 1, memo) + fib_memo(n - 2, memo)
    return memo[n]

# Tabulation (bottom-up DP)
def fib_tab(n: int) -> int:
    if n <= 1:
        return n
    
    dp = [0] * (n + 1)
    dp[1] = 1
    
    for i in range(2, n + 1):
        dp[i] = dp[i - 1] + dp[i - 2]
    
    return dp[n]

# Space-optimized
def fib_optimized(n: int) -> int:
    if n <= 1:
        return n
    
    prev, curr = 0, 1
    
    for _ in range(2, n + 1):
        prev, curr = curr, prev + curr
    
    return curr
```

## Anti-Patterns

### 1. Premature Optimization

**Bad:**
```python
# Using complex algorithm for small data
def find_smallest(arr):
    # Writing quicksort when list has 3 elements
    return quicksort(arr)[0]
```

**Solution:**
```python
def find_smallest(arr):
    if not arr:
        return None
    return min(arr)  # Simple for small data
```

### 2. Wrong Algorithm for Data Size

**Bad:**
- Using O(n²) algorithm when n is large
- Not considering growth

**Solution:**
- Analyze complexity
- Choose based on expected data size

### 3. Not Understanding Trade-offs

**Bad:**
- Always using the "best" algorithm
- Ignoring simplicity for small gains

**Solution:**
- Consider the context
- Balance readability and performance

## Best Practices

### 1. Choose Based on Complexity

| Data Size | Algorithm Type |
|-----------|----------------|
| n < 10 | Any O(n²) is fine |
| n < 1000 | O(n log n) sorting |
| n < 1M | Consider caching |
| n > 1M | O(n) or O(log n) |

### 2. Know Your Data

```python
# Sorted data? Use binary search
# Random data? Standard sort
# Unique values? Set operations
# Time-series? Consider trees
```

### 3. Measure Before Optimizing

```python
import time

# Measure actual performance
start = time.time()
result = algorithm(data)
elapsed = time.time() - start
print(f"Elapsed: {elapsed:.4f}s")
```

## Anti-Patterns

### 1. Premature Optimization

**Bad:** Implementing complex O(log n) algorithm when O(n) is fast enough for n < 1000
**Why it's bad:** Complex algorithms are harder to maintain, debug, and often have higher constant factors
**Good:** Start simple, profile, optimize only when proven necessary

### 2. Clever Over Clear

**Bad:** One-liner that's impossible to understand → bugs hide in cleverness
**Solution:** Prefer readable implementations, add comments for non-obvious optimizations

### 3. Wrong Algorithm for Data

**Bad:** Using quicksort on nearly-sorted data → O(n²) worst case
**Solution:** Know your data characteristics before choosing algorithms

## Failure Modes

- **Wrong algorithm for data size** → O(n²) on 1M items → timeout → choose by input scale
- **Ignoring worst case** → average O(n log n) but worst O(n²) → production spike → know worst cases
- **Not measuring** → assuming algorithm is fast → actually slow → profile before optimizing
- **Over-engineering** → custom algorithm when built-in suffices → maintenance burden → use standard library
- **Ignoring constant factors** → O(n log n) with huge constant slower than O(n) → measure real performance
- **Data characteristics mismatch** → binary search on unsorted data → wrong results → validate preconditions

## Decision Framework

```
Data size < 100? → Simple algorithm (readability wins)
Data size 100-10K? → Standard algorithm (balanced)
Data size > 10K? → Optimized algorithm (performance matters)
Data nearly sorted? → Insertion sort
Need stable sort? → Merge sort
Memory constrained? → In-place algorithm
```

## Related Topics

- [[DataStructures]]
- [[Complexity]]
- [[PerformanceOptimization]]
- [[PerformanceProfiling]]
- [[Sorting]]
- [[Searching]]
- [[GraphTheory]]
- [[DynamicProgramming]]

## Key Takeaways

- Algorithms are finite sequences of well-defined instructions for solving problems, with correctness, efficiency, and trade-offs as key evaluation criteria
- Matter when choosing data structures, optimizing performance, solving new problems, or understanding system behavior at scale
- For small datasets or when built-in functions suffice, simple approaches are preferable to custom algorithm implementations
- Tradeoff: optimal performance versus code clarity and maintainability; clever algorithms often hide bugs
- Main failure mode: choosing wrong algorithm for data size (e.g., O(n²) on large inputs) causes timeouts in production
- Best practice: understand the problem first, choose based on input scale and data characteristics, prefer clarity over cleverness, measure before optimizing, and use standard library implementations when adequate
- Related: data structures, complexity analysis, performance optimization, profiling

## Additional Notes
