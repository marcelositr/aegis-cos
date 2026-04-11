---
title: Data Structures
title_pt: Estruturas de Dados
layer: foundations
type: concept
priority: high
version: 1.0.0
tags:
  - Foundations
  - DataStructures
description: Ways of organizing and storing data for efficient access and modification.
description_pt: Formas de organizar e armazenar dados para acesso e modificação eficientes.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Data Structures

## Description

A data structure is a particular way of organizing and storing data so that it can be accessed and modified efficiently. The choice of data structure can dramatically affect algorithm performance.

Categories:
- **Linear**: Arrays, Linked Lists, Stacks, Queues
- **Hierarchical**: Trees, Heaps
- **Hash-based**: Hash Tables, Sets
- **Graph**: Adjacency list/matrix
- **String**: Tries, Suffix arrays

Understanding data structures helps you:
- Choose the right tool for the job
- Understand system behavior
- Optimize performance
- Solve problems elegantly

## Purpose

**When data structure selection is critical:**
- When performance matters
- When working with large datasets
- When implementing specific algorithms
- For optimizing memory usage

**When simple structures suffice:**
- For small datasets
- When readability is priority
- For one-time operations

**The key question:** What operations will be performed most frequently?

## Examples

### Arrays

```python
# Static array (fixed size)
import array

numbers = array.array('i', [1, 2, 3, 4, 5])
# Access: O(1)
# Search: O(n)
# Insert/Delete: O(n)

# Dynamic array (list in Python)
dynamic = [1, 2, 3]
dynamic.append(4)  # Amortized O(1)
dynamic.insert(0, 0)  # O(n)
```

### Linked List

```python
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class LinkedList:
    def __init__(self):
        self.head = None
    
    def append(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
            return
        current = self.head
        while current.next:
            current = current.next
        current.next = new_node
    
    def delete(self, data):
        if not self.head:
            return
        if self.head.data == data:
            self.head = self.head.next
            return
        current = self.head
        while current.next:
            if current.next.data == data:
                current.next = current.next.next
                return
            current = current.next

# Operations:
# Insert at head: O(1)
# Insert at tail: O(1) with tail pointer
# Search: O(n)
# Delete: O(1) with pointer
```

### Hash Table

```python
# Python dict (hash table)
user_info = {
    "name": "John",
    "email": "john@example.com",
    "age": 30
}

# Access: O(1) average
# Insert: O(1) average
# Search: O(1) average

# Custom hash table
class HashTable:
    def __init__(self, size=100):
        self.size = size
        self.table = [[] for _ in range(size)]
    
    def _hash(self, key):
        return hash(key) % self.size
    
    def put(self, key, value):
        index = self._hash(key)
        for i, (k, v) in enumerate(self.table[index]):
            if k == key:
                self.table[index][i] = (key, value)
                return
        self.table[index].append((key, value))
    
    def get(self, key, default=None):
        index = self._hash(key)
        for k, v in self.table[index]:
            if k == key:
                return v
        return default
```

### Stack and Queue

```python
# Stack (LIFO)
stack = []
stack.append(1)  # push
stack.append(2)
stack.append(3)
stack.pop()  # 3
stack.pop()  # 2

# Queue (FIFO)
from collections import deque
queue = deque([1, 2, 3])
queue.append(4)  # enqueue
queue.popleft()  # 1
queue.popleft()  # 2

# Priority Queue
import heapq

heap = []
heapq.heappush(heap, (3, "task3"))
heapq.heappush(heap, (1, "task1"))
heapq.heappush(heap, (2, "task2"))

# Lowest priority first
heapq.heappop(heap)  # (1, "task1")
```

### Binary Tree

```python
class TreeNode:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None

class BinaryTree:
    def __init__(self):
        self.root = None
    
    def insert(self, value):
        if not self.root:
            self.root = TreeNode(value)
            return
        
        queue = [self.root]
        while queue:
            node = queue.pop(0)
            
            if not node.left:
                node.left = TreeNode(value)
                return
            else:
                queue.append(node.left)
            
            if not node.right:
                node.right = TreeNode(value)
                return
            else:
                queue.append(node.right)
    
    def inorder_traversal(self, node, result=None):
        if result is None:
            result = []
        if node:
            self.inorder_traversal(node.left, result)
            result.append(node.value)
            self.inorder_traversal(node.right, result)
        return result
```

## Anti-Patterns

### 1. Wrong Data Structure

**Bad:**
- Using list for frequent lookups by key
- Using array for frequent insertions at beginning
- Not considering access patterns

**Solution:**
- Analyze access patterns
- Choose appropriate structure

### 2. Unnecessary Complexity

**Bad:**
- Implementing custom data structure when built-in suffices
- Over-engineering simple problems

**Solution:**
- Use built-in when adequate
- Don't reinvent wheel

### 3. Ignoring Memory

**Bad:**
- Creating many small objects
- Not releasing references
- Memory leaks

**Solution:**
- Consider memory usage
- Use appropriate data types

## Best Practices

### Choosing Data Structure

| Operation Needed | Use |
|-----------------|-----|
| Fast lookup by key | Hash Table |
| Ordered traversal | Tree |
| FIFO | Queue |
| LIFO | Stack |
| Frequent search | Binary Search Tree |
| Set operations | Set |
| Unique elements | Set |

### Know Built-ins

```python
# Python collections
from collections import defaultdict, Counter, OrderedDict
from collections import deque, namedtuple

# Use appropriate one
counts = defaultdict(int)  # Auto-initialize
word_count = Counter(text.split())  # Count occurrences
```

## Anti-Patterns

### 1. Wrong Structure for Access Pattern

**Bad:** Using list for frequent lookups → O(n) per lookup → use hash table for O(1)
**Solution:** Match data structure to most frequent operation

### 2. Reinventing Built-ins

**Bad:** Writing custom hash table when language has dict → bugs, slower → use built-in
**Solution:** Know your language's standard library

## Failure Modes

- **Array for frequent inserts/deletes** → O(n) per operation → use linked list or tree
- **Hash table with bad hash function** → collisions → O(n) lookups → use good hash
- **Tree without balancing** → degenerate to linked list → O(n) search → use balanced trees
- **Ignoring memory overhead** → hash table uses 2x memory → OOM on large datasets → measure memory
- **Mutable key in hash table** → key changes → lookup fails → use immutable keys
- **Not considering concurrency** → shared data structure without locks → race conditions → use thread-safe structures

## Decision Framework

```
Need fast lookup by key? → Hash Table / Dictionary
Need ordered iteration? → Tree / Sorted List
Need FIFO ordering? → Queue / Deque
Need LIFO ordering? → Stack
Need uniqueness? → Set
Need prefix matching? → Trie
Need range queries? → B-Tree
Need graph traversal? → Adjacency List
```

## Related Topics

- [[Algorithms]]
- [[Complexity]]
- [[Modularity]]
- [[Caching]]
- [[SQL]]
- [[NoSQL]]
- [[DatabaseOptimization]]
- [[PerformanceOptimization]]

## Key Takeaways

- Data structures organize and store data for efficient access and modification; the choice dramatically affects algorithm performance
- Critical when performance matters, working with large datasets, or implementing specific algorithms; simple structures suffice for small datasets
- Tradeoff: optimal operation performance versus memory overhead and implementation complexity
- Main failure mode: using wrong structure for access pattern (e.g., list for frequent key lookups) causes O(n) where O(1) is possible
- Best practice: match data structure to most frequent operations, use built-in collections before custom implementations, consider memory overhead, and use immutable keys in hash tables
- Related: algorithms, complexity, caching, SQL, NoSQL, database optimization

## Additional Notes
