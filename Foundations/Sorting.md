---
title: Sorting Algorithms
layer: foundations
type: concept
priority: high
version: 2.0.0
tags:
  - Foundations
  - Algorithms
  - Sorting
  - Complexity
description: Algorithms for ordering data: comparison-based and non-comparison-based sorts, stability, in-place operation, and the Omega(n log n) lower bound.
---

# Sorting Algorithms

## Description

Sorting arranges elements into a defined order (ascending, descending, lexicographic). It is one of the most studied algorithmic problems because sorted data enables efficient searching (O(log n) binary search), duplicate detection, range queries, and serves as a preprocessing step for countless other algorithms.

The comparison-based lower bound is **Omega(n log n)**: any algorithm that sorts by comparing elements must make at least log2(n!) = Theta(n log n) comparisons in the worst case. This is proven by the decision tree model -- there are n! possible permutations, and a binary comparison tree of height h can distinguish at most 2^h outcomes, so h >= log2(n!).

Non-comparison sorts (counting sort, radix sort, bucket sort) break this bound by exploiting structure in the data (integer keys, bounded range, uniform distribution), achieving O(n) under specific conditions.

Key properties for comparison:

| Property | What it means | Why it matters |
|---|---|---|
| **Stability** | Equal elements maintain their relative order | Critical when sorting by multiple keys (e.g., sort by department, then by name within department) |
| **In-place** | Uses O(1) extra space | Important for memory-constrained environments, large datasets |
| **Adaptive** | Faster on partially sorted data | Real-world data is rarely random; adaptive sorts exploit existing order |
| **Online** | Can sort as data arrives (not all at once) | Streaming data, real-time systems |

## Purpose

