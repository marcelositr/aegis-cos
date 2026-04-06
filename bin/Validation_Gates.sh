#!/bin/sh
# AEGIS Validation Gates - Validation Protocol
# Version: 0.0.1 Alpha Test
# Validates: .sh, .md, .yml
# Usage: ./Validation_Gates.sh <project_dir>

set -eu

PROJECT_DIR="${1:-.}"

ERRORS=0
WARNINGS=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "${TERM:-}" ] || [ "$TERM" = "dumb" ]; then
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log_pass() { printf '%s[PASS]%s %s\n' "$GREEN" "$NC" "$1"; }
log_fail() { printf '%s[FAIL]%s %s\n' "$RED" "$NC" "$1"; ERRORS=$((ERRORS + 1)); }
log_warn() { printf '%s[WARN]%s %s\n' "$YELLOW" "$NC" "$1"; WARNINGS=$((WARNINGS + 1)); }
log_info() { printf '%s[INFO]%s %s\n' "$BLUE" "$NC" "$1"; }

get_shell_scripts() {
    find "$PROJECT_DIR" -maxdepth 3 -name "*.sh" -type f 2>/dev/null || true
}

get_markdown_files() {
    find "$PROJECT_DIR" -maxdepth 3 -name "*.md" -type f 2>/dev/null || true
}

get_yaml_files() {
    find "$PROJECT_DIR" -maxdepth 3 \( -name "*.yml" -o -name "*.yaml" \) -type f 2>/dev/null || true
}

echo "=========================================="
echo " AEGIS Validation Gates v2.0"
echo " Project: $PROJECT_DIR"
echo "=========================================="
echo ""

# GATE 1: Pre-Execution - Shell Scripts
echo "--- GATE 1: Shell Scripts ---"

shell_scripts=$(get_shell_scripts)
if [ -n "$shell_scripts" ]; then
    for f in $shell_scripts; do
        [ -f "$f" ] || continue
        shebang=$(head -1 "$f" 2>/dev/null || echo "")
        case "$shebang" in
            "#!/bin/bash"*|"#!/usr/bin/bash"*)
                log_warn "$f: Uses bash (consider #!/bin/sh)"
                ;;
            "#!/bin/sh"*|"#!/usr/bin/env sh")
                log_pass "$f: POSIX shebang"
                ;;
        esac
    done
else
    log_info "No shell scripts found"
fi

# GATE 2: Real-Time - Error Handling
echo ""
echo "--- GATE 2: Error Handling ---"

if [ -n "$shell_scripts" ]; then
    for f in $shell_scripts; do
        [ -f "$f" ] || continue
        if ! grep -q "^set -eu" "$f" && ! grep -q "^set -e" "$f"; then
            log_fail "$f: Missing 'set -eu'"
        else
            log_pass "$f: Has error handling"
        fi
    done
fi

# GATE 3: File Size Limits
echo ""
echo "--- GATE 3: File Size Limits ---"

# Different limits for different file types
MAX_LINES_SH=250
MAX_LINES_OTHER=700

# Check shell scripts
for f in $(find "$PROJECT_DIR" -maxdepth 3 -name "*.sh" -type f 2>/dev/null || true); do
    [ -f "$f" ] || continue
    lines=$(wc -l < "$f" 2>/dev/null || echo 0)
    if [ "$lines" -gt "$MAX_LINES_SH" ]; then
        log_fail "$f: $lines lines (max: $MAX_LINES_SH)"
    else
        log_pass "$f: $lines lines"
    fi
done

# Check .md and .yml files
for f in $(find "$PROJECT_DIR" -maxdepth 3 \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -type f 2>/dev/null || true); do
    [ -f "$f" ] || continue
    lines=$(wc -l < "$f" 2>/dev/null || echo 0)
    if [ "$lines" -gt "$MAX_LINES_OTHER" ]; then
        log_fail "$f: $lines lines (max: $MAX_LINES_OTHER)"
    else
        log_pass "$f: $lines lines"
    fi
done

# GATE 4: YAML Validation
echo ""
echo "--- GATE 4: YAML Syntax ---"

yaml_files=$(get_yaml_files)
if [ -n "$yaml_files" ]; then
    for f in $yaml_files; do
        [ -f "$f" ] || continue
        # Basic YAML structure check
        if grep -qE "^---" "$f" 2>/dev/null; then
            log_pass "$f: Has YAML document start"
        else
            log_warn "$f: Missing YAML document start (---)"
        fi
        
        # Check for required fields
        if grep -q "^layer:" "$f" && grep -q "^name:" "$f" && grep -q "^summary:" "$f"; then
            log_pass "$f: Has required fields"
        else
            log_warn "$f: Missing required fields"
        fi
    done
else
    log_info "No YAML files found"
fi

# GATE 5: Markdown Validation
echo ""
echo "--- GATE 5: Markdown Structure ---"

md_files=$(get_markdown_files)
if [ -n "$md_files" ]; then
    for f in $md_files; do
        [ -f "$f" ] || continue
        
        # Check for frontmatter
        if head -1 "$f" 2>/dev/null | grep -q "^---"; then
            # Check for closing frontmatter
            if grep -q "^---" "$f" 2>/dev/null; then
                log_pass "$f: Has frontmatter"
            else
                log_fail "$f: Unclosed frontmatter"
            fi
        else
            log_warn "$f: Missing frontmatter"
        fi
    done
else
    log_info "No Markdown files found"
fi

# GATE 6: Dependency Check
echo ""
echo "--- GATE 6: Dependencies ---"

if [ -n "$shell_scripts" ]; then
    for f in $shell_scripts; do
        [ -f "$f" ] || continue
        case "$f" in
            */Validation_Gates.sh|*/Dependency_Check.sh|*/PreCommit_Hook.sh|*/Hostile_Env_Test.sh|*/Install.sh|*/Update.sh)
                continue
                ;;
        esac
        if grep -qE 'grep.*-[P]' "$f" 2>/dev/null; then
            log_warn "$f: Possible GNU-only 'grep -P'"
        fi
        if grep -qE 'sed.*-i' "$f" 2>/dev/null; then
            log_warn "$f: Possible GNU-only 'sed -i'"
        fi
    done
fi

# GATE 7: POSIX Compliance
echo ""
echo "--- GATE 7: POSIX Compliance ---"

if [ -n "$shell_scripts" ]; then
    for f in $shell_scripts; do
        [ -f "$f" ] || continue
        if ! sh -n "$f" 2>/dev/null; then
            log_fail "$f: Not POSIX compliant"
        else
            log_pass "$f: POSIX compliant"
        fi
    done
fi

# Summary
echo ""
echo "=========================================="
echo " SUMMARY"
echo "=========================================="
echo " Errors:   $ERRORS"
echo " Warnings: $WARNINGS"
echo ""

if [ "$ERRORS" -gt 0 ]; then
    echo "STATUS: FAILED"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo "STATUS: PASSED WITH WARNINGS"
    exit 0
else
    echo "STATUS: PASSED"
    exit 0
fi
