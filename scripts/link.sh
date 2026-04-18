#!/usr/bin/env bash
# Symlink dotfiles from repo into home directory
# Expects $DOTFILES_DIR, $CLIP_TOOL, $DISPLAY_SERVER to be set

set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Safely create a symlink, backing up any existing file/dir first
safe_link() {
    local src="$1"
    local dst="$2"

    # If dst already points to the right place, skip
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  [ok]   $dst"
        return
    fi

    # Back up existing file/dir
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local bak="${dst}.dotfiles.bak.${TIMESTAMP}"
        echo "  [bak]  $dst -> $bak"
        mv "$dst" "$bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  [link] $dst -> $src"
}

echo "==> Symlinking dotfiles..."

# home/* -> ~/.*
for f in "$DOTFILES_DIR"/home/.*; do
    name="$(basename "$f")"
    [ "$name" = "." ] || [ "$name" = ".." ] && continue
    safe_link "$f" "$HOME/$name"
done

# config dirs -> ~/.config/*
for d in "$DOTFILES_DIR"/config/*/; do
    name="$(basename "$d")"
    # zellij gets special treatment (generated, not symlinked)
    [ "$name" = "zellij" ] && continue
    safe_link "${d%/}" "$HOME/.config/$name"
done

# ── Zellij: generate config.kdl with correct clipboard line ──────────────────
echo "==> Generating zellij config (clipboard: $CLIP_TOOL)..."
mkdir -p "$HOME/.config/zellij"

ZELLIJ_TEMPLATE="$DOTFILES_DIR/config/zellij/config.kdl"
ZELLIJ_OUT="$HOME/.config/zellij/config.kdl"

if [ -L "$ZELLIJ_OUT" ]; then
    rm "$ZELLIJ_OUT"
elif [ -f "$ZELLIJ_OUT" ]; then
    mv "$ZELLIJ_OUT" "${ZELLIJ_OUT}.dotfiles.bak.${TIMESTAMP}"
fi

case "$CLIP_TOOL" in
    wl-copy)
        sed 's|// copy_command "wl-copy".*|copy_command "wl-copy"|' "$ZELLIJ_TEMPLATE" > "$ZELLIJ_OUT"
        ;;
    win32yank.exe)
        sed 's|// copy_command "win32yank.exe.*|copy_command "win32yank.exe -i"|' "$ZELLIJ_TEMPLATE" > "$ZELLIJ_OUT"
        ;;
    xclip)
        sed 's|// copy_command "xclip.*|copy_command "xclip -selection clipboard"|' "$ZELLIJ_TEMPLATE" > "$ZELLIJ_OUT"
        ;;
    *)
        cp "$ZELLIJ_TEMPLATE" "$ZELLIJ_OUT"
        echo "  [warn] Unknown clip tool '$CLIP_TOOL' — clipboard line left commented out"
        ;;
esac
echo "  [gen]  $ZELLIJ_OUT"

# ── SSH config: copy template if ~/.ssh/config doesn't exist ─────────────────
if [ ! -f "$HOME/.ssh/config" ]; then
    echo "==> Installing SSH config template..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    cp "$DOTFILES_DIR/ssh/config.template" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    echo "  [copy] ~/.ssh/config (from template — edit with your hosts)"
else
    echo "  [skip] ~/.ssh/config already exists"
fi

echo "==> Symlinks done."
