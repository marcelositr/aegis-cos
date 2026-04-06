---
layer: system
type: trigger-map
priority: critical
read_order: 3
version: 1.0.0
tags:
  - triggers
  - behavior
  - activation
---

# Triggers

## Purpose

Defines which thinking mode must activate based on task context. Prevents wrong cognitive behavior.

> "Wrong mode = wrong output."

## Task → Mode Routing

### Engineering Tasks

| Task Type | Mode | File Reference |
|-----------|------|----------------|
| Bug fixing | STRICT | [[knowledge/md/agent/Modes#strict-mode]] |
| Refactoring | STRICT | [[knowledge/md/agent/Modes#strict-mode]] |
| Code improvement | STRICT | [[knowledge/md/agent/Modes#strict-mode]] |
| Infrastructure | PARANOID | [[knowledge/md/agent/Modes#paranoid-mode]] |
| Security | PARANOID | [[knowledge/md/agent/Modes#paranoid-mode]] |
| Production system | PARANOID | [[knowledge/md/agent/Modes#paranoid-mode]] |

### Quick Tasks

| Task Type | Mode | File Reference |
|-----------|------|----------------|
| Simple questions | MINIMAL | [[knowledge/md/agent/Modes#minimal-mode]] |
| Command syntax | MINIMAL | [[knowledge/md/agent/Modes#minimal-mode]] |
| Package names | MINIMAL | [[knowledge/md/agent/Modes#minimal-mode]] |
| Direct answers | MINIMAL | [[knowledge/md/agent/Modes#minimal-mode]] |

### Complex Tasks

| Task Type | Mode | File Reference |
|-----------|------|----------------|
| Architecture | ANALYSIS | [[knowledge/md/agent/Modes#analysis-mode]] |
| Design decisions | ANALYSIS | [[knowledge/md/agent/Modes#analysis-mode]] |
| System problems | ANALYSIS | [[knowledge/md/agent/Modes#analysis-mode]] |
| Root cause analysis | ANALYSIS | [[knowledge/md/agent/Modes#analysis-mode]] |
| Unknown problems | ANALYSIS | [[knowledge/md/agent/Modes#analysis-mode]] |

### Creative Tasks

| Task Type | Mode | File Reference |
|-----------|------|----------------|
| Naming | CREATIVE | [[knowledge/md/agent/Modes#creative-mode]] |
| Brainstorming | CREATIVE | [[knowledge/md/agent/Modes#creative-mode]] |
| Concept ideas | CREATIVE | [[knowledge/md/agent/Modes#creative-mode]] |
| Documentation structure | CREATIVE | [[knowledge/md/agent/Modes#creative-mode]] |

### Risk Tasks

| Task Type | Mode | File Reference |
|-----------|------|----------------|
| Authentication | PARANOID | [[knowledge/md/agent/Modes#paranoid-mode]] |
| Networking | PARANOID | [[knowledge/md/agent/Modes#paranoid-mode]] |
| Data safety | PARANOID | [[knowledge/md/agent/Modes#paranoid-mode]] |
| Permissions | PARANOID | [[knowledge/md/agent/Modes#paranoid-mode]] |
| System modification | PARANOID | [[knowledge/md/agent/Modes#paranoid-mode]] |

## Mode Priority Matrix

| Mode A | vs Mode B | Winner |
|--------|-----------|--------|
| PARANOID | STRICT | PARANOID |
| PARANOID | ANALYSIS | PARANOID |
| PARANOID | MINIMAL | PARANOID |
| PARANOID | CREATIVE | PARANOID |
| STRICT | ANALYSIS | STRICT |
| STRICT | MINIMAL | STRICT |
| STRICT | CREATIVE | STRICT |
| ANALYSIS | MINIMAL | ANALYSIS |
| ANALYSIS | CREATIVE | ANALYSIS |
| MINIMAL | CREATIVE | MINIMAL |

## Default Rules

| Scenario | Action |
|----------|--------|
| Unclear task | Use ANALYSIS |
| Multiple modes apply | Use highest priority |
| Never default to | CREATIVE |

## Portuguese

### Propósito

Define qual modo de pensamento deve ativar baseado no contexto da tarefa. Previne comportamento cognitivo errado.

> "Modo errado = saída errada."

### Roteamento Tarefa → Modo

**Engenharia:**

| Tipo de Tarefa | Modo |
|----------------|------|
| Correção de bugs | STRICT |
| Refatoração | STRICT |
| Melhoria de código | STRICT |
| Infraestrutura | PARANOID |
| Segurança | PARANOID |
| Sistema de produção | PARANOID |

**Tarefas Rápidas:**

| Tipo de Tarefa | Modo |
|----------------|------|
| Perguntas simples | MINIMAL |
| Sintaxe de comandos | MINIMAL |
| Nomes de pacotes | MINIMAL |
| Respostas diretas | MINIMAL |

**Tarefas Complexas:**

| Tipo de Tarefa | Modo |
|----------------|------|
| Arquitetura | ANALYSIS |
| Decisões de design | ANALYSIS |
| Problemas de sistema | ANALYSIS |
| Análise de causa raiz | ANALYSIS |
| Problemas desconhecidos | ANALYSIS |

**Tarefas Criativas:**

| Tipo de Tarefa | Modo |
|----------------|------|
| Nomeação | CREATIVE |
| Brainstorming | CREATIVE |
| Ideias conceituais | CREATIVE |
| Estrutura de documentação | CREATIVE |

**Tarefas de Risco:**

| Tipo de Tarefa | Modo |
|----------------|------|
| Autenticação | PARANOID |
| Rede | PARANOID |
| Segurança de dados | PARANOID |
| Permissões | PARANOID |
| Modificação de sistema | PARANOID |

### Matriz de Prioridade de Modos

| Modo A | vs Modo B | Vencedor |
|--------|-----------|----------|
| PARANOID | STRICT | PARANOID |
| PARANOID | ANALYSIS | PARANOID |
| PARANOID | MINIMAL | PARANOID |
| PARANOID | CREATIVE | PARANOID |
| STRICT | ANALYSIS | STRICT |
| STRICT | MINIMAL | STRICT |
| STRICT | CREATIVE | STRICT |
| ANALYSIS | MINIMAL | ANALYSIS |
| ANALYSIS | CREATIVE | ANALYSIS |
| MINIMAL | CREATIVE | MINIMAL |

### Regras Padrão

| Cenário | Ação |
|---------|------|
| Tarefa não clara | Usar ANALYSIS |
| Múltiplos modos aplicáveis | Usar maior prioridade |
| Nunca usar como padrão | CREATIVE |

## Related

- [[knowledge/md/agent/Modes]]
- [[knowledge/md/execution/Decision]]
- [[knowledge/md/control/Scope]]