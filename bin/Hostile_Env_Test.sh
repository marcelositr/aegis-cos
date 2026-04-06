#!/bin/sh
# AEGIS Hostile Environment Test
# Version: 0.0.1 Alpha Test
# Tests software in minimal/restricted environments
# Validates: .sh, .md, .yml

set -eu

PROJECT_DIR="${1:-.}"

ERRORS=0
TESTS_RUN=0
TESTS_PASSED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_pass() { printf "${GREEN}[PASS]${NC} %s\n" "$1"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_fail() { printf "${RED}[FAIL]${NC} %s\n" "$1"; ERRORS=$((ERRORS + 1)); }
log_warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_test() { printf "  Testing: %s..." "$1"; TESTS_RUN=$((TESTS_RUN + 1)); }
log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }

echo "=========================================="
echo " AEGIS Hostile Environment Test v2.0"
echo " Project: $PROJECT_DIR"
echo "=========================================="
echo ""

# TEST 1: Shell Scripts - No bash dependency
echo "--- SHELL: No Bash Dependency ---"
if [ -f "$PROJECT_DIR/run.sh" ]; then
    shebang=$(head -1 "$PROJECT_DIR/run.sh")
    log_test "No bash dependency"
    case "$shebang" in
        "#!/bin/sh"*|"#!/bin/ash"*)
            log_pass "Uses POSIX shell"
            ;;
        "#!/bin/bash"*)
            log_fail "Requires bash (not portable)"
            ;;
    esac
fi

# TEST 2: Shell Scripts - Minimal dependencies
echo ""
echo "--- SHELL: Minimal Dependencies ---"
log_test "No external dependencies"
if grep -qE '(curl|wget|jq|bc)' "$PROJECT_DIR"/*.sh 2>/dev/null; then
    log_fail "External dependencies found (curl/wget/jq/bc)"
else
    log_pass "Minimal dependencies"
fi

# TEST 3: Shell Scripts - Error handling
echo ""
echo "--- SHELL: Error Handling ---"
for f in "$PROJECT_DIR"/*.sh; do
    [ -f "$f" ] || continue
    log_test "Error handling in $(basename "$f")"
    if grep -q "^set -eu" "$f"; then
        log_pass "Has 'set -eu'"
    else
        log_fail "Missing 'set -eu'"
    fi
done

# TEST 4: Shell Scripts - Variables quoted
echo ""
echo "--- SHELL: Variable Quoting ---"
log_test "Variable quoting"
if grep -E '\$\{?[a-zA-Z][a-zA-Z0-9_]*\}?[^"}]' "$PROJECT_DIR"/*.sh 2>/dev/null | grep -v '".*\$\|".*\\$' >/dev/null; then
    log_fail "Unquoted variables detected"
else
    log_pass "Variables properly quoted"
fi

# TEST 5: Shell Scripts - No dangerous operations
echo ""
echo "--- SHELL: Dangerous Operations ---"
log_test "No dangerous operations"
if grep -qE 'rm -rf /|dd if=.*of=/|mkfs' "$PROJECT_DIR"/*.sh 2>/dev/null; then
    log_fail "Dangerous operations detected"
else
    log_pass "No dangerous operations"
fi

# TEST 6: Shell Scripts - Has cleanup/trap (optional)
echo ""
echo "--- SHELL: Cleanup Handler (optional) ---"
log_test "Cleanup handler"
if grep -q "trap" "$PROJECT_DIR"/*.sh 2>/dev/null; then
    log_pass "Has trap/cleanup"
else
    log_warn "Missing trap/cleanup (recommended for production)"
fi

# TEST 7: Shell Scripts - Missing command handling (optional)
echo ""
echo "--- SHELL: Command Handling (optional) ---"
log_test "Command handling"
if grep -qE 'command -v|command_exists|type ' "$PROJECT_DIR"/*.sh 2>/dev/null; then
    log_pass "Checks for command availability"
else
    log_warn "No command availability check (recommended)"
fi

# TEST 8: YAML Files - Basic structure
echo ""
echo "--- YAML: Basic Structure ---"
yaml_count=$(find "$PROJECT_DIR" -name "*.yml" -type f 2>/dev/null | wc -l)
if [ "$yaml_count" -gt 0 ]; then
    log_test "YAML files present"
    log_pass "Found $yaml_count YAML files"
else
    log_info "No YAML files to test"
fi

# TEST 9: YAML - Required fields
echo ""
echo "--- YAML: Required Fields ---"
if [ -d "$PROJECT_DIR/knowledge/yaml" ]; then
    find "$PROJECT_DIR/knowledge/yaml" -name "*.yml" -type f 2>/dev/null | while IFS= read -r f; do
        log_test "Required fields in $(basename "$f")"
        if grep -q "^layer:" "$f" && grep -q "^name:" "$f" && grep -q "^summary:" "$f"; then
            log_pass "Has required fields"
        else
            log_fail "Missing required fields (layer, name, summary)"
        fi
    done
else
    log_info "No YAML directory to test"
fi

# TEST 10: Markdown - Frontmatter
echo ""
echo "--- MD: Frontmatter ---"
if [ -d "$PROJECT_DIR" ]; then
    find "$PROJECT_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | while IFS= read -r f; do
        log_test "Frontmatter in $(basename "$f")"
        if head -1 "$f" 2>/dev/null | grep -q "^---"; then
            log_pass "Has frontmatter"
        else
            log_warn "Missing frontmatter"
        fi
    done
fi

# Summary
echo ""
echo "=========================================="
echo " SUMMARY"
echo "=========================================="
echo " Tests run:    $TESTS_RUN"
echo " Tests passed: $TESTS_PASSED"
echo " Errors:       $ERRORS"
echo ""

if [ "$ERRORS" -gt 0 ]; then
    echo "STATUS: FAILED - Not hostile-environment ready"
    exit 1
else
    echo "STATUS: PASSED - Hostile-environment ready"
    exit 0
fi
