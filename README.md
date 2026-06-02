# dotfiles

My macOS development environment, managed with [chezmoi](https://chezmoi.io) +
a [Homebrew Brewfile](https://github.com/Homebrew/homebrew-bundle). Themed
[catppuccin mocha](https://github.com/catppuccin) throughout.

## Set up a new Mac (one command)

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply mdolensky0
```

This installs chezmoi, clones this repo, writes all configs into place, then runs
the bootstrap scripts: install Homebrew → install everything in the `Brewfile` →
set up themes, tmux plugins, gh extensions, and Neovim plugins.

After it finishes:

- **Reload the terminal** (`exec zsh`) or open a new window.
- **`gh auth login`** — GitHub auth lives in the macOS keychain, not in this repo.
- Grant the Xcode Command Line Tools prompt if it appears (needed by Homebrew).

## What's inside

| Path | Tool |
|------|------|
| `dot_zshrc`, `dot_config/zsh/` | zsh (modular config), oh-my-posh prompt |
| `dot_gitconfig` | git + [delta](https://github.com/dandavison/delta) |
| `dot_tmux.conf` | tmux (TPM, resurrect/continuum, catppuccin) |
| `dot_config/nvim/` | Neovim ([kickstart](https://github.com/nvim-lua/kickstart.nvim)-based, vim.pack) |
| `dot_config/{bat,ripgrep,fd,lazygit,fastfetch,ghostty}/` | per-tool config |
| `Brewfile` | every formula + cask on the machine |
| `run_onchange_before_*` | install Homebrew + packages |
| `run_onchange_after_*` | themes, tmux/nvim plugins, gh extensions |

## Day-to-day

```sh
chezmoi edit ~/.zshrc      # edit a tracked file, then...
chezmoi apply             # write changes into place
chezmoi add ~/.config/foo  # start tracking a new file
chezmoi cd                # open the repo; git commit & push as usual
chezmoi update            # pull latest from GitHub and apply
```

Editing the `Brewfile` and running `chezmoi apply` re-runs `brew bundle`
automatically (the script re-runs only when the Brewfile changes).
