---
title: Real-Time Architecture
title_pt: Arquitetura em Tempo Real
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - Real-Time
  - WebSockets
  - Event-Driven
  - Streaming
description: Architecture patterns for real-time applications, streaming, and event-driven systems.
description_pt: Padrões de arquitetura para aplicações em tempo real, streaming e sistemas orientados a eventos.
prerequisites:
  - Architecture
  - Network
estimated_read_time: 12 min
difficulty: advanced
---

# Real-Time Architecture

## Description

Real-time architecture refers to systems that process and deliver data with minimal latency, enabling immediate or near-immediate feedback between components. Unlike traditional request-response patterns, real-time architectures establish persistent connections that allow data to flow continuously in either direction.

Real-time systems are characterized by:
- **Low Latency** - Sub-second data delivery (often milliseconds)
- **Persistent Connections** - Long-lived connections between client and server
- **Bidirectional Communication** - Both client and server can initiate data transfer
- **Event-Driven** - System reacts to events rather than polling

Common use cases include:
- Financial trading platforms requiring real-time price updates
- Collaborative editing tools where multiple users work simultaneously
- Live dashboards for monitoring system metrics
- Chat applications and notifications
- IoT device streaming data to central systems

## Purpose

**When real-time architecture is needed:**
- Live updates (stock prices, sports scores)
- Collaborative applications (document editing)
- Monitoring and alerting systems
- IoT data streaming
- Gaming and interactive applications

**Alternatives to consider:**
- Polling for less frequent updates
- Server-Sent Events (SSE) for server-to-client only
- Webhooks for event notifications

## Rules

1. **Choose appropriate protocol** - WebSockets, SSE, or polling based on use case
2. **Handle connection failures** - Implement reconnection logic
3. **Scale horizontally** - Use message brokers for fan-out
4. **Manage state carefully** - Avoid memory leaks in long-lived connections
5. **Monitor latency** - Track real-time performance metrics

## Examples

### WebSocket Server (Python)

```python
import asyncio
import websockets
import json
from datetime import datetime
from typing import Set
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RealTimeServer:
    def __init__(self):
        self.clients: Set[websockets.WebSocketServerProtocol] = set()
        self.subscriptions: dict = {}  # client_id -> set of channels
    
    async def register(self, websocket: websockets.WebSocketServerProtocol):
        self.clients.add(websocket)
        logger.info(f"Client connected: {websocket.remote_address}")
    
    async def unregister(self, websocket: websockets.WebSocketServerProtocol):
        self.clients.remove(websocket)
        if websocket.remote_address in self.subscriptions:
            del self.subscriptions[websocket.remote_address]
        logger.info(f"Client disconnected: {websocket.remote_address}")
    
    async def handle_message(self, websocket: websockets.WebSocketServerProtocol, message: str):
        try:
            data = json.loads(message)
            
            if data['type'] == 'subscribe':
                channel = data['channel']
                client_id = websocket.remote_address
                if client_id not in self.subscriptions:
                    self.subscriptions[client_id] = set()
                self.subscriptions[client_id].add(channel)
                await self.send(websocket, {'type': 'subscribed', 'channel': channel})
                
            elif data['type'] == 'unsubscribe':
                channel = data['channel']
                client_id = websocket.remote_address
                if client_id in self.subscriptions:
                    self.subscriptions[client_id].discard(channel)
                    
            elif data['type'] == 'broadcast':
                await self.broadcast(data['channel'], data['payload'])
                
        except json.JSONDecodeError:
            logger.error("Invalid JSON received")
        except KeyError as e:
            logger.error(f"Missing field: {e}")
    
    async def send(self, websocket, message: dict):
        if websocket.open:
            await websocket.send(json.dumps(message))
    
    async def broadcast(self, channel: str, payload: dict):
        message = {
            'channel': channel,
            'timestamp': datetime.utcnow().isoformat(),
            'data': payload
        }
        
        for client in self.clients:
            client_id = client.remote_address
            if client_id in self.subscriptions and channel in self.subscriptions[client_id]:
                await self.send(client, message)
    
    async def handler(self, websocket: websockets.WebSocketServerProtocol):
        await self.register(websocket)
        try:
            async for message in websocket:
                await self.handle_message(websocket, message)
        except websockets.exceptions.ConnectionClosed:
            pass
        finally:
            await self.unregister(websocket)

async def main():
    server = RealTimeServer()
    async with websockets.serve(server.handler, "localhost", 8765):
        logger.info("WebSocket server started on ws://localhost:8765")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
```

