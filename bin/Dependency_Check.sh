#!/bin/sh
# AEGIS Dependency Check Script
# Version: 0.0.1 Alpha Test
# Checks for forbidden dependencies
# Validates: .sh, .md, .yml

set -eu

PROJECT_DIR="${1:-.}"

ERRORS=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "${TERM:-}" ] || [ "$TERM" = "dumb" ]; then
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log_fail() { printf '%s[FAIL]%s %s\n' "$RED" "$NC" "$1"; ERRORS=$((ERRORS + 1)); }
log_pass() { printf '%s[PASS]%s %s\n' "$GREEN" "$NC" "$1"; }
log_warn() { printf '%s[WARN]%s %s\n' "$YELLOW" "$NC" "$1"; }
log_info() { printf '%s[INFO]%s %s\n' "$BLUE" "$NC" "$1"; }

echo "=========================================="
echo " AEGIS Dependency Check v2.0"
echo " Project: $PROJECT_DIR"
echo "=========================================="
echo ""

# CHECK: C dependencies
echo "--- C/C++ Dependencies ---"
c_files=""
if [ -d "$PROJECT_DIR/src" ]; then
    c_files=$(find "$PROJECT_DIR/src" -name "*.c" -o -name "*.h" 2>/dev/null || true)
fi
if [ -d "$PROJECT_DIR/include" ]; then
    c_files="$c_files $(find "$PROJECT_DIR/include" -name "*.h" 2>/dev/null || true)"
fi

if [ -n "$c_files" ]; then
    for f in $c_files; do
        [ -f "$f" ] || continue
        
        while IFS= read -r line; do
            case "$line" in
                *"#include"*"<boost/"*|*"#include"*"<bsd/"*|*"#include"*"<linux/"*)
                    log_fail "$f: Forbidden include"
                    ;;
            esac
        done < "$f"
        
        if grep -qE 'strdup\s*\(|asprintf\s*\(|getline\s*\(' "$f" 2>/dev/null; then
            log_warn "$f: Uses non-POSIX functions"
        fi
    done
else
    log_pass "No C/C++ source found"
fi

# CHECK: Shell dependencies
echo ""
echo "--- Shell Script Dependencies ---"
shell_files=$(find "$PROJECT_DIR" -maxdepth 3 -name "*.sh" -type f 2>/dev/null || true)

if [ -n "$shell_files" ]; then
    for f in $shell_files; do
        [ -f "$f" ] || continue
        
        if grep -qE '\bperl\b|\bpython\b|\bruby\b|\blua\b' "$f" 2>/dev/null; then
            log_warn "$f: May use scripting language"
        fi
    done
else
    log_info "No shell scripts found"
fi

# CHECK: YAML - External links
echo ""
echo "--- YAML Dependencies ---"
if [ -d "$PROJECT_DIR/knowledge/yaml" ]; then
    yaml_count=$(find "$PROJECT_DIR/knowledge/yaml" -name "*.yml" -type f 2>/dev/null | wc -l)
    if [ "$yaml_count" -gt 0 ]; then
        log_info "Found $yaml_count YAML files"
        
        # Check for external URLs in YAML
        if grep -rqE 'https?://' "$PROJECT_DIR/knowledge/yaml" 2>/dev/null; then
            log_warn "YAML: External URLs found (consider embedding)"
        fi
    else
        log_info "No YAML files found"
    fi
else
    log_info "No YAML directory found"
fi

# CHECK: Package.json
if [ -f "$PROJECT_DIR/package.json" ]; then
    echo ""
    echo "--- Node Dependencies ---"
    if grep -qE '"dependencies"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        count=$(grep -c '"' "$PROJECT_DIR/package.json" 2>/dev/null || echo 0)
        count=$((count / 2))
        if [ "$count" -gt 5 ]; then
            log_warn "package.json: $count dependencies (recommend < 5)"
        else
            log_pass "package.json: $count dependencies"
        fi
    fi
fi

# CHECK: requirements.txt
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
    echo ""
    echo "--- Python Dependencies ---"
    count=$(wc -l < "$PROJECT_DIR/requirements.txt" 2>/dev/null || echo 0)
    if [ "$count" -gt 10 ]; then
        log_warn "requirements.txt: $count dependencies (recommend < 10)"
    else
        log_pass "requirements.txt: $count dependencies"
    fi
fi

# CHECK: Cargo.toml
if [ -f "$PROJECT_DIR/Cargo.toml" ]; then
    echo ""
    echo "--- Rust Dependencies ---"
    if grep -qE 'rand|serde|tokio|actix' "$PROJECT_DIR/Cargo.toml" 2>/dev/null; then
        log_warn "Cargo.toml: Heavy deps found (verify necessity)"
    else
        log_pass "Cargo.toml: Minimal deps"
    fi
fi

# Summary
echo ""
echo "=========================================="
echo " SUMMARY"
echo "=========================================="
if [ "$ERRORS" -gt 0 ]; then
    echo "STATUS: FAILED - Remove forbidden dependencies"
    exit 1
else
    echo "STATUS: PASSED - No forbidden dependencies"
    exit 0
fi
