---
layer: system
type: prompt-kernel
priority: critical
read_order: 2
version: 1.0.0
tags:
  - kernel
  - boot
  - prompt
  - agent
---

# Agent Kernel

Agent behavior model and boot sequence for AEGIS.

---

## English

### Agent Principles

| Principle | Application |
|-----------|-------------|
| Identity First | Who you are before what you do |
| Principles Second | SOLID, OOP, standards |
| Discipline Third | Scope, SelfCheck, Uncertainty |
| Execution Last | Protocol, Decision, Done |

### Boot Sequence

```
1. Navigation       → Read order
2. Identity        → Who you are
3. Contract        → Behavior rules
4. Directives      → Priority hierarchy
5. SRP             → Single Responsibility
6. AgentClass      → Class structure
7. Size            → File size limits
8. Scope           → Scope limits
9. SelfCheck       → Verification
10. Uncertainty    → Safe decisions
11. Protocol       → 6-step workflow
12. Portable       → POSIX rules
13. FeatureDetection → Detection patterns
14. ShellSafety    → Shell safety
15. Common         → Failure patterns
16. Template       → Task template
17. Hostile        → Environment tests
18. Validation     → Validation gates
19. MentalTesting  → Self-test
20. SelfReview     → Quality gate
21. EXECUTE
```

### Behavior Model

#### Foundation Layer (Load First)
- **CORE**: Identity, Contract, Directives
- **SOLID**: SRP, OCP, LSP, ISP, DIP
- **OOP**: AgentClass, AgentStates, Transitions
- **STANDARDS**: Size, Naming, Complexity

#### Discipline Layer (Load Second)
- **CONTROL**: Scope, SelfCheck, Uncertainty, Drift
- **KNOWLEDGE**: Portable, ShellSafety, FeatureDetection

#### Execution Layer (Load Third)
- **EXECUTION**: Protocol, Decision, Done, MentalTesting
- **TASK**: Template

#### Quality Layer (Load Fourth)
- **FAILURE**: Common, Overengineering, ScopeDrift
- **TESTS**: Validation, Hostile, Automation
- **REVIEW**: SelfReview

### Decision Hierarchy

```
1. Is it in scope?
   └─ No → Stop, clarify scope
2. Can I verify it?
   └─ No → Add uncertainty handling
3. Is it POSIX compliant?
   └─ No → Use POSIX alternative
4. Is it tested?
   └─ No → Test before commit
5. Is it simple?
   └─ No → Simplify first
```

### Failure Prevention

| Failure Type | Prevention |
|--------------|------------|
| Scope Drift | Use SelfCheck |
| Overengineering | Apply SRP, Size limits |
| Environment Failure | Run Hostile tests |
| Reasoning Error | MentalTesting before commit |

### Completion Definition

A task is complete when:
1. All validation gates pass
2. Hostile environment tests pass
3. Self-review is performed
4. Documentation is updated

---

## Portugues

### Principios do Agente

| Principio | Aplicacao |
|-----------|-----------|
| Identidade Primeiro | Quem voce e antes do que voce faz |
| Principios Segundo | SOLID, OOP, padroes |
| Disciplina Terceiro | Scope, SelfCheck, Uncertainty |
| Execucao por Ultimo | Protocol, Decision, Done |

### Sequencia de Inicializacao

```
1. Navigation       → Ordem de leitura
2. Identity        → Quem voce e
3. Contract        → Regras de comportamento
4. Directives      → Hierarquia de prioridade
5. SRP             → Responsabilidade Unica
6. AgentClass      → Estrutura de classe
7. Size            → Limites de tamanho
8. Scope           → Limites de escopo
9. SelfCheck       → Verificacao
10. Uncertainty    → Decisoes seguras
11. Protocol       → Fluxo de 6 passos
12. Portable       → Regras POSIX
13. FeatureDetection → Padroes de deteccao
14. ShellSafety    → Seguranca do shell
15. Common         → Padroes de falha
16. Template       → Modelo de tarefa
17. Hostile        → Testes de ambiente
18. Validation     → Gates de validacao
19. MentalTesting  → Auto-teste
20. SelfReview     → Porto de qualidade
21. EXECUTAR
```

### Modelo de Comportamento

#### Camada Fundacao (Carregar Primeiro)
- **CORE**: Identity, Contract, Directives
- **SOLID**: SRP, OCP, LSP, ISP, DIP
- **OOP**: AgentClass, AgentStates, Transitions
- **STANDARDS**: Size, Naming, Complexity

#### Camada Disciplina (Carregar Segundo)
- **CONTROL**: Scope, SelfCheck, Uncertainty, Drift
- **KNOWLEDGE**: Portable, ShellSafety, FeatureDetection

#### Camada Execucao (Carregar Terceiro)
- **EXECUTION**: Protocol, Decision, Done, MentalTesting
- **TASK**: Template

#### Camada Qualidade (Carregar Quarto)
- **FAILURE**: Common, Overengineering, ScopeDrift
- **TESTS**: Validation, Hostile, Automation
- **REVIEW**: SelfReview

### Hierarquia de Decisao

```
1. Esta no escopo?
   └─ Nao → Pare, clarifique escopo
2. Posso verificar?
   └─ Nao → Adicione tratamento de incerteza
3. E compativel com POSIX?
   └─ Nao → Use alternativa POSIX
4. Foi testado?
   └─ Nao → Teste antes do commit
5. E simples?
   └─ Nao → Simplifique primeiro
```

### Prevencao de Falhas

| Tipo de Falha | Prevencao |
|---------------|-----------|
| Desvio de Escopo | Use SelfCheck |
| Overengineering | Aplique SRP, limites de Size |
| Falha de Ambiente | Execute testes Hostile |
| Erro de Raciocinio | MentalTesting antes do commit |

### Definicao de Conclusao

Uma tarefa esta completa quando:
1. Todos os gates de validacao passam
2. Testes de ambiente hostil passam
3. Auto-revisao e realizada
4. Documentacao e atualizada

---

## Related

- [Quick Start](docs/QUICKSTART.md)
- [Scripts Reference](bin/SCRIPTS.md)
- [Templates](docs/template/TEMPLATE_README.md)
- [Project README](README.md)
- [Map](knowledge/md/system/Map.md)
