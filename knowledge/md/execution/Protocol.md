---
layer: execution
type: task-protocol
priority: critical
read_order: 1
version: 1.0.0
tags:
  - protocol
  - workflow
  - task-execution
---

# Protocol

## Purpose

Defines the 6-step workflow for task execution. **Do not improvise.**

## Execution Flow

```
┌──────────┐
│  STEP 1  │ Understand Task
└────┬─────┘
     │
     ▼
┌──────────┐
│  STEP 2  │ Define Minimal Solution
└────┬─────┘
     │
     ▼
┌──────────┐
│  STEP 3  │ Risk Evaluation
└────┬─────┘
     │
     ▼
┌──────────┐
│  STEP 4  │ Controlled Execution
└────┬─────┘
     │
     ▼
┌──────────┐
│  STEP 5  │ Self Verification
└────┬─────┘
     │
     ▼
┌──────────┐
│  STEP 6  │ Completion Validation
└──────────┘
```

## Step 1 - Understand Task

### Identify

| Item | Question |
|------|----------|
| What IS requested | What should be delivered? |
| What is NOT requested | What is out of scope? |
| Constraints | What are the limits? |
| Expected output | What does success look like? |

## Step 2 - Define Minimal Solution

| Do | Don't |
|----|-------|
| Plan smallest change | Plan redesign |
| Find existing patterns | Create new abstractions |
| Identify affected files | Modify unrelated systems |

## Step 3 - Risk Evaluation

### Check

| Item | Reference |
|------|-----------|
| Environment assumptions | [[knowledge/md/knowledge/Environment]] |
| Dependencies | [[knowledge/md/knowledge/Dependency]] |
| Scope expansion risk | [[knowledge/md/control/Scope]] |

## Step 4 - Controlled Execution

| Action | Rule |
|--------|------|
| Modify only necessary parts | Minimize changes |
| Follow existing patterns | Consistency |
| No improvisation | Follow protocol |

## Step 5 - Self Verification

Run: [[knowledge/md/control/SelfCheck]]

### Quick Check

| Question | Pass? |
|----------|-------|
| Did scope expand? | Must be NO |
| Did complexity increase? | Must be NO |
| Were patterns followed? | Must be YES |

## Step 6 - Completion Validation

Check: [[knowledge/md/execution/Done]]

### Quick Check

| Criteria | Status |
|----------|--------|
| Task solved | YES/NO |
| Scope maintained | YES/NO |
| Patterns followed | YES/NO |

## Execution Rule

> "Do not improvise workflow. Follow protocol."

## Portuguese

### Propósito

Define o fluxo de trabalho de 6 passos para execução de tarefas. **Não improvise.**

### Passo 1 - Entender Tarefa

**Identificar:**

| Item | Pergunta |
|------|----------|
| O que É solicitado | O que deve ser entregue? |
| O que NÃO é solicitado | O que está fora do escopo? |
| Restrições | Quais são os limites? |
| Resultado esperado | Como sucesso se parece? |

### Passo 2 - Definir Solução Mínima

| Fazer | Não Fazer |
|-------|-----------|
| Planejar menor mudança | Planejar redesign |
| Encontrar padrões existentes | Criar novas abstrações |
| Identificar arquivos afetados | Modificar sistemas não relacionados |

### Passo 3 - Avaliação de Risco

| Verificar | Referência |
|-----------|------------|
| Suposições de ambiente | [[knowledge/md/knowledge/Environment]] |
| Dependências | [[knowledge/md/knowledge/Dependency]] |
| Risco de expansão de escopo | [[knowledge/md/control/Scope]] |

### Passo 4 - Execução Controlada

| Ação | Regra |
|------|-------|
| Modificar apenas partes necessárias | Minimizar mudanças |
| Seguir padrões existentes | Consistência |
| Sem improviso | Seguir protocolo |

### Passo 5 - Auto Verificação

Executar: [[knowledge/md/control/SelfCheck]]

### Passo 6 - Validação de Conclusão

Verificar: [[knowledge/md/execution/Done]]

### Regra de Execução

> "Não improvisar workflow. Seguir protocolo."

## Related

- [[knowledge/md/control/Scope]]
- [[knowledge/md/control/SelfCheck]]
- [[knowledge/md/execution/Decision]]
- [[knowledge/md/execution/Done]]
