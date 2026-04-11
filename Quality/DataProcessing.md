---
title: Data Processing
title_pt: Processamento de Dados
layer: quality
type: concept
priority: high
version: 2.0.0
tags:
  - Quality
  - Data
  - Processing
  - ETL
  - Streaming
  - Batch
description: Techniques for transforming, validating, and moving data through systems -- batch and streaming -- with correctness, efficiency, and observability guarantees.
description_pt: Tecnicas para transformar, validar e mover dados atraves de sistemas -- batch e streaming -- com garantias de correcao, eficiencia e observabilidade.
prerequisites:
  - [[Performance]]
  - [[Architecture]]
estimated_read_time: 15 min
difficulty: advanced
---

# Data Processing

## Description

Data processing encompasses all operations that transform, validate, aggregate, filter, and route data from its input form to its output form within a system. It spans a spectrum:

| Pattern | Latency | Volume | Examples |
|---|---|---|---|
| **Batch processing** | Minutes to hours | GB to PB | Nightly ETL, data warehouse loads, report generation |
| **Micro-batch** | Seconds to minutes | MB to GB per batch | Spark Structured Streaming, Kafka Streams with tumbling windows |
| **Stream processing** | Milliseconds to seconds | Event-at-a-time | Fraud detection, real-time dashboards, alerting |
| **Interactive query** | Milliseconds | Single request/response | API endpoint fetching aggregated data |

The quality dimensions of data processing are:

- **Correctness**: Output is deterministic and accurate for a given input. Reprocessing the same input produces the same output.
- **Completeness**: All input records are processed; none are silently dropped.
- **Ordering**: Output respects required ordering constraints (event time vs. processing time).
- **Efficiency**: Processing completes within resource constraints (memory, CPU, time).
- **Observability**: Processing metrics (throughput, lag, error rate) are visible and alertable.
- **Recoverability**: Failed processing can be retried or resumed without duplication or data loss.

Data processing is where most data integrity bugs live. Schema mismatches, timezone errors, null handling, and duplicate processing account for the majority of data pipeline incidents.

## When to Use

- **ETL/ELT pipelines**: Moving data from OLTP databases to data warehouses (Snowflake, BigQuery) for analytics. Extract, transform (dbt, Spark), load with schema validation.
- **Event-driven architectures**: Processing streams of events (Kafka, Kinesis, Pub/Sub) for real-time aggregation, enrichment, or routing.
- **Data validation and cleansing**: Sanitizing user input, normalizing addresses, deduplicating records before storage.
- **Report generation**: Aggregating transactional data into periodic reports (daily revenue, weekly active users, monthly churn).
- **Machine learning feature pipelines**: Computing features from raw data at scale, either batch (historical features) or streaming (real-time features).
- **Data migration and synchronization**: Moving data between systems with transformation (e.g., MongoDB to PostgreSQL with schema changes).

## When NOT to Use

- **Simple CRUD passthrough**: If data flows from API to database without transformation, you do not need a data processing layer. Direct ORM/ODM access is simpler.
- **Real-time user-facing queries with sub-10ms SLA**: Data processing pipelines add latency. For sub-10ms queries, precompute results and serve from cache or materialized view.
- **One-off data fixes**: Ad-hoc SQL scripts or Python one-offs are faster than building a processing pipeline for a single correction.
- **When the processing logic is trivial and unlikely to grow**: A single `map` over a small list does not need a framework. Use built-in language constructs.
- **When you cannot guarantee source data quality**: A processing pipeline cannot fix fundamentally unreliable input. Fix the data source first (schema validation at ingestion, producer-side validation).

## Tradeoffs

| Aspect | Batch Processing | Stream Processing |
|---|---|---|
| Latency | High (minutes-hours) | Low (ms-seconds) |
| Complexity | Lower: process entire dataset at once | Higher: handle out-of-order events, late data, watermarks |
| Exactly-once | Easier: rerun entire batch | Harder: requires idempotent sinks or transactional writes |
| Resource usage | Bursty: spike during batch window | Steady: constant resource allocation |
| Debugging | Easier: compare input/output datasets | Harder: stateful processing across time windows |
| Cost | Pay for compute only during batch window | Pay for always-on infrastructure |
| Schema evolution | Easier: validate entire batch before writing | Harder: schema can change mid-stream |

| Aspect | Framework-based (Spark, Flink) | Hand-rolled (scripts, queues) |
|---|---|---|
| Learning curve | Steep: framework semantics | Shallow: familiar primitives |
| Fault tolerance | Built-in: checkpointing, exactly-once | Manual: implement retries, dead letter queues |
| Scalability | Horizontal out of the box | Must design partitioning and scaling |
| Operational cost | Managed services available | Full operational ownership |
| Flexibility | Constrained by framework capabilities | Unlimited but error-prone |

## Alternatives

