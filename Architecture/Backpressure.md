---
title: Backpressure
title_pt: Backpressure
layer: architecture
type: pattern
priority: high
version: 1.0.0
tags:
  - Architecture
  - Performance
  - DistributedSystems
  - Pattern
description: Flow control mechanism that allows a slow consumer to signal a fast producer to reduce its rate.
description_pt: Mecanismo de controle de fluxo que permite um consumidor lento sinalizar a um produtor rápido para reduzir sua taxa.
prerequisites:
  - Concurrency
  - Distributed Systems
  - Message Queues
estimated_read_time: 10 min
difficulty: advanced
---

# Backpressure

## Description

Backpressure is a flow control mechanism where a slow consumer signals a fast producer to slow down, preventing resource exhaustion. Instead of the producer pushing data as fast as possible (which overwhelms the consumer), the consumer controls the rate by signaling its capacity.

Key concepts:
- **Pull-based** — Consumer requests data when ready (natural backpressure)
- **Push-based with buffering** — Producer pushes, buffer absorbs spikes, then backpressure kicks in
- **Bounded queues** — Fixed-size buffer that blocks producer when full
- **Dropping** — Discarding data when consumer can't keep up (lossy but prevents crash)
- **Load shedding** — Intelligently rejecting low-priority requests under load

## Purpose

**When backpressure is essential:**
- Streaming data pipelines (producer faster than consumer)
- Real-time systems with variable load
- Reactive systems (Reactive Streams specification)
- Preventing cascading failures from queue overflow
- Memory-constrained environments (bounded buffers)

**When backpressure may not be needed:**
- Request/response patterns with natural flow control
- When producer is naturally slower than consumer
- Batch processing with controlled rates

**The key question:** What happens when the producer is 10x faster than the consumer?

## Patterns

### Bounded Queue (Blocking)

```python
import asyncio

async def producer(queue, items):
    for item in items:
        await queue.put(item)  # Blocks if queue is full
        print(f"Produced: {item}")

async def consumer(queue):
    while True:
        item = await queue.get()
        await asyncio.sleep(0.1)  # Slow processing
        print(f"Consumed: {item}")
        queue.task_done()

# Bounded queue creates natural backpressure
queue = asyncio.Queue(maxsize=10)  # Producer blocks at 10 items
```

### Reactive Streams (Async)

```python
# Reactive approach: consumer requests N items
class ReactiveConsumer:
    def __init__(self):
        self.demand = 0
    
    def request(self, n: int):
        self.demand += n
    
    async def receive(self, item):
        if self.demand > 0:
            self.demand -= 1
            await self.process(item)
        else:
            # Backpressure: buffer or reject
            await self.buffer(item)
```

### Load Shedding

```python
class LoadShedder:
    def __init__(self, max_concurrent: int = 100):
        self.active = 0
        self.max_concurrent = max_concurrent
    
    async def handle(self, request):
        if self.active >= self.max_concurrent:
            # Shed load: reject with 503
            return {"status": 503, "error": "overloaded"}
        
        self.active += 1
        try:
            return await self.process(request)
        finally:
            self.active -= 1
```

## Anti-Patterns

### 1. Unbounded Buffers

**Bad:** Queue grows indefinitely → memory exhaustion → OOM crash
**Solution:** Always use bounded queues with backpressure

### 2. Silent Dropping

**Bad:** Dropping data without logging → data loss goes unnoticed
**Solution:** Log dropped items, emit metrics, alert on drop rate

### 3. No Backpressure in Streams

**Bad:** Streaming pipeline has no flow control → slow consumer crashes
**Solution:** Use Reactive Streams or bounded channels

### 4. Backpressure Propagation Failure

**Bad:** One component applies backpressure, next doesn't → bottleneck moves downstream
**Solution:** Backpressure must propagate through entire pipeline

## Failure Modes

- **No backpressure** → buffer fills → OOM → crash → data loss
- **Backpressure too aggressive** → producer stalls → throughput drops unnecessarily
- **Deadlock** — circular backpressure: A waits for B, B waits for A
- **Backpressure ignored** — producer doesn't respect signals → same as no backpressure

## Related Topics

- [[MessageQueues]] — Queue depth as backpressure signal
- [[RateLimiting]] — Proactive rate control vs reactive backpressure
- [[Concurrency]] — Bounded channels for async backpressure
- [[DistributedSystems]] — Backpressure across service boundaries
- [[PerformanceOptimization]] — Preventing resource exhaustion
- [[CircuitBreaker]] — Complementary: circuit breaker stops, backpressure slows
- [[LoadTesting]] — Testing backpressure behavior under load

## Key Takeaways

- Backpressure is a flow control mechanism where a slow consumer signals a fast producer to reduce its rate, preventing resource exhaustion.
- Use for streaming data pipelines where producers outpace consumers, real-time systems with variable load, or memory-constrained environments.
- Do NOT use for request/response patterns with natural flow control, when producers are naturally slower than consumers, or controlled batch processing.
- Key tradeoff: preventing crashes from buffer overflow vs. reduced throughput when backpressure signals propagate upstream.
- Main failure mode: unbounded buffers growing indefinitely until OOM crash, or backpressure propagation failing at one component causing downstream bottlenecks.
- Best practice: always use bounded queues, propagate backpressure through the entire pipeline, log dropped items with metrics, and combine with load shedding.
- Related concepts: Reactive Streams, Message Queues, Rate Limiting, Circuit Breaker, Bounded Channels, Load Shedding, Concurrency.
