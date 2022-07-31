#!/usr/bin/fish

cd ~

# -------------------
# Variables
# -------------------
source ~/.dotfiles/.secret-env-vars

set -g -x fish_greeting ''
set -g -x GO111MODULE "on"


# -------------------
# Aliases 
# -------------------
alias nvim '~/downloads/nvim-linux64/bin/nvim'
alias vi nvim
alias vim nvim
alias fd (which fdfind)
alias lg 'lazygit'

alias ls 'exa --icons'
alias la 'exa -a --icons'
alias ld 'exa -TD --level=2 --icons'
alias lda 'exa -TDa --level=2 --icons'
alias ll 'exa -lT -g --sort=type --icons --level=2 --no-user --no-permissions'
alias lla 'exa -alT -g --sort=type --icons --level=2 --no-user --octal-permissions'


# -------------------
# Helper functions
# -------------------
function source_config 
  source ~/.config/fish/config.fish
  source ~/.config/omf/init.fish
end

function fish_remove_path 
  if set -l ind (contains -i -- $argv $fish_user_paths)
    set -e fish_user_paths[$ind]
  end
end

function docker-clean
  docker-compose down --volumes
  docker rm $(docker ps -aq)
  docker stop $(docker ps -aq)
  docker kill $(docker ps -aq) ; 
  docker system prune -af --volumes 
end



# -------------------
# Path
# -------------------
fish_add_path '/mnt/c/Program\ Files\ \(x86\)/Yarn/bin/' 
fish_add_path '/home/daniel/.nvm/versions/node/v16.11.0/bin'
fish_add_path 'bin'
fish_add_path '~/bin'
fish_add_path '~/.local/bin/'


# -------------------
# Go stuff
# -------------------
fish_add_path '/usr/local/go-1.18/bin/'
fish_add_path 'go/bin'
fish_add_path $HOME/go
fish_add_path $GOPATH/bin

# Start projects GO env with Direnv
function setgoenv 
   echo "export GOPATH=$(pwd)" >> .envrc
   direnv allow .
end


# -------------------
# Keybindings
# -------------------
function fish_user_key_bindings
  # peco
  bind \cr peco_select_history # Bind for peco select history to Ctrl+R
  bind \cf peco_change_directory # Bind for peco change directory to Ctrl+F
end


# -------------------
# Plugin's functions
# -------------------

# Peco 
function _peco_change_directory
  if [ (count $argv) ]
    peco --layout=bottom-up --query "$argv "|perl -pe 's/([ ()])/\\\\$1/g'|read foo
  else
    peco --layout=bottom-up |perl -pe 's/([ ()])/\\\\$1/g'|read foo
  end
  if [ $foo ]
    builtin cd $foo
    commandline -r ''
    commandline -f repaint
  else
    commandline ''
  end
end

function peco_change_directory
  begin
    echo $HOME/.config
    ghq list -p
    ls -ad */|perl -pe "s#^#$PWD/#"|grep -v \.git
    ls -ad $HOME/Developments/*/* |grep -v \.git
  end | sed -e 's/\/$//' | awk '!a[$0]++' | _peco_change_directory $argv
end

function peco_select_history
  if test (count $argv) = 0
    set peco_flags --layout=bottom-up
  else
    set peco_flags --layout=bottom-up --query "$argv"
  end

  history|peco $peco_flags|read foo

  if [ $foo ]
    commandline $foo
  else
    commandline ''
  end
end
