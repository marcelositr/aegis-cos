---
layer: system
type: feedback-loop
priority: high
read_order: 4
version: 1.0.0
tags:
  - feedback
  - failure
  - loop
---

# Feedback

## Purpose

Transform agent failures into permanent engineering memory. Create continuous improvement cycle.

> "Failure without recording = wasted compute.
> Failure with recording = engineering progress."

## Process Flow

```
┌─────────────┐
│   FAILURE   │
│   OCCURS    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ IDENTIFY    │──► Type classification
│ FAILURE     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ MAP TO      │──► Pattern matching
│ PATTERN     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ UPDATE      │──► Record to MEMORY
│ MEMORY      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ UPDATE      │──► Enhance rules
│ RULES       │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ GUARD       │──► Add to GUARD_Drift_Detection
│ FUTURE      │
└─────────────┘
```

## Failure Type Routing

| Failure Type | Routing Target |
|--------------|----------------|
| Architecture mistake | [[knowledge/md/failure/Overengineering]] |
| Scope drift | [[knowledge/md/failure/ScopeDrift]] |
| Execution failure | [[knowledge/md/execution/Done]] |
| Reasoning failure | [[knowledge/md/control/SelfCheck]] |
| Uncertainty failure | [[knowledge/md/control/Uncertainty]] |
| Environment failure | [[knowledge/md/knowledge/Environment]] |

## Learning Rules

Every repeated failure must generate:

| Output | Description |
|--------|-------------|
| New guard rule | Add to [[knowledge/md/control/Drift]] |
| New trigger rule | Update [[knowledge/md/system/Triggers]] |
| New lesson | Add to [[knowledge/md/memory/Lessons]] |

## Agent Directive

### Primary Rule
> "Never repeat same failure twice."

### Recovery Protocol

When failure repeats:

1. Slow down reasoning
2. Increase self-check depth
3. Increase rule consultation
4. Request human review if needed

## Portuguese

### Propósito

Transformar falhas de agentes em memória permanente de engenharia. Criar ciclo de melhoria contínua.

> "Falha sem registro = computação desperdiçada.
> Falha com registro = progresso de engenharia."

### Fluxo do Processo

```
┌─────────────┐
│   FALHA     │
│   OCORRE    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ IDENTIFICAR │
│ TIPO        │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ MAPEAR     │
│ PADRÃO      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ ATUALIZAR  │
│ MEMÓRIA    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ ATUALIZAR  │
│ REGRAS     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ GUARDAR    │
│ FUTURO     │
└─────────────┘
```

### Roteamento de Tipo de Falha

| Tipo de Falha | Destino |
|---------------|---------|
| Erro de arquitetura | [[knowledge/md/failure/Overengineering]] |
| Desvio de escopo | [[knowledge/md/failure/ScopeDrift]] |
| Falha de execução | [[knowledge/md/execution/Done]] |
| Falha de raciocínio | [[knowledge/md/control/SelfCheck]] |
| Falha de incerteza | [[knowledge/md/control/Uncertainty]] |
| Falha de ambiente | [[knowledge/md/knowledge/Environment]] |

### Regras de Aprendizado

Cada falha repetida deve gerar:

| Saída | Descrição |
|-------|-----------|
| Nova regra de guarda | Adicionar a [[knowledge/md/control/Drift]] |
| Nova regra de gatilho | Atualizar [[knowledge/md/system/Triggers]] |
| Nova lição | Adicionar a [[knowledge/md/memory/Lessons]] |

### Direto do Agente

**Regra Principal:**
> "Nunca repetir a mesma falha duas vezes."

**Protocolo de Recuperação:**

Quando falha se repete:

1. Desacelerar raciocínio
2. Aumentar profundidade de auto-verificação
3. Aumentar consulta de regras
4. Solicitar revisão humana se necessário

## Related

- [[knowledge/md/failure/Common]]
- [[knowledge/md/memory/Lessons]]
- [[knowledge/md/control/Drift]]
- [[knowledge/md/system/Triggers]]