---
title: Searching Algorithms
layer: foundations
type: concept
priority: high
version: 2.0.0
tags:
  - Foundations
  - Algorithms
  - Searching
description: Algorithms for finding elements or determining membership in data structures: linear, binary, interpolation, hash-based, and tree-based search with their complexity guarantees.
---

# Searching Algorithms

## Description

Searching is the fundamental operation of locating a target value (or determining its absence) within a collection. The choice of search algorithm is dictated by the data structure and access patterns:

| Algorithm | Data Structure | Time | Space | Precondition |
|---|---|---|---|---|
| Linear scan | Any | O(n) | O(1) | None |
| Binary search | Sorted array | O(log n) | O(1) iterative | Sorted, random access |
| Interpolation search | Sorted, uniformly distributed array | O(log log n) avg, O(n) worst | O(1) | Sorted, uniform distribution |
| Hash table lookup | Hash table | O(1) avg, O(n) worst | O(n) | Hash function |
| BST search | Binary search tree | O(log n) avg, O(n) worst | O(h) | BST property |
| Balanced BST search | AVL, Red-Black, B-tree | O(log n) worst | O(log n) | Balanced tree |
| Bloom filter | Bit array + hash functions | O(k) | O(m) bits | Probabilistic (false positives possible) |
| Ternary search | Sorted array (unimodal function) | O(log_3 n) | O(1) | Unimodal |

**Key insight:** The data structure determines the search complexity. You cannot binary search a linked list in O(log n) because random access is O(n). Choosing the right data structure is more important than optimizing the search algorithm.

## Purpose

**When to use:**
- **Binary search:** Whenever you have sorted data and need exact match, floor/ceil, or range queries. Examples: finding a timestamp in a sorted log file, looking up a version number in a sorted list of releases, finding the insertion point for a new element (bisect).
- **Hash-based search:** When you need O(1) average-case lookups and don't need ordering. Examples: user session lookup by token, configuration key-value store, deduplication.
- **B-tree/B+tree search:** When data is too large for memory and you need disk-efficient search. Examples: database indexes, filesystem directories, LSM-tree SSTable lookups.
- **Bloom filters:** When you need space-efficient membership testing and can tolerate false positives. Examples: Chrome's safe browsing (checking if a URL is malicious), Cassandra's SSTable bloom filters (skip disk reads for absent keys), CDN cache hit detection.
- **Interpolation search:** When data is sorted AND uniformly distributed. Example: searching a sorted phone book by name -- you intuitively interpolate (open near the middle of the alphabet section).
- **Binary search on answer space:** When you can check "is X feasible?" efficiently but don't know the optimal X. Examples: finding the minimum CPU count to meet an SLA, finding the maximum throughput of a system, competitive programming optimization problems.

**When NOT to use:**
- **Binary search on unsorted data** -- the result is meaningless. Sort first (O(n log n)) or use linear search (O(n)).
- **Binary search on linked lists** -- O(n) random access negates the O(log n) advantage. Use a BST or hash table instead.
- **Hash tables when you need ordering, range queries, or nearest-neighbor** -- use a balanced BST or skip list.
- **Bloom filters when false positives are unacceptable** -- a false positive in a payment fraud check means blocking a legitimate transaction. Use exact sets.
- **Interpolation search on non-uniform data** -- worst case is O(n). Example: [1, 2, 3, 4, 5, 1000000] -- interpolation guesses the middle first, but the target 5 is near the beginning.
- **Any complex search structure for n < 100** -- linear scan is faster due to cache locality and branch prediction.

## Tradeoffs

**Binary search vs Hash table:**
- Binary search gives you ordering for free (floor, ceil, range queries, rank). Hash tables do not.
- Hash tables have O(1) average lookup but O(n) worst case (collisions). Binary search is O(log n) guaranteed.
- Hash tables require O(n) extra space for the table. Binary search on a sorted array needs O(1) extra space.
- Hash tables are vulnerable to DoS via hash collisions (e.g., CVE-2011-4858 in multiple languages). Binary search has no such vulnerability.

**B-tree vs Hash index (databases):**
- B-tree supports range scans and ORDER BY efficiently. Hash index only supports point lookups.
- B-tree maintains sorted order during inserts/deletes. Hash index does not.
- Hash index is faster for point lookups (O(1) vs O(log_B n)) but B-tree is more versatile.

