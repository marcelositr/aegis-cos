---
title: Redis
layer: databases
type: concept
priority: high
version: 2.0.0
tags:
  - Databases
  - Redis
  - Caching
  - InMemory
  - DataStructures
  - PubSub
description: An in-memory data store used as database, cache, and message broker with sub-millisecond latency, supporting rich data structures and persistence options.
---

# Redis

## Description

Redis (REmote DIctionary Server) is an open-source, in-memory data store that operates as a database, cache, and message broker. It stores data as key-value pairs where values can be simple strings or rich data structures (strings, hashes, lists, sets, sorted sets, bitmaps, HyperLogLogs, streams, geospatial indexes). Redis is single-threaded in its core event loop (per shard), which eliminates lock contention and makes command execution atomic. It achieves throughput of 100K+ operations per second on commodity hardware with sub-millisecond p99 latency.

**Persistence options:**
- **RDB (Redis Database)** — point-in-time snapshots at configurable intervals. Fast recovery, but can lose minutes of data.
- **AOF (Append Only File)** — logs every write operation. Near-complete durability (fsync every second loses ~1s of data; `always` loses none but impacts throughput).
- **RDB + AOF** — Redis 4.0+ supports both simultaneously. AOF rewrites use RDB as a base for fast restart.
- **No persistence** — pure cache. Data is lost on restart.

**Deployment topologies:**
- **Standalone** — single instance. Simple but no HA.
- **Redis Sentinel** — master + replicas with automatic failover. Reads can be offloaded to replicas; writes go to master.
- **Redis Cluster** — sharded across 16,384 hash slots with master-replica pairs per slot range. Horizontal scale-out.
- **Redis Enterprise / managed** — AWS ElastiCache, Google Memorystore, Azure Cache. Adds modules (RediSearch, RedisJSON), automated backups, and multi-AZ.

## When to Use

- **Caching** — the most common use case. Cache expensive database queries, rendered HTML fragments, or API responses. A Redis cache sits between your application and the primary database, reducing p99 latency from ~50ms to <1ms.
- **Session storage** — HTTP sessions are naturally key-value data with TTLs. Redis's `SETEX` or `EXPIRE` commands handle expiration automatically, and Redis Cluster scales horizontally with user growth.
- **Leaderboards and rankings** — `ZADD`/`ZRANGE` on sorted sets implement O(log N) ranking. Used by gaming platforms for real-time scoreboards.
- **Rate limiting** — atomic `INCR` + `EXPIRE` or sliding-window algorithms using sorted sets. Far faster than database-backed rate limiters and essential for API gateways handling 10K+ RPS.
- **Pub/Sub and event streaming** — lightweight message passing between microservices. For higher throughput and persistence, use Redis Streams (`XADD`/`XREAD`) which support consumer groups and message acknowledgment.
- **Distributed locking** — `SET key value NX EX timeout` (Redlock algorithm) for coordinating access across distributed processes. Used for leader election, job deduplication, and preventing thundering herds.
- **Real-time analytics** — HyperLogLog for approximate cardinality counts (12 KB for ~2^64 unique elements), bitmaps for daily active user tracking, sorted sets for time-series aggregations.
- **Job/message queues** — `LPUSH`/`BRPOP` implement a reliable work queue. Combined with a visibility timeout pattern, this replaces RabbitMQ/SQS for simple workloads under ~50K jobs/sec.

## When NOT to Use

