---
title: Concurrency
title_pt: Concorrência
layer: programming
type: concept
priority: high
version: 1.0.0
tags:
  - Programming
  - Concurrency
  - Async
  - Threading
  - Parallelism
description: Handling multiple tasks simultaneously, including async/await, threading, and race condition prevention.
description_pt: Tratamento simultâneo de múltiplas tarefas, incluindo async/await, threading e prevenção de race conditions.
prerequisites:
  - Programming
estimated_read_time: 18 min
difficulty: advanced
---

# Concurrency

## Description

[[Concurrency]] is the ability to handle multiple tasks simultaneously, making progress on one task while waiting for another. It differs from parallelism (actually executing tasks simultaneously on multiple cores) - concurrency is about structure, parallelism is about execution.

Key concepts:
- **Async/await** - Non-blocking code that yields while waiting
- **Threading** - Parallel execution on multiple threads
- **Coroutines** - Lightweight cooperative multitasking
- **Thread pools** - Reusing threads for efficiency
- **Synchronization** - Coordinating access to shared resources

## Purpose

**When concurrency is essential:**
- I/O-bound operations (network, disk, database)
- Building responsive UIs
- Handling many simultaneous users
- Real-time systems
- Data pipelines

**When concurrency adds complexity:**
- CPU-bound computations (use parallelism instead)
- Simple sequential tasks
- When simplicity is priority

**The key question:** Does this task involve waiting that could be used for other work?

## Rules

1. **Prefer async over threads for I/O** - Lower overhead
2. **Avoid shared mutable state** - Use immutable data or synchronization
3. **Always handle race conditions** - Use locks, atomics, or actor model
4. **Don't block async with sync** - Use async throughout
5. **Use connection pools** - Don't create connections per request

## Examples

### Async/Await Pattern

```python
import asyncio
import aiohttp

async def fetch_data(session, url):
    async with session.get(url) as response:
        return await response.json()

async def main():
    async with aiohttp.ClientSession() as session:
        # Concurrent requests
        tasks = [
            fetch_data(session, 'https://api.example.com/users'),
            fetch_data(session, 'https://api.example.com/orders'),
            fetch_data(session, 'https://api.example.com/products'),
        ]
        results = await asyncio.gather(*tasks)
        return results

# Run
users, orders, products = asyncio.run(main())
```

### Thread Pool for CPU-Bound

```python
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import numpy as np

def process_chunk(data):
    # CPU-intensive computation
    return np.fft.fft(data)

def parallel_process(data, num_workers=4):
    chunks = np.array_split(data, num_workers)
    
    # Thread pool for I/O-bound, Process for CPU-bound
    with ProcessPoolExecutor(max_workers=num_workers) as executor:
        results = list(executor.map(process_chunk, chunks))
    
    return np.concatenate(results)
```

### Actor Model (Akka-style pattern in Python)

```python
from dataclasses import dataclass
from typing import Dict, Any
import asyncio

@dataclass
class Message:
    sender: str
    payload: Any

class Actor:
    def __init__(self, name: str):
        self.name = name
        self.mailbox: asyncio.Queue = asyncio.Queue()
        self.children: Dict[str, 'Actor'] = {}
    
    async def receive(self, message: Message):
        """Override in subclasses"""
        pass
    
    async def run(self):
        while True:
            message = await self.mailbox.get()
            if message is None:  # Poison pill
                break
            await self.receive(message)
    
    def tell(self, message: Message):
        self.mailbox.put_nowait(message)

class UserActor(Actor):
    async def receive(self, message: Message):
        if message.payload.get('type') == 'create_order':
            order_id = message.payload['order_id']
            print(f"UserActor creating order: {order_id}")
            # Create order through child actor
            # self.children['orders'].tell(Message(...))

# Usage
async def main():
    user_actor = UserActor("user-service")
    task = asyncio.create_task(user_actor.run())
    
    user_actor.tell(Message(sender="api", payload={'type': 'create_order', 'order_id': '123'}))
    
    await asyncio.sleep(0.1)
    user_actor.tell(None)  # Stop
    await task

asyncio.run(main())
```

