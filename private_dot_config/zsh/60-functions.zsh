# ~/.config/zsh/60-functions.zsh — interactive helpers (fzf-powered)
# Cancel-safe: each guards against ESC / empty selection before acting.
# These complement, and don't duplicate, the fzf-git.sh Ctrl-G widgets and the
# built-in fzf Ctrl-T / Ctrl-R / Alt-C bindings.

# --- edit / navigate ---
vf() {  # fuzzy-find a file, open it in nvim
  local f
  f=$(fd --type f --hidden --exclude .git "$@" \
       | fzf --preview 'bat -n --color=always --line-range :500 {}') || return
  [[ -n $f ]] && nvim -- "$f"
}

vg() {  # live ripgrep; Enter opens the match in nvim at the exact line
  # fzf escapes {1}/{2} automatically, so become() is safe for odd filenames.
  local rg='rg --line-number --no-heading --color=always --smart-case'
  fzf --ansi --disabled --query "${*:-}" \
      --bind "start:reload:$rg {q} || true" \
      --bind "change:reload:$rg {q} || true" \
      --delimiter : \
      --preview 'bat --color=always --highlight-line {2} {1}' \
      --preview-window 'up,60%,+{2}+3/3' \
      --bind 'enter:become(nvim {1} +{2})'
}

cdf() {  # fuzzy-cd into any subdir under cwd (typed form of the Alt-C keybind)
  local d
  d=$(fd --type d --hidden --exclude .git "$@" \
       | fzf --preview 'eza --tree --level=1 --color=always --icons=auto {}') || return
  [[ -n $d ]] && cd -- "$d"
}

# --- tmux ---
ts() {  # switch/attach to an existing session (works inside OR outside tmux)
  local s
  s=$(tmux ls -F '#{session_name}' 2>/dev/null | fzf) || return
  [[ -z $s ]] && return
  if [[ -n $TMUX ]]; then tmux switch-client -t "$s"; else tmux attach -t "$s"; fi
}

