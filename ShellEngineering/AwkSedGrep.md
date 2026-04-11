---
title: Awk, Sed, Grep
title_pt: Awk, Sed, Grep — Correspondência Avançada de Padrões
layer: shell_engineering
type: concept
priority: high
version: 2.0.0
tags:
  - ShellEngineering
  - AwkSedGrep
  - PatternMatching
  - Regex
description: Advanced text pattern matching and transformation with grep, sed, and awk — the three pillars of Unix text processing.
description_pt: Correspondência avançada de padrões e transformação com grep, sed e awk — os três pilares do processamento de texto Unix.
prerequisites:
  - "[[TextProcessing]]"
  - "[[Pipelines]]"
estimated_read_time: 15 min
difficulty: intermediate
---

# Awk, Sed, Grep

## Description

The three fundamental Unix text processing tools, each with a distinct role:

| Tool | Role | Strength |
|------|------|----------|
| **grep** | Filter lines by pattern | Fast matching, regex search |
| **sed** | Transform text line-by-line | Find/replace, line editing, deletion |
| **awk** | Process structured text fields | Field extraction, calculations, reporting |

**When to use which:**
- Need to **find** lines → `grep`
- Need to **change** lines → `sed`
- Need to **compute** from fields → `awk`

## Purpose

**When these tools are essential:**
- Log analysis with complex patterns
- Batch text transformation (config files, data files)
- Field-based extraction and aggregation
- Building shell-based data pipelines
- Quick ad-hoc analysis without leaving the terminal

**When to reach for something else:**
- JSON/XML data → `jq`, `xmllint`, Python
- Multi-line context-aware editing → Python, Perl
- When you need error handling and structured logic → any scripting language

**The key question:** Am I processing line-oriented text, or do I need structured data handling?

## Tradeoffs

| Tool | Strengths | Weaknesses | When Not to Use |
|------|-----------|------------|-----------------|
| `grep` | Fast, simple, universally available | Line-only, no transformation | Multi-line patterns, structured data |
| `sed` | Stream editing, in-place modification, widely available | Cryptic syntax, limited arithmetic | Complex field processing, calculations |
| `awk` | Field-based processing, built-in arithmetic, BEGIN/END blocks | Steeper learning curve, overkill for simple tasks | Simple string search (use grep instead) |

## Examples

### grep — Advanced Pattern Matching

```bash
# Search with context (3 lines before and after)
grep -C 3 "ERROR" app.log

# Extended regex with alternation
grep -E "ERROR|WARN|FATAL" app.log

# Invert match — show lines NOT matching
grep -v "^#" config.txt

# Count matches per file
grep -rc "TODO" src/

# Only show filenames (not matching lines)
grep -rl "FIXME" src/

# Word boundary matching
grep -w "error" log.txt  # matches "error" but not "errors"

# Fixed string (no regex interpretation — fastest)
grep -F "$literal_string" file.txt

# Binary file handling
grep -a "PATTERN" binary_file

# Recursive with file type filter
grep -r --include="*.py" "def " src/
```

### sed — Stream Editing

```bash
# Global replacement
sed 's/old/new/g' file.txt

# Replace only Nth occurrence per line
sed 's/old/new/2' file.txt  # 2nd occurrence only

# Multiple substitutions
sed 's/foo/bar/g; s/baz/qux/g' file.txt

# Delete lines by pattern
sed '/^#/d; /^$/d' file.txt  # remove comments and blank lines

# Insert/append lines
sed '/pattern/a\New line after match' file.txt
sed '/pattern/i\New line before match' file.txt

# Print range of lines
sed -n '10,20p' file.txt

# Delete range of lines
sed '5,10d' file.txt

# Extract between markers
sed -n '/START/,/END/p' log.txt

# In-place with backup (always!)
sed -i.bak 's/old/new/g' config.txt

# Using different delimiters (useful when pattern contains /)
sed 's|/old/path|/new/path|g' config.txt
```

### awk — Field Processing and Computation

```bash
# Basic field extraction (space-delimited)
awk '{print $1, $3}' file.txt

# Custom field separator
awk -F',' '{print $2, $5}' data.csv

# Multiple field separators
awk -F'[,;]' '{print $1, $3}' data.txt

# Conditional processing
awk '$3 > 100 {print $1, $3}' data.txt

# Aggregation — sum a column
awk '{sum += $2} END {print "Total:", sum}' data.txt

# Average with count
awk '{sum += $1; count++} END {print "Avg:", sum/count}' data.txt

# Group by field
awk -F',' '{count[$2]++} END {for (k in count) print k, count[k]}' data.csv

# Multi-line programs with BEGIN/END
awk '
    BEGIN { FS=","; OFS="\t"; print "Name", "Total" }
    NR > 1 { totals[$1] += $3 }
    END { for (name in totals) print name, totals[name] }
' sales.csv

# String functions
awk '{print toupper($1), length($2), substr($3, 1, 5)}' file.txt

# Pattern-action pairs
awk '/ERROR/ {errors++} /WARN/ {warns++} END {print errors, warns}' log.txt
```

