# ~/.config/zsh/10-exports.zsh — environment

export EDITOR=nvim
export VISUAL=nvim

# ripgrep reads its config from this path
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# bat theme (catppuccin mocha, built into bat cache)
export BAT_THEME="Catppuccin Mocha"

# Use bat as the man pager (colorized man pages)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# Java (maven). /usr/libexec/java_home resolves the active JDK.
if /usr/libexec/java_home >/dev/null 2>&1; then
  export JAVA_HOME="$(/usr/libexec/java_home)"
fi
