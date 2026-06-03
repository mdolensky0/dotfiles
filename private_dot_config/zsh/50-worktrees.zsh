# ~/.config/zsh/50-worktrees.zsh
# Parallel Claude sessions via git worktrees + tmux.
# Each task gets an isolated checkout on its own branch in its own tmux window,
# running its own `claude`. Switch with your tmux prefix (C-a); detach/reattach
# persists (resurrect/continuum).
#
# Layout: sibling dir  <repo>.wt/<branch>  (e.g. ~/Projects/Dido.wt/feature-x)
#
# Stack gotchas when running several at once:
#  • Dido (Xcode): concurrent xcodebuild share DerivedData + the simulator.
#    Use a per-worktree derived path:  -derivedDataPath "$PWD/.derived"  and
#    stagger simulator/UI tests.
#  • backend (Maven/Docker): ~/.m2 is concurrent-read-safe, but a running
#    server (:8080) and docker-compose Postgres (:5432) collide across worktrees.
#    Override the port per worktree and give compose a unique  -p <project>  name.
#  • Superpowers automates this too: its `using-git-worktrees` /
#    `dispatching-parallel-agents` skills, plus Claude's built-in `--worktree`.

cwt() {  # cwt <branch> : create/open a worktree + tmux window running claude
  emulate -L zsh
  [[ -n "$1" ]] || { print -u2 "usage: cwt <branch>"; return 1 }
  local branch="$1" root repo dir
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { print -u2 "not in a git repo"; return 1 }
  repo=${root:t}; dir="${root:h}/${repo}.wt/${branch}"
  if [[ -d "$dir" ]]; then
    print "worktree exists: $dir"
  else
    git worktree add -b "$branch" "$dir" 2>/dev/null \
      || git worktree add "$dir" "$branch" || return 1
  fi
  if [[ -n "$TMUX" ]]; then
    tmux new-window -n "wt:${branch}" -c "$dir" claude
  else
    print "→ $dir (not in tmux; cd'ing there)"; cd "$dir"
  fi
}

cwtls() { git worktree list; }   # list worktrees

cwtrm() {  # cwtrm <branch> : remove the worktree for <branch>
  emulate -L zsh
  [[ -n "$1" ]] || { print -u2 "usage: cwtrm <branch>"; return 1 }
  local branch="$1" root repo dir
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  repo=${root:t}; dir="${root:h}/${repo}.wt/${branch}"
  git worktree remove "$dir" "${@:2}"
}