### Real-World Pipelines

```bash
# Top 10 most active IPs from access log
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10

# Error rate per hour
grep "ERROR" app.log \
    | awk '{print substr($1,1,13)}' \
    | sort | uniq -c \
    | awk '{printf "%s: %d errors/hour\n", $2, $1}'

# Find all TODO comments with file:line
grep -rn "TODO\|FIXME\|HACK" --include="*.py" --include="*.js" src/

# Extract and sum response times from log
awk '{sum += $NF; count++} END {printf "Avg: %.2fms (%d requests)\n", sum/count, count}' access.log

# CSV column analysis (skip header, sum column 3)
awk -F',' 'NR > 1 {sum += $3} END {print "Total:", sum}' data.csv
```

## Failure Modes

- **grep regex injection** → user-controlled patterns → arbitrary regex execution or DoS via catastrophic backtracking → validate/escape input, use `grep -F` for literals
- **sed in-place without backup** → `sed -i` corrupts file on typo → original data lost → always use `sed -i.bak` or test without `-i` first
- **awk field separator mismatch** → wrong delimiter for CSV with quoted/embedded commas → silent wrong-column extraction → verify separator matches data, use CSV parser for complex data
- **Chained tools without error handling** → one stage fails, others process empty input → corrupted output → use `set -o pipefail` and validate output
- **awk arrays loading entire file into memory** → `awk '{a[$1]++} END {...}'` on multi-GB file → OOM → process line-by-line, avoid storing entire dataset
- **Greedy regex catastrophic backtracking** → nested quantifiers like `(a+)+` or `.*.*` → grep/sed hangs at 100% CPU → test regex performance, avoid nested quantifiers
- **Locale affecting sort and grep** → different locale changes sort order → inconsistent results → set `LC_ALL=C`
- **sed with unescaped special characters** → `/` in paths, `&` in replacement → syntax errors or wrong substitutions → use alternative delimiters (`|`, `:`), escape `&` as `\&`
- **grep matching binary files** → binary data interpreted as text → garbled output or skipped matches → use `grep -a` to force text mode, or `file` to check first
- **awk OFS not set** → `print $1, $2` uses space even if FS is comma → inconsistent output → set `OFS` explicitly when output format matters

## Anti-Patterns

### 1. Sed In-Place Without Backup

**Bad:** `sed -i 's/old/new/g' file.txt` without testing or backup
**Why it's bad:** A typo in the expression corrupts the file in place — no recovery possible
**Good:** Test without `-i` first to preview, or use `sed -i.bak` to create automatic backup

### 2. Greedy Regex Catastrophic Backtracking

**Bad:** `grep -E '(a+)+b' large_file.txt` — nested quantifiers on large input
**Why it's bad:** Regex engine enters exponential backtracking — appears to hang, consuming 100% CPU indefinitely
**Good:** Test regex on representative input — avoid nested quantifiers, prefer `grep -F` for literal matching

### 3. Awk Field Separator Mismatch

**Bad:** `awk -F',' '{print $2}' data.csv` on CSV with quoted fields containing commas
**Why it's bad:** Fields extracted from wrong columns — output silently incorrect, no error reported
**Good:** Verify separator matches data — for complex CSV with quoted fields, use `csvkit` or Python `csv` module

### 4. Chained Tools Without Error Handling

**Bad:** `grep "pattern" file | sed 's/x/y/' | awk '{print $1}'` without checking any stage
**Why it's bad:** If grep finds no matches (exit 1), sed processes empty input, awk produces nothing — pipeline "succeeds" with empty output
**Good:** Use `set -o pipefail` and validate output at critical stages

## Best Practices

1. **Choose the right tool** — grep for matching, sed for replacing, awk for computing
2. **Use `grep -E`** for extended regex (cleaner than escaping with `grep`)
3. **Use `grep -F`** for literal strings — faster and safer
4. **Test sed expressions** without `-i` before modifying files
5. **Use alternative sed delimiters** (`|`, `:`) when patterns contain `/`
6. **Set `LC_ALL=C`** for predictable behavior across environments
7. **Use `set -o pipefail`** to catch failures anywhere in the pipeline
8. **Prefer awk for calculations** — single-pass, no temp files needed
9. **Avoid storing entire files in awk arrays** — process line-by-line when possible
10. **For complex CSV/JSON, use proper parsers** — `csvkit`, `jq`, Python

## Related Topics

- [[TextProcessing]] — Fundamentals and broader text tool coverage
- [[Pipelines]] — Pipeline composition and error handling
- [[BashBestPractices]] — Shell scripting best practices
- [[EnvironmentVariables]] — LC_ALL and locale configuration
- [[Logging]] — Log analysis patterns using these tools