- **ELT over ETL**: Load raw data into the warehouse first, then transform with SQL (dbt). Shifts transformation to the warehouse engine, leveraging its optimizer. Better for teams with SQL expertise; requires a capable warehouse.
- **Materialized views**: Precompute aggregations in the database (PostgreSQL, ClickHouse). Eliminates the processing pipeline for specific query patterns but requires database support and refresh management.
- **Change Data Capture (CDC)**: Debezium, Maxwell capture database changes as events, eliminating the need for a separate extraction step. The processing pipeline consumes the CDC stream directly.
- **Lambda architecture**: Combines batch (accurate) and streaming (fast) layers. Historically popular but operationally complex; largely superseded by Kappa architecture (stream-only with reprocessing capability).
- **Kappa architecture**: All data flows through a single stream. Reprocessing is replaying the stream from the beginning. Simpler than Lambda but requires the stream system to retain data long enough for replay.

## Failure Modes

1. **Silent data loss on processing errors**: A transformation throws on record 10,001 of 100,000. The pipeline catches the exception, logs it, and continues. 99,999 records are written, 1 is lost, and nobody notices until a downstream report shows incorrect totals. Mitigation: use dead letter queues (DLQ) for failed records, alert on DLQ depth, and never silently drop records. Log the full failed record for replay.

2. **Duplicate processing due to at-least-once delivery**: Kafka consumer processes a message, writes to the database, but crashes before committing the offset. On restart, the message is reprocessed, creating a duplicate order. Mitigation: use idempotent writes (upsert by unique key), or use exactly-once semantics (Kafka transactions, idempotent producers). Design every sink operation to be safe when executed twice.

3. **Out-of-order event processing**: Event A (user.created at 10:00) arrives after Event B (user.updated at 10:01) due to network partition. The pipeline processes B first, creating a user that does not exist, then processes A, overwriting B's changes. Mitigation: use event time (not processing time) for ordering, implement late-event handling with watermarks, or use event sourcing with append-only logs where order is enforced by the store.

4. **Memory exhaustion on unbounded data**: Loading an entire CSV into memory (`pd.read_csv('large_file.csv')`) causes OOM on files larger than available RAM. The pipeline works in development (100MB file) but crashes in production (10GB file). Mitigation: use streaming/chunked processing (`pd.read_csv(..., chunksize=10000)`), process record-by-record, and set memory limits with backpressure.

5. **Schema drift without detection**: The upstream API adds a new field `user.phone` and changes `user.age` from `int` to `string`. The processing pipeline expects the old schema, silently drops `phone`, and fails to parse `age`. Output is wrong for weeks. Mitigation: enforce schema validation on input (JSON Schema, Avro schema registry), alert on schema changes, and use schema evolution strategies (backward/forward compatibility).

6. **Timezone and DST errors**: A daily batch job runs at "midnight UTC" but the business metric is "midnight US/Eastern". On DST transition days, the window is 23 or 25 hours, and aggregations are off by one day. Mitigation: store all timestamps in UTC, use event time with explicit timezone, and test DST boundary cases. Use libraries like `pytz` or `zoneinfo` correctly.

7. **Non-deterministic processing due to external calls**: A transformation calls an external API to enrich records. The API returns different results on retry (e.g., exchange rates change). Reprocessing the same input produces different output. Mitigation: cache external calls, snapshot external data at processing time, or design idempotent enrichment with versioned data sources.

## Code Examples

### Streaming data processing with backpressure (Node.js)

```typescript
import { pipeline, Transform, Writable } from 'stream';
import { createReadStream, createWriteStream } from 'fs';
import { parse } from 'csv-parse';
import { stringify } from 'csv-stringify';

// Transform: validate and enrich each record
const enrichUser: Transform = new Transform({
  objectMode: true,
  transform(record: Record<string, string>, _encoding, callback) {
    // Validate required fields
    if (!record.email || !record.name) {
      // Route invalid records to dead letter queue
      deadLetterQueue.push({ record, reason: 'Missing required fields' });
      return callback(); // continue processing, do not propagate
    }

    // Enrich with computed fields
    const enriched = {
      ...record,
      email_domain: record.email.split('@')[1],
      processed_at: new Date().toISOString(),
      status: isValidEmail(record.email) ? 'valid' : 'invalid',
    };
    callback(null, enriched);
  },
});

// Dead letter queue: failed records written to separate file
const deadLetterQueue: Array<{ record: any; reason: string }> = [];

function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// Pipeline: backpressure-aware, never loads entire file
pipeline(
  createReadStream('input.csv'),
  parse({ columns: true, skip_empty_lines: true }),
  enrichUser,
  stringify({ header: true }),
  createWriteStream('output.csv'),
  (err) => {
    if (err) {
      console.error('Pipeline failed:', err);
      process.exit(1);
    }
    // Write DLQ report
    if (deadLetterQueue.length > 0) {
      console.warn(`${deadLetterQueue.length} records failed validation`);
      writeDeadLetterReport(deadLetterQueue);
    }
    console.log('Processing complete');
  },
);
```

### Idempotent batch processing (Python with SQLAlchemy)

