---
title: Docker
title_pt: Docker
layer: devops
type: tool
priority: high
version: 1.0.0
tags:
  - DevOps
  - Docker
  - Container
  - Tool
description: Platform for building, running, and managing containerized applications.
description_pt: Plataforma para construir, executar e gerenciar aplicações em containers.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Docker

## Description

Docker is an open platform for developing, shipping, and running applications using containerization. Containers are lightweight, standalone packages that include everything needed to run software: code, runtime, system tools, libraries, and settings. Unlike virtual machines, containers share the host OS kernel, making them much more efficient.

Docker became the standard for containerization because:
- **Consistency**: Same environment from dev to production
- **Isolation**: Applications run in isolated environments
- **Efficiency**: Much lighter than VMs
- **Portability**: Runs anywhere Docker is installed

Key Docker concepts:
- **Image**: Read-only template for creating containers
- **Container**: Running instance of an image
- **Dockerfile**: Script defining how to build an image
- **Registry**: Storage for Docker images (Docker Hub, ECR, etc.)
- **Docker Compose**: Define multi-container applications

Docker enables microservices architectures by allowing each service to run in its own container with its dependencies, making it easy to deploy, scale, and maintain complex applications.

## Purpose

**When Docker is valuable:**
- For consistent environments across dev/prod
- In microservices architectures
- For CI/CD pipelines
- When scaling applications
- For local development

**When to avoid:**
- For very simple single-service apps
- When container overhead is too high
- In environments that don't support containers

## Rules

1. **Use official base images** - Start from trusted sources
2. **Minimize image size** - Use multi-stage builds, small base images
3. **Don't run as root** - Use USER directive
4. **Use .dockerignore** - Exclude unnecessary files
5. **Set health checks** - Monitor container health
6. **Use specific tags** - Don't use 'latest' in production
7. **Cache intelligently** - Order instructions for better caching
8. **Use multi-stage builds** - Reduce final image size

## Examples

### Basic Dockerfile

```dockerfile
# Use specific version, not latest
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Change ownership
CHOWN nodejs:nodejs .

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Define health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

# Start application
CMD ["node", "server.js"]
```

### Multi-Stage Build

```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine AS production

WORKDIR /app

# Copy only production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Create user and set ownership
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

USER nodejs

EXPOSE 3000

CMD ["node", "dist/server.js"]
```

### Python with Multi-Stage

```dockerfile
# Build stage
FROM python:3.11-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Production stage
FROM python:3.11-slim AS production

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

COPY . .

RUN useradd -m -u 1000 appuser && \
    chown -R appuser /app

USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=db
      - REDIS_HOST=redis
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=app
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d app"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - app

volumes:
  postgres_data:
  redis_data:
```

### Optimization Example

```dockerfile
# BAD: Poor caching, large image
FROM ubuntu
RUN apt-get update
RUN apt-get install -y python3 python3-pip
RUN pip install flask
COPY . /app
WORKDIR /app
CMD ["python3", "app.py"]

# GOOD: Optimized
FROM python:3.11-slim

WORKDIR /app

# Copy only requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Then copy code
COPY . .

CMD ["python", "app.py"]
```

## Anti-Patterns

### 1. Running as Root

```dockerfile
# BAD
FROM node:18
COPY . .
CMD ["node", "app.js"]

# GOOD
FROM node:18
RUN adduser -m -u 1000 appuser
COPY --chown=appuser:appuser . .
USER appuser
CMD ["node", "app.js"]
```

### 2. Using Latest Tag

```dockerfile
# BAD - unpredictable
FROM node:latest
FROM python:latest

# GOOD - specific version
FROM node:18-alpine
FROM python:3.11-slim
```

### 3. Not Using .dockerignore

```dockerfile
# Without .dockerignore, copies everything including:
# - node_modules (huge!)
# - .git
# - coverage
# - .env files
# - logs
```

Create `.dockerignore`:
```
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.env.local
coverage/
.vscode/
.idea/
*.md
```

## Best Practices

### Security Scanning

```bash
# Scan images for vulnerabilities
docker scout cves myimage:latest

# Use Trivy
trivy image myimage:latest

# Scan in CI
- name: Run Trivy scanner
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
    scan-ref: '.'
    format: 'sarif'
```

### Image Size Optimization

```dockerfile
# Use Alpine for small base
FROM node:18-alpine  # ~170MB vs ~900MB

# Use slim variants
FROM python:3.11-slim  # ~140MB vs ~900MB

# Multi-stage builds
# Build in one stage, copy to production stage

# Don't install dev dependencies
RUN npm ci --only=production
```

### Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/health || exit 1
```

## Failure Modes

- **Running as root** → container escape → host compromise → always use USER directive
- **Secrets in image** → API keys in Dockerfile → exposed in registry → use build args, secrets mount, or external vault
- **Image bloat** → dev dependencies in production → large attack surface → use multi-stage builds, slim base images
- **No health checks** → container appears running but app is dead → load balancer sends traffic → user errors
- **Using latest tag** → unpredictable builds → different behavior across environments → pin versions
- **No .dockerignore** → .env files in image → secrets leaked → always use .dockerignore
- **Layer cache invalidation** → COPY . before dependencies → every change rebuilds everything → order matters
- **Container resource limits missing** → one container consumes all host memory → OOM kills other containers → set limits

## Technology Stack

| Tool | Use Case |
|------|----------|
| Docker Compose | Multi-container apps |
| Docker Hub | Image registry |
| BuildKit | Build optimization |
| Buildah | Building without Docker |

## Related Topics

- [[Kubernetes]]
- [[CiCd]]
- [[ContainerOrchestration]]
- [[InfrastructureAsCode]]
- [[Monitoring]]
- [[Logging]]
- [[ServiceMesh]]
- [[Serverless]]

## Additional Notes

**Key Commands:**
```bash
docker build -t myapp .
docker run -d -p 3000:3000 myapp
docker ps
docker logs -f container_id
docker exec -it container_id sh
docker-compose up -d
```

**Best Practices:**
- Use specific versions
- Don't run as root
- Use .dockerignore
- Multi-stage builds
- Scan for vulnerabilities
- Use health checks

## Key Takeaways

- Docker packages applications into lightweight, portable containers that include everything needed to run, sharing the host OS kernel for efficiency.
- Use for consistent environments across dev/prod, microservices architectures, CI/CD pipelines, and local development with complex dependencies.
- Do NOT use for very simple single-service apps, environments that don't support containers, or when container overhead is prohibitive.
- Key tradeoff: environment consistency and isolation vs. added build/deployment complexity and image management overhead.
- Main failure mode: running containers as root or embedding secrets in images, leading to container escape and credential exposure.
- Best practice: use multi-stage builds for small images, pin specific base image versions, never run as root, use .dockerignore, and add health checks.
- Related concepts: Kubernetes, Container Orchestration, Docker Compose, CI/CD, Service Mesh, Infrastructure as Code, Image Registries.