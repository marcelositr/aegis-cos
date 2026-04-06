# AEGIS Script Template

Minimal POSIX shell script project template that passes AEGIS validation.

---

## English

### Purpose

This template provides a starting point for creating POSIX-compliant shell scripts that pass AEGIS validation gates. Use this template when creating new scripts or projects within the AEGIS ecosystem.

### Structure

```
template/
├── run.sh              # Main script (POSIX compliant)
├── test.sh             # Test script
├── TEMPLATE_README.md  # This file
├── MD/                 # Markdown document templates
│   ├── Concept.md      # Concept documentation
│   └── Template.md     # Task template
└── YAML/               # YAML context templates
    ├── Concept.yml     # Concept YAML
    ├── Template.yml    # Task YAML
    └── README.md       # YAML guide
```

### Features

| Feature | Implementation |
|---------|----------------|
| POSIX Compliance | `#!/bin/sh` shebang |
| Error Handling | `set -eu` enabled |
| Variable Quoting | All variables quoted |
| Help Output | `-h` flag with usage |
| Version Flag | `-v` flag |
| Quiet Mode | `-q` flag |
| Argument Parsing | `getopts` implementation |

### Usage

#### Initialize New Script

```bash
cp -r docs/template/run.sh ./new-script.sh
chmod +x new-script.sh
./new-script.sh -h
```

#### Run Tests

```bash
cd docs/template
./test.sh
```

#### Create Documentation

```bash
cp docs/template/MD/Concept.md ./docs/MyConcept.md
cp docs/template/YAML/Concept.yml ./knowledge/yaml/MyConcept.yml
```

### Validation

Before committing, validate with:

```bash
./bin/Validation_Gates.sh .
./bin/Hostile_Env_Test.sh .
./bin/Dependency_Check.sh .
```

### Extension Rules

1. Maintain POSIX compliance - no bash-isms
2. Keep scripts under 250 lines
3. Use `set -eu` error handling
4. Quote all variables
5. Include frontmatter in markdown
6. Use YAML for AI context files

### Integration with AEGIS

To add validation to your script project:

```bash
/path/to/aegis/bin/Install.sh .
./validate.sh
```

---

## Português

### Proposito

Este modelo fornece um ponto de partida para criar scripts shell compatíveis com POSIX que passam nos gates de validação do AEGIS. Use este modelo ao criar novos scripts ou projetos dentro do ecossistema AEGIS.

### Estrutura

```
template/
├── run.sh              # Script principal (POSIX compliant)
├── test.sh             # Script de testes
├── TEMPLATE_README.md  # Este arquivo
├── MD/                 # Modelos de documento markdown
│   ├── Concept.md      # Documentação de conceito
│   └── Template.md     # Modelo de tarefa
└── YAML/               # Modelos de contexto YAML
    ├── Concept.yml     # Conceito YAML
    ├── Template.yml    # Tarefa YAML
    └── README.md       # Guia YAML
```

### Funcionalidades

| Funcionalidade        | Implementação               |
| --------------------- | --------------------------- |
| Conformidade POSIX    | Shebang `#!/bin/sh`         |
| Tratamento de Erros   | `set -eu` habilitado        |
| Variáveis Quotadas    | Todas variáveis com aspas   |
| Saída de Ajuda        | Flag `-h` com uso           |
| Flag de Versão        | Flag `-v`                   |
| Modo Silencioso       | Flag `-q`                   |
| Parsing de Argumentos | Implementação com `getopts` |

### Uso

#### Inicializar Novo Script

```bash
cp -r docs/template/run.sh ./novo-script.sh
chmod +x novo-script.sh
./novo-script.sh -h
```

#### Executar Testes

```bash
cd docs/template
./test.sh
```

#### Criar Documentação

```bash
cp docs/template/MD/Concept.md ./docs/MeuConceito.md
cp docs/template/YAML/Concept.yml ./knowledge/yaml/MeuConceito.yml
```

### Validação

Antes de fazer commit, valide com:

```bash
./bin/Validation_Gates.sh .
./bin/Hostile_Env_Test.sh .
./bin/Dependency_Check.sh .
```

### Regras de Extensão

1. Mantenha conformidade POSIX - sem bash-isms
2. Mantenha scripts abaixo de 250 linhas
3. Use tratamento de erros com `set -eu`
4. Cite todas as variáveis
5. Inclua frontmatter em markdown
6. Use YAML para arquivos de contexto de IA

### Integração com AEGIS

Para adicionar validação ao seu projeto:

```bash
/caminho/para/aegis/bin/Install.sh .
./validate.sh
```

---

## Related

- [Quick Start](docs/QUICKSTART.md)
- [Scripts Reference](bin/SCRIPTS.md)
- [Agent Kernel](knowledge/md/system/Kernel.md)
- [Project README](README.md)
