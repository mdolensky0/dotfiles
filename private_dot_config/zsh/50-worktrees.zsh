# ~/.config/zsh/50-worktrees.zsh
# Per-branch dev cockpits: a git worktree + a tmux session laid out as nvim|shell.
#   dir: <repo>.wt/<branch>   session: <repo>_<branch>   (e.g. Dido.wt/feat, Dido_feat)
# The main clone stays put — park it on trunk and branch worktrees off it.
# Interactive list/remove: fzf-git's C-g C-w.  Jump between worktrees: `wtcd`.

_wt_main() { git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p'; }

_wt_sesh() {  # <repo> <branch> -> tmux-safe session name
  emulate -L zsh
  local s="${1}_${2}"; s=${s//\//_}; s=${s//[.: ]/_}
  print -r -- "$s"
}

_wt_open() {  # <session> <dir>: ensure the nvim|shell session, then attach/switch
  emulate -L zsh
  local name="$1" dir="$2"
  command -v tmux >/dev/null || { cd -- "$dir"; return }
  if ! tmux has-session -t "=$name" 2>/dev/null; then
    tmux new-session  -ds "$name" -c "$dir" -n code
    tmux split-window -h -t "${name}:code" -c "$dir"
    tmux resize-pane  -t "${name}:code.1" -x '62%' 2>/dev/null
    tmux send-keys    -t "${name}:code.1" 'nvim .' Enter
    tmux select-pane  -t "${name}:code.1"
  fi
  if [[ -n $TMUX ]]; then tmux switch-client -t "$name"; else tmux attach -t "$name"; fi
}

wt() {  # wt <branch> [base]: create/open a worktree cockpit (base defaults to trunk)
  emulate -L zsh
  [[ -n "$1" ]] || { print -u2 "usage: wt <branch> [base]"; return 1 }
  git rev-parse --is-inside-work-tree &>/dev/null || { print -u2 "wt: not in a git repo"; return 1 }
  local branch="$1" base="$2" main repo dir
  main=$(_wt_main); repo=${main:t}; dir="${main:h}/${repo}.wt/${branch}"
  if [[ ! -d "$dir" ]]; then
    if git show-ref --verify --quiet "refs/heads/$branch"; then
      git worktree add "$dir" "$branch" || return 1
    else
      : ${base:=$(git -C "$main" symbolic-ref --quiet --short HEAD || echo HEAD)}
      git worktree add -b "$branch" "$dir" "$base" || return 1
    fi
  fi
  _wt_open "$(_wt_sesh "$repo" "$branch")" "$dir"
}

wtcd() {  # fuzzy-pick a live worktree and open its cockpit
  emulate -L zsh
  git rev-parse --is-inside-work-tree &>/dev/null || { print -u2 "wtcd: not in a git repo"; return 1 }
  local main repo line dir branch
  main=$(_wt_main); repo=${main:t}
  line=$(git worktree list | sed 1d \
          | fzf --prompt='worktree> ' \
                --preview 'git -C {1} log --oneline --color=always -n 20') || return
  [[ -n "$line" ]] || return
  dir=${line%% *}
  if [[ "$line" == *\[*\]* ]]; then branch=${${line##*\[}%%\]*}; else branch=${dir:t}; fi
  _wt_open "$(_wt_sesh "$repo" "$branch")" "$dir"
}

wtrm() {  # wtrm <branch> [git-worktree-remove flags]: remove worktree + kill its session
  emulate -L zsh
  [[ -n "$1" ]] || { print -u2 "usage: wtrm <branch> [--force ...]"; return 1 }
  git rev-parse --is-inside-work-tree &>/dev/null || { print -u2 "wtrm: not in a git repo"; return 1 }
  local branch="$1" main repo dir
  main=$(_wt_main); repo=${main:t}; dir="${main:h}/${repo}.wt/${branch}"
  git worktree remove "$dir" "${@:2}" || return 1
  tmux kill-session -t "=$(_wt_sesh "$repo" "$branch")" 2>/dev/null
  print "removed $dir (branch kept; git branch -d $branch to delete)"
}
