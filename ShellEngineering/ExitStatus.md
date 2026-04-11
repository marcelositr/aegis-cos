---
title: Exit Status
title_pt: Status de Saída
layer: shell_engineering
type: concept
priority: high
version: 1.0.0
tags:
  - ShellEngineering
  - ExitStatus
description: Understanding and using exit codes in shell scripts.
description_pt: Entendendo e usando códigos de saída em scripts shell.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Exit Status

## Description

Commands return exit status 0-255:
- 0 = success
- 1-255 = failure (specific meanings vary)



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
# Check exit status
command
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi

# Direct check
if command; then
    echo "Success"
fi

# In functions
die() {
    echo "$*" >&2
    exit 1
}

# Use set -e to fail on errors
set -e
command_that_might_fail
```

## Common Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Misuse of command |
| 126 | Command not executable |
| 127 | Command not found |
| 128+N | Signal N |

## Failure Modes

- **Ignoring non-zero exit codes** → script continues after command failure → corrupted state and cascading errors → use set -e or explicitly check exit status after critical commands
- **Using exit codes above 255** → exit code wraps around modulo 256 → wrong error code reported → keep exit codes in 1-255 range and use standard conventions
- **Not propagating exit codes from functions** → function succeeds even when internal command fails → caller cannot detect failure → return $? from functions or use set -e within functions
- **Exit code collision** → different errors use same exit code → cannot distinguish failure types → define and document specific exit codes for different error conditions
- **set -e with conditional commands** → set -e causes unexpected exit in if statements → script terminates prematurely → understand set -e exceptions and use explicit error handling
- **Missing cleanup on exit** → script exits without removing temp files → resource leaks and disk space waste → use trap cleanup EXIT to ensure cleanup on any exit path
- **Silent failures in pipelines** → pipeline exit status is only last command → intermediate failures go unnoticed → use set -o pipefail and check PIPESTATUS array

## Anti-Patterns

### 1. Ignoring Non-Zero Exit Codes

**Bad:** Running commands without checking their exit status, allowing the script to continue after failures
**Why it's bad:** A failed `cd`, `rm`, or database migration goes unnoticed — subsequent commands operate on wrong directories, delete wrong files, or corrupt data
**Good:** Use `set -e` to exit on any error, or explicitly check `$?` after critical commands that require special handling

### 2. Silent Failures in Pipelines

**Bad:** A pipeline where an early command fails but the last command succeeds, masking the failure
**Why it's bad:** `cat missing_file | wc -l` returns 0 (success) even though the input file was never read — the script processes empty data silently
**Good:** Use `set -o pipefail` so the pipeline fails if any component fails, and check `${PIPESTATUS[@]}` for detailed diagnostics

### 3. Not Propagating Exit Codes from Functions

**Bad:** A function that runs commands but always returns 0, hiding internal failures from the caller
**Why it's bad:** The caller assumes success and continues — the function's internal error is invisible to the rest of the script
**Good:** Return `$?` from functions or use `set -e` within functions — let callers detect and handle failures appropriately

### 4. Missing Cleanup on Exit

**Bad:** A script that creates temporary files, locks, or network connections but does not clean them up on error exit
**Why it's bad:** Failed scripts leave behind orphaned resources that accumulate over time — temp files fill disk, locks prevent reruns, connections exhaust pools
**Good:** Use `trap cleanup EXIT` to ensure cleanup runs on every exit path — success, failure, or interruption

## Best Practices

### 1. Use set -e

```bash
set -e  # Exit on error
```

### 2. Propagate Errors

```bash
# Let caller know about failures
command || return $?
```

## Related Topics

- [[Shell Engineering MOC]]
- [[BashBestPractices]]
- [[CiCd]]
- [[Alerting]]
- [[IncidentManagement]]
