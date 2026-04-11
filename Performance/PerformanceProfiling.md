---
title: Performance Profiling
title_pt: Profiling de Performance
layer: performance
type: practice
priority: high
version: 1.0.0
tags:
  - Performance
  - Profiling
  - Optimization
  - Practice
description: Techniques for identifying performance bottlenecks.
description_pt: Técnicas para identificar gargalos de desempenho.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Performance Profiling

## Description

Performance profiling is the process of measuring and analyzing application performance to identify bottlenecks and optimization opportunities. It involves collecting data about execution time, memory usage, and resource consumption to understand where the application spends its time.

Key profiling types:
- **CPU profiling** - Time spent in functions/methods
- **Memory profiling** - Memory allocation and usage
- **I/O profiling** - Disk and network operations
- **Concurrency profiling** - Thread and async behavior

Profiling is essential for:
- Finding hot spots (most time-consuming code)
- Identifying memory leaks
- Understanding call patterns
- Making optimization decisions

Unlike benchmarking (measuring overall performance), profiling pinpoints specific areas needing attention.

## Purpose

**When to profile:**
- When application is slow
- Before optimization (know where to focus)
- After optimization (verify improvement)
- During performance testing

**What to profile:**
- CPU-intensive operations
- Memory allocations
- Database queries
- External API calls

## Rules

1. **Profile in production-like environment** - Dev may differ
2. **Profile realistic workloads** - Use production data
3. **Focus on hot spots** - 80% of time in 20% of code
4. **Iterate** - Profile, optimize, profile again
5. **Measure after changes** - Verify improvements

## Examples

### Python Profiling

```python
# Using cProfile
import cProfile
import pstats
import io

def profile_function(func):
    def wrapper(*args, **kwargs):
        profiler = cProfile.Profile()
        profiler.enable()
        
        result = func(*args, **kwargs)
        
        profiler.disable()
        
        # Print results
        stream = io.StringIO()
        stats = pstats.Stats(profiler, stream=stream)
        stats.sort_stats('cumulative')
        stats.print_stats(20)  # Top 20
        
        print(stream.getvalue())
        
        return result
    return wrapper

@profile_function
def run_heavy_calculation():
    # Your code here
    pass

# Using line_profiler for line-by-line
# pip install line_profiler
# Add @profile decorator and run: kernprof -l script.py

# Using py-spy for production profiling
# py-spy record -o profile.svg -- python app.py
# py-spy top -- python app.py
```

### Node.js Profiling

```javascript
// Built-in profiler
node --prof app.js

// Analyze log
node --prof-process isolate-*.log > processed.txt

// Clinic.js for visual profiling
// npm install -g clinic
// clinic doctor -- node app.js
// clinic flame -- node app.js
// clinic bubbleprof -- node app.js

// 0x for flame graphs
// npx 0x app.js

// Quick profile in code
const { performance } = require('perf_hooks');

function measure(name, fn) {
    const start = performance.now();
    const result = fn();
    const duration = performance.now() - start;
    console.log(`${name}: ${duration.toFixed(2)}ms`);
    return result;
}

measure('heavy operation', () => {
    // Code to measure
});
```

### Memory Profiling

```python
# Python memory profiler
# pip install memory_profiler

from memory_profiler import profile

@profile
def process_data():
    data = load_data()  # ~100MB
    result = transform(data)
    save(result)
    return result

# Run with: python -m memory_profiler app.py

# tracemalloc for targeted analysis
import tracemalloc

tracemalloc.start()

# Your code
result = process_large_data()

current, peak = tracemalloc.get_traced_memory()
print(f"Current: {current / 1024 / 1024:.1f} MB")
print(f"Peak: {peak / 1024 / 1024:.1f} MB")

tracemalloc.stop()

# Object-level tracking
snapshot1 = tracemalloc.take_snapshot()
# ... run code ...
snapshot2 = tracemalloc.take_snapshot()

top_stats = snapshot2.compare_to(snapshot1, 'lineno')
for stat in top_stats[:10]:
    print(stat)
```

