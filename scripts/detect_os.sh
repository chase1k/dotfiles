#!/usr/bin/env bash
# Detect OS, package manager, display server, and clipboard tool
# Source this file — do not execute directly

IS_WSL=false
PKG_MGR=""
DISPLAY_SERVER=""
CLIP_TOOL=""

# WSL detection
if grep -qi "microsoft" /proc/version 2>/dev/null; then
    IS_WSL=true
fi

# OS / package manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian|pop)
            PKG_MGR="apt"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            PKG_MGR="dnf"
            ;;
        *)
            # Fallback: check what's available
            if command -v apt-get &>/dev/null; then
                PKG_MGR="apt"
            elif command -v dnf &>/dev/null; then
                PKG_MGR="dnf"
            else
                echo "ERROR: Unsupported OS: $ID" >&2
                exit 1
            fi
            ;;
    esac
fi

# Display server / clipboard
if $IS_WSL; then
    DISPLAY_SERVER="wsl"
    CLIP_TOOL="win32yank.exe"
elif [ -n "$WAYLAND_DISPLAY" ]; then
    DISPLAY_SERVER="wayland"
    CLIP_TOOL="wl-copy"
else
    DISPLAY_SERVER="x11"
    CLIP_TOOL="xclip"
fi

export IS_WSL PKG_MGR DISPLAY_SERVER CLIP_TOOL

echo "  OS:             ${PRETTY_NAME:-unknown}"
echo "  Package mgr:    $PKG_MGR"
echo "  Display server: $DISPLAY_SERVER"
echo "  Clipboard tool: $CLIP_TOOL"
echo "  WSL:            $IS_WSL"
