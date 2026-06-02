#!/bin/bash
# Sets up tool extras that aren't plain config files: themes, plugins, extensions.
# Runs after configs are applied; re-runs whenever this script changes. Idempotent.
set -eu

# Ensure brew is on PATH
if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi

# 1. bat: catppuccin theme + cache (config references "Catppuccin Mocha")
BAT_THEMES="$(bat --config-dir)/themes"
if [ ! -e "$BAT_THEMES/Catppuccin Mocha.tmTheme" ]; then
  echo "==> Installing bat catppuccin theme..."
  mkdir -p "$BAT_THEMES"
  tmp="$(mktemp -d)"; git clone --depth 1 https://github.com/catppuccin/bat.git "$tmp"
  cp "$tmp"/themes/*.tmTheme "$BAT_THEMES/"; rm -rf "$tmp"
fi
bat cache --build >/dev/null

# 2. delta: catppuccin theme (gitconfig includes ~/.config/delta/catppuccin.gitconfig)
if [ ! -d "$HOME/.config/delta" ]; then
  echo "==> Cloning catppuccin delta theme..."
  git clone --depth 1 https://github.com/catppuccin/delta.git "$HOME/.config/delta"
fi

# 3. fzf-git.sh (sourced from ~/.config/zsh/20-tools.zsh)
if [ ! -f "$HOME/.config/zsh/fzf-git.sh" ]; then
  echo "==> Downloading fzf-git.sh..."
  curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh \
    -o "$HOME/.config/zsh/fzf-git.sh"
fi

# 4. tmux: TPM + plugins
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "==> Installing tmux plugin manager..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true

# 5. gh extensions
if command -v gh >/dev/null 2>&1; then
  gh extension list 2>/dev/null | grep -q "dlvhdr/gh-dash" || gh extension install dlvhdr/gh-dash || true
fi

# 6. neovim: install plugins headlessly (kickstart uses vim.pack)
if command -v nvim >/dev/null 2>&1; then
  echo "==> Installing Neovim plugins..."
  nvim --headless "+qa" >/dev/null 2>&1 </dev/null || true
fi

echo "==> Tool setup complete."
