---
title: Pipelines
title_pt: Pipelines
layer: shell_engineering
type: concept
priority: high
version: 1.0.0
tags:
  - ShellEngineering
  - Pipelines
description: Chaining commands to process data efficiently in shell scripts.
description_pt: Encadeando comandos para processar dados eficientemente em scripts shell.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Pipelines

## Description

Pipelines chain commands where each command's output becomes the next command's input. They're powerful but have pitfalls.



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

### Good Pipeline

```bash
# Process log file
cat access.log | grep "ERROR" | sort | uniq -c | sort -rn | head -20

# 1. cat - read file
# 2. grep - filter ERROR lines
# 3. sort - sort lines
# 4. uniq - count duplicates
# 5. sort - sort by count descending
# 6. head - get top 20
```

### Pipeline Variables

```bash
# Capture pipeline output
result=$(cat file.txt | tr '[:lower:]' '[:upper:]')

# Process substitution when needed
while read -r line; do
    process "$line"
done < <(grep pattern file.txt)
```

## Anti-Patterns

### 1. Missing Pipefail Causing Silent Failures

**Bad:** A pipeline where an early command fails but the pipeline reports success because only the last command's exit status is checked
**Why it's bad:** `grep "ERROR" missing.log | wc -l` returns 0 (success) even though the log file was never read — the script processes empty data and reports "0 errors found"
**Good:** Always `set -o pipefail` in scripts using pipelines — the pipeline fails if any component fails, not just the last one

### 2. Pipeline Variable Scope Loss

**Bad:** Setting variables inside a pipeline's `while read` loop and expecting them to be available afterward
**Why it's bad:** Each pipeline component runs in a subshell — variables set inside the loop are lost when the subshell exits, and the parent script sees nothing
**Good:** Use process substitution (`while read -r line; do ... done < <(grep pattern file)`) instead of piping to while loops — this keeps the loop in the current shell

### 3. Complex Pipelines Instead of Scripts

**Bad:** A one-liner with 10+ pipe stages that nobody can read, debug, or modify
**Why it's bad:** When the pipeline breaks (and it will), nobody understands what each stage does, what the expected intermediate output is, or how to fix it
**Good:** Break complex pipelines into named functions or separate script files — each stage should have a clear name and purpose

### 4. Unnecessary Cat (UUOC)

**Bad:** `cat file.txt | grep pattern` instead of `grep pattern file.txt`
**Why it's bad:** An unnecessary process is spawned and a pipe is created — this is wasteful in loops processing many files and sets a bad pattern for script readability
**Good:** Pass files directly to commands that accept file arguments — reserve `cat` for concatenating multiple files or when you need to chain stdin

## Best Practices

### 1. Set Pipefail

```bash
# Fail on any command failure in pipeline
set -o pipefail

# Without this, pipeline succeeds if last command succeeds
```

### 2. Avoid Unnecessary Cats

```bash
# Bad
cat file.txt | grep pattern

# Good
grep pattern file.txt
```

## Failure Modes

- **Missing pipefail causing silent failures** → earlier command fails but pipeline succeeds → data processing completes with missing input → always set -o pipefail in scripts using pipelines
- **Unnecessary cat (UUOC)** → cat file | command instead of command file → extra process and pipe overhead → pass files directly to commands that accept file arguments
- **Pipeline variable scope loss** → variables set in pipeline subshell not available in parent → lost results and state → use process substitution or here-strings instead of piping to while read
- **Unbounded pipeline buffering** → large data flows through pipe without backpressure → memory exhaustion → implement rate limiting or chunked processing for large data pipelines
- **Pipeline without error propagation** → middle command fails but pipeline continues → partial or corrupted output → check pipeline exit status and abort on any component failure
- **Complex pipelines instead of scripts** → one-liner with 10+ pipe stages → unmaintainable and hard to debug → break complex pipelines into named functions or separate script files
- **Pipeline output not validated** → assuming pipeline produces correct output → silent data corruption → validate pipeline output format and content at critical stages

## Related Topics

- [[BashBestPractices]]
- [[TextProcessing]]
- [[TextTools]]
- [[CiCd]]
- [[Docker]]
- [[Monitoring]]
- [[Logging]]
- [[InfrastructureAsCode]]
