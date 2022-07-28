#!/usr/bin/fish

cd ~
set -g -x fish_greeting ''

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

# need to migrate this to fish script
# Start projects GO env with Direnv
function setgoenv 
   echo "export GOPATH=$(pwd)" >> .envrc
   direnv allow .
end

# direnv
direnv hook fish | source

# Aliases 
alias nvim '~/downloads/nvim-linux64/bin/nvim'
alias vi nvim
alias vim nvim
alias fd (which fdfind)
alias lg 'lazygit'

alias ld 'exa -TD --level=2 --icons'
alias lda 'exa -TDa --level=2 --icons'
alias ll 'exa -lT -g --icons --level=2 --no-user --no-permissions'
alias lla 'exa -alT -g --icons --level=2 --no-user --octal-permissions'

# Path
fish_add_path '/mnt/c/Program\ Files\ \(x86\)/Yarn/bin/' 
fish_add_path '/home/daniel/.nvm/versions/node/v16.11.0/bin'
fish_add_path 'bin'
fish_add_path '~/bin'
fish_add_path '~/.local/bin/'

# Go path
fish_add_path '/usr/local/go-1.18/bin/'
fish_add_path 'go/bin'
fish_add_path $HOME/go
fish_add_path $GOPATH/bin
