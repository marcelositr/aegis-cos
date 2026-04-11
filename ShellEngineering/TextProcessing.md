---
title: Text Processing
title_pt: Processamento de Texto
layer: shell_engineering
type: concept
priority: high
version: 2.0.0
tags:
  - ShellEngineering
  - TextProcessing
  - Pipelines
  - UnixTools
description: Unix text processing tools and pipeline patterns — from basic file operations to advanced pattern matching with grep, sed, and awk.
description_pt: Ferramentas de processamento de texto Unix e padrões de pipeline — de operações básicas de arquivo a correspondência avançada de padrões com grep, sed e awk.
prerequisites:
  - "[[Pipelines]]"
  - "[[BashBestPractices]]"
estimated_read_time: 15 min
difficulty: intermediate
---

# Text Processing

## Description

Unix philosophy: "Everything is a file, and text is the universal interface." Text processing tools form the backbone of shell engineering — from simple file inspection to complex data transformation pipelines.

**Tool taxonomy:**
- **File inspection:** `cat`, `head`, `tail`, `wc`, `less`
- **Column/line extraction:** `cut`, `sort`, `uniq`, `tr`, `paste`
- **Pattern matching:** `grep`, `egrep`, `fgrep`
- **Stream editing:** `sed` — find/replace, line deletion, insertion
- **Field processing:** `awk` — structured text, calculations, reporting

## Purpose

**When text processing is essential:**
- Log analysis and debugging in production
- Data transformation in ETL pipelines
- Configuration file manipulation
- Quick ad-hoc data analysis without leaving the terminal
- Building shell scripts for automation

**When to use a higher-level language instead:**
- Complex data structures (JSON, XML) — use `jq`, Python, or Node.js
- Multi-line structured editing — use Python or a proper parser
- When performance matters on multi-gigabyte files — consider Python with buffered I/O or specialized tools

**The key question:** Can I solve this with a pipeline of simple text tools, or do I need structured data processing?

## Tradeoffs

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| Shell text tools | Available everywhere, composable, fast for simple tasks | Hard to debug, regex limits, no structured data | Quick inspection, simple transforms |
| `awk`/`sed` | Powerful, single-pass processing, no temp files | Steep learning curve, cryptic syntax | Log processing, report generation |
| Python/Node.js | Rich libraries, structured data, testable | Requires interpreter, slower startup | Complex parsing, JSON/XML, multi-step ETL |
| `jq` | Native JSON handling, composable | JSON-only, extra dependency | API responses, config files |

## Alternatives

- **For JSON:** `jq` — purpose-built for JSON, handles nesting, arrays, filters
- **For CSV:** `csvkit`, Python `csv` module — handles quoted fields, embedded commas
- **For XML/HTML:** `xmllint`, `xmlstarlet`, Python `BeautifulSoup` — proper parsers
- **For complex pipelines:** Python generators, Go goroutines — better error handling and structure

## Examples

### Basic File Operations

```bash
# Count lines, words, characters
wc -l -w -c access.log

# First/last N lines
head -n 20 access.log
tail -n 50 access.log

# Follow a log in real-time
tail -f /var/log/app.log | grep --line-buffered ERROR

# Extract specific columns
cut -d',' -f1,3,5 data.csv

# Sort and count unique values
cut -d',' -f7 access.log | sort | uniq -c | sort -rn | head -20
```

### grep — Pattern Matching

```bash
# Basic search with context
grep -C 3 "ERROR" app.log

# Extended regex
grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}" access.log

# Fixed string (no regex — faster and safer)
grep -F "user_id=12345" access.log

# Count matches per file
grep -rc "NullPointerException" /var/log/

# Exclude patterns
grep -v "DEBUG" app.log | grep "ERROR"
```

### sed — Stream Editor

```bash
# Replace all occurrences
sed 's/old_value/new_value/g' config.txt

# In-place with backup
sed -i.bak 's/old/new/g' config.txt

# Delete lines matching pattern
sed '/^#/d; /^$/d' config.txt

# Print specific range
sed -n '10,20p' access.log

# Multiple transformations
sed -e 's/foo/bar/g' -e '/^$/d' file.txt

# Extract between markers
sed -n '/START/,/END/p' log.txt
```

### awk — Field Processing

