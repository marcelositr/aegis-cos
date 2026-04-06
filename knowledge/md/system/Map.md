---
layer: system
type: cognitive-map
priority: critical
read_order: 1
version: 1.0.0
tags:
  - navigation
  - map
  - structure
---

# Map

## Navigation

| Conflict | Resolution |
|----------|------------|
| Governance vs All | Governance overrides |
| Foundation vs Execution | SOLID/OOP overrides |
| KNOWLEDGE vs Assumptions | Portability overrides |
| TESTS vs Confidence | Validation overrides |

---

## FOUNDATION

| Layer | Files |
|-------|-------|
| **SOLID** | SRP, OCP, LSP, ISP, DIP |
| **OOP** | Class, States, Transitions, Interface, Contracts |
| **STANDARDS** | Naming, Size, Complexity, Validation, Templates |

---

## CORE

| File | Purpose |
|------|---------|
| [[knowledge/md/agent/Navigation]] | Reading order |
| [[knowledge/md/agent/Identity]] | Agent mindset |
| [[knowledge/md/agent/Contract]] | Behavior rules |
| [[knowledge/md/agent/Directives]] | Priority hierarchy |

---

## KNOWLEDGE

| File | Purpose |
|------|---------|
| [[knowledge/md/knowledge/Portable]] | POSIX rules |
| [[knowledge/md/knowledge/ShellSafety]] | Shell safety |
| [[knowledge/md/knowledge/FeatureDetection]] | Detection patterns |
| [[knowledge/md/knowledge/Dependency]] | Dependency rules |
| [[knowledge/md/knowledge/Robustness]] | Fail-fast rules |

---

## CONTROL

| File | Purpose |
|------|---------|
| [[knowledge/md/control/Scope]] | Scope limits |
| [[knowledge/md/control/SelfCheck]] | Verification |
| [[knowledge/md/control/Uncertainty]] | Safe decisions |

---

## EXECUTION

| File | Purpose |
|------|---------|
| [[knowledge/md/execution/Protocol]] | 6-step workflow |
| [[knowledge/md/execution/Decision]] | Solution selection |
| [[knowledge/md/execution/Done]] | Completion criteria |

---

## TESTS

| File | Purpose |
|------|---------|
| [[knowledge/md/tests/Validation]] | 4 validation gates |
| [[knowledge/md/tests/Hostile]] | Hostile env tests |
| [[knowledge/md/tests/Automation]] | CI/automation |

---

## SCRIPTS

| Script | Purpose |
|--------|---------|
| [[bin/Validation_Gates]] | Validation gates |
| [[bin/Hostile_Env_Test]] | Hostile testing |
| [[bin/PreCommit_Hook]] | Git hook |
| [[bin/Feature_Detection]] | Detection library |
| [[bin/Dependency_Check]] | Dep validation |

---

## Engineering Truths

| Truth |
|-------|
| "Fast agents fail. Stable agents succeed." |
| "Every dependency is a liability." |
| "Complexity grows faster than value." |
| "If not tested in hostile env, it will fail there." |

---

## Portuguese

### Propósito

Arquivo principal de navegação do sistema AEGIS. Define a estrutura de camadas e a ordem de leitura para inicialização correta do agente.

### Navegação

| Conflito | Resolução |
|----------|-----------|
| Governança vs Todos | Governança sobrescreve |
| Fundação vs Execução | SOLID/OOP sobrescreve |
| KNOWLEDGE vs Suposições | Portabilidade sobrescreve |
| TESTS vs Confiança | Validação sobrescreve |

## Related

- [[knowledge/md/system/Kernel]]
- [[knowledge/md/agent/Navigation]]
- [[bin/SCRIPTS]]