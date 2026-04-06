# AEGIS Cognitive Engineering OS

[![AEGIS Validation](https://github.com/marcelositr/aegis-cos/actions/workflows/aegis.yml/badge.svg)](https://github.com/marcelositr/aegis-cos/actions/workflows/aegis.yml)

**Version:** 0.0.1 Alpha Test

| Status | License | Files |
|--------|---------|-------|
| Alpha Test | MIT | 119 |

---

## English

A cognitive engineering framework for AI agents. Provides rules, protocols, and validation tools for controlling agent behavior during task execution.

### Core Capabilities

- Behavioral rules for AI agents
- Execution protocols and checklists
- Shell script validation tools
- Failure pattern documentation
- POSIX-compliant tooling

### Project Structure

```
AEGIS/
├── README.md              # This file
├── bin/                   # Validation scripts
│   ├── SCRIPTS.md         # Script reference
│   ├── Validation_Gates.sh
│   ├── Hostile_Env_Test.sh
│   ├── Dependency_Check.sh
│   ├── Feature_Detection.sh
│   ├── PreCommit_Hook.sh
│   ├── Install.sh
│   └── Update.sh
├── docs/
│   ├── QUICKSTART.md      # Fast setup guide
│   └── template/
│       └── TEMPLATE_README.md  # Development template
├── knowledge/
│   ├── md/                # 53 markdown files
│   │   └── system/
│   │       └── Kernel.md  # Agent behavior model
│   └── yaml/              # 54 YAML context files
```

### Installation

```bash
git clone <repository-url>
cd your-project
/path/to/aegis/bin/Install.sh
```

### Quick Usage

```bash
./validate.sh                    # Run validation
./bin/Validation_Gates.sh .     # Direct validation
./bin/Hostile_Env_Test.sh .     # Environment tests
./bin/Dependency_Check.sh .     # Dependency check
```

### Documentation Map

```
Documentation:
├── Quick Start → docs/QUICKSTART.md
├── Scripts Reference → bin/SCRIPTS.md
├── Agent Kernel → knowledge/md/system/Kernel.md
└── Templates → docs/template/TEMPLATE_README.md
```

### Design Principles

| Principle | Description |
|-----------|-------------|
| POSIX Compliance | All scripts use `#!/bin/sh` |
| Fail-Fast | Errors detected early via validation gates |
| Self-Documenting | YAML provides AI context |
| Minimal Dependencies | No external dependencies required |
| Layered Structure | Agent, Control, Execution, Foundation |

### Requirements

- POSIX shell (`sh`)
- `set -eu` error handling
- No bash-isms
- No external dependencies (except feature detection)

---

## Português

Framework de engenharia cognitiva para agentes de IA. Fornece regras, protocolos e ferramentas de validação para controlar o comportamento do agente durante a execução de tarefas.

### Capacidades Principais

- Regras comportamentais para agentes de IA
- Protocolos de execução e checklists
- Ferramentas de validação de scripts shell
- Documentação de padrões de falha
- Ferramentas compatíveis com POSIX

### Estrutura do Projeto

```
AEGIS/
├── README.md              # Este arquivo
├── bin/                   # Scripts de validacao
│   ├── SCRIPTS.md         # Referência de scripts
│   ├── Validation_Gates.sh
│   ├── Hostile_Env_Test.sh
│   ├── Dependency_Check.sh
│   ├── Feature_Detection.sh
│   ├── PreCommit_Hook.sh
│   ├── Install.sh
│   └── Update.sh
├── docs/
│   ├── QUICKSTART.md      # Guia de inicio rápido
│   └── template/
│       └── TEMPLATE_README.md  # Modelo de desenvolvimento
├── knowledge/
│   ├── md/                # 53 arquivos markdown
│   │   └── system/
│   │       └── Kernel.md  # Modelo de comportamento do agente
│   └── yaml/              # 54 arquivos YAML de contexto
```

### Instalação

```bash
git clone <url-do-repositorio>
cd seu-projeto
/caminho/para/aegis/bin/Install.sh
```

### Uso Rápido

```bash
./validate.sh                          # Executar validação
./bin/Validation_Gates.sh .           # Validação direta
./bin/Hostile_Env_Test.sh .           # Testes de ambiente
./bin/Dependency_Check.sh .           # Verificação de dependências
```

### Mapa de Documentação

```
Documentacao:
├── Inicio Rápido → docs/QUICKSTART.md
├── Referência de Scripts → bin/SCRIPTS.md
├── Kernel do Agente → knowledge/md/system/Kernel.md
└── Modelos → docs/template/TEMPLATE_README.md
```

### Princípios de Design

| Principio            | Descrição                                    |
| -------------------- | -------------------------------------------- |
| Conformidade POSIX   | Todos os scripts usam `#!/bin/sh`            |
| Fail-Fast            | Erros detectados cedo via gates de validação |
| Auto-Documentado     | YAML fornece contexto para IA                |
| Dependências Minimas | Sem dependências externas                    |
| Estrutura em Camadas | Agent, Control, Execution, Foundation        |

### Requisitos

- Shell POSIX (`sh`)
- Tratamento de erros com `set -eu`
- Sem bash-isms
- Sem dependências externas (exceto detecção de recursos)

---

## Related

- [Quick Start](docs/QUICKSTART.md)
- [Scripts Reference](bin/SCRIPTS.md)
- [Agent Kernel](knowledge/md/system/Kernel.md)
- [Templates](docs/template/TEMPLATE_README.md)
