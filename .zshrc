# Enable Powerlevel10k instant prompt. 
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Powerline configuration
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  source /usr/share/powerline/bindings/bash/powerline.sh
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
source ~/.profile
source ~/.zshrc_env_vars
cd ~

# Import NeoVim
export PATH=$PATH:$HOME/downloads/nvim-linux64/bin

# Go installed added to path
export PATH=$PATH:~/go/bin/

# Import GO to path
export GOROOT=/usr/local/go-1.18
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
# Set Go ModuleOn
export GO111MODULE="on"

# Start projects GO env with Direnv
setgoenv() {
   echo "export GOPATH=$(pwd)" >> .envrc
   direnv allow .
}

# Aliases
alias git=git.exe
alias ll="ls -l"
alias la="ls -A"
alias lla="ll -A"
alias lg='lazygit'
alias vi='nvim'

alias docker-clean=' \
   docker kill $(docker ps -q) ; \
   docker container prune -f ; \
   docker image prune -f ; \
   docker network prune -f ; \
   docker volume prune -f '

# Load nvm
export NVM_DIR="$HOME/.nvm"
 [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
 [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 


show_virtual_env() {
  if [ -n "$VIRTUAL_ENV" ]; then
      echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1

# direnv
eval "$(direnv hook zsh)"	
