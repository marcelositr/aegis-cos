---
title: Secrets Management
title_pt: Gerenciamento de Segredos
layer: security
type: concept
priority: high
version: 1.0.0
tags:
  - Security
  - SecretsManagement
description: Secure handling of passwords, API keys, tokens, and other sensitive data.
description_pt: Manuseio seguro de senhas, chaves de API, tokens e outros dados sensíveis.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Secrets Management

## Description

Secrets management handles passwords, API keys, tokens, certificates securely:
- Never commit secrets to version control
- Use environment variables or secret managers
- Rotate secrets regularly
- Audit secret access

## Purpose

**When secrets management is essential:**
- When any credentials exist in the system
- For production systems
- For compliance (PCI-DSS, SOC2)
- When secrets might be shared

**When secrets management may be simple:**
- For local development only
- For throwaway projects
- When no credentials exist

**The key question:** Could a leaked credential cause damage?

## Examples

```python
# Environment variables
import os

API_KEY = os.getenv('API_KEY')
DATABASE_PASSWORD = os.getenv('DB_PASSWORD')

# AWS Secrets Manager
import boto3

secrets_client = boto3.client('secretsmanager')

def get_secret(secret_name):
    response = secrets_client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# HashiCorp Vault
import hvac

client = hvac.Client(url='https://vault.example.com')
secret = client.secrets.kv.v2.read_secret_version(path='my-secret')
```

## Failure Modes

- **Secrets committed to version control** → exposed in git history → credential theft → use pre-commit hooks and secret scanning tools
- **Hardcoded secrets in code** → source code leak → full system compromise → inject secrets via environment or secret manager
- **No secret rotation** → compromised secrets remain valid → persistent unauthorized access → automate rotation on a schedule
- **Logging secrets** → secrets in log files → credential exposure → implement log sanitization and redaction
- **Shared secrets across environments** → dev credentials in production → lateral movement → use unique secrets per environment
- **Unencrypted secret storage** → disk access reveals secrets → data breach → encrypt secrets at rest and in transit
- **No access auditing** → secret access untracked → undetected compromise → log and monitor all secret access events

## Anti-Patterns

### 1. Secrets in Version Control

**Bad:** Committing API keys, passwords, or certificates to git — even temporarily, even if you plan to remove them later
**Why it's bad:** Git history is permanent — removing a secret from the current commit does not remove it from history, and anyone with read access to the repo can find it
**Good:** Use pre-commit hooks with secret scanning (git-secrets, detect-secrets) and never commit secrets — use environment variables or secret managers

### 2. Shared Secrets Across Environments

**Bad:** Using the same API key or database password in development, staging, and production
**Why it's bad:** A leaked development credential gives an attacker access to production — lateral movement is trivial when secrets are shared
**Good:** Use unique secrets per environment — a compromise in one environment should not affect any other

### 3. .env Files in Production

**Bad:** Using `.env` files as the secrets mechanism in production environments
**Why it's bad:** `.env` files are flat files on disk — they lack access control, audit logging, rotation, and encryption at rest
**Good:** Use dedicated secret managers in production (AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager) — `.env` files are for local development only

### 4. No Secret Rotation

**Bad:** Setting a secret once and never rotating it — the same API key is used for years
**Why it's bad:** If the secret is ever compromised (and you may not know it), the attacker has permanent access — there is no way to revoke without breaking the system
**Good:** Automate secret rotation on a schedule — design systems so that secrets can be rotated without downtime using overlapping validity periods

## Best Practices

### 1. Use Secret Managers

```python
# Don't use .env files in production
# Use AWS Secrets Manager, HashiCorp Vault, etc.
```

### 2. Rotate Secrets

```python
# Rotate API keys, passwords regularly
# Automate rotation when possible
```

### 3. Never Log Secrets

```python
# Bad
logger.info(f"API key: {API_KEY}")

# Good - never log secrets
logger.info("API key accessed")
```

## Related Topics

- [[Security MOC]]
- [[InfrastructureAsCode]]
- [[Docker]]
- [[Kubernetes]]
- [[CiCd]]

## Key Takeaways

- Secrets management securely handles passwords, API keys, tokens, and certificates through environment variables, secret managers, rotation, and access auditing
- Essential when any credentials exist in the system, for production systems, compliance requirements, or when secrets are shared
- Simple for local development only, throwaway projects, or when no credentials exist
- Tradeoff: centralized secure management versus operational complexity of secret rotation and access control infrastructure
- Main failure mode: secrets committed to version control are permanently exposed in git history, enabling credential theft by anyone with repo read access
- Best practice: never commit secrets (use pre-commit hooks with secret scanning), use dedicated secret managers in production (not .env files), use unique secrets per environment, automate rotation with overlapping validity periods, and never log secrets
- Related: infrastructure as code, Docker, Kubernetes, CI/CD
