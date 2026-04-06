---
layer: failure
type: scope-drift-patterns
priority: high
read_order: 3
version: 1.0.0
tags:
  - scope
  - drift
  - expansion
---

# ScopeDrift

## Purpose

Documents scope drift behaviors and signals. Use for early detection.

## Drift Behaviors

| # | Behavior | Result |
|---|----------|--------|
| 1 | Adding improvements not requested | Scope expanded |
| 2 | Fixing unrelated issues | Task mutated |
| 3 | Redesigning working code | Unnecessary risk |
| 4 | Adding "while here" changes | Scope creep |
| 5 | Adding future improvements | Future proofing trap |

## Task Mutation Signals

### Visual Indicators

| Signal | Detection |
|--------|-----------|
| Task gets bigger | Compare initial vs current |
| New systems appear | Count new files |
| New abstractions appear | Complexity increase |
| Solution grows | Line count difference |

### Behavioral Indicators

When you catch yourself:
- "Let me also fix..."
- "This would be better..."
- "I should improve..."
- "While I'm here..."
- "In the future..."

## Correction Protocol

```
┌─────────────────────────────────┐
│      DRIFT DETECTED             │
├─────────────────────────────────┤
│ 1. Stop current work            │
│ 2. Return to original task      │
│ 3. Remove extra work            │
│ 4. Verify minimal solution      │
│ 5. Continue only task scope     │
└─────────────────────────────────┘
```

## Core Rule

> "Return to original task definition. Remove extra work."

## Portuguese

### Propósito

Documenta comportamentos de desvio de escopo e sinais. Usar para detecção precoce.

### Sinais de Mutação

**Indicadores Visuais:**

| Sinal | Detecção |
|-------|----------|
| Tarefa fica maior | Comparar inicial vs atual |
| Novos sistemas aparecem | Contar novos arquivos |
| Novas abstrações aparecem | Aumento de complexidade |
| Solução cresce | Diferença de linhas |

**Indicadores Comportamentais:**

Quando pegar-se pensando:
- "Deixa eu também corrigir..."
- "Isso seria melhor..."
- "Eu deveria melhorar..."
- "Já que estou aqui..."
- "No futuro..."

### Protocolo de Correção

```
┌─────────────────────────────────┐
│      DRIFT DETECTADO            │
├─────────────────────────────────┤
│ 1. Parar trabalho atual         │
│ 2. Voltar à tarefa original     │
│ 3. Remover trabalho extra       │
│ 4. Verificar solução mínima     │
│ 5. Continuar só escopo da tarefa│
└─────────────────────────────────┘
```

## Related

- [[knowledge/md/control/Scope]]
- [[knowledge/md/failure/Common]]
- [[knowledge/md/failure/Overengineering]]
- [[knowledge/md/execution/Done]]