**Bloom filter vs exact set:**
- Bloom filter: 10 bits per element, 1% false positive rate. Exact set (hash table): 64+ bits per element, 0% false positives.
- Bloom filter supports inserts but not deletes (without Counting Bloom Filter, which uses 4x space).
- Bloom filter cannot enumerate elements; exact set can.

## Alternatives

- **Linear scan:** For small n (<100) or when data is already in cache, linear scan with SIMD (vectorized comparison) can beat binary search due to branch misprediction avoidance.
- **Skip lists:** Probabilistic alternative to balanced BSTs. Simpler to implement, comparable O(log n) performance. Used in Redis sorted sets.
- **Trie / Radix tree:** For string-prefix search. O(m) where m is key length, independent of n. Used in routing tables, autocomplete, IP longest-prefix matching.
- **Inverted index:** For full-text search. Maps terms to document IDs. Used in Elasticsearch, Lucene, search engines.
- **Vector similarity search (HNSW, FAISS):** For nearest-neighbor in high-dimensional space. Binary search doesn't apply to embedding spaces.

## Failure Modes

1. **Off-by-one errors in binary search boundaries:** The most common bug. Using `low <= high` vs `low < high`, or `mid = (low + high) // 2` vs `mid = low + (high - low) // 2`. Example: searching for the first element >= X (lower_bound) requires careful boundary handling. **Mitigation:** Use the standard template: `low = 0, high = n` (exclusive), `while low < high`, `mid = low + (high - low) // 2`. Always test: empty array, single element, element at index 0, element at index n-1, element not present.

2. **Integer overflow in midpoint calculation:** `(low + high) // 2` overflows when `low + high > INT_MAX`. This is a real CVE (CVE-2006-2451 in Apache). **Mitigation:** Always use `mid = low + (high - low) // 2`. In languages with fixed-size integers, use unsigned or 64-bit arithmetic for the addition.

