# ~/.config/zsh/40-fzf.zsh — fzf defaults (fd-powered, bat/eza previews, catppuccin mocha)

# Use fd for listing (respects .gitignore + ~/.config/fd/ignore, includes hidden)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Previews
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 --icons=auto {}'"

# Layout + catppuccin mocha colours
export FZF_DEFAULT_OPTS="\
--height 60% --layout=reverse --border --info=inline --multi \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=border:#6c7086"