**When to use:**
- **Timsort (Python's `sorted()`, Java's `Arrays.sort()` for objects):** The default for general-purpose sorting. Stable, adaptive, O(n log n) worst case, O(n) on already-sorted data. Use it for virtually all application-level sorting.
- **Quicksort (C's `qsort`, C++ `std::sort` for primitives):** Fast in practice (excellent cache locality), O(n log n) average, but O(n^2) worst case and unstable. Use for sorting primitives where stability doesn't matter and speed is critical.
- **Mergesort:** Stable, O(n log n) guaranteed, excellent for external sorting (data too large for RAM, sorted in chunks and merged). Used in databases, file system sorts, and linked list sorting.
- **Heapsort:** O(n log n) worst case, in-place, but poor cache performance and not stable. Used in the Linux kernel's `sched.c` for priority queues and as the fallback in Introsort.
- **Radix sort:** O(n * k) for fixed-width integers or strings. Faster than comparison sorts when k is small. Used in high-performance computing, GPU sorting, and database column scans.
- **Topological sort:** For ordering tasks with dependencies. Used in build systems, course scheduling, package installation order.

**When NOT to use:**
- **When data is already sorted and you're resorting needlessly** -- maintain sorted order with a data structure (BST, skip list) that supports O(log n) inserts.
- **When you only need the top-k elements** -- use a heap (O(n + k log n)) or QuickSelect (O(n) average) instead of full sort (O(n log n)).
- **When you only need to find duplicates** -- use a hash set (O(n) average) instead of sort + adjacent comparison (O(n log n)).
- **When n is tiny (< 20)** -- insertion sort is simpler and often faster due to low constant factors. Timsort uses insertion sort for small runs.
- **When the sort order is application-specific and dynamic** (e.g., "sort by relevance, which depends on the user's profile") -- scoring + heap selection may be more appropriate than general-purpose sort.

## Tradeoffs

**Stability vs performance:** Quicksort (unstable, faster on average) vs Mergesort (stable, guaranteed O(n log n)). If you need stability and the data fits in memory, use Timsort. If data is too large, use external mergesort.

**In-place vs guaranteed performance:** Heapsort is in-place with O(n log n) worst case but has terrible cache behavior. Mergesort has great cache behavior but needs O(n) extra space. Introsort (C++ `std::sort`) combines quicksort's speed with heapsort's worst-case guarantee by switching to heapsort when recursion depth exceeds 2 * log2(n).

**Comparison vs non-comparison:** Radix sort is O(n) for 32-bit integers but uses O(n) extra space and only works on fixed-width keys. Quicksort is O(n log n) average but works on any comparable type. When n > 10M and keys are integers, radix sort typically wins by 2-5x.

**Adaptive behavior on real-world data:** Timsort detects "runs" (already-sorted subsequences) and merges them efficiently. On data that is 90% sorted, Timsort runs in O(n) -- 10-100x faster than quicksort's O(n log n).

## Alternatives

- **Selection algorithms (QuickSelect, Median of Medians):** When you only need the k-th smallest element or top-k, not full ordering. QuickSelect is O(n) average, Median of Medians is O(n) worst case (but high constant).
- **Heap-based partial sorting:** Build a heap in O(n), then extract k elements in O(k log n). Better than full sort when k << n.
- **Bucket sort:** Distribute elements into buckets, sort each bucket individually. O(n) average when data is uniformly distributed. Degrades to O(n^2) when all elements land in one bucket.
- **Counting sort:** O(n + k) when keys are integers in range [0, k]. Excellent for small-range integers (e.g., sorting ages, test scores). Useless for floating-point or string keys.
- **External sorting (multiway mergesort):** When data doesn't fit in RAM. Sort chunks in memory, write to disk, then merge sorted runs. Used by every database's ORDER BY implementation.

## Failure Modes

1. **Unstable sort breaking multi-key ordering:** Sorting a list of employees first by name, then by department. An unstable sort destroys the name ordering within departments. Example: Python 2's `list.sort()` was stable, but C's `qsort()` is not. **Mitigation:** Use stable sorts (Timsort, Mergesort) for multi-key sorting. Or use a composite key: `sorted(employees, key=lambda e: (e.department, e.name))` which sorts correctly in one pass.

2. **Quicksort worst-case O(n^2) on sorted/reverse-sorted data:** With naive pivot selection (first or last element), quicksort degrades to O(n^2) on already-sorted input. This is exploitable for DoS attacks. **Mitigation:** Use randomized pivot, median-of-three, or Introsort (switch to heapsort when depth exceeds threshold). Modern implementations (C++ `std::sort`, Rust `slice::sort_unstable`) use these defenses.

3. **Comparator violating transitivity causing crashes or infinite loops:** The comparator must define a strict weak ordering: `cmp(a, b) && cmp(b, c)` implies `cmp(a, c)`, and `cmp(a, a)` is always false. Violating this causes undefined behavior in C++, panics in Rust, and silent wrong results in Python. Real example: Java's `Arrays.sort()` throws `IllegalArgumentException: Comparison method violates its general contract!` **Mitigation:** Test comparator properties: reflexivity, antisymmetry, transitivity. For floating-point comparisons, handle NaN explicitly: `NaN` compares unequal to everything including itself.

4. **Integer overflow in comparator subtraction:** `return a - b` in C/C++ overflows when `a` is large positive and `b` is large negative. This was a common cause of wrong sort results in competitive programming and production code. **Mitigation:** Use `return (a > b) - (a < b)` or `std::compare_three_way` in C++20. In Java, use `Integer.compare(a, b)` not `a - b`.

5. **Modifying data during sort causing corruption:** If the comparison function reads data that is being mutated by another thread, sort results are undefined. Example: sorting a list of stock prices while a market data feed updates the list. **Mitigation:** Sort a snapshot (copy) of the data. Use thread-safe data structures or locks around the sort operation.

6. **Memory exhaustion in mergesort on large data:** Mergesort allocates O(n) auxiliary space. Sorting 100 million 64-bit integers requires 800MB for the data plus 800MB for the auxiliary array -- 1.6GB total. **Mitigation:** Use in-place mergesort variants (complex, slower in practice), or external mergesort that processes data in chunks. Use `sort_unstable` (quicksort-based) in Rust when stability isn't needed.

7. **Sorting mutable references with aliasing issues:** In languages with mutable references, sorting a list of objects that are also referenced elsewhere can cause subtle bugs if the comparison depends on mutable fields that change during the sort. **Mitigation:** Sort by immutable key (extract key first, sort by key). In Python: `sorted(data, key=lambda x: x.mutable_field)` extracts all keys before sorting begins.

## Code Examples

### Example 1: Introsort (Quicksort + Heapsort Fallback)

```python
"""
Introsort: combines quicksort's average-case speed with heapsort's
worst-case O(n log n) guarantee. Switches to heapsort when recursion
depth exceeds 2 * log2(n).

This is the algorithm behind C++ std::sort and Rust's sort_unstable.
"""
import math
import heapq
from typing import TypeVar, List, Callable

T = TypeVar('T')


def introsort(arr: List[T], cmp: Callable[[T, T], bool] = None) -> List[T]:
    """
    Sort arr in-place using Introsort.
    cmp(a, b) returns True if a < b. Default: standard less-than.
    
    Time: O(n log n) worst case, O(n log n) average
    Space: O(log n) stack
    """
    if cmp is None:
        cmp = lambda a, b: a < b
    
    n = len(arr)
    if n <= 1:
        return arr
    
    max_depth = 2 * int(math.log2(n)) if n > 1 else 0
    _introsort_recursive(arr, 0, n - 1, cmp, max_depth)
    return arr


def _introsort_recursive(arr, lo, hi, cmp, max_depth):
    while hi - lo > 16:  # Small arrays: defer to insertion sort
        if max_depth == 0:
            # Switch to heapsort -- guarantees O(n log n)
            _heapsort(arr, lo, hi, cmp)
            return
        max_depth -= 1
        
        # Median-of-three pivot selection
        mid = (lo + hi) // 2
        # Sort arr[lo], arr[mid], arr[hi] to pick median as pivot
        if cmp(arr[mid], arr[lo]):
            arr[lo], arr[mid] = arr[mid], arr[lo]
        if cmp(arr[hi], arr[lo]):
            arr[lo], arr[hi] = arr[hi], arr[lo]
        if cmp(arr[hi], arr[mid]):
            arr[mid], arr[hi] = arr[hi], arr[mid]
        
        pivot = arr[mid]
        arr[mid], arr[hi - 1] = arr[hi - 1], arr[mid]  # Hide pivot
        
        # Partition (Lomuto scheme with pivot hidden)
        i = lo
        for j in range(lo, hi - 1):
            if cmp(arr[j], pivot):
                arr[i], arr[j] = arr[j], arr[i]
                i += 1
        
        # Place pivot in correct position
        arr[i], arr[hi - 1] = arr[hi - 1], arr[i]
        
        # Recurse on smaller partition, iterate on larger (tail call optimization)
        if i - lo < hi - i:
            _introsort_recursive(arr, lo, i - 1, cmp, max_depth)
            lo = i + 1
        else:
            _introsort_recursive(arr, i + 1, hi, cmp, max_depth)
            hi = i - 1
    
    # Insertion sort for small subarrays
    _insertion_sort(arr, lo, hi, cmp)


def _heapsort(arr, lo, hi, cmp):
    """Heapsort on arr[lo:hi+1]. O(n log n) guaranteed."""
    # Build max-heap
    n = hi - lo + 1
    for i in range(n // 2 - 1, -1, -1):
        _sift_down(arr, lo, lo + n, i, cmp)
    
    # Extract elements one by one
    for end in range(n - 1, 0, -1):
        arr[lo], arr[lo + end] = arr[lo + end], arr[lo]
        _sift_down(arr, lo, lo + end, 0, cmp)


def _sift_down(arr, lo, hi, root, cmp):
    """Restore heap property at root."""
    while True:
        largest = root
        left = 2 * root + 1
        right = 2 * root + 2
        
        if lo + left < hi and cmp(arr[largest], arr[lo + left]):
            largest = lo + left
        if lo + right < hi and cmp(arr[largest], arr[lo + right]):
            largest = lo + right
        
        if largest == root:
            break
        arr[lo + root], arr[lo + largest] = arr[lo + largest], arr[lo + root]
        root = largest


def _insertion_sort(arr, lo, hi, cmp):
    """Insertion sort on arr[lo:hi+1]. O(n^2) but fast for small n."""
    for i in range(lo + 1, hi + 1):
        key = arr[i]
        j = i - 1
        while j >= lo and cmp(key, arr[j]):
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key


# Test correctness
import random
for trial in range(100):
    n = random.randint(0, 500)
    arr = [random.randint(-1000, 1000) for _ in range(n)]
    expected = sorted(arr)
    introsort(arr)
    assert arr == expected, f"Failed on trial {trial}"

# Test worst-case: already sorted (naive quicksort would be O(n^2))
arr = list(range(10000))
introsort(arr)
assert arr == list(range(10000))

# Test worst-case: reverse sorted
arr = list(range(10000, 0, -1))
introsort(arr)
assert arr == list(range(1, 10001))
```

### Example 2: Timsort Conceptual Overview (Python's `sorted()`)

```python
"""
Timsort is NOT for interview implementation -- it's complex.
But understanding its design is valuable.

Timsort strategy:
1. Scan for "runs" (ascending or strictly descending subsequences)
2. Reverse descending runs to make them ascending
3. Maintain a stack of runs; merge when size invariants are violated
   (Tim Peters' invariant: run[i-1] > run[i] + run[i+1])
4. Use galloping mode during merge when one run consistently "wins"

Key properties:
- Stable: equal elements maintain relative order
- Adaptive: O(n) on already-sorted data
- Worst case: O(n log n)
- Space: O(n) for the merge buffer

Python's sorted() and list.sort() use Timsort.
Java's Arrays.sort(Object[]) uses Timsort.
"""

def multi_key_sort_with_timsort(data: list[dict], keys: list[str]) -> list[dict]:
    """
    Sort by multiple keys using Python's stable sort.
    Sort by keys in REVERSE order of priority (last key = most important).
    
    Example: sort by department, then by name within department:
    multi_key_sort(employees, ['name', 'department'])
    """
    result = list(data)  # Copy
    for key in reversed(keys):
        result.sort(key=lambda x: x[key])
    return result


# Verification
employees = [
    {"name": "Charlie", "department": "Engineering"},
    {"name": "Alice", "department": "Engineering"},
    {"name": "Bob", "department": "Sales"},
    {"name": "Diana", "department": "Sales"},
]

sorted_employees = multi_key_sort_with_timsort(employees, ["department", "name"])
assert sorted_employees[0]["name"] == "Alice"      # Engineering, Alice
assert sorted_employees[1]["name"] == "Charlie"    # Engineering, Charlie
assert sorted_employees[2]["name"] == "Bob"        # Sales, Bob
assert sorted_employees[3]["name"] == "Diana"      # Sales, Diana

# This works BECAUSE Python's sort is stable.
# An unstable sort would produce arbitrary ordering within departments.
```

### Example 3: Radix Sort (LSD) for 32-bit Integers

```python
def radix_sort(arr: list[int]) -> list[int]:
    """
    Least Significant Digit radix sort for non-negative 32-bit integers.
    
    Strategy: sort by each digit position, from LSD to MSD.
    Each digit pass uses a stable counting sort.
    
    Time: O(n * k) where k = number of digits (4 passes for 32-bit with base 2^8)
    Space: O(n + k_base) where k_base = 256 (bucket count for base-256)
    
    For n = 10M 32-bit integers, radix sort is typically 2-5x faster
    than comparison-based sort.
    """
    if not arr:
        return []
    
    assert all(x >= 0 for x in arr), "This implementation handles non-negative integers"
    
    # Use base 2^8 = 256 (one byte at a time)
    # 32-bit integers need 4 passes
    base = 256
    max_val = max(arr)
    num_passes = 0
    temp = max_val
    while temp > 0:
        temp //= base
        num_passes += 1
    num_passes = max(num_passes, 1)
    
    result = list(arr)
    
    for shift in range(num_passes):
        # Counting sort on current byte
        count = [0] * base
        output = [0] * len(result)
        
        # Extract current byte
        for x in result:
            byte_val = (x >> (shift * 8)) & 0xFF
            count[byte_val] += 1
        
        # Cumulative count
        for i in range(1, base):
            count[i] += count[i - 1]
        
        # Build output (iterate backwards for stability)
        for i in range(len(result) - 1, -1, -1):
            byte_val = (result[i] >> (shift * 8)) & 0xFF
            count[byte_val] -= 1
            output[count[byte_val]] = result[i]
        
        result = output
    
    return result


# Test
import random
arr = [random.randint(0, 2**31 - 1) for _ in range(10000)]
assert radix_sort(arr) == sorted(arr)

# Edge cases
assert radix_sort([]) == []
assert radix_sort([42]) == [42]
assert radix_sort([0, 0, 0]) == [0, 0, 0]
assert radix_sort([1, 3, 2, 5, 4]) == [1, 2, 3, 4, 5]
```

### Example 4: External Mergesort (for Data Larger than RAM)

```python
"""
External mergesort: sort data that doesn't fit in memory.

Strategy:
1. Read chunks that fit in memory, sort each chunk, write to temp file
2. Merge all sorted chunks using a k-way merge (min-heap)

Used by: PostgreSQL ORDER BY, MySQL filesort, Hadoop MapReduce shuffle phase.
"""
import heapq
import tempfile
import os
from typing import Iterator, TypeVar

T = TypeVar('T')


def external_sort(input_file: str, output_file: str, chunk_size: int, key=None):
    """
    Sort a file too large to fit in memory.
    
    input_file: path to file with one value per line
    output_file: path to sorted output
    chunk_size: number of lines to sort in memory at once
    key: function to extract sort key (like sorted's key parameter)
    """
    sorted_chunks = []
    
    # Phase 1: Sort chunks in memory, write to temp files
    with open(input_file, 'r') as f:
        chunk = []
        for line in f:
            chunk.append(line)
            if len(chunk) >= chunk_size:
                chunk.sort(key=key)
                tmp = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.chunk')
                tmp.writelines(chunk)
                tmp.close()
                sorted_chunks.append(tmp.name)
                chunk = []
        
        # Handle remaining
        if chunk:
            chunk.sort(key=key)
            tmp = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.chunk')
            tmp.writelines(chunk)
            tmp.close()
            sorted_chunks.append(tmp.name)
    
    # Phase 2: K-way merge of sorted chunks
    with open(output_file, 'w') as out:
        # Open all chunk files
        chunk_files = [open(path, 'r') for path in sorted_chunks]
        
        # Initialize heap with first line of each chunk
        heap = []
        for i, f in enumerate(chunk_files):
            line = f.readline()
            if line:
                sort_key = key(line) if key else line
                heap.append((sort_key, i, line))
        
        heapq.heapify(heap)
        
        while heap:
            sort_key, file_idx, line = heapq.heappop(heap)
            out.write(line)
            
            next_line = chunk_files[file_idx].readline()
            if next_line:
                next_key = key(next_line) if key else next_line
                heapq.heappush(heap, (next_key, file_idx, next_line))
        
        # Cleanup
        for f in chunk_files:
            f.close()
        for path in sorted_chunks:
            os.unlink(path)


# Test with data larger than chunk size
import tempfile
tmp_in = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt')
for n in [5, 3, 8, 1, 9, 2, 7, 4, 6, 0]:
    tmp_in.write(f"{n}\n")
tmp_in.close()

tmp_out = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt')
tmp_out.close()

external_sort(tmp_in.name, tmp_out.name, chunk_size=3, key=lambda x: int(x))

with open(tmp_out.name) as f:
    result = [int(line) for line in f]
assert result == list(range(10))

os.unlink(tmp_in.name)
os.unlink(tmp_out.name)
```

## Best Practices

- **Use the standard library sort for everything except interviews.** Python's `sorted()`, Rust's `sort()`/`sort_unstable()`, C++'s `std::sort()` -- they are heavily optimized and correct.
- **Prefer stable sorts by default.** Stability is almost always desirable even when you don't realize it. The cost difference between Timsort and quicksort is negligible for most workloads.
- **Extract sort keys before sorting.** `data.sort(key=lambda x: x.field)` is faster and safer than a custom comparator because the key is evaluated once per element, not O(n log n) times.
- **For numeric keys, use tuples for multi-key sorting.** `sorted(data, key=lambda x: (x.primary, x.secondary))` is cleaner and faster than two-pass stable sort.
- **Profile before implementing custom sort.** If sorting is < 5% of your program's runtime, a 2x speedup is irrelevant. Optimize the hot path.
- **For very large datasets, use external sort or a database.** Don't load 100GB into Python and call `sorted()`. Use PostgreSQL's `ORDER BY`, Spark's `sortBy`, or external mergesort.
- **Handle NaN and None explicitly in comparators.** `NaN != NaN`, `NaN < x` is False, `NaN > x` is False. Define a total ordering: e.g., `NaN` sorts last.

## Related Topics

- [[Searching]] -- Sorting enables binary search; searching is the motivation for sorting
- [[BigO]] -- The Omega(n log n) lower bound for comparison-based sorting
- [[Algorithms]] -- Sorting as a fundamental algorithmic building block
- [[DataStructures]] -- Heaps for priority queues and heapsort; BSTs for in-order traversal
- [[DynamicProgramming]] -- Sorting as a preprocessing step for DP (e.g., LIS requires sorted data)
- [[GraphTheory]] -- Topological sort for DAGs; Kahn's algorithm
- [[Performance]] -- Cache locality in sorting; SIMD; parallel merge sort
- [[Databases]] -- External sort in database ORDER BY; index maintenance
- [[Principles/Determinism]] -- Sort stability as a form of determinism
- [[Quality]] -- Testing sort implementations: edge cases, stability, worst-case inputs
