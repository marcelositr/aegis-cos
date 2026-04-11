---
title: Serverless
title_pt: Serverless (Arquitetura Sem Servidor)
layer: architecture
type: pattern
priority: medium
version: 1.0.0
tags:
  - Architecture
  - Serverless
  - Cloud
  - Pattern
description: Cloud execution model where cloud provider manages server infrastructure.
description_pt: Modelo de execução em nuvem onde o provedor gerencia a infraestrutura do servidor.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Serverless

## Description

Serverless architecture is a cloud computing execution model where the cloud provider dynamically manages the allocation and provisioning of servers. The name "serverless" is somewhat misleading - there are still servers - but the developers don't need to think about them. They simply deploy code, and the cloud provider handles all the infrastructure concerns.

In serverless computing, the cloud provider runs the serverless code on demand, scaling automatically based on request volume. Users are charged only for the compute time they consume, rather than for provisioned infrastructure. This model shifts operational responsibilities from the developer to the cloud provider.

Key characteristics of serverless:
- **No server management**: Developers don't provision or manage servers
- **Automatic scaling**: Scales up or down based on demand
- **Pay per use**: Only charged for actual compute time
- **Stateless**: Functions don't maintain state between executions
- **Event-driven**: Functions respond to events or HTTP requests

Popular serverless platforms include AWS Lambda, Google Cloud Functions, Azure Functions, and Cloudflare Workers. Each offers different languages, limits, and integrations, but share the core serverless principles.

Serverless is ideal for:
- Event-driven workloads
- Variable traffic patterns
- Quick prototyping
- Cost-effective burst handling

However, serverless isn't suitable for all use cases. Long-running processes, consistent high-load workloads, or applications requiring fine-grained control may be better served by traditional or container-based architectures.

## Purpose

**When serverless is valuable:**
- For event-driven applications
- With variable, unpredictable traffic
- For rapid prototyping and deployment
- When you want to reduce operational overhead
- For batch jobs or periodic tasks
- For API backends with variable load

**When to avoid serverless:**
- For consistent high-load workloads
- When low latency is critical
- For long-running processes
- When vendor lock-in is a concern

## Rules

1. **Design for statelessness** - Functions should not rely on local state
2. **Keep functions small** - Single responsibility functions
3. **Minimize cold starts** - Optimize for fast initialization
4. **Use managed services** - Leverage cloud-native databases and storage
5. **Implement proper error handling** - Functions can fail
6. **Monitor costs** - Pay attention to invocation costs
7. **Design for retries** - Functions may be retried
8. **Separate concerns** - Don't bundle multiple functions unnecessarily

## Examples

### AWS Lambda Function

```python
# Lambda handler
import json
import boto3

def lambda_handler(event, context):
    # Parse the event
    body = json.loads(event.get('body', '{}'))
    
    # Process the request
    action = body.get('action')
    
    if action == 'create_user':
        return create_user(body)
    elif action == 'get_user':
        return get_user(body.get('user_id'))
    
    return {
        'statusCode': 400,
        'body': json.dumps({'error': 'Unknown action'})
    }

def create_user(data):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    
    user_id = data.get('user_id')
    table.put_item(Item={
        'user_id': user_id,
        'name': data.get('name'),
        'email': data.get('email'),
        'created_at': __import__('datetime').datetime.utcnow().isoformat()
    })
    
    return {
        'statusCode': 201,
        'body': json.dumps({'user_id': user_id, 'status': 'created'})
    }

def get_user(user_id):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    
    response = table.get_item(Key={'user_id': user_id})
    item = response.get('Item')
    
    if not item:
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'User not found'})
        }
    
    return {
        'statusCode': 200,
        'body': json.dumps(item)
    }
```

### Serverless API with API Gateway

```yaml
# serverless.yml - Serverless Framework
service: user-api

provider:
  name: aws
  runtime: python3.9
  stage: ${opt:stage, 'dev'}
  environment:
    TABLE_NAME: ${self:service}-${self:provider.stage}
  iam:
    role:
      statements:
        - Effect: Allow
          Action:
            - dynamodb:Query
            - dynamodb:GetItem
            - dynamodb:PutItem
          Resource: !GetAtt UsersTable.Arn

functions:
  getUser:
    handler: handler.get_user
    events:
      - http:
          path: users/{user_id}
          method: get
          cors: true

  createUser:
    handler: handler.create_user
    events:
      - http:
          path: users
          method: post
          cors: true

  listUsers:
    handler: handler.list_users
    events:
      - http:
          path: users
          method: get
          cors: true

resources:
  Resources:
    UsersTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:provider.environment.TABLE_NAME}
        BillingMode: PAY_PER_REQUEST
        AttributeDefinitions:
          - AttributeName: user_id
            AttributeType: S
        KeySchema:
          - AttributeName: user_id
            KeyType: HASH
```

### Cloudflare Worker

```javascript
// Cloudflare Worker - Edge serverless
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    
    // Router
    if (url.pathname === '/api/users' && request.method === 'GET') {
      return handleGetUsers(env);
    }
    
    if (url.pathname.startsWith('/api/users/') && request.method === 'GET') {
      const userId = url.pathname.split('/').pop();
      return handleGetUser(env, userId);
    }
    
    return new Response('Not Found', { status: 404 });
  }
};

async function handleGetUsers(env) {
  const users = await env.DB.prepare(
    'SELECT * FROM users LIMIT 10'
  ).all();
  
  return new Response(JSON.stringify(users), {
    headers: { 'Content-Type': 'application/json' }
  });
}

async function handleGetUser(env, userId) {
  const user = await env.DB.prepare(
    'SELECT * FROM users WHERE id = ?'
  ).bind(userId).first();
  
  if (!user) {
    return new Response(JSON.stringify({ error: 'Not found' }), { 
      status: 404 
    });
  }
  
  return new Response(JSON.stringify(user), {
    headers: { 'Content-Type': 'application/json' }
  });
}
```