3. **Hash collision DoS:** An attacker sends keys that all hash to the same bucket, degrading O(1) lookup to O(n). This affected Python, Java, Ruby, PHP, and Node.js (2011-2012). **Mitigation:** Use a randomized hash function per process (Python does this by default since 3.3). Use SipHash (Rust's default hasher). Limit the size of hash tables from untrusted input.

4. **Comparator violates strict weak ordering:** In C++ `std::binary_search` or `std::lower_bound`, the comparator must define a strict weak ordering. A broken comparator (e.g., `<=` instead of `<`) causes undefined behavior. **Mitigation:** Use `<` for ordering, never `<=`. Verify: `comp(x, x)` must be `false`, and `comp(a, b) && comp(b, c)` implies `comp(a, c)`.

5. **Floating-point binary search infinite loop:** Comparing floats with `<` or `>` in binary search can loop forever when the target is between two representable floats. Example: searching for 0.3 in an array where 0.3 is not exactly representable. **Mitigation:** Use epsilon comparison: `abs(arr[mid] - target) < 1e-9` for equality. Or search on integer indices and compare by value at termination.

6. **Stale sorted data:** Binary search on data that was sorted but then modified without re-sorting. The search returns wrong results silently. **Mitigation:** Encapsulate the sorted collection in a type that enforces sortedness (e.g., a `SortedList` class that maintains invariant on mutation). Document the sorted precondition prominently.

7. **Binary search on the wrong predicate:** When using binary search on answer space, the predicate must be monotonic. If `feasible(x)` is true, then `feasible(x+1)` must also be true (or vice versa). A non-monotonic predicate gives wrong results. **Mitigation:** Prove monotonicity before coding. Plot `feasible(x)` for several x values to check visually.

## Code Examples

### Example 1: Binary Search with All Variants

```python
from typing import TypeVar, List, Optional
from bisect import bisect_left, bisect_right

T = TypeVar('T')


def binary_search(arr: List[T], target: T) -> int:
    """
    Standard binary search. Returns index of target or -1 if not found.
    
    Invariant: if target is in arr, it must be in arr[low:high]
    Loop: arr[low:high] shrinks by at least 1 each iteration
    Termination: low == high, search space exhausted
    
    Time: O(log n), Space: O(1)
    """
    low, high = 0, len(arr)
    while low < high:
        mid = low + (high - low) // 2  # Avoid overflow
        if arr[mid] < target:
            low = mid + 1
        else:
            high = mid
    # low == high: arr[low] is the first element >= target
    if low < len(arr) and arr[low] == target:
        return low
    return -1


def lower_bound(arr: List[T], target: T) -> int:
    """
    First index where arr[i] >= target (equivalent to bisect_left).
    Useful for: finding insertion point, floor queries, range starts.
    """
    low, high = 0, len(arr)
    while low < high:
        mid = low + (high - low) // 2
        if arr[mid] < target:
            low = mid + 1
        else:
            high = mid
    return low


def upper_bound(arr: List[T], target: T) -> int:
    """
    First index where arr[i] > target (equivalent to bisect_right).
    Useful for: range ends, counting elements <= target.
    """
    low, high = 0, len(arr)
    while low < high:
        mid = low + (high - low) // 2
        if arr[mid] <= target:
            low = mid + 1
        else:
            high = mid
    return low


def find_first_and_last(arr: List[int], target: int) -> tuple[int, int]:
    """
    Find the first and last occurrence of target in a sorted array
    that may contain duplicates.
    Returns (-1, -1) if target not found.
    """
    first = lower_bound(arr, target)
    if first >= len(arr) or arr[first] != target:
        return (-1, -1)
    last = upper_bound(arr, target) - 1
    return (first, last)


# Comprehensive tests
arr = [1, 2, 2, 2, 3, 4, 5]

# Exact search
assert binary_search(arr, 2) == 1  # First occurrence
assert binary_search(arr, 6) == -1
assert binary_search([], 1) == -1
assert binary_search([5], 5) == 0

# Lower bound
assert lower_bound(arr, 2) == 1  # First 2
assert lower_bound(arr, 0) == 0  # Before first element
assert lower_bound(arr, 6) == 7  # After last element
assert lower_bound(arr, 2.5) == 4  # First element > 2

# Upper bound
assert upper_bound(arr, 2) == 4  # After last 2
assert upper_bound(arr, 5) == 7  # After last element

# First and last
assert find_first_and_last(arr, 2) == (1, 3)
assert find_first_and_last(arr, 6) == (-1, -1)
assert find_first_and_last([1, 1, 1], 1) == (0, 2)
```

### Example 2: Binary Search on Answer Space

```python
def min_capacity_for_slade(intervals: list[tuple[int, int]], target_time: int) -> int:
    """
    Problem: You have a list of (requests_per_second, duration) intervals.
    What is the minimum server capacity (requests/second) needed to handle
    all requests within target_time seconds?
    
    This is solved by binary search on the answer:
    - Predicate: can(capacity) = True if all requests finish within target_time
    - The predicate is monotonic: if capacity X works, X+1 also works
    
    Time: O(n * log(max_capacity)), Space: O(1)
    """
    def can_handle(capacity: int) -> bool:
        """Check if all intervals can be handled within target_time."""
        total_time = 0
        for req_rate, duration in intervals:
            # Time to process this interval at given capacity
            total_time += (req_rate * duration) / capacity
            if total_time > target_time:
                return False
        return total_time <= target_time
    
    # Binary search on answer space
    low = 1
    high = sum(r * d for r, d in intervals)  # Worst case: process one at a time
    
    while low < high:
        mid = low + (high - low) // 2
        if can_handle(mid):
            high = mid
        else:
            low = mid + 1
    
    return low


# Test
intervals = [(100, 5), (200, 3), (50, 10)]  # (rate, duration)
capacity = min_capacity_for_slade(intervals, target_time=10)
print(f"Minimum capacity: {capacity} req/s")
```

### Example 3: Bloom Filter Implementation

```python
"""
Bloom filter: space-efficient probabilistic set membership.
Guarantees: no false negatives. False positives possible.
"""
import hashlib
from typing import Any
import math


class BloomFilter:
    def __init__(self, expected_items: int, false_positive_rate: float = 0.01):
        """
        Size and number of hash functions are computed from expected
        item count and desired false positive rate.
        
        m = -n * ln(p) / (ln(2))^2   -- optimal bit array size
        k = (m/n) * ln(2)            -- optimal number of hash functions
        """
        self.n = expected_items
        self.p = false_positive_rate
        
        # Optimal parameters
        self.m = max(1, int(-expected_items * math.log(false_positive_rate) / (math.log(2) ** 2)))
        self.k = max(1, int((self.m / expected_items) * math.log(2)))
        
        self.bit_array = bytearray((self.m + 7) // 8)  # Bit array as bytes
    
    def _hashes(self, item: Any) -> list[int]:
        """Generate k hash indices for an item."""
        # Use different seeds for each hash function
        item_bytes = str(item).encode('utf-8')
        indices = []
        for i in range(self.k):
            h = hashlib.sha256(f"{i}:{item_bytes}".encode()).hexdigest()
            indices.append(int(h, 16) % self.m)
        return indices
    
    def add(self, item: Any) -> None:
        for idx in self._hashes(item):
            byte_idx = idx // 8
            bit_idx = idx % 8
            self.bit_array[byte_idx] |= (1 << bit_idx)
    
    def __contains__(self, item: Any) -> bool:
        """
        Returns True if item is PROBABLY in the set,
        False if item is DEFINITELY NOT in the set.
        """
        for idx in self._hashes(item):
            byte_idx = idx // 8
            bit_idx = idx % 8
            if not (self.bit_array[byte_idx] & (1 << bit_idx)):
                return False
        return True


# Test: verify no false negatives
bf = BloomFilter(expected_items=1000, false_positive_rate=0.01)
for i in range(1000):
    bf.add(f"user_{i}")

# No false negatives guaranteed
for i in range(1000):
    assert f"user_{i}" in bf, f"False negative for user_{i}!"

# False positives are probabilistic (~1% for this configuration)
false_positives = 0
for i in range(1000, 2000):
    if f"user_{i}" in bf:
        false_positives += 1

fp_rate = false_positives / 1000
print(f"Observed false positive rate: {fp_rate:.3f} (expected ~0.01)")
assert fp_rate < 0.05, f"FP rate too high: {fp_rate}"
```

### Example 4: Exponential Search (for unbounded/infinite arrays)

```python
def exponential_search(arr: list[int], target: int) -> int:
    """
    Search in a sorted array of unknown/large size.
    First finds a range [2^(k-1), 2^k] containing the target,
    then binary searches within that range.
    
    Better than binary search when target is near the beginning
    of a very large array: O(log p) where p is the target position.
    
    Time: O(log p), Space: O(1)
    """
    if not arr:
        return -1
    if arr[0] == target:
        return 0
    
    # Find range [low, high] that contains target
    low, high = 0, 1
    while high < len(arr) and arr[high] < target:
        low = high
        high = min(high * 2, len(arr) - 1)
        if low == high:  # Reached end of array
            break
    
    # Binary search within [low, high]
    while low <= high:
        mid = low + (high - low) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    
    return -1


# Test: target near the beginning of a large array
arr = list(range(1000000))
assert exponential_search(arr, 3) == 3  # Found in O(log 3) = O(1) steps
# Binary search would take O(log 1000000) = 20 steps
assert exponential_search(arr, 999999) == 999999
assert exponential_search(arr, -1) == -1
```

## Best Practices

- **Use the standard library's binary search:** `bisect_left`/`bisect_right` in Python, `std::lower_bound`/`std::upper_bound` in C++, `sort.Search` in Go. They are correct, tested, and optimized.
- **Always use `mid = low + (high - low) // 2`.** Never `(low + high) // 2` -- overflow is a real security vulnerability.
- **Test boundary conditions exhaustively:** empty collection, single element, target at index 0, target at last index, target not present, target smaller than all, target larger than all.
- **For hash tables from untrusted input, use a cryptographically strong hash:** SipHash (default in Rust, available in Python as `hashlib`). Don't rely on `hash()` for security.
- **Choose the data structure based on access patterns, not theoretical complexity:** For n < 100, linear scan is often faster than binary search due to CPU cache and branch prediction.
- **When binary searching on answer space, prove monotonicity first.** A non-monotonic predicate invalidates the entire approach.
- **Document the preconditions prominently:** "REQUIRES: arr is sorted in ascending order." A violated precondition is the most common cause of silent wrong-answer bugs.

## Related Topics

- [[Sorting]] -- Sorting is the prerequisite for binary search; sorting algorithms maintain the sorted invariant
- [[DataStructures]] -- Hash tables, BSTs, B-trees, skip lists -- the structures that enable efficient search
- [[BigO]] -- Understanding why O(log n) search beats O(n) for large collections
- [[Algorithms]] -- Searching as a fundamental algorithmic pattern
- [[DynamicProgramming]] -- Binary search as an optimization in DP (e.g., LIS in O(n log n) with patience sorting)
- [[GraphTheory]] -- BFS and DFS as graph search strategies; Dijkstra as weighted graph search
- [[Performance]] -- Cache effects on search performance; SIMD linear scan
- [[Principles/Determinism]] -- Search algorithms must be deterministic for the same input
- [[Principles/FailFast]] -- Assert preconditions (sortedness) at the entry point
