---
title: GraphQL Architecture
title_pt: Arquitetura GraphQL
layer: architecture
type: pattern
priority: medium
version: 1.0.0
tags:
  - Architecture
  - GraphQL
  - API
  - Pattern
description: API query language and runtime for requesting exactly the data needed.
description_pt: Linguagem de consulta de API e runtime para solicitar exatamente os dados necessários.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# GraphQL Architecture

## Description

GraphQL is a query language and runtime for APIs that was developed by Facebook and released in 2015. Unlike traditional REST APIs where the server defines the structure of responses, GraphQL allows clients to specify exactly what data they need, enabling more efficient and flexible data fetching.

The core philosophy of GraphQL is declarative data fetching: clients describe their data requirements using a type system, and servers provide exactly what was requested. This solves several problems common in REST APIs:

1. **Over-fetching**: Getting more data than needed
2. **Under-fetching**: Making multiple requests to get all needed data
3. **Schema coupling**: Clients tied to specific endpoint structures

GraphQL provides a complete and understandable description of your data, gives clients the power to ask for exactly what they need, makes APIs easier to evolve over time, and enables powerful developer tools like GraphiQL and Apollo Client.

A GraphQL service is defined by types and fields on those types, not by endpoints. You define capabilities (types), and clients compose queries from those types. This creates a contract between client and server that is self-documenting and type-safe.

GraphQL is particularly valuable for:
- Mobile apps with varying data needs
- Complex frontend frameworks (React, Vue, Angular)
- Microservices requiring aggregated data
- APIs with evolving requirements

## Purpose

**When GraphQL is valuable:**
- For complex frontends with varying data needs
- When clients need different data shapes
- For aggregating data from multiple sources
- When API requirements evolve frequently
- For mobile apps with bandwidth constraints

**When to avoid GraphQL:**
- For simple, static APIs
- When RESTful is already working well
- When caching requirements are complex
- When security model is simple

## Rules

1. **Design types first** - Define schema before implementation
2. **Use connections for relationships** - Follow Relay specification
3. **Implement proper error handling** - Use errors extension
4. **Add caching strategically** - Use DataLoader for batching
5. **Secure the schema** - Implement proper authorization
6. **Version carefully** - Prefer evolution over versioning
7. **Document the schema** - Use description annotations

## Examples

### Schema Definition

```python
# GraphQL schema with types
type Query {
    user(id: ID!): User
    users(limit: Int, offset: Int): [User!]!
    posts(authorId: ID): [Post!]!
}

type Mutation {
    createUser(input: CreateUserInput!): User!
    updateUser(id: ID!, input: UpdateUserInput!): User
    deleteUser(id: ID!): Boolean!
    createPost(input: CreatePostInput!): Post!
}

type User {
    id: ID!
    name: String!
    email: String!
    avatar: String
    createdAt: DateTime!
    posts: [Post!]!
    friends: [User!]!
    friendCount: Int!
}

type Post {
    id: ID!
    title: String!
    content: String!
    author: User!
    comments: [Comment!]!
    commentCount: Int!
    createdAt: DateTime!
    updatedAt: DateTime
}

input CreateUserInput {
    name: String!
    email: String!
    avatar: String
}

input CreatePostInput {
    title: String!
    content: String!
    authorId: ID!
}

enum DateTime {
    # ISO 8601 format
}
```

### Resolver Implementation

