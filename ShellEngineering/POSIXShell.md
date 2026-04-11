---
title: POSIX Shell
title_pt: Shell POSIX
layer: shell_engineering
type: concept
priority: high
version: 1.0.0
tags:
  - ShellEngineering
  - POSIXShell
description: Writing portable shell scripts that work across different Unix systems.
description_pt: Escrevendo scripts shell portáteis que funcionam em diferentes sistemas Unix.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# POSIX Shell

## Description

POSIX (Portable Operating System Interface) is a standard for Unix-like systems. Writing POSIX-compliant scripts ensures portability.



## Purpose

**When POSIX compliance is valuable:**
- Scripts must run across different Unix systems (Linux, macOS, BSD)
- Writing portable installation scripts, CI runners, or Docker entrypoints
- Targeting minimal environments (Alpine, busybox, embedded systems)
- Distributing scripts to unknown environments

**When POSIX may not be needed:**
- Scripts only run on a single known environment (e.g., Ubuntu CI runner)
- You control the target platform and it has bash/zsh
- Script is internal and never leaves your infrastructure
- You need bash-specific features (arrays, associative maps, process substitution)

**The key question:** Will this script run on systems where bash isn't the default shell?

## Portable Patterns

```bash
# Use $(command) instead of `command`
result=$(date +%s)

# Use [ instead of [[ for portability
if [ "$var" = "value" ]; then
    echo "Match"
fi

# Use printf for output
printf "%s\n" "Output"
```

## Non-Portable Features

```bash
# Bash-isms to avoid:
# - [[ ]] (use [ ])
# - (( )) (use expr)
# - $(( )) for arithmetic (use expr or $(()))
# - source (use .)
# - declare/typeset
# - local in functions
```

## Failure Modes

- **Using bash-isms in POSIX scripts** → arrays, [[ ]], or process substitution used → script fails on dash or sh → test scripts with dash and avoid bash-specific features
- **Unquoted variables causing word splitting** → spaces in filenames break commands → unexpected behavior and security issues → always quote variable expansions with double quotes
- **Not checking command exit status** → script continues after failed command → cascading errors and corrupted state → use set -e or check $? after critical commands
- **Using backticks instead of $()** → backticks are harder to nest and read → maintenance difficulty → use $(command) syntax for command substitution
- **Hardcoded paths that vary across systems** → /usr/bin vs /usr/local/bin → script fails on different Unix variants → use PATH search or detect paths at runtime
- **Assuming GNU coreutils availability** → BSD and macOS have different tool flags → script fails on non-Linux systems → use POSIX-compliant flags or detect OS and adjust
- **Not handling signals and cleanup** → script interrupted leaves temp files or partial state → resource leaks and orphaned processes → use trap to clean up on EXIT, INT, and TERM signals

## Anti-Patterns

### 1. Bash-isms in POSIX Scripts

**Bad:** Using `[[ ]]`, arrays, `source`, or process substitution in a script with `#!/bin/sh` shebang
**Why it's bad:** The script works on systems where `sh` is bash (many Linux distributions) but fails on systems where `sh` is dash (Ubuntu, Debian) or ash (Alpine)
**Good:** Test scripts with `dash` or `busybox sh` — if it runs there, it is truly POSIX-compliant

### 2. Unquoted Variable Expansions

**Bad:** Using `$var` without quotes, causing word splitting and glob expansion on values with spaces
**Why it's bad:** A filename like `my file.txt` becomes two arguments `my` and `file.txt` — commands operate on wrong files or fail unexpectedly
**Good:** Always quote variable expansions with double quotes — `"$var"` preserves the value exactly as assigned

### 3. Assuming GNU Coreutils

**Bad:** Using GNU-specific flags like `sed -i` (no backup extension), `sort -V`, or `date -d` without checking OS compatibility
**Why it's bad:** BSD/macOS versions of these tools have different flags — the script works on Linux but fails everywhere else
**Good:** Use POSIX-compliant flags or detect the OS and adjust behavior — `sed -i ''` on macOS vs `sed -i` on Linux

### 4. Not Handling Signals and Cleanup

**Bad:** A script creates temporary files and directories but does not clean them up when interrupted
**Why it's bad:** Ctrl+C or a timeout leaves orphaned temp files, locked resources, and partial state that confuses the next run
**Good:** Use `trap cleanup EXIT INT TERM` to ensure cleanup runs on any exit path — normal completion, error, or interruption

## Best Practices

### 1. Test with dash/sh

```bash
# Test with different shells
sh -n script.sh    # Check syntax
dash script.sh     # Test with dash
```

## Related Topics

- [[BashBestPractices]] — Bash-specific best practices
