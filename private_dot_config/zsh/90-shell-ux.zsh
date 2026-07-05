# ~/.config/zsh/90-shell-ux.zsh — interactive-UX integrations. MUST be the last file
# sourced, and the order below is deliberate — do NOT reorder:
#   1. autosuggestions    — registers ZLE widgets + a precmd hook
#   2. zoxide             — its chpwd/precmd hook must be the LAST one registered, else
#                           `zoxide doctor` warns; hence it loads after autosuggestions
#   3. syntax-highlighting — must be sourced after every other widget-defining plugin
#                           (its INSTALL.md rule), so it goes dead last
: "${HOMEBREW_PREFIX:=/opt/homebrew}"

# 1. zsh-autosuggestions — greyed-out inline completion from history; press → to accept.
if [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# 2. zoxide — replaces `cd` (normal cd + frecency jumps); `cdi` = interactive picker.
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# 3. zsh-syntax-highlighting — colours the command line as you type. KEEP THIS LAST.
if [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
