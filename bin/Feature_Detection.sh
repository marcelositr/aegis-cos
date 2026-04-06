#!/bin/sh
# AEGIS Feature Detection Library
# Version: 0.0.1 Alpha Test
# Usage: . ./Feature_Detection.sh

set -eu

# Detect command availability (POSIX)
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    OS="$(uname -s 2>/dev/null || echo 'unknown')"
    case "$OS" in
        Linux*)     OS=linux ;;
        Darwin*)    OS=macos ;;
        FreeBSD*)   OS=freebsd ;;
        OpenBSD*)   OS=openbsd ;;
        NetBSD*)    OS=netbsd ;;
        CYGWIN*)    OS=windows ;;
        MINGW*)     OS=windows ;;
        MSYS*)      OS=windows ;;
        *)          OS=unknown ;;
    esac
    echo "$OS"
}

# Detect architecture
detect_arch() {
    ARCH="$(uname -m 2>/dev/null || echo 'unknown')"
    case "$ARCH" in
        x86_64|amd64)  ARCH=x64 ;;
        aarch64|arm64)  ARCH=arm64 ;;
        armv7l)        ARCH=arm32 ;;
        i386|i486|i586|i686) ARCH=x86 ;;
        *)              ARCH=unknown ;;
    esac
    echo "$ARCH"
}

# Detect libc
detect_libc() {
    if command_exists ldd; then
        if ldd --version 2>&1 | grep -qi musl; then
            echo "musl"
        elif ldd --version 2>&1 | grep -qi 'GLIBC\|glibc'; then
            echo "glibc"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Detect init system
detect_init() {
    if command_exists systemctl; then
        echo "systemd"
    elif command_exists rc-service; then
        echo "openrc"
    elif command_exists initctl; then
        echo "upstart"
    elif [ -f /etc/init.d/cron ] && [ -d /etc/rc.d ]; then
        echo "sysv"
    else
        echo "unknown"
    fi
}

# Detect if running as root
is_root() {
    [ "$(id -u 2>/dev/null || echo 1)" -eq 0 ]
}

# Detect if command exists, exit if not
require_command() {
    cmd="$1"
    msg="${2:-Command '$cmd' is required but not found.}"
    if ! command_exists "$cmd"; then
        echo "Error: $msg" >&2
        exit 1
    fi
}

# Detect fetch tool with fallback
detect_fetch() {
    if command_exists curl; then
        echo "curl -L -s"
    elif command_exists wget; then
        echo "wget -q -O -"
    elif command_exists fetch; then
        echo "fetch -o -"
    else
        return 1
    fi
}

# Detect editor
detect_editor() {
    for ed in "${EDITOR:-}" "${VISUAL:-}" vim vi nano pico; do
        if command_exists "$ed"; then
            echo "$ed"
            return 0
        fi
    done
    echo "vi"
}

# Detect package manager
detect_package_manager() {
    for pm in apt-get yum dnf apk pacman zypper pkg; do
        if command_exists "$pm"; then
            echo "$pm"
            return 0
        fi
    done
    echo "none"
}

# Detect shell type
detect_shell() {
    if [ -n "${BASH_VERSION:-}" ]; then
        echo "bash"
    elif [ -n "${ZSH_VERSION:-}" ]; then
        echo "zsh"
    else
        echo "sh"
    fi
}