- **As the system of record for relational data** — Redis lacks joins, secondary indexes (without RediSearch), and ACID transactions across multiple keys (multi-key transactions exist but are limited). Use PostgreSQL or MySQL for authoritative data.
- **When your dataset exceeds available RAM** — Redis holds all data in memory. A 1 TB dataset requires 1 TB of RAM (plus overhead for replication and snapshots). SSD-backed databases are far more cost-effective at this scale.
- **When you need complex queries** — ad-hoc filtering, full-text search (without RediSearch), or aggregations across heterogeneous fields. Use Elasticsearch or a relational database.
- **When strict durability is non-negotiable** — even with AOF `fsync=always`, there is a small window of vulnerability. For financial ledgers or compliance data, use a WAL-based RDBMS.
- **For large blob storage** — storing >1 MB values in Redis is an anti-pattern. It fragments memory, slows down fork-based persistence, and wastes RAM. Use S3 or a CDN.
- **When your access pattern is write-heavy and you need durability** — Redis is optimized for read-heavy workloads. A write-heavy workload with AOF `fsync=always` can degrade to <5K ops/sec, losing its primary advantage.
- **When the team has no operational Redis experience** — managing persistence tuning, memory eviction policies, cluster rebalancing, and failover requires specific expertise.

## Tradeoffs

| Dimension | Redis | PostgreSQL (for comparison) |
|-----------|-------|---------------------------|
| **Latency** | <1ms (in-memory, single-threaded) | 5–50ms (disk + query planner) |
| **Throughput** | 100K–200K ops/sec per instance | 5K–20K queries/sec per instance |
| **Durability** | Best-effort (AOF every sec) | Full ACID with WAL |
| **Query flexibility** | Key-based, data-structure-specific | Full SQL, joins, indexes |
| **Memory cost** | $2–5/GB/month (RAM) | $0.10–0.30/GB/month (SSD) |
| **Horizontal scaling** | Redis Cluster (16K hash slots) | Read replicas; sharding is manual |
| **Data size limit** | 512 MB per key, bounded by RAM | Limited by disk (TB scale) |

| Dimension | Redis as Cache | Application-Level Cache (e.g., Guava, Caffeine) |
|-----------|---------------|------------------------------------------------|
| **Scope** | Shared across all instances | Per-instance |
| **Eviction** | LRU/LFU/TTL at server level | LRU at JVM/process level |
| **Network cost** | One network hop per access | In-process, zero network |
| **Consistency** | Single source of truth | Each instance has its own view |

## Alternatives

- **Memcached** — simpler, multi-threaded, key-value only. Better for pure caching when you do not need Redis's data structures or persistence. Lacks Redis Streams, pub/sub, and Lua scripting.
- **Dragonfly** — a modern, multi-threaded in-memory store with Redis-compatible API. Claims 25x throughput over Redis on the same hardware by leveraging parallelism.
- **KeyDB** — a multi-threaded Redis fork. Drop-in compatible with better multi-core utilization.
- **Apache Ignite / Hazelcast** — distributed in-memory data grids with SQL support and compute colocation. Better for enterprise caching with computation.
- **Ehcache / Caffeine (Java)** — local in-process caches. No network hop, but no sharing across instances. Best paired with Redis as a two-level cache (L1: Caffeine, L2: Redis).
- **etcd / Consul** — distributed key-value stores with strong consistency (Raft consensus). Better for configuration management and service discovery, not for high-throughput caching.

## Failure Modes

1. **Cache stampede (thundering herd)** → a popular cache key expires, and 100 concurrent requests all miss and hit the database simultaneously, causing a cascading outage → use cache-aside with jittered TTLs, or implement request coalescing (only one request populates the cache; others wait). Alternatively, use probabilistic early expiration.

2. **Memory eviction deleting live data** → the `maxmemory-policy` is set to `allkeys-lru`, and frequently accessed session keys are evicted under memory pressure → use `volatile-lru` (evict only keys with TTL) for cache data, and keep critical data in a separate Redis instance or database index.

3. **Slow commands blocking the event loop** → running `KEYS *`, `SMEMBERS` on a 10M-element set, or `HGETALL` on a hash with 500K fields blocks all other commands for seconds → never use `KEYS` in production (use `SCAN`). Use `SSCAN`/`HSCAN` for large collections. Monitor slow logs (`SLOWLOG GET`).

4. **Replication lag causing stale reads** → a replica is 2 seconds behind the master. A user writes data, then reads from the replica and sees stale data → for read-your-writes consistency, route reads to the master for a configurable window after a write, or use sticky sessions.