### Avoiding Race Conditions with Lock

```python
import asyncio
from collections import Counter

class SafeCounter:
    def __init__(self):
        self._counter = Counter()
        self._lock = asyncio.Lock()
    
    async def increment(self, key: str):
        async with self._lock:
            self._counter[key] += 1
            return self._counter[key]
    
    async def get(self, key: str) -> int:
        async with self._lock:
            return self._counter[key]

# Usage
counter = SafeCounter()

async def worker(worker_id):
    for i in range(100):
        await counter.increment(f"worker-{worker_id}")

async def main():
    tasks = [worker(i) for i in range(10)]
    await asyncio.gather(*tasks)
    
    # Should be exactly 1000
    total = sum(await counter.get(f"worker-{i}") for i in range(10))
    print(f"Total: {total}")

asyncio.run(main())
```

### Semaphore for Rate Limiting

```python
import asyncio

async def limited_request(semaphore, url):
    async with semaphore:
        # Only 5 concurrent requests
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                return await response.text()

async def main():
    semaphore = asyncio.Semaphore(5)  # Max 5 concurrent
    
    urls = [f'https://api.example.com/item/{i}' for i in range(100)]
    tasks = [limited_request(semaphore, url) for url in urls]
    
    results = await asyncio.gather(*tasks)
    return results
```

### Producer-Consumer Pattern

```python
import asyncio
from dataclasses import dataclass

@dataclass
class Task:
    id: int
    data: str

async def producer(queue: asyncio.Queue, num_tasks: int):
    for i in range(num_tasks):
        task = Task(id=i, data=f"task-{i}")
        await queue.put(task)
        await asyncio.sleep(0.1)  # Simulate production rate

async def consumer(queue: asyncio.Queue, name: str):
    while True:
        task = await queue.get()
        if task is None:  # Poison pill
            break
        print(f"{name} processing {task.id}")
        await asyncio.sleep(0.2)  # Simulate processing
        queue.task_done()

async def main():
    queue = asyncio.Queue(maxsize=10)
    
    # Start producers and consumers
    producers = [asyncio.create_task(producer(queue, 20))]
    consumers = [asyncio.create_task(consumer(queue, f"worker-{i}")) for i in range(3)]
    
    # Wait for producers
    await asyncio.gather(*producers)
    
    # Send poison pills
    for _ in range(3):
        await queue.put(None)
    
    # Wait for consumers
    await asyncio.gather(*consumers)

asyncio.run(main())
```

## Anti-Patterns

### 1. Blocking Call in Async Code

```python
# BAD - Blocks the event loop
async def fetch_data():
    requests.get('https://api.example.com')  # Blocks!

# GOOD - Use async library
async def fetch_data():
    async with aiohttp.ClientSession() as session:
        await session.get('https://api.example.com')
```

### 2. Shared Mutable State Without Synchronization

```python
# BAD - Race condition
counter = 0

async def increment():
    global counter
    await asyncio.sleep(0.01)  # Context switch
    counter += 1  # Race!

# GOOD - Use lock or atomic
counter = 0
lock = asyncio.Lock()

async def safe_increment():
    global counter
    async with lock:
        counter += 1
```

### 3. Creating Threads per Request

```python
# BAD - High overhead
def handle_request(request):
    thread = Thread(target=process, args=(request,))
    thread.start()

# GOOD - Use thread pool
with ThreadPoolExecutor(max_workers=100) as executor:
    executor.submit(process, request)
```

### 4. Not Handling Exceptions in Concurrent Code

```python
# BAD - Exceptions lost
async def risky_task():
    if random.random() < 0.5:
        raise ValueError("Oops!")
    return "success"

async def main():
    results = await asyncio.gather(*[risky_task() for _ in range(10)])
    # If any fail, all fail silently!

# GOOD - Handle exceptions
async def main():
    results = await asyncio.gather(
        *[risky_task() for _ in range(10)],
        return_exceptions=True
    )
    for r in results:
        if isinstance(r, Exception):
            print(f"Task failed: {r}")
```

## Best Practices

### 1. Choose Right Tool

