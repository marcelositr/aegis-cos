---
layer: control
type: drift-detection
priority: high
read_order: 4
version: 1.0.0
tags:
  - guard
  - detection
  - monitoring
---

# Drift

## Purpose

Monitors for uncontrolled growth and complexity anomalies.

## Drift Indicators

| # | Indicator | Detection Method |
|---|-----------|------------------|
| 1 | Solution getting larger | Line count comparison |
| 2 | New abstractions appearing | AST/structure analysis |
| 3 | New files appearing | File count check |
| 4 | Task expanding | Scope comparison |
| 5 | Complexity increasing | Cyclomatic complexity |

## Alert Levels

### Level 1: Warning

| Signal | Action |
|--------|--------|
| +10% size | Monitor |
| 1-2 new files | Review necessity |
| New abstraction | Question need |

### Level 2: Alert

| Signal | Action |
|--------|--------|
| +25% size | Stop and review |
| 3-5 new files | Revert extras |
| Multiple abstractions | Question all |

### Level 3: Critical

| Signal | Action |
|--------|--------|
| +50% size | Rollback recommended |
| 5+ new files | Reject changes |
| Complex structure | Simplify first |

## Detection Flow

```
┌─────────────────────────────────────┐
│         MONITORING ACTIVE           │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│         DRIFT DETECTED?             │
└────────┬───────────────┬────────────┘
         │               │
        YES              NO
         │               │
         ▼               ▼
┌─────────────┐  ┌─────────────────────┐
│   ALERT    │  │   CONTINUE          │
│   LEVEL    │  │   NORMALLY          │
└──────┬──────┘  └─────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│         CORRECTIVE ACTION           │
│  1. Stop expansion                 │
│  2. Return to minimal solution     │
│  3. Remove additions               │
└─────────────────────────────────────┘
```

## Core Rule

> "Uncontrolled growth is failure."

## Portuguese

### Propósito

Monitora crescimento descontrolado e anomalias de complexidade.

### Níveis de Alerta

**Nível 1: Aviso**

| Sinal | Ação |
|-------|------|
| +10% tamanho | Monitorar |
| 1-2 novos arquivos | Revisar necessidade |
| Nova abstração | Questionar necessidade |

**Nível 2: Alerta**

| Sinal | Ação |
|-------|------|
| +25% tamanho | Parar e revisar |
| 3-5 novos arquivos | Reverter extras |
| Múltiplas abstrações | Questionar todas |

**Nível 3: Crítico**

| Sinal | Ação |
|-------|------|
| +50% tamanho | Rollback recomendado |
| 5+ novos arquivos | Rejeitar mudanças |
| Estrutura complexa | Simplificar primeiro |

## Related

- [[knowledge/md/failure/ScopeDrift]]
- [[knowledge/md/control/SelfCheck]]
- [[knowledge/md/system/Feedback]]
- [[knowledge/md/execution/Done]]
