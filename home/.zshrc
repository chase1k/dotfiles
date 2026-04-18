# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Homebrew (Linux) — optional
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# fzf key bindings and fuzzy completion
if command -v fzf &>/dev/null; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  fi
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
  export FZF_CTRL_R_OPTS='--sort --exact'
fi

# zoxide (replaces cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
  export _ZO_DOCTOR=0
fi

# 1Password CLI plugin (optional)
[ -f "$HOME/.config/op/plugins.sh" ] && source "$HOME/.config/op/plugins.sh"

# Aliases
alias neofetch="fastfetch"
alias fj="firejail --net=none --noprofile"

export EDITOR=vim

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