5. **Cluster slot migration failures during resharding** → adding a new node to a Redis Cluster requires moving hash slots. If a slot is in "migrating" state, requests for keys in that slot fail with `MOVED` or `ASK` errors → use a Redis client that handles cluster redirects automatically (e.g., Lettuce, JedisCluster). Automate resharding with `redis-cli --cluster reshard`.

6. **Fork-based persistence causing latency spikes** — RDB snapshots and AOF rewrites use `fork()`, which on Linux triggers copy-on-write. Under heavy write load during a fork, memory usage doubles and latency spikes → schedule snapshots during low-traffic windows. Monitor `child_fork` latency. Use `no-appendfsync-on-rewrite yes` to reduce AOF rewrite impact.

7. **Network partition causing split-brain in Sentinel** → a network partition isolates the master from sentinels. Sentinels promote a replica, but the old master still accepts writes from partitioned clients → configure `min-replicas-to-write` on the master to reject writes when isolated. Use network monitoring to detect partitions.

8. **Connection pool exhaustion** → your application opens a new Redis connection per request without pooling, hitting the `maxclients` limit (default 10,000) → use connection pooling (Lettuce shares connections; Jedis requires `JedisPool`). Set appropriate timeouts (`SET timeout 300` to close idle connections server-side).

9. **Data loss during failover** → a master crashes before its latest writes are replicated. Sentinel promotes a replica that is missing the last 5 seconds of data → enable `min-replicas-max-lag` and `repl-diskless-sync` to minimize data loss. For zero data loss, use AOF with `fsync=always` and accept the throughput penalty.

10. **Lua script atomicity violations** → a Lua script runs for >5 seconds, blocking all other commands. Redis 7+ has a Lua time limit (`lua-time-limit` 5000ms by default), but the script is not interrupted — it just stops accepting new commands → keep Lua scripts under 100ms. Break long scripts into smaller atomic operations.

## Code Examples

### Cache-Aside Pattern with Fallback (Go)

```go
type OrderCache struct {
    redis    *redis.Client
    db       OrderRepository
    jitter   time.Duration
}

func (c *OrderCache) GetOrder(ctx context.Context, id string) (*Order, error) {
    // 1. Try cache first
    cached, err := c.redis.Get(ctx, "order:"+id).Result()
    if err == nil {
        var order Order
        if err := json.Unmarshal([]byte(cached), &order); err == nil {
            return &order, nil
        }
    }

    // 2. Cache miss — fetch from DB
    order, err := c.db.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }

    // 3. Populate cache with jittered TTL to prevent stampede
    ttl := 10*time.Minute + time.Duration(rand.Int63n(int64(c.jitter)))
    serialized, _ := json.Marshal(order)
    c.redis.Set(ctx, "order:"+id, serialized, ttl)

    return order, nil
}
```

### Distributed Lock with Redlock Pattern (Python)

```python
import redis
from redlock import Redlock

# Three independent Redis instances for Redlock consensus
dlm = Redlock([
    {"host": "redis1.internal", "port": 6379, "db": 0},
    {"host": "redis2.internal", "port": 6379, "db": 0},
    {"host": "redis3.internal", "port": 6379, "db": 0},
])

def process_payment(order_id: str, amount: float):
    # Acquire lock with 10-second TTL
    acquired, lock = dlm.lock(f"payment_lock:{order_id}", 10_000)
    if not acquired:
        raise PaymentInProgressError(order_id)

    try:
        # Critical section — only one process can execute
        charge = charge_payment(order_id, amount)
        mark_order_paid(order_id)
    finally:
        dlm.unlock(lock)  # Release lock early, don't wait for TTL
```

### Rate Limiting with Sliding Window (Lua Script)

