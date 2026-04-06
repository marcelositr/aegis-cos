#!/bin/sh
# Template Test Script
# POSIX compliant test script

set -eu

PROGRAM_NAME="${0##*/}"
VERSION="0.0.1 Alpha Test"

echo "=========================================="
echo " $PROGRAM_NAME Test Suite"
echo " Version: $VERSION"
echo "=========================================="
echo ""

log_test() {
    printf 'Testing: %s... ' "$1"
}

log_pass() {
    printf 'PASS\n'
}

log_fail() {
    printf 'FAIL\n'
    exit 1
}

# Test help
log_test "Help output"
if ./run.sh -h >/dev/null 2>&1; then
    log_pass
else
    log_fail
fi

# Test version
log_test "Version output"
if ./run.sh -v >/dev/null 2>&1; then
    log_pass
else
    log_fail
fi

# Test quiet mode
log_test "Quiet mode"
if ./run.sh -q test >/dev/null 2>&1; then
    log_pass
else
    log_fail
fi

# Test argument
log_test "Argument processing"
output=$(./run.sh -d /tmp testarg 2>/dev/null)
if echo "$output" | grep -q "testarg"; then
    log_pass
else
    log_fail
fi

echo "All tests passed!"
