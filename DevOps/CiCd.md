---
title: CI/CD
title_pt: CI/CD (Integração Contínua / Entrega Contínua)
layer: devops
type: process
priority: high
version: 1.0.0
tags:
  - DevOps
  - CI
  - CD
  - Automation
description: Practices of frequently integrating code and automating delivery.
description_pt: Práticas de integrar código frequentemente e automatizar a entrega.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# CI/CD

## Description

CI/CD stands for Continuous Integration and Continuous Delivery (or Deployment). It's a methodology and set of practices that enable developers to deliver code changes more frequently and reliably. The goal is to reduce integration problems and allow rapid delivery of software.

**Continuous Integration (CI)** is the practice of automatically integrating code changes from multiple contributors into a shared repository. Each integration triggers automated builds and tests to detect issues early. Key practices include:
- Automated builds on every commit
- Automated testing (unit, integration, etc.)
- Fast feedback on code quality
- Maintaining a deployable state

**Continuous Delivery (CD)** extends CI by ensuring that code changes are automatically prepared for release to production. The application is always in a deployable state, and deployments happen on demand. 

**Continuous Deployment** goes further by automatically deploying every change that passes tests to production.

Modern CI/CD pipelines include stages like:
1. **Source** - Code commit triggers pipeline
2. **Build** - Compile and package
3. **Test** - Run various test types
4. **Security** - Scan for vulnerabilities
5. **Deploy** - Deploy to environment
6. **Monitor** - Track deployment health

## Purpose

**When CI/CD is valuable:**
- For teams with multiple contributors
- When frequent releases are needed
- To reduce manual deployment errors
- For faster feedback loops
- In DevOps transformation

**When to avoid:**
- Single developer projects
- Prototypes that will be discarded
- When infrastructure doesn't support automation

## Rules

1. **Commit frequently** - Small, frequent commits trigger more feedback
2. **Keep builds fast** - Under 10 minutes if possible
3. **Run tests in parallel** - Speed up pipeline
4. **Use feature flags** - Control feature releases
5. **Maintain pipeline as code** - Version control pipeline config
6. **Fail fast** - Detect issues early
7. **Use staging environments** - Test before production
8. **Monitor deployments** - Track health metrics

## Examples

### GitHub Actions Pipeline

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  REGISTRY: ghcr.io

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run unit tests
        run: npm run test:unit
      
      - name: Run integration tests
        run: npm run test:integration
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build application
        run: npm run build
      
      - name: Build Docker image
        run: |
          docker build -t ${{ env.REGISTRY }}/app:${{ github.sha }} .
          docker push ${{ env.REGISTRY }}/app:${{ github.sha }}

  security:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run SAST
        uses: github/codeql-action/analyze@v2
      
      - name: Dependency audit
        run: npm audit --audit-level=high

  deploy:
    needs: [build, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    environment:
      name: production
      url: https://app.example.com
    
    steps:
      - name: Deploy to production
        run: |
          kubectl set image deployment/app app=${{ env.REGISTRY }}/app:${{ github.sha }}
          kubectl rollout status deployment/app
```

### GitLab CI Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - security
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG

test:
  stage: test
  image: node:18
  script:
    - npm ci
    - npm run test:coverage
  coverage: '/Coverage: \d+\.\d+%/'

test:integration:
  stage: test
  image: node:18
  services:
    - postgres:15
    - redis:7
  variables:
    POSTGRES_DB: test
    POSTGRES_USER: test
    POSTGRES_PASSWORD: test
    REDIS_URL: redis://redis
  script:
    - npm run test:integration

security:
  stage: security
  image: node:18
  script:
    - npm audit --audit-level=high
    - npm run security:check

deploy:staging:
  stage: deploy
  script:
    - kubectl config use-context staging
    - kubectl apply -f k8s/
    - kubectl set image deployment/app app=$IMAGE_TAG
  environment:
    name: staging
    url: https://staging.example.com

deploy:production:
  stage: deploy
  script:
    - kubectl config use-context production
    - kubectl apply -f k8s/
    - kubectl set image deployment/app app=$IMAGE_TAG
    - kubectl rollout status deployment/app
  environment:
    name: production
    url: https://app.example.com
  when: manual
```

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        APP_NAME = 'myapp'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'npm audit --audit-level=high'
                sh 'trivy image --severity HIGH myapp:latest'
            }
        }
        
        stage('Build Image') {
            steps {
                sh """
                    docker build -t ${APP_NAME}:${env.BUILD_NUMBER} .
                    docker tag ${APP_NAME}:${env.BUILD_NUMBER} ${DOCKER_REGISTRY}/${APP_NAME}:latest
                """
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                sh 'kubectl apply -f k8s/staging/'
                sh "kubectl set image deployment/app app=${APP_NAME}:${env.BUILD_NUMBER}"
                sh 'kubectl rollout status deployment/app -n staging'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to production?"
                ok "Deploy"
            }
            steps {
                sh 'kubectl apply -f k8s/production/'
                sh "kubectl set image deployment/app app=${APP_NAME}:${env.BUILD_NUMBER}"
                sh 'kubectl rollout status deployment/app -n production'
            }
        }
    }
    
    post {
        always {
            junit '**/test-results/*.xml'
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'coverage',
                reportFiles: 'index.html',
                reportName: 'Coverage Report'
            ])
        }
        failure {
            slackSend(
                color: 'danger',
                message: "Build ${env.BUILD_NUMBER} failed: ${env.JOB_NAME}"
            )
        }
    }
}
```

## Anti-Patterns

### 1. Long-Running Builds

**Bad:**
- Building everything from scratch
- Running all tests sequentially
- Not using caching

**Solution:**
- Use incremental builds
- Parallel test execution
- Cache dependencies

### 2. Not Running Tests Locally

**Bad:**
- Relying only on CI to run tests
- Waiting for CI to find basic issues

**Solution:**
- Run tests before committing
- Use pre-commit hooks
- Set up pre-push checks

### 3. Not Using Feature Flags

**Bad:**
- Merging incomplete features
- Long-lived branches

**Solution:**
- Use feature flags
- Deploy incomplete code safely
- Release incrementally

## Best Practices

### 1. Pipeline as Code

```yaml
# Version control your pipeline
# .github/workflows/ci.yml
# Never use manual configurations
```

### 2. Environment Parity

```yaml
# Same configuration across environments
# Use values files for differences
# k8s/
#   base/
#     deployment.yaml
#   staging/
#     kustomization.yaml
#   production/
#     kustomization.yaml
```

### 3. Automated Rollbacks

```yaml
# Auto-rollback on failure
steps:
  - name: Deploy
    run: kubectl apply -f .
  
  - name: Health Check
    run: kubectl get pods -l app=myapp
  
  - name: Rollback on failure
    if: failure()
    run: kubectl rollout undo deployment/myapp
