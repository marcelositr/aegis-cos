---
title: Environment Variables
title_pt: Variáveis de Ambiente
layer: shell_engineering
type: concept
priority: high
version: 1.0.0
tags:
  - ShellEngineering
  - EnvironmentVariables
description: Using and managing environment variables in shell scripts.
description_pt: Usando e gerenciando variáveis de ambiente em scripts shell.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Environment Variables

## Description

Environment variables pass configuration to processes:
- System-wide: `/etc/environment`
- User: `~/.bashrc`, `~/.profile`
- Session: `export VAR=value`



## Purpose

**When this is valuable:**
- For understanding and applying the concept
- For making architectural decisions
- For team communication

**When this may not be needed:**
- For quick reference
- For simple implementations
- When basics are well understood

**The key question:** How does this concept help us build better software?

## Examples

```bash
# Set variable
export MY_VAR="value"

# Use variable
echo "$MY_VAR"

# Unset variable
unset MY_VAR

# Default values
echo "${MY_VAR:-default}"

# If not set, set it
: "${MY_VAR:=value}"

# Import from file
source .env

# Export function
export -f my_function
```

## Failure Modes

- **Unquoted variable expansion** → spaces in variable values cause word splitting → commands receive wrong arguments → always quote variables: echo "$VAR" not echo $VAR
- **Exporting unnecessary variables** → all variables exported to child processes → environment pollution and security risk → only export variables that child processes actually need
- **Hardcoded paths in environment variables** → absolute paths that differ across systems → script fails on different machines → use relative paths or detect paths dynamically
- **Sensitive data in environment variables** → passwords and tokens visible in /proc/*/environ → credential exposure to other processes → use secret management tools and limit environment variable scope
- **Environment variable name collisions** → generic names like CONFIG or DATA conflict with system variables → unexpected behavior → use prefixed names like APP_CONFIG or MYAPP_DATA
- **Missing default values for optional variables** → unset variables cause errors → script fails when optional config not provided → use ${VAR:-default} syntax for safe defaults
- **Environment changes not scoped** → exported variables affect all subsequent commands → unintended side effects in script → use local variables or subshells to limit variable scope

## Anti-Patterns

### 1. Sensitive Data in Environment Variables

**Bad:** Storing passwords, API keys, or tokens in environment variables that are visible to any process via `/proc/*/environ`
**Why it's bad:** Any process running as the same user can read environment variables — a compromised dependency or malicious script can exfiltrate secrets trivially
**Good:** Use secret management tools (Vault, AWS Secrets Manager) and limit environment variable scope — inject secrets only when needed and clear them after use

### 2. Environment Variable Name Collisions

**Bad:** Using generic names like `CONFIG`, `DATA`, or `PORT` that may conflict with system or other application variables
**Why it's bad:** Your script reads a `PORT` value set by another application, connects to the wrong service, and the bug is nearly impossible to trace
**Good:** Use prefixed names like `APP_CONFIG`, `MYAPP_DATA`, or `MYAPP_PORT` — namespace your variables to avoid collisions

### 3. Exporting Unnecessarily

**Bad:** Using `export` for every variable, polluting the environment of all child processes
**Why it's bad:** Child processes inherit variables they do not need — this increases their attack surface, confuses debugging, and can cause unexpected behavior in tools that read environment variables
**Good:** Only export variables that child processes actually need — use local variables for script-internal values

### 4. Environment Changes Not Scoped

**Bad:** Exporting a variable that affects all subsequent commands in the script, including ones that should not see it
**Why it's bad:** A variable set for one command leaks into unrelated commands — side effects cascade through the script in unpredictable ways
**Good:** Use inline environment variables for single-command scope (`VAR=value command`) or subshells (`(export VAR=value; command)`) to limit variable visibility

## Best Practices

### 1. Quote Variables

```bash
# Always quote to handle spaces
echo "$MY_VAR"
```

### 2. Use Defaults

```bash
# Default when not set
CONFIG_FILE="${CONFIG_FILE:-config.yaml}"
```

### 3. Don't Export Unnecessarily

```bash
# Only export when needed
MY_VAR="value"  # Not exported
export MY_VAR="value"  # Exported to child processes
```

## Related Topics

- [[Shell Engineering MOC]]
- [[SecretsManagement]]
- [[InfrastructureAsCode]]
- [[Docker]]
- [[CiCd]]
