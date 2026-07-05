# ~/.config/zsh/70-prompt.zsh — shell prompt. Loads after core config so it owns PROMPT
# and registers its precmd hook before zoxide's (see 90-shell-ux.zsh).

# oh-my-posh — skip under Apple Terminal (limited truecolor / ANSI support).
if [ "$TERM_PROGRAM" != "Apple_Terminal" ] && command -v oh-my-posh >/dev/null; then
  eval "$(oh-my-posh init zsh)"
fi
