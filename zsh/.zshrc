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
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# aliases
alias rm='rm -i'
alias chomd='chmod'
alias celar='clear'
alias claer='clear'
alias clera='clear'

# run fetch (https://www.github.com/terra2o/fetch) when sourced
fetch
