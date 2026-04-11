---
title: Node.js
title_pt: Node.js
layer: programming
type: concept
priority: high
version: 1.0.0
tags:
  - Programming
  - JavaScript
  - Runtime
  - Backend
description: A JavaScript runtime built on Chrome's V8 engine, enabling server-side execution with non-blocking I/O.
description_pt: Um runtime JavaScript construído no motor V8 do Chrome, permitindo execução server-side com I/O não-bloqueante.
prerequisites:
  - JavaScript
  - AsyncIO
estimated_read_time: 10 min
difficulty: intermediate
---

# Node.js

## Description

[[NodeJS]] is a JavaScript runtime built on Chrome's V8 engine that enables server-side execution. It uses an event-driven, non-blocking I/O model that makes it efficient for I/O-intensive operations.

Key concepts:
- **Event Loop** — Single thread processing events asynchronously
- **V8 Engine** — Google's JavaScript engine (also used in Chrome)
- **npm** — Package ecosystem with millions of packages
- **Non-blocking** — I/O operations don't block the thread

## Purpose

**When Node.js is valuable:**
- Real-time applications (chat, live updates)
- I/O-heavy workloads (APIs, data streaming)
- Microservices with JSON-heavy payloads
- Single-page application backends
- CLI tools and build scripts

**When Node.js may NOT be appropriate:**
- CPU-intensive computations (video encoding, complex calculations)
- Heavy data processing that requires parallelism
- Applications requiring multithreading for performance
- Systems needing strong type safety at scale
- When team lacks JavaScript expertise

**The key question:** Does your workload benefit from non-blocking I/O, or is it CPU-bound?

## Event-Driven Architecture

```javascript
// Event-driven pattern
const EventEmitter = require('events');

class DataProcessor extends EventEmitter {
    process(data) {
        // Emit event for async handling
        this.emit('data', data);
    }
}

const processor = new DataProcessor();
processor.on('data', (data) => {
    console.log('Processing:', data);
});
processor.process({ id: 1, value: 'test' });
```

## Failure Modes

- **Event loop blocking** → CPU-intensive code blocks all requests → use worker threads or offload to separate service
- **Callback hell** → Nested callbacks create unreadable code → use async/await or Promises
- **Memory leaks** → Unreleased event listeners → remove listeners when done
- **Callback not called** → Promises never resolved/rejected → always handle timeouts
- **Uncaught exceptions** → Async errors crash process → use domain or process.on('uncaughtException')

## Anti-Patterns

### 1. Blocking the Event Loop

**Bad:** CPU-intensive work in main thread
```javascript
// Blocks event loop!
app.get('/heavy', (req, res) => {
    const result = heavyComputation();  // Blocks everything
    res.json(result);
});
```

**Good:** Offload to worker thread
```javascript
const { Worker } = require('worker_threads');

app.get('/heavy', async (req, res) => {
    const result = await runWorker(heavyData);
    res.json(result);
});

function runWorker(data) {
    return new Promise((resolve, reject) => {
        const worker = new Worker('./worker.js', { workerData: data });
        worker.on('message', resolve);
        worker.on('error', reject);
    });
}
```

### 2. Not Handling Errors

**Bad:** Unhandled promise rejection
```javascript
// Will crash!
app.get('/data', async (req, res) => {
    const data = await fetchExternal();
    res.json(data);  // If fetchExternal throws, unhandled!
});
```

**Good:** Always catch
```javascript
app.get('/data', async (req, res) => {
    try {
        const data = await fetchExternal();
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
```

### 3. Not Cleaning Up Resources

**Bad:** Event listeners accumulate
```javascript
// Memory leak!
function onEvent(data) {
    processEvent(data);
}
emitter.on('event', onEvent);
// Never removed!
```

**Good:** Clean up
```javascript
// Clean up when done
emitter.on('event', handler);
process.on('SIGTERM', () => emitter.removeAllListeners());
```

## Best Practices

### 1. Use Async/Await

```javascript
// Clean async code
async function fetchUser(id) {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) throw new Error('User not found');
    return response.json();
}

async function handler(req, res) {
    const user = await fetchUser(req.params.id);
    res.json(user);
}
```

### 2. Structure Project

```
my-app/
├── src/
│   ├── routes/      # HTTP handlers
│   ├── services/    # Business logic
│   ├── models/      # Data models
│   └── utils/       # Utilities
├── tests/
├── package.json
└── index.js
```

### 3. Environment Configuration

```javascript
const config = {
    port: process.env.PORT || 3000,
    env: process.env.NODE_ENV || 'development',
    db: {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
    }
};
```

## Technology Stack

| Tool | Use |
|------|-----|
| Express | Web framework |
| Fastify | High-performance framework |
| NestJS | Framework with DI |
| Koa | Minimal framework |
| TypeScript | Type safety |
| Prisma | ORM |

## Related Topics

- [[JavaScript]] — Language foundation
- [[TypeScript]] — Typed JavaScript
- [[APIDesign]] — Building APIs
- [[REST]] — RESTful APIs

## Key Takeaways

- Node.js uses non-blocking I/O for high concurrency
- Use for I/O-heavy workloads, not CPU-intensive tasks
- Use async/await for readable async code
- Handle errors in every async function
- Offload CPU work to worker threads
- Monitor event loop latency in production