```python
# Graphene-Django implementation
import graphene
from graphene_django import DjangoObjectType
from .models import User, Post

class UserType(DjangoObjectType):
    class Meta:
        model = User
        fields = "__all__"
    
    # Computed field
    friend_count = graphene.Int()
    
    # Resolver for computed field
    def resolve_friend_count(self, info):
        return self.friends.count()

class PostType(DjangoObjectType):
    class Meta:
        model = Post
        fields = "__all__"
    
    comment_count = graphene.Int()
    
    def resolve_comment_count(self, info):
        return self.comments.count()

class Query(graphene.ObjectType):
    user = graphene.Field(UserType, id=graphene.ID(required=True))
    users = graphene.List(UserType, limit=graphene.Int(), offset=graphene.Int())
    posts = graphene.List(PostType, author_id=graphene.ID())
    
    def resolve_user(self, info, id):
        return User.objects.get(id=id)
    
    def resolve_users(self, info, limit=None, offset=None):
        queryset = User.objects.all()
        if offset:
            queryset = queryset[offset:]
        if limit:
            queryset = queryset[:limit]
        return queryset
    
    def resolve_posts(self, info, author_id=None):
        queryset = Post.objects.all()
        if author_id:
            queryset = queryset.filter(author_id=author_id)
        return queryset

class Mutation(graphene.ObjectType):
    create_user = CreateUser.Field()
    update_user = UpdateUser.Field()
    delete_user = DeleteUser.Field()
    create_post = CreatePost.Field()

class CreateUser(graphene.Mutation):
    class Arguments:
        input = CreateUserInput(required=True)
    
    user = graphene.Field(UserType)
    
    @classmethod
    def mutate(cls, root, info, input):
        user = User.objects.create(
            name=input.name,
            email=input.email,
            avatar=input.avatar
        )
        return CreateUser(user=user)

schema = graphene.Schema(query=Query, mutation=Mutation)
```

### DataLoader for Batching

```python
# DataLoader - prevents N+1 queries
from dataloader import DataLoader

class UserLoader(DataLoader):
    def batch_load_fn(self, user_ids):
        # Fetch all users in one query
        users = User.objects.filter(id__in=user_ids)
        user_map = {user.id: user for user in users}
        
        # Return in same order as requested
        return [user_map.get(uid) for uid in user_ids]

# In resolver
class PostType(graphene.ObjectType):
    author = graphene.Field(UserType)
    
    def resolve_author(self, info):
        # Use dataloader to batch requests
        loader = info.context.loaders['user']
        return loader.load(self.author_id)

# Add to context
def get_context(request):
    return {
        'request': request,
        'loaders': {
            'user': UserLoader(),
            'post': PostLoader(),
        }
    }
```

### Apollo Server Setup

```javascript
// Apollo Server with authentication
const { ApolloServer, gql } = require('apollo-server');
const typeDefs = gql`
  type Query {
    currentUser: User
  }
  
  type User {
    id: ID!
    name: String!
    email: String!
  }
`;

const resolvers = {
  Query: {
    currentUser: (parent, args, context) => {
      // Check authentication
      if (!context.user) {
        throw new AuthenticationError('Not authenticated');
      }
      return context.user;
    }
  }
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: async ({ req }) => {
    // Extract token from header
    const token = req.headers.authorization;
    
    if (token) {
      const user = await authenticate(token);
      return { user };
    }
  },
  formatError: (error) => {
    // Don't expose internal errors to clients
    return {
      message: error.message,
      locations: error.locations,
      path: error.path
    };
  }
});

server.listen().then(({ url }) => {
  console.log(`Server ready at ${url}`);
});
```

## Anti-Patterns

### 1. Over-fetching in Resolver

**Bad:**
- Fetching all fields even when not requested

```python
# BAD - always fetching related objects
def resolve_user(self, info, id):
    user = User.objects.get(id=id)
    user.posts  # Always fetched!
    return user
```

**Solution:**
- Use info.field_name in resolver to check what's needed
- Use DataLoader for batching

### 2. Not Securing the Schema

**Bad:**
- Exposing internal fields
- No authorization checks

```python
# BAD - exposing sensitive data
type User {
    password: String  # Never expose!
    internal_id: ID
}
```

**Solution:**
- Hide sensitive fields
- Add authorization in resolvers
- Use schema directives

### 3. Deep Query Nesting

**Bad:**
- Allowing unlimited nesting
- Creating performance issues

```query
# BAD - infinite nesting
query {
  user {
    posts {
      comments {
        author {
          posts {
            comments { ... }
          }
        }
      }
    }
  }
}
```

