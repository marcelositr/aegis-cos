---
title: NoSQL
title_pt: NoSQL
layer: databases
type: concept
priority: high
version: 1.0.0
tags:
  - Databases
  - NoSQL
  - Non-Relational
  - Concept
description: Non-relational database patterns and use cases.
description_pt: Padrões e casos de uso de banco de dados não relacional.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# NoSQL

## Description

NoSQL (Not Only SQL) databases are non-relational databases designed for specific data models and flexible schemas. They emerged to address limitations of relational databases, particularly around scalability, flexibility, and handling unstructured data.

NoSQL databases are categorized by their data model:
- **Document** - MongoDB, CouchDB (JSON documents)
- **Key-Value** - Redis, DynamoDB (simple key-value pairs)
- **Column-Family** - Cassandra, HBase (wide columns)
- **Graph** - Neo4j, Amazon Neptune (relationships)

Key characteristics:
- **Flexible schemas** - No fixed structure
- **Horizontal scaling** - Easy to add nodes
- **High performance** - Optimized for specific operations
- **Eventual consistency** - Often traded for availability

NoSQL excels in:
- Big data applications
- Real-time web apps
- Content management
- Caching layers

## Purpose

**When NoSQL is appropriate:**
- For flexible data structures
- When horizontal scaling is needed
- For high read/write throughput
- For specific access patterns

**When SQL is better:**
- For complex joins
- When ACID is critical
- For structured data with relationships
- For reporting/analytics

## Rules

1. **Understand access patterns** - Design for how data is used
2. **Design for scale** - Think about partitioning
3. **Handle consistency** - Choose appropriate level
4. **Use appropriate data model** - Match to use case
5. **Plan for failure** - NoSQL assumes failures

## Examples

### MongoDB Document Model

```javascript
// Collection: users
{
  "_id": ObjectId("..."),
  "username": "john_doe",
  "email": "john@example.com",
  "profile": {
    "firstName": "John",
    "lastName": "Doe",
    "bio": "Software engineer",
    "avatar": "https://...",
    "socialLinks": [
      { "platform": "twitter", "url": "..." },
      { "platform": "github", "url": "..." }
    ]
  },
  "preferences": {
    "theme": "dark",
    "notifications": {
      "email": true,
      "push": false
    },
    "language": "en"
  },
  "createdAt": ISODate("2024-01-15"),
  "lastLogin": ISODate("2024-01-20")
}

// Embed related data
{
  "_id": ObjectId("..."),
  "userId": ObjectId("..."),
  "items": [
    {
      "productId": ObjectId("..."),
      "name": "Widget",
      "quantity": 2,
      "price": 19.99
    },
    {
      "productId": ObjectId("..."),
      "name": "Gadget",
      "quantity": 1,
      "price": 49.99
    }
  ],
  "total": 89.97,
  "status": "completed"
}
```

### Redis Data Types

```javascript
// String - simple values
await redis.set('user:123:profile', JSON.stringify({ name: 'John' }));
await redis.get('user:123:profile');

// Hash - objects
await redis.hSet('user:123', 'name', 'John');
await redis.hSet('user:123', 'email', 'john@example.com');
await redis.hGetAll('user:123');

// List - ordered values
await redis.lPush('recent_searches', 'javascript');
await redis.lPush('recent_searches', 'python');
await redis.lRange('recent_searches', 0, 9);

// Set - unique values
await redis.sAdd('user:123:tags', 'developer', 'engineer', 'python');
await redis.sMembers('user:123:tags');

// Sorted Set - ranked items
await redis.zAdd('leaderboard', { score: 1000, value: 'user1' });
await redis.zAdd('leaderboard', { score: 1500, value: 'user2' });
await redis.zRangeWithScores('leaderboard', 0, 9);

// Pub/Sub
await redis.subscribe('notifications', (message) => {
  console.log('Received:', message);
});
await redis.publish('notifications', 'New message!');
```

### Cassandra Wide Columns

```sql
-- Table for time-series data
CREATE TABLE sensor_readings (
    sensor_id UUID,
    timestamp TIMESTAMP,
    temperature DOUBLE,
    humidity DOUBLE,
    battery_level DOUBLE,
    PRIMARY KEY (sensor_id, timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC)
  AND compaction = {'class': 'TimeWindowCompactionStrategy'}
  AND default_time_to_live = 31536000;

-- Query by sensor and time range
SELECT * FROM sensor_readings 
WHERE sensor_id = ? 
AND timestamp > ? 
AND timestamp < ?;

-- Wide column for user events (many columns per row)
CREATE TABLE user_events (
    user_id UUID,
    event_type TEXT,
    event_time TIMESTAMP,
    event_data MAP<TEXT, TEXT>,
    PRIMARY KEY (user_id, event_type, event_time)
) WITH CLUSTERING ORDER BY (event_type ASC, event_time DESC);
```

### Neo4j Graph Model

