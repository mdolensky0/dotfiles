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

# --- fd: include dotfiles by default (still respects ignore files) ---
# Without this, bare `fd 10-expor` misses hidden paths like ~/.config/zsh/*.
# FZF_DEFAULT_COMMAND already passes --hidden, so fzf was unaffected; this fixes
# interactive `fd`. Reach vanilla fd with `command fd` if ever needed.
alias fd='fd --hidden'

# --- navigation (AUTO_CD already turns bare `..` into `cd ..`) ---
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# --- tmux ---
alias ta='tmux attach -t'
alias tl='tmux ls'
alias tn='tmux new -A -s'        # -A = attach if the session already exists, else create
alias tkill='tmux kill-session -t'
alias td='tmux detach'

# --- gh (pull requests) ---
alias ghpr='gh pr checkout'
alias ghpv='gh pr view'
alias ghvw='gh pr view --web'
# Open PRs from your review circle (functions live in 60-functions.zsh).
# TODO: replace coworker1/coworker2 with real GitHub usernames.
alias tprs='prs mdolensky0 coworker1 coworker2'    # list
alias tprsf='prsf mdolensky0 coworker1 coworker2'  # fzf picker

# --- chezmoi (matches the edit-real-file -> `re-add` workflow) ---
alias cz='chezmoi'
alias cze='chezmoi edit'
alias cza='chezmoi add'
alias czra='chezmoi re-add'
alias czp='chezmoi apply -v'
alias czs='chezmoi status'
alias czd='chezmoi diff'
alias czcd='chezmoi cd'

# --- maven ---
alias mci='mvn clean install'
alias mcp='mvn clean package'
alias mvt='mvn test'             # unit tests (surefire)
alias mvv='mvn verify'           # unit + integration tests (failsafe) + verify