```bash
# Print specific fields
awk '{print $1, $3}' access.log

# Field separator for CSV
awk -F',' '{print $2, $5}' data.csv

# Conditional processing
awk '$3 > 100 {print $1, $3}' data.txt

# Aggregation with counters
awk '{sum += $2; count++} END {print "Average:", sum/count}' data.txt

# Multi-line programs
awk '
    BEGIN { FS=","; total=0 }
    NR > 1 { total += $3 }
    END { print "Total:", total }
' report.csv
```

### Complex Pipeline

```bash
# Analyze top 10 IP addresses from access log
tail -n 10000 access.log \
    | grep "GET /api/" \
    | awk '{print $1}' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -10

# Extract error rates per hour
grep "ERROR" app.log \
    | awk '{print substr($1,1,13)}' \
    | sort | uniq -c \
    | awk '{printf "%s: %d errors\n", $2, $1}'
```

## Failure Modes

- **Processing binary files as text** → corrupted output or tool crashes → verify file type with `file` command before processing
- **Unbounded input causing memory exhaustion** → multi-gigabyte files in memory → OOM crashes → use streaming tools, process line-by-line for large files
- **Locale-dependent behavior** → `sort` and `grep` vary by locale → inconsistent results across systems → set `LC_ALL=C` for predictable behavior
- **Special characters in filenames** → spaces, newlines, glob chars → commands fail or process wrong files → use null-delimited output (`-print0`, `xargs -0`)
- **Regex injection via user input** → user-controlled patterns in `grep`/`sed` → arbitrary command execution → validate/escape patterns, use `grep -F` for literals
- **Pipeline failure masked by last command** → earlier stage fails silently → data loss → always use `set -o pipefail`
- **sed in-place without backup** → typo corrupts original file → always test without `-i` first, or use `sed -i.bak`
- **Greedy regex catastrophic backtracking** → complex nested quantifiers → grep/sed hangs at 100% CPU → test regex performance, avoid `(a+)+` patterns
- **awk field separator mismatch** → wrong delimiter for CSV with quoted fields → silent wrong-column extraction → use proper CSV parser for complex data
- **Inefficient per-line tool calls** → calling grep/sed inside `while read` loop → 10,000 process forks → use `awk`/`sed` for batch processing

## Anti-Patterns

### 1. Inefficient Per-Line Tool Invocation

**Bad:** Calling `grep`, `sed`, or `awk` once per line inside a `while read` loop
**Why it's bad:** Each invocation forks a new process — 10,000 lines = 10,000 process forks, orders of magnitude slower than batch processing
**Good:** Use `awk` or `sed` for batch processing — they handle the entire file in a single invocation

### 2. Pipeline Failure Masking

**Bad:** Assuming pipeline success because last command returned 0
**Why it's bad:** `grep` finds no matches (exit 1), `wc -l` counts zero lines (exit 0) — pipeline "succeeds" with empty results, data silently lost
**Good:** Always use `set -o pipefail` — exit status becomes the last non-zero status of any command in the chain

### 3. Locale-Dependent Processing

**Bad:** Running `sort`, `grep`, or `tr` without `LC_ALL` — expecting consistent results across machines
**Why it's bad:** Sort order, character classes, and case matching vary by locale — same script, different output on different servers
**Good:** Set `LC_ALL=C` for consistent, byte-level behavior across all environments

### 4. Regex Injection

**Bad:** Passing user input directly into `grep` or `sed` patterns
**Why it's bad:** Attacker crafts input that changes regex behavior — DoS via catastrophic backtracking or unintended data extraction
**Good:** Validate and escape user patterns — use `grep -F` for literal matching when regex isn't needed

## Best Practices

1. **Use the simplest tool that works** — `grep` before `awk`, `awk` before Python
2. **Always set `set -o pipefail`** — catch failures anywhere in the pipeline
3. **Set `LC_ALL=C`** for predictable behavior across environments
4. **Test `sed` expressions without `-i`** before modifying files in place
5. **Use `grep -F` for literal strings** — faster and immune to regex injection
6. **Prefer `awk` for calculations** — single-pass, no temp files, built-in arithmetic
7. **Use `jq` for JSON** — don't try to parse JSON with `grep`/`sed`/`awk`
8. **Stream large files** — avoid loading entire file into memory with `cat file |`

## Related Topics

- [[Pipelines]] — Pipeline composition and error handling
- [[BashBestPractices]] — Shell scripting best practices
- [[Logging]] — Log analysis patterns
- [[AwkSedGrep]] — Advanced pattern matching deep dive
- [[EnvironmentVariables]] — LC_ALL and locale settings