### Client Implementation

```javascript
// Real-time client with reconnection logic
class RealtimeClient {
    constructor(url, options = {}) {
        this.url = url;
        this.options = options;
        this.ws = null;
        this.subscriptions = new Set();
        this.reconnectDelay = options.reconnectDelay || 1000;
        this.maxReconnectDelay = options.maxReconnectDelay || 30000;
        this.reconnectAttempts = 0;
        this.handlers = new Map();
    }

    connect() {
        return new Promise((resolve, reject) => {
            this.ws = new WebSocket(this.url);
            
            this.ws.onopen = () => {
                console.log('Connected to WebSocket server');
                this.reconnectAttempts = 0;
                this.resubscribe();
                resolve();
            };
            
            this.ws.onmessage = (event) => {
                this.handleMessage(JSON.parse(event.data));
            };
            
            this.ws.onclose = () => {
                console.log('Disconnected from WebSocket server');
                this.scheduleReconnect();
            };
            
            this.ws.onerror = (error) => {
                console.error('WebSocket error:', error);
                reject(error);
            };
        });
    }

    scheduleReconnect() {
        const delay = Math.min(
            this.reconnectDelay * Math.pow(2, this.reconnectAttempts),
            this.maxReconnectDelay
        );
        
        console.log(`Reconnecting in ${delay}ms...`);
        setTimeout(() => {
            this.reconnectAttempts++;
            this.connect().catch(() => {});
        }, delay);
    }

    handleMessage(message) {
        const { channel, data, type } = message;
        
        if (type === 'ping') {
            this.send({ type: 'pong', timestamp: Date.now() });
            return;
        }
        
        if (this.handlers.has(channel)) {
            this.handlers.get(channel).forEach(handler => handler(data));
        }
    }

    subscribe(channel, handler) {
        this.subscriptions.add(channel);
        
        if (!this.handlers.has(channel)) {
            this.handlers.set(channel, new Set());
        }
        this.handlers.get(channel).add(handler);
        
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.send({ type: 'subscribe', channel });
        }
    }

    unsubscribe(channel, handler) {
        this.subscriptions.delete(channel);
        
        if (this.handlers.has(channel)) {
            if (handler) {
                this.handlers.get(channel).delete(handler);
            } else {
                this.handlers.delete(channel);
            }
        }
        
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.send({ type: 'unsubscribe', channel });
        }
    }

    resubscribe() {
        this.subscriptions.forEach(channel => {
            this.send({ type: 'subscribe', channel });
        });
    }

    send(message) {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(message));
        }
    }

    disconnect() {
        if (this.ws) {
            this.ws.close();
        }
    }
}

// Usage
const client = new RealtimeClient('ws://localhost:8765');

client.connect()
    .then(() => {
        // Subscribe to price updates
        client.subscribe('prices:AAPL', (data) => {
            console.log(`AAPL Price: $${data.price}`);
        });
        
        // Subscribe to notifications
        client.subscribe('notifications', (notification) => {
            showNotification(notification);
        });
    });
```

### Event-Driven Architecture (Kafka)