```
I/O-bound (network, DB, file) → Async/await
CPU-bound (computation) → Process pool
Simple background tasks → Thread pool
Complex stateful → Actor model
```

### 2. Timeouts Everywhere

```python
async def fetch_with_timeout():
    try:
        async with asyncio.timeout(5):  # 5 second timeout
            return await slow_operation()
    except asyncio.TimeoutError:
        return None  # Handle timeout
```

### 3. Graceful Shutdown

```python
async def server():
    running = True
    
    async def shutdown():
        running = False
        # Cancel ongoing tasks
        for task in asyncio.all_tasks():
            if task != asyncio.current_task():
                task.cancel()
    
    # Run until shutdown signal
    while running:
        await asyncio.sleep(0.1)
    
    # Wait for cleanup
    await asyncio.sleep(0.5)
```

### 4. Structured Concurrency (Python 3.11+)

```python
async def parent():
    async with asyncio.TaskGroup() as tg:
        tg.create_task(child_task1())
        tg.create_task(child_task2())
    # All tasks cancelled if any fails
```

## Failure Modes

- **Shared mutable state without synchronization** → multiple threads access same data without locks → race conditions and data corruption → use locks, atomics, or actor model for shared state access
- **Blocking async code with sync calls** → synchronous I/O in async context → event loop blocked and all tasks stalled → use async libraries throughout and run sync code in thread pool
- **Deadlocks from lock ordering** → two threads acquire locks in different order → both threads wait forever → establish consistent lock ordering and use lock-free data structures when possible
- **Creating threads per request** → new thread for each incoming request → thread exhaustion and memory overhead → use thread pools or async I/O for handling concurrent requests
- **Not handling exceptions in concurrent code** → exceptions in async tasks silently lost → failures go unnoticed → use return_exceptions in gather and implement proper error propagation
- **Missing timeouts on blocking operations** → network or disk operations without timeout → threads hang indefinitely → set timeouts on all I/O operations and handle timeout exceptions gracefully
- **Starvation from unfair scheduling** → some tasks never get CPU time → request timeouts and poor user experience → use fair scheduling, priority queues, and monitor task wait times

## Related Topics

- [[DistributedSystems]] — Concurrency across network boundaries
- [[PerformanceOptimization]] — Concurrency for throughput
- [[Idempotency]] — Making concurrent operations safe
- [[RateLimiting]] — Controlling concurrent request rates
- [[Swift]] — Swift async/await
- [[Kotlin]] — Kotlin coroutines
- [[TypeScript]] — TypeScript async/await patterns
- [[JavaScript]] — JavaScript event loop
- [[Caching]] — Thread-safe caching
- [[Microservices]] — Concurrent service communication
- [[DistributedTransactions]] — Concurrent data consistency
- [[ConnectionPooling]] — Thread-safe resource pooling

## Additional Notes

**Languages with Good Concurrency:**
- Go: Goroutines + channels
- Rust: Async + tokio
- Python: Async + asyncio
- Kotlin: Coroutines
- Elixir: Actor model (BEAM)

**Common Concurrency Models:**
- Threads (shared memory)
- Actors (isolated state)
- CSP (channel-based)
- STM (software transactional memory)

## Key Takeaways

- Concurrency is the ability to make progress on multiple tasks simultaneously, distinct from parallelism which is about actual simultaneous execution.
- Use for I/O-bound operations (network, disk, database), responsive UIs, handling many simultaneous users, and real-time systems.
- Do NOT use for CPU-bound computations (use parallelism instead), simple sequential tasks, or when simplicity is the top priority.
- Key tradeoff: improved throughput and responsiveness vs. increased complexity from race conditions, deadlocks, and debugging difficulty.
- Main failure mode: shared mutable state without synchronization leading to race conditions, or blocking async code with sync calls.
- Best practice: prefer async/await for I/O-bound work, avoid shared mutable state, use timeouts everywhere, and apply structured concurrency.
- Related concepts: Async/Await, Actor Model, Thread Pools, Semaphores, Race Conditions, Deadlocks, Parallelism, Event Loops.