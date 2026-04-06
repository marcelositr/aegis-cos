---
layer: knowledge
type: environment-rules
priority: high
read_order: 6
version: 1.0.0
tags:
  - environment
  - assumptions
  - detection
---

# Environment

## Purpose

Defines realistic environment expectations. Prevents assumption failures.

## Target Environments

| Environment | Assumptions |
|-------------|-------------|
| Minimal systems | No extra tools |
| Busybox systems | Limited utilities |
| POSIX only | Standard tools only |
| Containers | May be stripped |
| Restricted systems | Limited permissions |
| Embedded | Minimal libraries |

## Never Assume

| # | Forbidden Assumption |
|---|---------------------|
| 1 | GNU tools exist |
| 2 | Latest versions available |
| 3 | Extra packages installed |
| 4 | Full OS features |
| 5 | Write permissions |
| 6 | Network access |
| 7 | Persistent storage |

## Detection Protocol

```
┌─────────────────────────────────────┐
│         DETECT FIRST                │
├─────────────────────────────────────┤
│ 1. Check tool availability          │
│ 2. Check version compatibility      │
│ 3. Check permissions                │
│ 4. Provide fallback if missing      │
└─────────────────────────────────────┘
```

## Engineering Survival Rule

| Action | Rule |
|--------|------|
| Detect capabilities | Do not assume |
| Verify availability | Check first |
| Provide fallbacks | Handle missing |

> "Reliable engineering adapts to environment reality."

## Portuguese

### Propósito

Define expectativas realistas de ambiente. Previne falhas de suposição.

### Ambientes Alvo

| Ambiente | Suposições |
|----------|------------|
| Sistemas mínimos | Sem ferramentas extras |
| Sistemas Busybox | Utilitários limitados |
| Apenas POSIX | Ferramentas padrão |
| Containers | Podem estar stripped |
| Sistemas restritos | Permissões limitadas |
| Embarcados | Bibliotecas mínimas |

### Nunca Assumir

| # | Suposição Proibida |
|---|-------------------|
| 1 | Ferramentas GNU existem |
| 2 | Versões recentes disponíveis |
| 3 | Pacotes extras instalados |
| 4 | Features completas de OS |
| 5 | Permissões de escrita |
| 6 | Acesso à rede |
| 7 | Armazenamento persistente |

### Regra de Sobrevivência

| Ação | Regra |
|------|-------|
| Detectar capacidades | Não assumir |
| Verificar disponibilidade | Checar primeiro |
| Prover fallbacks | Lidar com ausência |

## Links

- [[knowledge/md/knowledge/Portability]]
- [[knowledge/md/knowledge/DependencyRules]]