### Event-Driven Serverless

```python
# S3 trigger Lambda - image processing
import boto3
import urllib.parse

s3 = boto3.client('s3')

def handler(event, context):
    # Get the bucket and key from the event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    
    # Download the image
    download_path = f'/tmp/{key}'
    s3.download_file(bucket, key, download_path)
    
    # Process image (resize, optimize)
    process_image(download_path)
    
    # Upload processed image
    processed_key = f'processed/{key}'
    s3.upload_file(download_path, bucket, processed_key)
    
    # Generate thumbnail
    thumbnail_key = f'thumbnails/{key}'
    create_thumbnail(download_path, bucket, thumbnail_key)
    
    return {
        'statusCode': 200,
        'body': f'Processed {key}'
    }

def process_image(path):
    # Image processing logic
    pass

def create_thumbnail(path, bucket, key):
    # Thumbnail creation
    pass
```

## Anti-Patterns

### 1. Long-Running Functions

**Bad:**
- Functions that run for minutes
- Complex processing in single function

**Solution:**
- Break into smaller functions
- Use step functions for orchestration
- Consider containers for long tasks

### 2. Heavy Dependencies

**Bad:**
- Large dependency trees
- Slow cold starts

**Solution:**
- Use minimal dependencies
- Consider Lambda layers
- Pre-compile dependencies

### 3. Not Handling Idempotency

**Bad:**
- Functions that modify state without idempotency checks
- Duplicate processing on retries

**Solution:**
- Use idempotency keys
- Check for existing work before processing
- Design for retries

## Best Practices

### 1. Environment Configuration

```python
# Environment variables for configuration
import os

def handler(event, context):
    db_host = os.environ.get('DB_HOST')
    db_name = os.environ.get('DB_NAME')
    api_key = os.environ.get('API_KEY')
    
    # Use configuration
    pass
```

### 2. Proper Error Handling

```python
# Structured error handling
import json
import logging

logger = logging.getLogger()

def handler(event, context):
    try:
        result = process_request(event)
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    except ValidationError as e:
        logger.warning(f"Validation error: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }
    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal error'})
        }
```

### 3. Connection Pooling

```python
# Reuse connections across invocations
import boto3
import os

# Global connection
dynamodb = None

def get_dynamodb():
    global dynamodb
    if dynamodb is None:
        dynamodb = boto3.resource('dynamodb')
    return dynamodb

def handler(event, context):
    db = get_dynamodb()
    # Use db
```

### 4. Performance Optimization

```python
# Minimize cold start time
# 1. Keep handler lightweight
def handler(event, context):
    # Do imports at global level
    pass

import json
import boto3

# 2. Initialize outside handler
s3 = boto3.client('s3')

def handler(event, context):
    s3.get_object(...)  # Use pre-initialized client
```

## Failure Modes

- **Cold start latency** → first request after idle takes seconds → user-facing timeout → need provisioned concurrency
- **Execution timeout** → function exceeds time limit → partial work → need idempotency and retries
- **Memory exhaustion** → function allocated too little memory → OOM kill → monitor and right-size
- **Concurrent execution limit** → provider caps concurrent functions → requests queued or rejected → request limit increase
- **Dependency bloat** → large package → slow cold starts → use layers, tree-shake dependencies
- **Vendor lock-in** → heavy use of provider-specific APIs → migration becomes expensive → abstract provider calls
- **Cost surprise** → unexpected traffic spike → massive bill → set budgets and alerts

## Technology Stack

| Provider | Service | Languages |
|----------|---------|-----------|
| AWS | Lambda | Node.js, Python, Java, Go, Ruby |
| Google | Cloud Functions | Node.js, Python, Go, Java |
| Microsoft | Azure Functions | C#, JavaScript, Python, Java |
| Cloudflare | Workers | JavaScript, Rust |
| Vercel | Functions | Node.js, Python, Go |
| Netlify | Functions | Node.js |

## Related Topics

- [[EventArchitecture]]
- [[Docker]]
- [[Kubernetes]]
- [[CiCd]]
- [[Monitoring]]
- [[APIDesign]]
- [[Idempotency]]

## Additional Notes

**Serverless vs Containers:**
- Serverless: Auto-scale to zero, pay per use
- Containers: More control, predictable costs

**Cold Starts:**
- First invocation after idle is slower
- Varies by provider and language
- Can be mitigated with provisioned concurrency

**Vendor Lock-in:**
- Each provider has different APIs
- Consider abstraction layers
- Keep functions small and portable

**Cost Optimization:**
- Right-size memory allocation
- Use provisioned concurrency for consistent workloads
- Monitor for unused functions

## Key Takeaways

- Serverless is a cloud execution model where the provider manages infrastructure, automatically scales, and charges only for actual compute time consumed.
- Use for event-driven workloads, variable/unpredictable traffic, rapid prototyping, batch jobs, and API backends with variable load.
- Do NOT use for consistent high-load workloads, low-latency-critical applications, long-running processes, or when vendor lock-in is a major concern.
- Key tradeoff: zero operational overhead and pay-per-use pricing vs. cold start latency, vendor lock-in, and potential cost surprises at scale.
- Main failure mode: cold start latency causing user-facing timeouts, or unexpected traffic spikes generating massive bills.
- Best practice: design stateless functions, minimize dependencies for fast cold starts, implement idempotency for retries, and use connection pooling.
- Related concepts: Event-Driven Architecture, API Gateway, Lambda Functions, Cloud Providers, Containers, Idempotency, Edge Computing.