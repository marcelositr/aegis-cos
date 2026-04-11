---
title: Bash Best Practices
title_pt: Melhores Práticas de Bash
layer: shell_engineering
type: concept
priority: high
version: 1.0.0
tags:
  - ShellEngineering
  - BashBestPractices
description: Best practices for writing robust and maintainable shell scripts.
description_pt: Melhores práticas para escrever scripts shell robustos e manuteníveis.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Bash Best Practices

## Description

Writing good bash scripts requires:
- Proper error handling
- Quoted variables
- Functions for organization
- Meaningful naming
- Consistent style

## Purpose

**When bash scripting is valuable:**
- Automation of repetitive tasks
- System administration
- CI/CD pipelines
- Quick utilities and prototyping

**When to avoid bash:**
- Complex applications (use Python, Go, etc.)
- Cross-platform needs
- When readability matters most

**The key question:** Is bash the right tool for this automation task?

## Examples

### Good Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    log "ERROR: $*" >&2
    exit 1
}

# Main
main() {
    log "Starting process..."
    
    local input_file="$1"
    [[ -f "$input_file" ]] || error "File not found: $input_file"
    
    log "Processing $input_file"
    process_file "$input_file"
    
    log "Done"
}

main "$@"
```

### Variable Quoting

```bash
# Bad - fails with spaces
for file in *.txt; do
    cat $file  # Breaks with spaces in filename
done

# Good - properly quoted
for file in *.txt; do
    cat "$file"  # Works with any filename
done
```

### Error Handling

```bash
# Exit on any error
set -e

# Also exit on undefined variables
set -u

# Exit on pipe failure
set -o pipefail

# Check command result
command || error "Command failed"
```

## Anti-Patterns

### 1. Using eval with User Input

**Bad:** Using `eval` to construct and execute commands from user-supplied input
**Why it's bad:** `eval` executes arbitrary code — an input like `$(rm -rf /)` or `; cat /etc/passwd` runs with the script's privileges, causing catastrophic damage
**Good:** Avoid `eval` entirely — use arrays for dynamic command construction (`cmd=(grep "$pattern" "$file")` and `"${cmd[@]}"`) or indirect expansion

### 2. Missing set Flags for Error Handling

**Bad:** Writing bash scripts without `set -euo pipefail`, allowing silent failures to cascade
**Why it's bad:** A failed command goes unnoticed — the script continues with invalid state, corrupting data or performing unintended operations
**Good:** Always start scripts with `set -euo pipefail` — exit on errors, treat unset variables as errors, and fail on any pipeline component failure

### 3. No Main Function Pattern

**Bad:** Writing scripts as a flat sequence of commands with global variables scattered throughout
**Why it's bad:** Variables leak between sections, the script is impossible to test, and understanding the flow requires reading every line from top to bottom
**Good:** Use a `main()` function with local variables and explicit parameter passing — this enables testing, limits variable scope, and clarifies the script's entry point

### 4. Hardcoded Paths and Configuration

**Bad:** Embedding absolute paths like `/home/user/data` or `/opt/app/config.yaml` directly in scripts
**Why it's bad:** The script fails on any system where the path differs — it cannot be reused, shared, or deployed to different environments
**Good:** Use configurable paths with sensible defaults and environment variable overrides — `DATA_DIR="${DATA_DIR:-/var/data}"`

## Best Practices

### 1. Use set Flags

```bash
set -euo pipefail
```

### 2. Quote Variables

```bash
echo "$variable"
cat "$file"
```

### 3. Use Functions

```bash
cleanup() {
    rm -rf "$temp_dir"
}
trap cleanup EXIT
```

## Failure Modes

- **Missing set flags for error handling** → script continues after errors → cascading failures and corrupted state → always use set -euo pipefail at script start
- **Unquoted variables with spaces** → filenames or arguments with spaces cause word splitting → commands fail or operate on wrong files → quote all variable expansions with double quotes
- **No main function pattern** → global variables and inline code → hard to test and understand → use main function with local variables and explicit parameter passing
- **Missing cleanup on exit** → temp files and resources not released → resource leaks on script failure → use trap cleanup EXIT to ensure cleanup regardless of exit path
- **Using eval with user input** → eval executes arbitrary code from user input → command injection vulnerability → avoid eval entirely; use arrays or indirect expansion instead
- **Not validating input arguments** → script runs with missing or invalid parameters → unexpected behavior and errors → validate all required arguments at script start with clear error messages
- **Hardcoded paths and configuration** → paths embedded in script → script fails on different systems → use configurable paths with sensible defaults and environment variable overrides

## Related Topics

- [[Pipelines]]
- [[POSIXShell]]
- [[CiCd]]
- [[InfrastructureAsCode]]
- [[Docker]]
- [[GitOps]]
- [[Monitoring]]
- [[Logging]]