```python
from sqlalchemy.dialects.postgresql import insert
from datetime import datetime, timezone
import hashlib

def process_daily_orders(batch_date: str, records: list[dict]) -> None:
    """
    Process daily order batch with idempotent upsert.
    Safe to retry: running twice produces the same result.
    """
    processed = []
    for record in records:
        # Deterministic processing: same input always produces same output
        processed.append({
            'order_id': record['id'],
            'batch_date': batch_date,
            'total_cents': calculate_total(record),
            'tax_cents': calculate_tax(record),
            'status': classify_order(record),
            'processed_at': datetime.now(timezone.utc),
            # Deduplication key: hash of input ensures idempotency
            'input_hash': hashlib.sha256(
                json.dumps(record, sort_keys=True).encode()
            ).hexdigest(),
        })

    # Upsert: if order_id + batch_date already exists, update only if
    # input_hash differs (meaning source data changed)
    stmt = insert(OrderFact).values(processed)
    stmt = stmt.on_conflict_do_update(
        constraint='uq_order_batch',
        set_={
            'total_cents': stmt.excluded.total_cents,
            'tax_cents': stmt.excluded.tax_cents,
            'status': stmt.excluded.status,
            'input_hash': stmt.excluded.input_hash,
            'processed_at': stmt.excluded.processed_at,
        },
        where=OrderFact.input_hash != stmt.excluded.input_hash,
    )

    db.session.execute(stmt)
    db.session.commit()

def calculate_total(record: dict) -> int:
    """Deterministic: no external calls, no randomness."""
    return sum(item['price_cents'] * item['quantity'] for item in record['items'])

def calculate_tax(record: dict) -> int:
    """Use fixed tax table -- not a live API call."""
    tax_rates = {'US': 0.08, 'UK': 0.20, 'EU': 0.21}
    country = record.get('country', 'US')
    total = calculate_total(record)
    return int(total * tax_rates.get(country, 0))

def classify_order(record: dict) -> str:
    if record['total_cents'] > 100000:
        return 'high_value'
    elif len(record['items']) > 5:
        return 'bulk'
    return 'standard'
```

### Schema validation at pipeline boundary (Python/Pydantic)

```python
from pydantic import BaseModel, EmailStr, Field, ValidationError
from typing import Optional
from datetime import date

class UserEvent(BaseModel):
    """Schema for incoming user events -- rejects invalid data at the boundary."""
    user_id: str = Field(min_length=1, max_length=36)
    event_type: Literal['created', 'updated', 'deleted']
    timestamp: str  # ISO 8601
    email: Optional[EmailStr] = None
    name: Optional[str] = Field(None, max_length=200)
    age: Optional[int] = Field(None, ge=0, le=150)

    def validate_timestamp(self) -> 'UserEvent':
        """Parse and validate timestamp after model construction."""
        try:
            datetime.fromisoformat(self.timestamp.replace('Z', '+00:00'))
        except ValueError:
            raise ValueError(f'Invalid ISO 8601 timestamp: {self.timestamp}')
        return self

def process_user_event(raw: dict) -> UserEvent | None:
    """Validate incoming event. Returns None and logs to DLQ on failure."""
    try:
        event = UserEvent(**raw)
        event.validate_timestamp()
        return event
    except ValidationError as e:
        logger.error(
            'Invalid user event: %s | raw=%s',
            e,
            json.dumps(raw),
            extra={'dlq_reason': 'schema_validation', 'raw_event': raw},
        )
        metrics.increment('events.validation_failed')
        return None
```

## Best Practices

- **Make every operation idempotent**: Design every write as an upsert or idempotent operation. At-least-once delivery is easier to implement than exactly-once; idempotent sinks make at-least-once equivalent to exactly-once.
- **Validate at every boundary**: Validate input when it enters the pipeline, validate output before it leaves. Use schema enforcement (JSON Schema, Avro, Protobuf) and reject invalid data immediately.
- **Use dead letter queues**: Never silently drop failed records. Route them to a DLQ with the failure reason and the full original record. Monitor DLQ depth and alert on growth.
- **Log processing metrics**: Track records processed, records failed, processing latency, and queue depth. Use these metrics for alerting and capacity planning.
- **Test with production-scale data**: Unit tests with 5 records miss OOM errors, timeout issues, and performance degradation. Run integration tests with production-scale datasets regularly.
- **Design for reprocessing**: Assume you will need to reprocess data. Keep raw input data immutable, make transformations deterministic, and version transformation logic.
- **Use event time, not processing time**: For any time-based aggregation, use the timestamp embedded in the event, not the time your system received it. Handle late events with watermarks.
- **Monitor data quality, not just pipeline health**: A pipeline can be "healthy" (processing fast, no errors) while producing garbage output. Implement data quality checks: row counts, null rates, value distributions, and referential integrity.

## Related Topics

- [[Performance]] -- processing efficiency, memory management, backpressure
- [[Architecture]] -- system patterns for data flow (event-driven, batch, streaming)
- [[QualityGates]] -- data quality validation as a gate in deployment pipelines
- [[Configuration]] -- parameterizing data pipelines (batch sizes, timeouts, endpoints)
- [[Security]] -- data masking, PII handling in processing pipelines
- [[Databases]] -- data storage patterns that interact with processing (CDC, materialized views)
- [[StaticAnalysis]] -- schema validation as a form of static analysis for data
- [[Composability]] -- composing data transformations from small, focused operations
