export ZSH="$HOME/.oh-my-zsh"

XDG_CONFIG_HOME=~/.config/
ZSH_THEME="bira"

plugins=(
  git
  bundler
  dotenv
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

export EDITOR='emacs'
export VISUAL='emacs'
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/libexec/lua-language-server:$PATH"

# aliases
alias rm='rm -i'
alias chomd='chmod'
alias celar='clear'
alias claer='clear'
alias clera='clear'
alias vim='vimx'

# run fetch (https://www.github.com/terra2o/fetch) when sourced
# fetch
fastfetch
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