```

## Failure Modes

- **Flaky tests in CI** → false failures → team ignores CI → fix flaky tests or quarantine them
- **Slow pipeline** → 30+ minute builds → developers skip running locally → parallelize stages, cache dependencies
- **Secrets in pipeline logs** → credentials exposed in build output → mask secrets, use secret managers
- **Manual deployment steps** → human error during release → automate everything, use deployment scripts
- **No rollback strategy** → bad deploy breaks production → can't revert quickly → automated rollbacks, blue-green deployments
- **Pipeline as bottleneck** → single CI runner for entire team → queues form → scale runners, optimize pipeline
- **Environment drift** → staging differs from production → works in staging, breaks in prod → IaC, immutable infrastructure

## Technology Stack

| Tool | Use Case |
|------|----------|
| GitHub Actions | GitHub CI/CD |
| GitLab CI | GitLab CI/CD |
| Jenkins | Open source CI/CD |
| CircleCI | Cloud CI/CD |
| ArgoCD | GitOps CD |
| Tekton | Kubernetes native CI/CD |

## Related Topics

- [[Docker]]
- [[Kubernetes]]
- [[GitOps]]
- [[InfrastructureAsCode]]
- [[Monitoring]]
- [[QualityGates]]
- [[UnitTesting]]
- [[StaticAnalysis]]

## Additional Notes

**Pipeline Stages:**
1. Source - Trigger on commit
2. Build - Compile code
3. Test - Run automated tests
4. Security - Scan vulnerabilities
5. Deploy - Deploy to environment
6. Monitor - Track health

**Key Metrics:**
- Build time
- Test coverage
- Deployment frequency
- Mean time to recovery

**Best Practices:**
- Commit often
- Run tests locally
- Use feature flags
- Monitor everything

## Key Takeaways

- CI/CD automates code integration, testing, and delivery to enable frequent, reliable software releases with fast feedback loops.
- Use for teams with multiple contributors, when frequent releases are needed, to reduce manual deployment errors, or in DevOps transformations.
- Do NOT use for single-developer projects, throwaway prototypes, or when infrastructure doesn't support automation.
- Key tradeoff: faster, safer releases with automated quality gates vs. pipeline maintenance overhead and initial setup complexity.
- Main failure mode: flaky tests causing false failures that teams learn to ignore, or slow pipelines (30+ minutes) that developers bypass.
- Best practice: keep builds under 10 minutes, run tests in parallel, maintain pipeline as code, use feature flags, and implement automated rollbacks.
- Related concepts: GitOps, Infrastructure as Code, Docker, Kubernetes, Quality Gates, Feature Flags, Blue-Green Deployment.