tsesh() {  # project sessionizer: pick a repo under ~/Projects, create/attach its session
  emulate -L zsh
  local dir name
  local -a roots=("$HOME/Projects")
  # -I so the global `.git/` ignore rule doesn't hide the repos we're looking for
  dir=$(fd --hidden --no-ignore --type d --max-depth 4 '^\.git$' "${roots[@]}" 2>/dev/null \
         | sed 's#/\.git/\?$##' | sort -u \
         | fzf --prompt='project> ' \
               --preview 'eza --tree --level=1 --color=always --icons=auto {}') || return
  [[ -z $dir ]] && return
  name=${${dir:t}//[.: ]/_}      # tmux treats . and : specially -> sanitize
  tmux has-session -t "$name" 2>/dev/null || tmux new-session -ds "$name" -c "$dir"
  if [[ -n $TMUX ]]; then tmux switch-client -t "$name"; else tmux attach -t "$name"; fi
}

# --- git ---
gcb() {  # fuzzy-switch branch (most recently committed first)
  local b
  b=$(git branch --format='%(refname:short)' --sort=-committerdate \
       | fzf --preview 'git log --oneline --color=always -n 20 {}') || return
  [[ -n $b ]] && git switch "$b"
}

# --- gh / pull requests ---
# Goal: open PRs authored by ANY of a set of users. GitHub's issue/PR search has
# no OR operator and ANDs repeated `author:` qualifiers — and a PR has exactly
# one author — so `author:a author:b` matches nothing. Instead query per user
# and union the results; since each PR has one author the sets never overlap, so
# no dedup is needed. Pass usernames as args; see `tprs` / `tprsf` (30-aliases).
_prs_json() {  # internal: combined JSON of open PRs for the given authors, newest first
  emulate -L zsh
  local u
  for u in "$@"; do
    gh search prs --state=open --author="$u" --sort=updated --limit 50 \
       --json number,title,repository,url,author,updatedAt
  done | jq -s 'add // [] | sort_by(.updatedAt) | reverse'
}

prs() {  # prs <user> [user...] : list open PRs authored by any of these users
  emulate -L zsh
  (( $# )) || { print -u2 "usage: prs <user> [user...]"; return 1 }
  _prs_json "$@" \
    | jq -r '.[] | "\(.repository.nameWithOwner)#\(.number)\t\(.title)\t@\(.author.login)"' \
    | column -t -s $'\t'
}

prsf() {  # prsf <user> [user...] : fzf-pick an open PR — Enter opens it in the browser
  emulate -L zsh
  (( $# )) || { print -u2 "usage: prsf <user> [user...]"; return 1 }
  # Cross-repo results, so the actions are: preview inline, open in browser (Enter),
  # read in a pager (Ctrl-V), or copy the URL (Ctrl-Y).
  _prs_json "$@" \
    | jq -r '.[] | [.url, .repository.nameWithOwner, (.number|tostring),
             "\(.repository.nameWithOwner)#\(.number)  \(.title)  (@\(.author.login))"] | @tsv' \
    | fzf --ansi --delimiter='\t' --with-nth=4.. \
          --header 'enter: open in browser   ctrl-v: view here   ctrl-y: copy url' \
          --preview 'gh pr view {3} --repo {2}' \
          --preview-window 'right,60%,wrap' \
          --bind 'ctrl-v:execute(gh pr view {3} --repo {2} --comments | less -R)' \
          --bind 'ctrl-y:execute-silent(printf %s {1} | pbcopy)' \
          --bind 'enter:become(gh pr view {3} --repo {2} --web)'
}

# --- system / utility ---
fkill() {  # fuzzy-pick process(es) and kill them (default TERM; `fkill KILL` to override)
  local pids
  pids=$(ps -eo pid,ppid,%cpu,%mem,comm,args | sed 1d \
          | fzf --multi --header='TAB mark - Enter kill' | awk '{print $1}')
  [[ -z $pids ]] && return
  echo "$pids" | xargs kill "-${1:-TERM}"
}

mkcd() { mkdir -p -- "$1" && cd -- "$1"; }                 # make a dir and enter it
bak()  { cp -a -- "$1" "$1.$(date +%Y%m%d-%H%M%S).bak"; }  # timestamped backup copy

json() {  # pretty-print + page JSON: `json f.json`  or  `curl ... | json`
  if [[ -n $1 && -f $1 ]]; then jq --color-output . "$1" | less -R
  else jq --color-output . | less -R; fi
}

extract() {  # extract almost any archive: `extract foo.tar.zst`
  local f=$1
  [[ -f $f ]] || { print -u2 "extract: '$f' is not a file"; return 1; }
  case $f in
    *.tar.bz2|*.tbz2) tar xjf "$f" ;;   *.tar.gz|*.tgz) tar xzf "$f" ;;
    *.tar.xz|*.txz)   tar xJf "$f" ;;   *.tar.zst)      tar --zstd -xf "$f" ;;
    *.tar)            tar xf  "$f" ;;   *.gz)           gunzip "$f" ;;
    *.bz2)            bunzip2 "$f" ;;   *.xz)           unxz "$f" ;;
    *.zst)            unzstd  "$f" ;;   *.zip|*.jar)    unzip "$f" ;;
    *.7z)             7z x    "$f" ;;
    *) print -u2 "extract: don't know how to handle '$f'"; return 1 ;;
  esac
}

# --- project-specific (your two coupled repos) ---
proto-regen() {  # regenerate the Dido Swift gRPC client from the backend proto contract
  emulate -L zsh
  local protos="${DIDO_DIR:-$HOME/Projects/Dido}/DidoSwiftProtos"
  [[ -x "$protos/RUNME" ]] || { print -u2 "proto-regen: no RUNME at $protos"; return 1; }
  ( cd "$protos" && ./RUNME ) && print "OK Swift protos regenerated"
}

xcclean() {  # clear Xcode DerivedData (the classic iOS build unsticker)
  rm -rf ~/Library/Developer/Xcode/DerivedData/* && print "OK DerivedData cleared"
}
