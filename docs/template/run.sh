#!/bin/sh
# Template Project - Entry Point
# This is a minimal POSIX shell script template

set -eu

PROGRAM_NAME="${0##*/}"
VERSION="0.0.1 Alpha Test"

usage() {
    cat << EOF
Usage: $PROGRAM_NAME [OPTIONS] <argument>

Options:
    -h          Show this help
    -v          Show version
    -q          Quiet mode
    -d DIR      Set directory

Example:
    $PROGRAM_NAME -h
EOF
}

# Parse arguments
QUIET=0
TARGET_DIR="."

while getopts "hvqd:" opt; do
    case "$opt" in
        h) usage; exit 0 ;;
        v) echo "$VERSION"; exit 0 ;;
        q) QUIET=1 ;;
        d) TARGET_DIR="$OPTARG" ;;
        *) usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Main logic
main() {
    if [ "$QUIET" -eq 0 ]; then
        echo "Running $PROGRAM_NAME..."
    fi
    
    if [ $# -lt 1 ]; then
        echo "Error: Missing argument" >&2
        exit 1
    fi
    
    echo "Argument: $1"
    echo "Directory: $TARGET_DIR"
}

main "$@"