```python
from kafka import KafkaProducer, KafkaConsumer
import json
import asyncio
from datetime import datetime
from typing import Callable

class EventBus:
    def __init__(self, bootstrap_servers: list):
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )
    
    def publish(self, topic: str, event: dict):
        event['timestamp'] = datetime.utcnow().isoformat()
        future = self.producer.send(topic, value=event)
        return future
    
    def subscribe(self, topic: str, group_id: str, handler: Callable):
        consumer = KafkaConsumer(
            topic,
            bootstrap_servers=bootstrap_servers,
            group_id=group_id,
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            auto_offset_reset='latest'
        )
        
        for message in consumer:
            handler(message.value)

# Real-time analytics with Kafka Streams concept
class RealTimeAnalytics:
    def __init__(self, event_bus: EventBus):
        self.event_bus = event_bus
        self.counters = {}
        self.aggregates = {}
    
    async def process_click_event(self, event: dict):
        user_id = event['user_id']
        page = event['page']
        
        # Update counters
        key = f"clicks:{page}"
        self.counters[key] = self.counters.get(key, 0) + 1
        
        # Update user activity
        if user_id not in self.aggregates:
            self.aggregates[user_id] = {'clicks': 0, 'pages': set()}
        
        self.aggregates[user_id]['clicks'] += 1
        self.aggregates[user_id]['pages'].add(page)
        
        # Publish aggregated metrics
        await self.event_bus.publish('metrics.page_clicks', {
            'page': page,
            'total_clicks': self.counters[key]
        })
    
    def get_metrics(self) -> dict:
        return {
            'page_clicks': self.counters,
            'active_users': len(self.aggregates),
            'unique_pages': len(set().union(*[s['pages'] for s in self.aggregates.values()]))
        }

# Usage
event_bus = EventBus(['localhost:9092'])
analytics = RealTimeAnalytics(event_bus)

# Subscribe to click events
event_bus.subscribe('user.clicks', 'analytics-service', analytics.process_click_event)

# Publish an event
event_bus.publish('user.clicks', {
    'user_id': 'user123',
    'page': '/products',
    'timestamp': datetime.utcnow().isoformat()
})
```

### Server-Sent Events (SSE)

```python
from flask import Flask, Response, stream_with_context
import time
import random
import json

app = Flask(__name__)

@app.route('/stream')
def event_stream():
    def generate():
        while True:
            data = {
                'timestamp': time.time(),
                'value': random.randint(1, 100),
                'status': random.choice(['normal', 'warning', 'critical'])
            }
            yield f"data: {json.dumps(data)}\n\n"
            time.sleep(1)
    
    return Response(
        stream_with_context(generate()),
        mimetype='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'X-Accel-Buffering': 'no'
        }
    )

# Client-side
// JavaScript SSE client
const eventSource = new EventSource('/stream');

eventSource.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log('Received:', data);
    
    if (data.status === 'critical') {
        showAlert(data);
    }
};

eventSource.onerror = (error) => {
    console.error('SSE error:', error);
    eventSource.close();
};
```

## Anti-Patterns

### 1. No Reconnection Strategy

```javascript
// BAD - No handling of connection drops
const ws = new WebSocket('ws://example.com');
ws.onmessage = (msg) => process(msg.data);

// GOOD - Reconnection logic
class ReconnectingWebSocket {
    constructor(url) {
        this.url = url;
        this.connect();
    }
    
    connect() {
        this.ws = new WebSocket(this.url);
        this.ws.onclose = () => setTimeout(() => this.connect(), 1000);
    }
}
```

### 2. Sending Too Many Messages

```python
# BAD - Update every millisecond
async def send_updates(websocket):
    while True:
        await websocket.send(json.dumps(get_all_data()))
        await asyncio.sleep(0.001)  # Too frequent!

# GOOD - Throttle updates
async def send_updates(websocket):
    last_update = 0
    while True:
        now = time.time()
        if now - last_update >= 1:  # Max 1 update per second
            await websocket.send(json.dumps(get_all_data()))
            last_update = now
        await asyncio.sleep(0.1)
```

### 3. Not Cleaning Up Connections

```python
# BAD - Connections never cleaned up
async def handler(websocket):
    await websocket.recv()  # No cleanup

# GOOD - Proper cleanup
async def handler(websocket):
    try:
        await websocket.recv()
    except websockets.exceptions.ConnectionClosed:
        pass
    finally:
        await websocket.close()
```