### Flame Graph Generation

```python
# Generate flame graph
# Install py-spy: pip install py-spy

# Record profile
# py-spy record -o profile.svg -- python app.py

# Or for faster sampling
# py-spy record -d 30 -o profile.svg -- python app.py

# View in browser - interactive SVG
# Red = Python, Orange = C extension
```

### Database Query Profiling

```python
# Django query profiling
from django.db import connection
from django.test.utils import override_settings

# Enable query logging
import logging
logging.basicConfig()
logging.getLogger('django.db.backends').setLevel.DEBUG)

# Manual query count
from django.db import connection
from django.conf import settings

def get_query_count():
    original = settings.DEBUG
    settings.DEBUG = True
    connection.queries_log.clear()
    
    # Run your code
    result = my_view(request)
    
    queries = connection.queries
    print(f"Queries: {len(queries)}")
    for q in queries:
        print(f"{q['time']}: {q['sql']}")
    
    settings.DEBUG = original
    return result

# Using django-silk
# pip install django-silk
# Provides profiling UI
```

## Anti-Patterns

### 1. Premature Optimization

```python
# BAD - Optimizing without profiling
# "This might be slow, let me optimize it"
# 80% of time in 20% of code - optimize wrong place!

# GOOD - Profile first
# Then optimize where it matters
```

### 2. Not Using Production Data

```python
# BAD - Profiling with tiny test data
data = [1, 2, 3]  # Too small to show real issues

# GOOD - Use production-like data
data = load_production_data()  # Real size
```

## Failure Modes

- **Profiling in dev environment** → results don't match production → optimization targets wrong issues → profile in production-like environments with realistic data
- **Tiny test data** → bottlenecks don't manifest → missed hot spots → use production-scale data volumes during profiling
- **Sampling overhead distortion** → profiler slows application → skewed results → use low-overhead profilers for production profiling
- **Single-run profiling** → results dominated by noise → misleading hot spots → average multiple profiling runs for statistical significance
- **Ignoring I/O wait** → only profiling CPU → missing network/disk bottlenecks → profile all resource types including I/O and memory
- **Not establishing baseline** → cannot measure improvement → optimization effectiveness unknown → record metrics before making changes
- **Production profiling impact** → profiler degrades user experience → performance regression → use async profilers with minimal sampling rates

## Best Practices

### Profiling Workflow

```
1. Establish baseline
   - Run performance tests
   - Record metrics

2. Profile under load
   - Use realistic workload
   - Capture profile

3. Analyze results
   - Focus on hot spots
   - Identify patterns

4. Optimize
   - Fix biggest issues first
   - Change one thing at a time

5. Verify
   - Re-profile
   - Compare to baseline
```

### Profiling in Production

```python
# Low-overhead continuous profiling
# Use async profiler
# py-spy can profile without stopping
# Continuous profiling services: 
# - Datadog
# - New Relic
# - Lightstep
```

## Technology Stack

| Tool | Language | Use Case |
|------|-----------|----------|
| cProfile | Python | CPU profiling |
| py-spy | Python | Production profiling |
| clinic | Node.js | Visual profiling |
| Chrome DevTools | JS | Browser profiling |
| async-profiler | Java | Production profiling |

## Related Topics

- [[PerformanceOptimization]]
- [[DatabaseOptimization]]
- [[Monitoring]]
- [[Logging]]
- [[LoadTesting]]
- [[Algorithms]]
- [[Complexity]]
- [[Caching]]

## Additional Notes

**Key Metrics:**
- Execution time
- Memory allocation
- Function call count
- I/O wait time

**Profiling Types:**
- Sampling (lower overhead)
- Instrumentation (more accurate)

**Flame Graphs:**
- Horizontal = function name
- Width = time spent
- Stack = call hierarchy