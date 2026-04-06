# Quick Start

5-minute setup guide for AEGIS validation in your project.

---

## English

### Installation

```bash
git clone <repository-url>
cd your-project
/path/to/aegis/bin/Install.sh
```

The installer creates:
- `.aegis/` directory with validation scripts
- `validate.sh` wrapper script
- Git hooks (if `.git` exists)
- YAML context files in `knowledge/yaml/`

### First Validation

```bash
./validate.sh
```

Or directly:

```bash
./bin/Validation_Gates.sh .
./bin/Hostile_Env_Test.sh .
./bin/Dependency_Check.sh .
```

### Common Commands

| Command | Purpose |
|---------|---------|
| `./validate.sh` | Run all validation gates |
| `./bin/Validation_Gates.sh .` | Validation gates only |
| `./bin/Hostile_Env_Test.sh .` | Hostile environment tests |
| `./bin/Dependency_Check.sh .` | Dependency verification |
| `./bin/Feature_Detection.sh` | Detect system features |

### Installation Options

```bash
AEGIS_INSTALL_YAML=no ./bin/Install.sh .    # Skip YAML files
AEGIS_INSTALL_DIR=/path/to/aegis ./bin/Install.sh .
```

### Project Integration

Add to your project:

```bash
# After install, add to git
git add .aegis/ validate.sh

# Use pre-commit hook
./bin/PreCommit_Hook.sh
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| "Scripts not found" | Check AEGIS path is correct |
| "Permission denied" | `chmod +x` on scripts |
| "Git hooks not installed" | Ensure `.git` directory exists |
| Validation fails | Check error messages, fix issues |

### Next Steps

1. Read [Agent Kernel](knowledge/md/system/Kernel.md) for behavior model
2. Review [Scripts Reference](bin/SCRIPTS.md) for tooling details
3. Use [Templates](docs/template/TEMPLATE_README.md) for new scripts

---

## Português

### Instalação

```bash
git clone <url-do-repositorio>
cd seu-projeto
/caminho/para/aegis/bin/Install.sh
```

O instalador cria:
- Diretório `.aegis/` com scripts de validação
- Script wrapper `validate.sh`
- Hooks git (se `.git` existir)
- Arquivos YAML em `knowledge/yaml/`

### Primeira Validação

```bash
./validate.sh
```

Ou diretamente:

```bash
./bin/Validation_Gates.sh .
./bin/Hostile_Env_Test.sh .
./bin/Dependency_Check.sh .
```

### Comandos Comuns

| Comando                       | Proposito                            |
| ----------------------------- | ------------------------------------ |
| `./validate.sh`               | Executar todos os gates de validação |
| `./bin/Validation_Gates.sh .` | Somente gates de validação           |
| `./bin/Hostile_Env_Test.sh .` | Testes de ambiente hostil            |
| `./bin/Dependency_Check.sh .` | Verificação de dependências          |
| `./bin/Feature_Detection.sh`  | Detectar recursos do sistema         |

### Opcões de Instalação

```bash
AEGIS_INSTALL_YAML=no ./bin/Install.sh .    # Pular arquivos YAML
AEGIS_INSTALL_DIR=/caminho/para/aegis ./bin/Install.sh .
```

### Integração com Projeto

Adicione ao seu projeto:

```bash
# Apos instalar, adicione ao git
git add .aegis/ validate.sh

# Usar pre-commit hook
./bin/PreCommit_Hook.sh
```

### Solução de Problemas

| Problema                  | Solucao                             |
| ------------------------- | ----------------------------------- |
| "Scripts not found"       | Verifique o caminho do AEGIS        |
| "Permission denied"       | `chmod +x` nos scripts              |
| "Git hooks not installed" | Garanta que diretório `.git` existe |
| Validação falha           | Verifique mensagens de erro         |

### Proximos Passos

1. Leia [Kernel do Agente](knowledge/md/system/Kernel.md) para modelo de comportamento
2. Revise [Referencia de Scripts](bin/SCRIPTS.md) para detalhes das ferramentas
3. Use [Modelos](docs/template/TEMPLATE_README.md) para novos scripts

---

## Related

- [Scripts Reference](bin/SCRIPTS.md)
- [Agent Kernel](knowledge/md/system/Kernel.md)
- [Templates](docs/template/TEMPLATE_README.md)
- [Project README](README.md)
