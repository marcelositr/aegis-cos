#!/bin/sh
# AEGIS Pre-Commit Hook
# Version: 0.0.1 Alpha Test
# Validates: .sh, .md, .yml
# Installation: Copy to .git/hooks/pre-commit and chmod +x
# Or: ln -s ../../SCRIPTS/PreCommit_Hook.sh .git/hooks/pre-commit

set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ERRORS=0

log_fail() { printf "${RED}[FAIL]${NC} %s\n" "$1"; ERRORS=$((ERRORS + 1)); }
log_pass() { printf "${GREEN}[PASS]${NC} %s\n" "$1"; }
log_warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }

echo "AEGIS Pre-Commit Hook v2.0"

# Get staged files
STAGED_SH=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(sh)$' || true)
STAGED_MD=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(md)$' || true)
STAGED_YML=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(yml|yaml)$' || true)
STAGED_C=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(c|h)$' || true)

[ -z "$STAGED_SH" ] && [ -z "$STAGED_MD" ] && [ -z "$STAGED_YML" ] && [ -z "$STAGED_C" ] && echo "No relevant files staged" && exit 0

# CHECK 1: Shell Safety
if [ -n "$STAGED_SH" ]; then
    echo ""
    echo "Checking shell scripts..."
    for f in $STAGED_SH; do
        [ -f "$f" ] || continue
        
        if ! grep -q "^set -eu" "$f" && ! grep -q "^set -e" "$f"; then
            log_fail "$f: Missing 'set -eu'"
        fi
        
        if grep -qE 'console\.log|print\s+\"|debugger|console\.debug' "$f"; then
            log_fail "$f: Debug code found"
        fi
        
        if grep -q 'echo -e' "$f"; then
            log_fail "$f: 'echo -e' is not POSIX (use printf)"
        fi
        
        if ! sh -n "$f" 2>/dev/null; then
            log_fail "$f: Not POSIX compliant"
        fi
    done
fi

# CHECK 2: Markdown Structure
if [ -n "$STAGED_MD" ]; then
    echo ""
    echo "Checking Markdown files..."
    for f in $STAGED_MD; do
        [ -f "$f" ] || continue
        
        if head -1 "$f" 2>/dev/null | grep -q "^---"; then
            log_pass "$f: Has frontmatter"
        else
            log_warn "$f: Missing frontmatter"
        fi
    done
fi

# CHECK 3: YAML Structure
if [ -n "$STAGED_YML" ]; then
    echo ""
    echo "Checking YAML files..."
    for f in $STAGED_YML; do
        [ -f "$f" ] || continue
        
        if grep -qE "^---" "$f" 2>/dev/null; then
            log_pass "$f: Has YAML document start"
        else
            log_fail "$f: Missing YAML document start"
        fi
        
        if grep -q "^layer:" "$f" && grep -q "^name:" "$f" && grep -q "^summary:" "$f"; then
            log_pass "$f: Has required fields"
        else
            log_warn "$f: Missing required fields"
        fi
    done
fi

# CHECK 4: File Size
echo ""
echo "Checking file sizes..."
all_files="$STAGED_SH $STAGED_MD $STAGED_YML $STAGED_C"
for f in $all_files; do
    [ -f "$f" ] || continue
    lines=$(wc -l < "$f" 2>/dev/null || echo 0)
    if [ "$lines" -gt 200 ]; then
        log_fail "$f: $lines lines (max: 200)"
    fi
done

# CHECK 5: C Dependencies
if [ -n "$STAGED_C" ]; then
    echo ""
    echo "Checking C dependencies..."
    for f in $STAGED_C; do
        [ -f "$f" ] || continue
        
        if grep -qE '#include.*<(boost|bsd/string|linux/kernel)' "$f"; then
            log_fail "$f: Non-portable include"
        fi
        
        if grep -qE 'TODO|FIXME|HACK' "$f"; then
            log_warn "$f: Contains TODO/FIXME"
        fi
    done
fi

# CHECK 6: Secrets
echo ""
echo "Checking for secrets..."
if git diff --cached | grep -iE '(password|api_key|secret|token)\s*=' >/dev/null 2>&1; then
    log_fail "Possible secret in staged changes"
fi

# CHECK 7: Binary files
echo ""
echo "Checking for binary files..."
all_check="$STAGED_SH $STAGED_C"
for f in $all_check; do
    [ -f "$f" ] || continue
    if command -v file >/dev/null 2>&1; then
        if file "$f" 2>/dev/null | grep -q "binary"; then
            log_fail "$f: Binary file detected"
        fi
    fi
done

# Summary
echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "Pre-commit FAILED: $ERRORS error(s)"
    echo "Fix errors before committing"
    exit 1
else
    echo "Pre-commit PASSED"
    exit 0
fi