```lua
-- KEYS[1] = rate limit key (e.g., "rl:api:user:42")
-- ARGV[1] = current timestamp (microseconds)
-- ARGV[2] = window size (microseconds, e.g., 1_000_000 for 1 second)
-- ARGV[3] = max requests per window
-- ARGV[4] = unique request ID (for dedup)

local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local limit = tonumber(ARGV[3])
local request_id = ARGV[4]

-- Remove expired entries
redis.call('ZREMRANGEBYSCORE', key, 0, now - window)

-- Count current requests in window
local count = redis.call('ZCARD', key)

if count < limit then
    -- Allow: add request and set expiry
    redis.call('ZADD', key, now, request_id)
    redis.call('PEXPIRE', key, window / 1000)
    return 1  -- allowed
else
    return 0  -- rate limited
end
```

### Redis Streams for Event Processing (Java/Jedis)

```java
// Producer: publish events to a stream
Jedis jedis = new Jedis("redis://events-redis:6379");
Map<String, String> event = Map.of(
    "type", "order.created",
    "orderId", "ord-12345",
    "userId", "usr-42",
    "total", "99.99",
    "timestamp", String.valueOf(System.currentTimeMillis())
);
String messageId = jedis.xadd("order-events", StreamEntryID.NEW_ENTRY, event);

// Consumer: read from a consumer group
jedis.xgroupCreate("order-events", "fulfillment-group", StreamEntryID.LAST_ENTRY, true);

while (running) {
    List<Map.Entry<String, List<StreamEntry>>> entries =
        jedis.xreadGroup("fulfillment-group", "consumer-1",
            100, // block 100ms
            10,  // max 10 entries
            new AbstractMap.SimpleEntry<>("order-events", ">"));

    for (var groupEntries : entries) {
        for (StreamEntry entry : groupEntries.getValue()) {
            processEvent(entry.getFields());
            jedis.xack("order-events", "fulfillment-group", entry.getID());
        }
    }
}
```

## Best Practices

- **Always set a TTL on cache keys.** Untagged keys accumulate indefinitely and cause memory pressure. Use `volatile-lru` or `volatile-ttl` eviction policies.
- **Monitor the memory fragmentation ratio** (`redis-cli INFO memory` → `mem_fragmentation_ratio`). A ratio > 1.5 indicates significant fragmentation. Restart the instance or use `MEMORY PURGE` (jemalloc only).
- **Use `SCAN` instead of `KEYS`** in all production code. `KEYS *` is O(N) and blocks the entire server. `SCAN` is incremental and non-blocking.
- **Enable AOF with `fsync=everysec`** as the default persistence setting. It provides a reasonable balance between durability (lose at most 1 second of data) and performance (< 10% throughput impact).
- **Use connection pooling or a multiplexing client.** Lettuce (Java) and the Go redis/go-redis client multiplex a single connection. Jedis requires explicit pooling.
- **Separate concerns across Redis instances.** Do not mix caching, session storage, and pub/sub on the same instance. A slow query on one workload blocks all others.
- **Set `maxmemory` explicitly** — never let Redis run without a memory cap. When it hits the limit, the eviction policy kicks in predictably. Without a cap, the OS OOM-killer terminates Redis.
- **Use Redis Cluster for datasets > 10 GB or throughput > 100K ops/sec.** A single instance is limited by one CPU core and available RAM.
- **Implement circuit breakers around Redis calls.** When Redis is down, fail fast and fall back to the database or a degraded mode. Do not block waiting for a timeout.
- **Version your cache key schemas.** Include a version prefix (`"v2:order:42"`) so you can invalidate an entire key space during schema changes without flushing the entire database.
- **Benchmark before and after.** Use `redis-benchmark -t get,set,lpush -c 100 -n 100000` to establish baseline throughput. Profile your application's Redis usage with `redis-cli --latency` and `SLOWLOG`.

## Related Topics

- [[Caching]]
- [[DatabaseOptimization]]
- [[NoSQL]]
- [[Databases MOC]]
- [[Performance MOC]]
- [[Architecture MOC]]
- [[MessageQueues]]
- [[Backpressure]]
