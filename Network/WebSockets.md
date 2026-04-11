---
title: WebSockets
title_pt: WebSockets
layer: network
type: concept
priority: medium
version: 1.0.0
tags:
  - Network
  - WebSockets
  - Real-Time
  - Protocol
description: Protocol for full-duplex communication channels over a single TCP connection.
description_pt: Protocolo para canais de comunicação full-duplex sobre uma única conexão TCP.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# WebSockets

## Description

WebSockets provide a persistent, full-duplex communication channel between a client and server over a single TCP connection. Unlike HTTP's request-response model, WebSockets allow either party to send messages at any time, making it ideal for real-time applications.

WebSockets start with an HTTP "upgrade" request. The client sends a request with `Upgrade` headers, and if the server supports WebSockets, it responds with a 101 status code (Switching Protocols). Once upgraded, the connection remains open, and both parties can send frames independently.

Key characteristics:
- **Full-duplex** - Bidirectional communication
- **Persistent** - Connection stays open
- **Low overhead** - No HTTP headers after initial handshake
- **Event-driven** - Push notifications without polling

Common use cases:
- Real-time chat applications
- Live dashboards and monitoring
- Collaborative editing tools
- Gaming
- Financial trading platforms

## Purpose

**When WebSockets are valuable:**
- For real-time updates (chat, notifications)
- For bidirectional communication
- For low-latency data transfer
- For streaming data

**When to avoid:**
- For simple request-response patterns
- When HTTP is sufficient
- In environments that block WebSocket connections

## Rules

1. **Use secure WebSocket (WSS)** - Always use wss:// in production
2. **Implement reconnection logic** - Handle connection drops
3. **Handle backpressure** - Don't overwhelm clients
4. **Validate messages** - Sanitize all incoming data
5. **Use heartbeats** - Detect dead connections

## Examples

### Server Implementation (Python)

```python
import asyncio
import websockets
import json

# WebSocket server
async def echo_handler(websocket, path):
    try:
        async for message in websocket:
            data = json.loads(message)
            
            # Process message
            response = process_message(data)
            
            # Send response
            await websocket.send(json.dumps(response))
            
    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")

# Start server
async def main():
    server = await websockets.serve(
        echo_handler,
        "localhost",
        8765,
        ping_interval=30,  # Heartbeat every 30s
        ping_timeout=10    # Close if no response
    )
    
    print("WebSocket server started on ws://localhost:8765")
    await server.wait_closed()

asyncio.run(main())
```

### Client Implementation (JavaScript)

```javascript
class WebSocketClient {
  constructor(url) {
    this.url = url;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }
  
  connect() {
    this.ws = new WebSocket(this.url);
    
    this.ws.onopen = () => {
      console.log('Connected to WebSocket');
      this.reconnectAttempts = 0;
      this.send({ type: 'auth', token: this.getToken() });
    };
    
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleMessage(data);
    };
    
    this.ws.onclose = () => {
      console.log('Disconnected');
      this.attemptReconnect();
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }
  
  send(data) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }
  
  handleMessage(data) {
    // Handle different message types
    switch (data.type) {
      case 'notification':
        this.showNotification(data.payload);
        break;
      case 'update':
        this.updateState(data.payload);
        break;
      case 'error':
        this.handleError(data.payload);
        break;
    }
  }
  
  attemptReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
      setTimeout(() => this.connect(), delay);
    }
  }
  
  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}

// Usage
const client = new WebSocketClient('wss://api.example.com/ws');
client.connect();
```

### With Authentication

```python
# Server with authentication
async def authenticated_handler(websocket, path):
    try:
        # Wait for auth message
        auth_message = await asyncio.wait_for(websocket.recv(), timeout=10)
        auth_data = json.loads(auth_message)
        
        # Validate token
        if not validate_token(auth_data.get('token')):
            await websocket.close(4001, "Unauthorized")
            return
        
        # Authenticated - handle messages
        async for message in websocket:
            await process_message(websocket, json.loads(message))
            
    except asyncio.TimeoutError:
        await websocket.close(4000, "Authentication timeout")
```

## Anti-Patterns

### 1. No Reconnection Logic

```javascript
// BAD - No reconnection
const ws = new WebSocket('wss://example.com/ws');
ws.onclose = () => {};  // Does nothing!

// GOOD - With reconnection
ws.onclose = () => {
  setTimeout(() => connect(), 5000);  // Reconnect after 5s
};
```

### 2. Not Handling Errors

```javascript
// BAD
ws.send(data);  // Might fail silently

// GOOD
if (ws.readyState === WebSocket.OPEN) {
  ws.send(data);
} else {
  queueMessage(data);  // Queue for later
}
```

## Failure Modes

- **No reconnection logic** → dropped connections → permanent disconnection → implement exponential backoff reconnection strategy
- **Missing heartbeat/ping** → dead connections undetected → resource leak and stale state → configure ping/pong intervals with timeout
- **Unvalidated messages** → malicious payloads → injection attacks or crashes → sanitize and validate all incoming WebSocket messages
- **No backpressure handling** → server overwhelms slow clients → memory exhaustion → implement message queuing and drop policies
- **Missing authentication** → unauthorized connections → data exposure → authenticate during WebSocket handshake or first message
- **No rate limiting** → message flooding → server resource exhaustion → enforce per-connection message rate limits
- **Cleartext WebSocket (ws://)** → traffic interception → credential and data theft → always use WSS (wss://) in production

## Best Practices

### Message Format

```json
// Use structured messages
{
  "type": "message_type",
  "payload": { ... },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Heartbeat

```python
# Server-side ping/pong
async with websockets.connect(url) as ws:
    while True:
        await ws.send(json.dumps({"type": "ping"}))
        await asyncio.sleep(30)
        # Handle pong response
```

### Rate Limiting

```python
# Server-side rate limiting
class RateLimiter:
    def __init__(self, max_messages=100, window=60):
        self.max_messages = max_messages
        self.window = window
        self.clients = {}
    
    def is_allowed(self, client_id):
        now = time.time()
        if client_id not in self.clients:
            self.clients[client_id] = []
        
        # Clean old messages
        self.clients[client_id] = [
            t for t in self.clients[client_id]
            if now - t < self.window
        ]
        
        if len(self.clients[client_id]) >= self.max_messages:
            return False
        
        self.clients[client_id].append(now)
        return True
```

## Related Topics

- [[HTTP]]
- [[HTTPS]]
- [[REST]]
- [[TlsSsl]]
- [[Authentication]]
- [[APIDesign]]
- [[Caching]]
- [[Monitoring]]

## Additional Notes

**WebSocket vs HTTP:**
- WebSocket: Persistent, full-duplex
- HTTP: Request-response, stateless

**Security:**
- Always use WSS (WebSocket Secure)
- Validate and sanitize messages
- Implement authentication
- Use rate limiting