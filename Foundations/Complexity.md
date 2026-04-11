---
title: Complexity
title_pt: Complexidade
layer: foundations
type: concept
priority: high
version: 1.0.0
tags:
  - Foundations
  - Complexity
description: Analysis of algorithm performance in terms of time and space requirements.
description_pt: Análise de performance de algoritmos em termos de requisitos de tempo e espaço.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Complexity

## Description

Complexity analysis measures how an algorithm's resource requirements (time and memory) grow as input size increases. It helps you choose between algorithms and understand system behavior at scale.

Two types:
- **Time Complexity**: How execution time grows
- **Space Complexity**: How memory usage grows

Big O notation describes upper bound:
- O(1) - Constant
- O(log n) - Logarithmic
- O(n) - Linear
- O(n log n) - Linearithmic
- O(n²) - Quadratic
- O(2^n) - Exponential
- O(n!) - Factorial

## Purpose

**When complexity analysis is critical:**
- When processing large datasets
- When performance matters
- When designing scalable systems
- For algorithm selection
- For identifying bottlenecks

**When complexity may not matter:**
- For small, bounded inputs
- For one-time operations
- When hardware can compensate
- For prototype/MVP code

**The key question:** How will this algorithm perform when data grows 10x, 100x, 1000x?

## Time Complexity

```python
# O(1) - Constant time
def get_first_element(arr):
    return arr[0]  # Always one operation

# O(n) - Linear time
def find_max(arr):
    max_val = arr[0]
    for num in arr:  # n iterations
        if num > max_val:
            max_val = num
    return max_val

# O(n²) - Quadratic time
def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

# O(log n) - Logarithmic
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    while left <= right:
        mid = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1
```

## Space Complexity

```python
# O(1) - Constant space
def sum_array(arr):
    total = 0
    for num in arr:
        total += num
    return total  # Only one variable

# O(n) - Linear space
def create_copy(arr):
    return arr[:]  # Creates new array

# O(n²) - Quadratic space
def create_matrix(n):
    return [[0] * n for _ in range(n)]
```

## Common Patterns

### Multiple loops

```python
# O(n + m) - Linear of sum
def process_arrays(arr1, arr2):
    for x in arr1:  # n
        process(x)
    for x in arr2:  # m
        process(x)

# O(n * m) - Product
def process_matrix(matrix):
    for row in matrix:  # n
        for col in row:  # m
            process(col)
```

### Recursive complexity

```python
# O(2^n) - Exponential (avoid!)
def fib_recursive(n):
    if n <= 1:
        return n
    return fib_recursive(n - 1) + fib_recursive(n - 2)

# O(n) - With memoization
def fib_memo(n, memo={}):
    if n in memo:
        return memo[n]
    if n <= 1:
        return n
    memo[n] = fib_memo(n - 1) + fib_memo(n - 2)
    return memo[n]
```

## Amortized Analysis

```python
# Dynamic array - O(1) amortized
# When full, resize to 2x (copy all n elements)
# This happens infrequently

# n insertions: O(n) total
# Amortized: O(1) per insertion

class DynamicArray:
    def __init__(self):
        self.capacity = 1
        self.size = 0
        self.array = [None] * self.capacity
    
    def append(self, item):
        if self.size == self.capacity:
            self.capacity *= 2
            new_array = [None] * self.capacity
            for i in range(self.size):
                new_array[i] = self.array[i]
            self.array = new_array
        
        self.array[self.size] = item
        self.size += 1
```

## Best Practices

### 1. Consider Worst, Average, Best Case

| Case | Description | Use When |
|------|-------------|----------|
| Worst | Maximum resources needed | Guaranteeing performance |
| Average | Expected resources | Planning capacity |
| Best | Minimum resources | Marketing claims |

### 2. Know the Constants

```python
# O(n) might be faster than O(1) for small n
# Constants matter in practice

# This O(n) might be slower:
def process_linear(arr):
    for x in arr:
        complex_operation(x)

# Than this O(n²):
def process_quadratic(arr):
    for i in range(len(arr)):
        for j in range(len(arr)):
            simple_op(arr[i], arr[j]))
```

### 3. Profile in Practice

```python
import time
import random

# Test different approaches
def benchmark(func, *args, iterations=1000):
    start = time.time()
    for _ in range(iterations):
        func(*args)
    return time.time() - start

# Don't assume - measure!
```

## Anti-Patterns

### 1. Big O Obsession

**Bad:** Choosing algorithm purely by Big O → ignoring constant factors → slower in practice
**Solution:** Big O describes growth rate, not absolute speed — measure real performance

### 2. Ignoring Space Complexity

**Bad:** O(n log n) time but O(n²) memory → runs out of RAM → consider space too
**Solution:** Always analyze both time and space

## Failure Modes

- **O(n²) in hot path** → works in dev with 100 items → crashes in prod with 1M → analyze before deploy
- **Recursive without base case** → stack overflow → always define termination condition
- **Hidden complexity** → library call is O(n) inside loop → becomes O(n²) → know your dependencies
- **Amortized worst case** → hash table resize is O(n) → occasional latency spike → understand amortized costs
- **Ignoring I/O complexity** → algorithm is O(n log n) but does O(n) disk reads → I/O dominates → consider access patterns
- **Space-time tradeoff wrong** → caching everything → memory exhaustion → find balance

## Decision Framework

```
n < 100? → Any complexity works (focus on clarity)
n < 10K? → O(n²) acceptable (focus on correctness)
n < 1M? → O(n log n) needed (focus on efficiency)
n > 1M? → O(n) or O(log n) required (focus on scalability)
Memory constrained? → Prioritize space complexity
Latency sensitive? → Prioritize worst-case time
Throughput sensitive? → Prioritize amortized time
```

## Related Topics

- [[Algorithms]]
- [[DataStructures]]
- [[PerformanceOptimization]]
- [[PerformanceProfiling]]
- [[CyclomaticComplexity]]
- [[Metrics]]
- [[Caching]]
- [[DatabaseOptimization]]

## Examples

### Choosing the Right Algorithm

```python
# For small arrays, O(n²) might be faster than O(n log n)
# due to lower constant factors

# Quick sort O(n log n) avg, but overhead for small n
def quick_sort(arr):
    if len(arr) <= 1:
        return arr
    # ... partitioning overhead

# Bubble sort O(n²), but fewer operations for n < 10
def bubble_sort(arr):
    # ... simple nested loops
```

### Real-World Performance

```python
# Database query optimization
# O(log n) index lookup vs O(n) full table scan
# With 1M rows: ~20 operations vs 1,000,000 operations

# Caching strategy
# O(1) cache hit vs O(n) database query
# Multiply by request volume = significant savings
```

## Key Takeaways

- Complexity analysis measures how algorithm resource requirements grow with input size using Big O notation for time and space
- Critical when processing large datasets, designing scalable systems, or selecting between algorithms; less important for small bounded inputs or prototypes
- Tradeoff: theoretical growth rate understanding versus ignoring constant factors that dominate at practical input sizes
- Main failure mode: O(n²) algorithms in hot paths work in development with small data but crash in production with real-scale inputs
- Best practice: analyze both time and space complexity, consider worst/average/best cases, profile real performance before optimizing, and choose algorithms based on expected data scale
- Related: algorithms, data structures, performance optimization, profiling, cyclomatic complexity, caching

## Additional Notes
