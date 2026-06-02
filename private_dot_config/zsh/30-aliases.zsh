# ~/.config/zsh/30-aliases.zsh — aliases
# Aliases are interactive-only and never affect scripts. Reach the original
# command any time with a leading backslash (\ls) or `command ls`.

# --- eza (replaces ls) ---
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lh  --icons=auto --group-directories-first --git'
alias la='eza -lah --icons=auto --group-directories-first --git'
alias lt='eza --tree --level=2 --icons=auto'
alias tree='eza --tree --icons=auto'

# --- bat (replaces cat) ---
# bat auto-detects pipes and prints plain output, so this is pipe-safe.
alias cat='bat --paging=never'

# --- git / lazygit ---
alias lg='lazygit'
alias gs='git status -sb'

# --- system ---
alias top='btop'        # btop is nicer; real htop still available as `htop`
alias ff='fastfetch'

# NOTE: `find` is intentionally NOT aliased to fd — their argument syntax is
# incompatible. Use `fd` directly.
