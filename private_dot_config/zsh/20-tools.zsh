# ~/.config/zsh/20-tools.zsh — tool initialisation & integrations
# (zoxide + the interactive plugins live in 90-shell-ux.zsh — they must load last.)

# fzf — key bindings (Ctrl-T files, Ctrl-R history, Alt-C cd) + fuzzy completion
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi

# fzf-git.sh — Ctrl-G then Ctrl-B/F/T/H/R/S for git branches/files/tags/hashes/remotes/stashes
[ -f "$HOME/.config/zsh/fzf-git.sh" ] && source "$HOME/.config/zsh/fzf-git.sh"

# Completions for tools that generate them at runtime
if command -v gh >/dev/null; then
  eval "$(gh completion -s zsh)"
fi
if command -v ast-grep >/dev/null; then
  eval "$(ast-grep completions zsh 2>/dev/null)"
fi
