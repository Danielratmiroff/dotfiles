if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g -x fish_greeting ''
set -g -x GO111MODULE on
set -g theme_powerline_fonts no

# -------------------
# Theme config
# -------------------

source ~/.config/fish/theme_bobthefish.fish
set -g -x theme_color_scheme solarized-dark

# -------------------
# Aliases 
# -------------------
#alias nvim '~/downloads/nvim-linux64/bin/nvim'
alias nv nvim
#alias fd (which fdfind)
#alias lg lazygit

# Navigation
alias .. 'cd ..'
alias cda 'cd ~/ansible'
alias edit 'nv ~/dotfiles/fish/config.fish'
#alias ... 'cd ../..'

# File listing
alias ls 'exa --icons'
alias la 'exa -a --icons'
alias ld 'exa -TD --icons'
alias lda 'exa -TDa --icons'
alias ll 'exa -lT -g --sort=type --icons --level=2 --no-user'
alias lla 'exa -alT -g --sort=type --icons --level=2 --no-user --octal-permissions'

alias cat='batcat --paging=never'
alias catp='batcat --style=plain'


# -------------------
# Helper functions
# -------------------
# Multipass
function mp
    multipass $argv
end

# Minikube
function mk
    mminikube $argv
end

function k
    minikube kubectl -- $argv
end

function ap
    ansible-playbook $HOME/ansible/$argv
end

function sap
    ansible-playbook -K $HOME/ansible/$argv
end

function source_config
    source $HOME/.config/fish/config.fish
end

function clean_gitignore
    git rm -r --cached .
    git add .
    git commit -m ".gitignore is now working"
    echo "## Deleted git cache and committed the changes"
end

function fish_remove_path
    if set -l ind (contains -i -- $argv $fish_user_paths)
        set -e fish_user_paths[$ind]
    end
end

function docker_clean
    docker rm (docker ps -aq)
    docker stop (docker ps -aq)
    docker kill (docker ps -aq)
    docker system prune -af --volumes
    docker rmi (docker images -aq)
    docker image prune -af
end

function android_studio
    set cmd $argv[1]

    switch $cmd
        case start
            pkill java
            /snap/bin/android-studio
        case stop
            pkill java
            echo "Android Studio stopped"
        case '*'
            echo "Unknown command '$cmd'"
    end
end

# Start projects GO env with Direnv
function setgoenv
    echo "export GOPATH=(pwd)" >>.envrc
    direnv allow .
end

# Create and CD into dir 
function mkcd
    mkdir $argv
    cd $argv
end


# -------------------
# Set Path Variable
# -------------------
function set_path_variables
    fish_add_path bin
    fish_add_path '~/bin'
    fish_add_path '~/.local/bin/'

    # Go stuff
    fish_add_path '/usr/local/go-1.18/bin/'
    fish_add_path '$HOME/go/bin'
    fish_add_path '$HOME/go'
    fish_add_path '$GOPATH/bin'
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
        peco --layout=bottom-up --query "$argv " | perl -pe 's/([ ()])/\\\\$1/g' | read foo
    else
        peco --layout=bottom-up | perl -pe 's/([ ()])/\\\\$1/g' | read foo
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
        ls -ad */ | perl -pe "s#^#$PWD/#" | grep -v \.git
        ls -ad $HOME/Developments/*/* | grep -v \.git
    end | sed -e 's/\/$//' | awk '!a[$0]++' | _peco_change_directory $argv
end

function peco_select_history
    if test (count $argv) = 0
        set peco_flags --layout=bottom-up
    else
        set peco_flags --layout=bottom-up --query "$argv"
    end

    history | peco $peco_flags | read foo

    if [ $foo ]
        commandline $foo
    else
        commandline ''
    end
end
