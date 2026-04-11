---
title: Message Queues
title_pt: Filas de Mensagens
layer: architecture
type: concept
priority: high
version: 1.0.0
tags:
  - Architecture
  - Messaging
  - DistributedSystems
  - Async
description: Asynchronous communication pattern using message brokers for decoupled, reliable service communication.
description_pt: Padrão de comunicação assíncrona usando brokers de mensagens para comunicação desacoplada e confiável entre serviços.
prerequisites:
  - Distributed Systems
  - Event Architecture
estimated_read_time: 15 min
difficulty: advanced
---

# Message Queues

## Description

Message queues enable asynchronous communication between services by acting as an intermediary buffer. Instead of services calling each other directly (synchronous HTTP), they send messages to a queue, and consumers process them at their own pace.

Key concepts:
- **Producer/Publisher** — sends messages to the queue
- **Consumer/Subscriber** — receives and processes messages
- **Broker** — the message queue system itself (Kafka, RabbitMQ)
- **Topic/Queue** — named channel for messages
- **Offset** — position in the message stream
- **Consumer Group** — group of consumers sharing load
- **Dead Letter Queue (DLQ)** — queue for messages that can't be processed

## Purpose

**When message queues are essential:**
- Decoupling services that don't need real-time responses
- Handling traffic spikes (buffer between producer and consumer)
- Ensuring message delivery even when consumers are down
- Enabling event-driven architectures at scale
- Processing tasks asynchronously (emails, reports, data pipelines)
- Fan-out patterns (one event → many consumers)

**When message queues add unnecessary complexity:**
- Simple request/response patterns (use HTTP)
- When you need immediate responses
- Small systems with 1-2 services
- When eventual consistency is unacceptable

**The key question:** Does this interaction need to be synchronous, or can it be async?

## Rules

1. **Design for idempotent consumers** — messages may be delivered more than once
2. **Set appropriate retention** — how long to keep unprocessed messages
3. **Monitor queue depth** — growing queue = consumer can't keep up
4. **Use dead letter queues** — handle poison messages without blocking the queue
5. **Order matters** — some systems guarantee order (Kafka partitions), others don't (RabbitMQ)

## Patterns

### Point-to-Point (Queue)

One message → one consumer. Multiple consumers compete for messages.

```python
# RabbitMQ - work queue
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()
channel.queue_declare(queue='task_queue', durable=True)

# Producer
channel.basic_publish(
    exchange='',
    routing_key='task_queue',
    body='Task data',
    properties=pika.BasicProperties(delivery_mode=2)  # Persistent
)

# Consumer
def callback(ch, method, properties, body):
    process_task(body)
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_qos(prefetch_count=1)  # Fair dispatch
channel.basic_consume(queue='task_queue', on_message_callback=callback)
channel.start_consuming()
```

### Publish/Subscribe (Topic)

One message → many consumers. Each consumer gets a copy.

```python
# Kafka - pub/sub
from kafka import KafkaProducer, KafkaConsumer

# Producer
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)
producer.send('user-events', {'event': 'user_created', 'user_id': '123'})
producer.flush()

# Consumer
consumer = KafkaConsumer(
    'user-events',
    bootstrap_servers=['localhost:9092'],
    group_id='notification-service',
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)
for message in consumer:
    handle_event(message.value)
```

### Dead Letter Queue

```python
# RabbitMQ - DLQ setup
channel.queue_declare(queue='orders', durable=True)
channel.queue_declare(queue='orders.dlq', durable=True)

# Messages that fail 3 times go to DLQ
channel.queue_declare(
    queue='orders',
    arguments={
        'x-dead-letter-exchange': '',
        'x-dead-letter-routing-key': 'orders.dlq',
        'x-message-ttl': 60000,
        'x-max-length': 10000
    }
)
```

## Anti-Patterns

### 1. No Idempotency

**Bad:** Processing a payment message twice → double charge
**Solution:** Use idempotency keys, check before processing

### 2. No Dead Letter Queue

**Bad:** Poison message blocks queue forever
**Solution:** Route failed messages to DLQ for manual inspection

### 3. Unbounded Queue Growth

**Bad:** Consumer can't keep up → queue grows → memory exhaustion
**Solution:** Monitor queue depth, add consumers, set max length

### 4. Synchronous Dependencies on Async

**Bad:** Sending message → immediately expecting response
**Solution:** Use request-reply pattern with correlation IDs, or switch to sync

### 5. No Message Schema

**Bad:** Producers and consumers disagree on message format
**Solution:** Use schema registry (Avro, Protobuf), version messages

## Best Practices

1. **Make consumers idempotent** — assume duplicate delivery
2. **Monitor queue metrics** — depth, processing rate, lag
3. **Use consumer groups** — scale horizontally
4. **Implement retry with backoff** — don't hammer failing services
5. **Version your messages** — backward-compatible schema evolution
6. **Log message processing** — traceability for debugging
7. **Set appropriate timeouts** — don't hold messages forever

## Failure Modes

- **Consumer crash mid-processing** → message requeued → duplicate processing → need idempotency
- **Broker goes down** → producers can't send → need local buffer or circuit breaker
- **Slow consumer** → queue grows → memory exhaustion → need backpressure or max length
- **Schema change breaks consumers** → need schema registry and versioning
- **Partition rebalance** (Kafka) → consumer reassignment → brief processing pause
- **Message ordering lost** → need partition key for ordering guarantee

## Technology Stack

| Tool | Pattern | Ordering | Throughput | Use Case |
|------|---------|----------|------------|----------|
| Kafka | Log-based | Per-partition | Very high | Event streaming, analytics |
| RabbitMQ | Queue-based | Per-queue | High | Task queues, RPC |
| AWS SQS | Queue-based | FIFO (optional) | Medium | Cloud-native queues |
| Redis Streams | Log-based | Per-stream | High | Lightweight messaging |
| NATS | Pub/Sub | No | Very high | IoT, microservices |
| Amazon SNS | Pub/Sub | No | High | Fan-out notifications |

## Related Topics

- [[EventArchitecture]] — Message queues enable event-driven patterns
- [[DistributedSystems]] — Async communication in distributed environments
- [[Microservices]] — Decoupling services with message queues
- [[CQRS]] — Event bus for command/query separation
- [[EventSourcing]] — Event store as append-only log
- [[Idempotency]] — Making consumers safe for duplicate delivery
- [[RateLimiting]] — Controlling message production rate
- [[Backpressure]] — Handling consumer overload
- [[Observability]] — Monitoring queue depth and consumer lag
- [[Docker]] — Running message brokers in containers
- [[Kubernetes]] — Orchestrating message broker clusters

## Key Takeaways

- Message queues enable asynchronous communication between services via a broker, decoupling producers from consumers and buffering traffic spikes.
- Use for decoupling services that don't need real-time responses, handling traffic spikes, ensuring delivery when consumers are down, or enabling event-driven architectures.
- Do NOT use for simple request/response patterns needing immediate responses, small systems with 1-2 services, or when eventual consistency is unacceptable.
- Key tradeoff: loose coupling, scalability, and delivery guarantees vs. added infrastructure complexity and eventual consistency.
- Main failure mode: non-idempotent consumers processing duplicate messages, or unbounded queue growth causing memory exhaustion.
- Best practice: design idempotent consumers, use dead letter queues for poison messages, monitor queue depth, and version message schemas.
- Related concepts: Event-Driven Architecture, Distributed Systems, Kafka, RabbitMQ, Idempotency, Backpressure, Dead Letter Queues, Pub/Sub.
