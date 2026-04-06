---
layer: knowledge
type: portability-standards
priority: critical
read_order: 7
version: 1.0.0
tags:
  - portability
  - cross-platform
  - compatibility
---

# Portability

## Purpose

Defines rules for creating portable, cross-platform code.

## Portability Mindset

> "Software should run in unknown environments."

## Preference Hierarchy

| Priority | Use | Avoid |
|----------|-----|-------|
| 1 | POSIX behavior | Platform-specific |
| 2 | Standard features | Experimental APIs |
| 3 | Feature detection | Version checking |
| 4 | Graceful fallback | Hard failures |

## POSIX Compliance

### Do

| # | Practice |
|---|----------|
| 1 | Use standard POSIX calls |
| 2 | Assume basic Unix tools |
| 3 | Handle signals consistently |
| 4 | Use file descriptors |
| 5 | Support stdin/stdout/stderr |

### Don't

| # | Avoid |
|---|-------|
| 1 | Windows-specific APIs |
| 2 | macOS-specific features |
| 3 | Linux-specific ioctls |
| 4 | GNU extensions |
| 5 | Hardcoded paths |

## Feature Detection Pattern

```bash
# Instead of assuming, detect:
if command -v jq > /dev/null 2>&1; then
    use_jq
else
    use_awk
fi
```

## Cross-Platform Checklist

| # | Check | Standard |
|---|-------|----------|
| 1 | File paths | Use path.join or / |
| 2 | Line endings | Handle \n and \r\n |
| 3 | Shell | Use POSIX sh |
| 4 | Commands | Check availability |
| 5 | Permissions | Handle EACCES |

## Engineering Rule

> "Portable code survives longer."

## Portuguese

### Propósito

Define regras para criar código portátil e multiplataforma.

### Mentalidade de Portabilidade

> "Software deve rodar em ambientes desconhecidos."

### Hierarquia de Preferência

| Prioridade | Usar | Evitar |
|------------|------|--------|
| 1 | Comportamento POSIX | Específico de plataforma |
| 2 | Features padrão | APIs experimentais |
| 3 | Detecção de feature | Checagem de versão |
| 4 | Fallback gracioso | Falhas hard |

### Checklist Cross-Platform

| # | Verificar | Padrão |
|---|-----------|--------|
| 1 | Paths de arquivo | Usar path.join ou / |
| 2 | Fim de linha | Lidar com \n e \r\n |
| 3 | Shell | Usar sh POSIX |
| 4 | Comandos | Verificar disponibilidade |
| 5 | Permissões | Lidar com EACCES |

### Regra de Engenharia

> "Código portátil sobrevive mais."

## Links

- [[knowledge/md/knowledge/Environment]]
- [[knowledge/md/knowledge/DependencyRules]]