**Solution:**
- Set max depth in server config
- Use pagination at each level
- Limit query complexity

## Best Practices

### 1. Pagination with Connections

```python
# Cursor-based pagination (Relay)
class Query(graphene.ObjectType):
    users = graphene.ConnectionField(UserConnection)
    
    def resolve_users(self, info, **kwargs):
        # Get pagination args
        first = kwargs.get('first', 10)
        after = kwargs.get('after')
        
        queryset = User.objects.all()
        
        if after:
            queryset = queryset.filter(id__gt=after)
        
        return queryset[:first + 1]

class UserConnection(graphene.Connection):
    class Edge:
        cursor = graphene.String()
    
    class Meta:
        node = UserType
```

### 2. Error Handling

```python
# Structured error responses
{
  "errors": [
    {
      "message": "User not found",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["user"],
      "extensions": {
        "code": "NOT_FOUND",
        "timestamp": "2024-01-15T10:30:00Z"
      }
    }
  ]
}
```

### 3. Schema Versioning

```python
# Deprecate rather than remove
type User {
    # Old field - deprecated
    fullName: String @deprecated(reason: "Use 'name' instead")
    
    # New field
    name: String!
}
```

## Technology Stack

| Tool | Use Case |
|------|----------|
| Apollo Server | Node.js GraphQL server |
| Graphene | Python GraphQL |
| Absinthe | Elixir GraphQL |
| Apollo Client | React client |
| URQL | Lightweight client |
| Hasura | GraphQL over Postgres |

## Failure Modes

- **N+1 query problem from nested resolvers** → each field triggers separate database query → exponential query count → use DataLoader batching to consolidate queries into single round trips
- **Deeply nested queries causing resource exhaustion** → client requests infinite nesting levels → server memory and CPU exhaustion → enforce query depth limits and complexity analysis before execution
- **Introspection exposing internal schema in production** → attackers discover all types and mutations → attack surface mapping → disable introspection in production or restrict to authenticated users
- **Missing authorization at field level** → resolver returns data without checking permissions → unauthorized data access → implement field-level authorization checks in every resolver
- **Unbounded list responses** → query returns all records without pagination → memory overflow → enforce pagination with cursor-based connections and maximum page sizes
- **Schema design coupling to UI needs** → GraphQL schema mirrors specific frontend requirements → backend becomes frontend-specific → design schema around domain concepts, not UI components
- **Error masking in GraphQL responses** → errors returned alongside partial data → clients cannot distinguish success from failure → use proper error extensions with codes

## Related Topics

- [[Architecture MOC]]
- [[REST]]
- [[APIDesign]]
- [[Microservices]]
- [[EventArchitecture]]

## Key Takeaways

- GraphQL lets clients declaratively request exactly the data they need through a type-safe schema, solving REST's over-fetching and under-fetching problems
- Valuable for complex frontends with varying data needs, mobile apps with bandwidth constraints, or APIs aggregating data from multiple sources
- Avoid for simple static APIs, when REST already works well, or when caching/security requirements are complex
- Tradeoff: flexible client-driven queries versus N+1 query risks, complex caching, and the need for query depth/complexity limits
- Main failure mode: deeply nested queries without limits cause resource exhaustion; N+1 resolver queries cause exponential database load
- Best practice: design schema around domain concepts (not UI), use DataLoader for batching, enforce query depth limits, implement field-level authorization, and deprecate rather than remove fields
- Related: REST, API design, microservices, event-driven architecture

## Additional Notes

**GraphQL vs REST:**
- GraphQL: Client specifies exact needs
- REST: Server defines response structure

**N+1 Problem:**
- Solved with DataLoader batching
- Common performance issue

**Security Considerations:**
- Query complexity limits
- Rate limiting
- Authorization at field level
- Introspection in production

**When to use:**
- Complex frontends
- Mobile apps
- Aggregating multiple services
- Evolving APIs