#!/bin/sh
# AEGIS Update Script
# Version: 0.0.1 Alpha Test
# Updates AEGIS scripts in installed projects

set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ -z "${TERM:-}" ] || [ "$TERM" = "dumb" ]; then
    RED='' GREEN='' NC=''
fi

log_ok() { printf '%s[OK]%s %s\n' "$GREEN" "$NC" "$1"; }
log_err() { printf '%s[ERROR]%s %s\n' "$RED" "$NC" "$1"; }

AEGIS_SOURCE="${AEGIS_SOURCE:-.}"
TARGET_DIR="${1:-.}"

echo "=========================================="
echo " AEGIS Update v1.0"
echo " Source: $AEGIS_SOURCE"
echo " Target: $TARGET_DIR"
echo "=========================================="
echo ""

# Check source
if [ ! -d "$AEGIS_SOURCE/bin" ]; then
    log_err "AEGIS source not found at $AEGIS_SOURCE"
fi

# Update scripts
if [ -d "$TARGET_DIR/.aegis" ]; then
    log_ok "Updating .aegis scripts..."
    rm -f "$TARGET_DIR/.aegis"/*.sh
    for f in "$AEGIS_SOURCE/bin"/*.sh; do
        cp "$f" "$TARGET_DIR/.aegis/"
        chmod +x "$TARGET_DIR/.aegis/${f##*/}"
    done
    log_ok "Scripts updated"
else
    log_err ".aegis not found. Run Install.sh first."
fi

# Update hooks
if [ -d "$TARGET_DIR/.git/hooks" ]; then
    log_ok "Updating git hooks..."
    ln -sf "../../.aegis/PreCommit_Hook.sh" "$TARGET_DIR/.git/hooks/pre-commit"
    ln -sf "../../.aegis/Validation_Gates.sh" "$TARGET_DIR/.git/hooks/commit-msg"
    chmod +x "$TARGET_DIR/.git/hooks/pre-commit"
    chmod +x "$TARGET_DIR/.git/hooks/commit-msg"
    log_ok "Hooks updated"
fi

# Update wrapper
if [ -f "$TARGET_DIR/validate.sh" ]; then
    cat > "$TARGET_DIR/validate.sh" << 'WRAPPER'
#!/bin/sh
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AEGIS_DIR="$SCRIPT_DIR/.aegis"
"$AEGIS_DIR/Validation_Gates.sh" "$SCRIPT_DIR"
WRAPPER
    chmod +x "$TARGET_DIR/validate.sh"
    log_ok "Wrapper updated"
fi

echo ""
log_ok "Update complete!"