## Best Practices

### Connection Management

```
┌─────────────────────────────────────────────────────────────┐
│                     Load Balancer                          │
│                  (WebSocket-aware)                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
   ┌────┴────┐   ┌────┴────┐   ┌────┴────┐
   │Server 1 │   │Server 2 │   │Server 3 │
   │ (WS)    │   │ (WS)    │   │ (WS)    │
   └────┬────┘   └────┬────┘   └────┬────┘
        │             │             │
        └─────────────┼─────────────┘
                      │
              ┌───────┴───────┐
              │ Message Broker│
              │   (Kafka)     │
              └───────┬───────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
    ┌────┴────┐ ┌────┴────┐ ┌────┴────┐
    │Analytics│ │Notifs   │ │Real-time│
    └─────────┘ └─────────┘ └─────────┘
```

### Scaling Strategy

```python
# Horizontal scaling with Redis Pub/Sub
import redis
import json
from kafka import KafkaConsumer

redis_client = redis.Redis(host='localhost', port=6379)

# Each WebSocket server subscribes to Redis channel
def start_websocket_server(server_id: str):
    pubsub = redis_client.pubsub()
    pubsub.subscribe('broadcast')
    
    # Also consume from Kafka for persistence
    consumer = KafkaConsumer('events', group_id=f'ws-{server_id}')
    
    # Forward both Redis and Kafka messages to WebSocket clients
    for message in pubsub.listen():
        if message['type'] == 'message':
            broadcast_to_ws_clients(json.loads(message['data']))
    
    for msg in consumer:
        broadcast_to_ws_clients(json.loads(msg.value))
```

## Failure Modes

- **Connection storm on server restart** → thousands of clients reconnect simultaneously → server overload → implement exponential backoff with jitter and connection rate limiting
- **Memory leaks from orphaned connections** → disconnected clients not cleaned up → server memory exhaustion → implement connection timeouts, heartbeat checks, and automatic cleanup
- **Message ordering violations** → events delivered out of sequence → inconsistent client state → use sequence numbers and implement client-side reordering buffers
- **Broadcast fan-out overwhelming servers** → single message replicated to all connected clients → network saturation → use pub/sub with topic filtering and message batching
- **No backpressure mechanism** → server produces messages faster than clients consume → client buffer overflow → implement client-side flow control and server-side message dropping policies
- **State synchronization gaps after reconnection** → client reconnects with stale state → user sees outdated data → implement state reconciliation with version vectors or snapshot-plus-delta sync
- **Horizontal scaling without message routing** → WebSocket connections distributed across servers → messages lost between instances → use Redis Pub/Sub or message broker for cross-server fan-out

## Related Topics

- [[Architecture MOC]]
- [[WebSockets]]
- [[EventArchitecture]]
- [[MessageQueues]]
- [[Backpressure]]

## Key Takeaways

- Real-time architecture enables sub-second data delivery through persistent bidirectional connections (WebSockets, SSE) and event-driven processing
- Needed for live updates, collaborative applications, monitoring systems, IoT streaming, and interactive applications
- Consider alternatives like polling, SSE, or webhooks when bidirectional real-time communication isn't required
- Tradeoff: immediate data delivery versus connection management complexity, horizontal scaling challenges, and memory leak risks
- Main failure mode: connection storms on server restart combined with orphaned connections cause memory exhaustion and cascading failures
- Best practice: implement exponential backoff reconnection, use message brokers for cross-server fan-out, enforce connection timeouts with heartbeats, and implement backpressure mechanisms
- Related: WebSockets, event-driven architecture, message queues, backpressure

## Additional Notes

**Protocol Comparison:**
- WebSockets: Full-duplex, bidirectional
- SSE: Server-to-client only
- Polling: Simple but less efficient

**Scalability Considerations:**
- Use Redis for connection state
- Kafka for message persistence
- CDN for static content

**Monitoring:**
- Connection count per server
- Message throughput
- Latency percentiles