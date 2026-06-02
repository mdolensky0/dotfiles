# ~/.config/zsh/00-options.zsh — zsh history, options, completion

# --- History ---
HISTFILE="$HOME/.config/zsh/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY          # share history across sessions
setopt INC_APPEND_HISTORY     # write as commands are entered
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate entries
setopt HIST_IGNORE_SPACE      # don't record commands starting with a space
setopt HIST_REDUCE_BLANKS     # trim superfluous blanks
setopt HIST_VERIFY            # confirm history-expansion before running

# --- Navigation / behaviour ---
setopt AUTO_CD                # `dir` == `cd dir`
setopt AUTO_PUSHD             # cd pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS   # allow # comments in interactive shell
setopt EXTENDED_GLOB
setopt NO_BEEP

# --- Completion ---
fpath=("$HOME/.config/zsh/completions" $fpath)
autoload -Uz compinit
# only fully re-scan once a day for faster startup
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