```cypher
// Create nodes
CREATE (alice:Person {name: 'Alice', age: 30})
CREATE (bob:Person {name: 'Bob', age: 25})
CREATE (charlie:Person {name: 'Charlie', age: 35})

// Create relationships
CREATE (alice)-[:KNOWS {since: 2020}]->(bob)
CREATE (bob)-[:KNOWS {since: 2019}]->(charlie)
CREATE (alice)-[:WORKED_WITH {project: 'ProjectX'}]->(charlie)

// Query patterns
MATCH (person:Person {name: 'Alice'})-[:KNOWS]->(friend)
RETURN friend.name, friend.age

// Find friends of friends
MATCH (alice:Person {name: 'Alice'})-[:KNOWS]->()-[:KNOWS]->(fof)
WHERE NOT (alice)-[:KNOWS]->(fof)
RETURN DISTINCT fof.name

// Shortest path
MATCH (start:Person {name: 'Alice'}), (end:Person {name: 'Charlie'})
MATCH path = shortestPath((start)-[:KNOWS*..5]-(end))
RETURN path
```

## Anti-Patterns

### 1. Using Wrong Data Model

```javascript
// BAD - Storing relational data as documents
{
  "orderId": 123,
  "customerName": "John",
  "items": [
    { "itemId": 1, "name": "Widget", "categoryId": 10, "categoryName": "Gadgets" },
    { "itemId": 2, "name": "Gadget", "categoryId": 10, "categoryName": "Gadgets" }
  ]
}

// GOOD - Use reference for normalized data
{
  "orderId": 123,
  "customerId": "customer_123",
  "itemIds": ["item_1", "item_2"]
}

// Reference lookup separately
{
  "items": [
    { "itemId": "item_1", "categoryRef": "category_10" }
  ]
}
```

### 2. No Connection Management

```javascript
// BAD - Create new connection for each request
app.get('/user/:id', async (req, res) => {
  const client = new MongoClient(url);  // Expensive!
  await client.connect();
  const user = await client.db().collection('users').findOne({ id: req.params.id });
  await client.close();
  res.json(user);
});

// GOOD - Reuse connection
const client = new MongoClient(url);
await client.connect();

app.get('/user/:id', async (req, res) => {
  const user = await client.db().collection('users').findOne({ id: req.params.id });
  res.json(user);
});
```

### 3. Ignoring Consistency

```javascript
// Ignoring eventual consistency issues
// BAD - Read after write without handling staleness
await collection.insertOne({ _id: 1, value: 'test' });
const result = await collection.findOne({ _id: 1 }); // Might not exist yet!

// GOOD - Handle with read concern or retry
await collection.insertOne({ _id: 1, value: 'test' });
await collection.findOne({ _id: 1 }); // With retry or read preference
```

## Failure Modes

- **Wrong data model for access patterns** → inefficient queries → high latency and cost → design schema around read patterns, not storage structure
- **Ignoring eventual consistency** → stale reads → data integrity issues → handle consistency requirements at the application level
- **No connection management** → connection exhaustion → service unavailability → reuse connections with proper pooling
- **Hot partition problem** → uneven data distribution → single node bottleneck → use hashed or composite partition keys for even distribution
- **Missing TTL on ephemeral data** → unbounded storage growth → increased costs → set TTLs on time-sensitive documents
- **Schema-less chaos** → inconsistent data → application errors → enforce schema validation at the application layer
- **No backup strategy** → data loss → unrecoverable state → implement point-in-time recovery and cross-region backups

## Best Practices

### Data Modeling

```javascript
// Model for read pattern, not storage structure
// Query: Get all orders for a user with items
// Embed items in order document
{
  "orderId": "123",
  "userId": "user_1",
  "createdAt": "2024-01-15",
  "items": [
    { "productId": "p1", "name": "Widget", "qty": 2, "price": 10 }
  ],
  "total": 20
}

// Query: Get user's recent orders
// Denormalize user info in order
{
  "orderId": "123",
  "userId": "user_1",
  "userName": "John Doe",  // Denormalized for quick reads
  "items": [...]
}
```

### Scaling Strategy

```javascript
// Shard by user_id for even distribution
shardCollection("mydb.orders", { userId: "hashed" });

// Use read replicas for scaling reads
const options = {
  readPreference: 'secondaryPreferred',
  retryWrites: true,
  retryReads: true
};
const client = new MongoClient(uri, options);
```

## Technology Stack

| Type | Database | Use Case |
|------|----------|----------|
| Document | MongoDB | General purpose |
| Key-Value | Redis | Caching, session |
| Wide Column | Cassandra | Time-series |
| Graph | Neo4j | Relationships |

## Related Topics

- [[SQL]]
- [[Caching]]
- [[DatabaseOptimization]]
- [[DataStructures]]
- [[Complexity]]
- [[Monitoring]]
- [[EventSourcing]]
- [[DDD]]

## Additional Notes

**NoSQL Types:**
- Document: MongoDB, CouchDB
- Key-Value: Redis, DynamoDB
- Column: Cassandra, HBase
- Graph: Neo4j, Amazon Neptune

**When to Use:**
- Flexible schemas
- Horizontal scaling
- Specific access patterns
- High throughput

**Trade-offs:**
- Less consistency
- Less query flexibility
- More client-side logic