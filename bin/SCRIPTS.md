---
layer: scripts
type: executable
priority: critical
tags:
  - scripts
  - executable
  - validation
  - automation
  - testing
---

# Scripts Reference

Executable scripts for AEGIS validation and testing.

---

## English

### Script Index

| Script | Purpose | Entry Point |
|--------|---------|-------------|
| [Validation_Gates.sh](Validation_Gates.sh) | Validation gates (pre, real-time, post) | Primary |
| [Hostile_Env_Test.sh](Hostile_Env_Test.sh) | Hostile environment testing | Primary |
| [Dependency_Check.sh](Dependency_Check.sh) | Dependency validation | Primary |
| [Feature_Detection.sh](Feature_Detection.sh) | Feature detection library | Library |
| [PreCommit_Hook.sh](PreCommit_Hook.sh) | Git pre-commit hook | Hook |
| [Install.sh](Install.sh) | Install AEGIS in projects | Setup |
| [Update.sh](Update.sh) | Update installed scripts | Maintenance |

### Usage

#### Install AEGIS

```bash
./bin/Install.sh /path/to/project
```

#### Run All Validations

```bash
./validate.sh
```

#### Run Validation Gates

```bash
./bin/Validation_Gates.sh /path/to/project
```

#### Run Hostile Environment Test

```bash
./bin/Hostile_Env_Test.sh /path/to/project
```

#### Check Dependencies

```bash
./bin/Dependency_Check.sh /path/to/project
```

#### Source Feature Detection

```bash
. ./bin/Feature_Detection.sh
OS=$(detect_os)
ARCH=$(detect_arch)
```

#### Install Pre-Commit Hook

```bash
ln -s ../../bin/PreCommit_Hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Requirements

- POSIX shell (`#!/bin/sh`)
- `set -eu` enabled
- No bash-isms
- No external dependencies (except for detection)

### Safety Rules

1. Scripts validate before execution
2. Errors trigger exit with code 1
3. Warnings allow continuation
4. Git hooks prevent invalid commits
5. All paths are relative or configurable

### Integration Notes

| Integration | Method |
|-------------|--------|
| CI/CD | Run `validate.sh` in pipeline |
| Pre-commit | Hook runs automatically |
| IDE | Use `Feature_Detection.sh` for system info |
| Project install | Use `Install.sh` once per project |

---

## Português

### Índice de Scripts

| Script                                       | Proposito                                 | Ponto de Entrada |
| -------------------------------------------- | ----------------------------------------- | ---------------- |
| [Validation_Gates.sh](Validation_Gates.sh)   | Gates de validação (pre, real-time, post) | Primário         |
| [Hostile_Env_Test.sh](Hostile_Env_Test.sh)   | Testes de ambiente hostil                 | Primário         |
| [Dependency_Check.sh](Dependency_Check.sh)   | Validação de dependências                 | Primário         |
| [Feature_Detection.sh](Feature_Detection.sh) | Biblioteca de detecção de recursos        | Biblioteca       |
| [PreCommit_Hook.sh](PreCommit_Hook.sh)       | Hook pre-commit do git                    | Hook             |
| [Install.sh](Install.sh)                     | Instalar AEGIS em projetos                | Setup            |
| [Update.sh](Update.sh)                       | Atualizar scripts instalados              | Manutenção       |

### Uso

#### Instalar AEGIS

```bash
./bin/Install.sh /caminho/para/projeto
```

#### Executar Todas as Validações

```bash
./validate.sh
```

#### Executar Gates de Validação

```bash
./bin/Validation_Gates.sh /caminho/para/projeto
```

#### Executar Testes de Ambiente Hostil

```bash
./bin/Hostile_Env_Test.sh /caminho/para/projeto
```

#### Verificar Dependências

```bash
./bin/Dependency_Check.sh /caminho/para/projeto
```

#### Incluir Biblioteca de Detecção

```bash
. ./bin/Feature_Detection.sh
OS=$(detect_os)
ARCH=$(detect_arch)
```

#### Instalar Pré-Commit Hook

```bash
ln -s ../../bin/PreCommit_Hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Requisitos

- Shell POSIX (`#!/bin/sh`)
- `set -eu` habilitado
- Sem bash-isms
- Sem dependências externas (exceto detecção)

### Regras de Segurança

1. Scripts validam antes da execução
2. Erros causam exit com código 1
3. Avisos permitem continuação
4. Hooks git previnem commits inválidos
5. Todos os caminhos são relativos ou configuráveis

### Notas de Integração

| Integracao | Metodo                                           |
| ---------- | ------------------------------------------------ |
| CI/CD      | Executar `validate.sh` no pipeline               |
| Pre-commit | Hook executa automaticamente                     |
| IDE        | Usar `Feature_Detection.sh` para info do sistema |
| Instalação | Usar `Install.sh` uma vez por projeto            |

---

## Related

- [Quick Start](docs/QUICKSTART.md)
- [Agent Kernel](knowledge/md/system/Kernel.md)
- [Templates](docs/template/TEMPLATE_README.md)
- [Project README](README.md)
