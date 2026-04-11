---
title: MemoryManagement
title_pt: Gerenciamento de Memória
layer: performance
type: concept
priority: high
version: 1.0.0
tags:
  - Performance
  - Memory
  - Profiling
description: Managing memory allocation and preventing memory issues.
description_pt: Gerenciando alocação de memória e prevenindo problemas de memória.
prerequisites:
  - PerformanceProfiling
  - Concurrency
estimated_read_time: 10 min
difficulty: intermediate
---

# Memory Management

## Description

[[MemoryManagement]] involves understanding how your application allocates, uses, and releases memory. Poor memory management leads to performance degradation, memory leaks, and crashes.

Key concepts:
- **Allocation** — Requesting memory from the system
- **Garbage Collection** — Automatic memory reclamation
- **Memory Leaks** — Memory not released when no longer needed
- **GC Pressure** — Excessive garbage collection overhead

## Purpose

**When memory management matters:**
- Long-running applications
- High-throughput services
- Applications processing large datasets
- Containers with memory limits

**When simpler approaches work:**
- Short-lived scripts
- Applications with low memory usage
- Development/debugging only

**The key question:** Can your application run indefinitely without memory issues?

## Memory Issues

### Memory Leaks

```python
# Bad: Accumulating references
class DataProcessor:
    def __init__(self):
        self.cache = []  # Never cleared!
    
    def process(self, data):
        self.cache.append(data)  # Grows forever
        return self.transform(data)

# Good: Bounded cache
class DataProcessor:
    def __init__(self, max_size=1000):
        self.cache = deque(maxlen=max_size)  # Evicts old
    
    def process(self, data):
        self.cache.append(data)
        return self.transform(data)
```

### Memory Spikes

```python
# Bad: Loading everything into memory
def process_large_file(filename):
    with open(filename) as f:
        data = f.read()  # Entire file in memory!
    return process(data)

# Good: Stream processing
def process_large_file(filename):
    with open(filename) as f:
        for line in f:  # One line at a time
            yield process(line)
```

## Failure Modes

- **Memory leak** → Unreleased memory → eventual OOM crash → profile and fix leaks
- **Excessive GC** → GC pauses → latency spikes → reduce allocations
- **Memory fragmentation** → Unable to allocate despite available memory → use memory pooling
- **Out of memory** → No memory available → application crashes → set memory limits and monitor
- **Memory overcommit** → Promised more memory than available → system instability → configure limits

## Anti-Patterns

### 1. Unbounded Collections

**Bad:** List grows forever
```python
# Keeps all results
results = []
for item in items:
    results.append(expensive_operation(item))
```

**Good:** Streaming or batching
```python
# Process in chunks
for chunk in chunked(items, 1000):
    process_chunk(chunk)
```

### 2. Not Closing Resources

**Bad:** Leaking file handles and connections
```python
# Forgot to close
file = open("data.txt")
data = file.read()
# file stays open!
```

**Good:** Use context managers
```python
# Automatic cleanup
with open("data.txt") as file:
    data = file.read()
```

### 3. Large Object Graphs

**Bad:** Deep object hierarchies
```python
# Complex graph prevents GC
class Node:
    children = []  # References other nodes
    parent = None  # Back-reference creates cycle
```

**Good:** Weak references where appropriate
```python
import weakref

# Allows GC to collect
class Node:
    children = []
    parent = weakref.ref(None)  # Weak reference
```

## Best Practices

### 1. Monitor Memory Usage

```python
import tracemalloc
import gc

# Track memory allocation
tracemalloc.start()

# Your code
process_data()

# Report
current, peak = tracemalloc.get_traced_memory()
print(f"Current: {current / 1024 / 1024:.1f} MB")
print(f"Peak: {peak / 1024 / 1024:.1f} MB")
tracemalloc.stop()

# Force garbage collection
gc.collect()
```

### 2. Use Memory Profiling

```python
# Use memory_profiler
@profile
def my_function():
    # Memory-intensive operations
    pass

# Run: python -m memory_profiler script.py
```

### 3. Set Container Limits

```yaml
# Kubernetes memory limits
resources:
  limits:
    memory: "512Mi"
  requests:
    memory: "256Mi"
```

## Related Topics

- [[PerformanceProfiling]] — Finding memory issues
- [[PerformanceOptimization]] — Overall performance
- [[GarbageCollection]] — Automatic memory management
- [[MemoryLeaks]] — Common leak patterns

## Key Takeaways

- Monitor memory usage in production with metrics and alerts
- Use bounded collections and streaming for large data
- Always close resources with context managers
- Profile memory to identify leaks and pressure points
- Set appropriate memory limits in containers
- Understand your language's garbage collection behavior