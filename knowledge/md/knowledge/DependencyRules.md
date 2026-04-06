---
layer: knowledge
type: dependency-constraints
priority: high
read_order: 5
version: 1.0.0
tags:
  - dependencies
  - rules
  - constraints
---

# Dependency Rules

## Purpose

Every dependency is a risk. This document establishes hard constraints.

## Dependency Cost

| Cost | Impact |
|------|--------|
| Risk | New failure point |
| Maintenance | Version tracking |
| Probability | Increased failure chance |
| Compatibility | Version conflicts |
| Size | Larger distribution |
| Security | Attack surface |

## Decision Hierarchy

```
┌─────────────────────────────────────┐
│         PREFERENCE ORDER            │
├─────────────────────────────────────┤
│ 1. Built-in tools                   │
│ 2. Standard libraries               │
│ 3. Existing project tools           │
│ 4. Proven lightweight libraries     │
│ 5. New dependencies (last resort)   │
└─────────────────────────────────────┘
```

## Dependency Checklist

Before adding ANY dependency:

| # | Question | If NO → Don't add |
|---|----------|-------------------|
| 1 | Does simple code fail? | Use simple code |
| 2 | Is it standard library? | Verify necessity |
| 3 | Is it widely used? | Check alternatives |
| 4 | Do we maintain it? | Consider maintenance |
| 5 | Is it necessary? | Try without first |

## Engineering Truth

> "The best dependency is the one you do not add."

## Alternative Strategy

| Need | Instead of | Use |
|------|------------|-----|
| JSON parsing | External library | Built-in json module |
| HTTP client | New library | stdlib urllib |
| Date handling | moment.js | native Date |
| Validation | validator lib | simple regex |
| Logging | fancy logger | print/stderr |

## Portuguese

### Propósito

Define disciplina de dependências. Toda dependência é um risco.

### Custo de Dependência

| Custo | Impacto |
|-------|---------|
| Risco | Novo ponto de falha |
| Manutenção | Rastreamento de versão |
| Probabilidade | Maior chance de falha |
| Compatibilidade | Conflitos de versão |
| Tamanho | Maior distribuição |
| Segurança | Superfície de ataque |

### Verdade de Engenharia

> "A melhor dependência é a que você não adiciona."

### Estratégia Alternativa

| Necessidade | Em vez de | Usar |
|-------------|-----------|------|
| Parsing JSON | Biblioteca externa | Módulo json nativo |
| Cliente HTTP | Nova biblioteca | urllib padrão |
| Manipulação de datas | moment.js | Date nativo |
| Validação | lib validadora | Regex simples |
| Logging | Logger elaborado | print/stderr |

## Links

- [[knowledge/md/knowledge/Environment]]
- [[knowledge/md/knowledge/Portability]]