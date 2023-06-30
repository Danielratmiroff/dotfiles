if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g -x fish_greeting ''
set -g -x GO111MODULE on
set -g theme_powerline_fonts no

# -------------------
# Theme config
# -------------------

source $HOME/.config/fish/theme_bobthefish.fish
set -g -x theme_color_scheme solarized-dark

# -------------------
# Aliases 
# -------------------
alias nv nvim
#alias fd (which fdfind)
#alias lg lazygit

# Navigation
alias .. 'cd ..'
alias cda 'cd $HOME/automation'
alias cds 'cd $HOME/code/bycs-messenger-android/'
alias edit 'nv $HOME/dotfiles/fish/config.fish'

# File listing
alias ls 'exa --icons'
alias la 'exa -a --icons'
alias ld 'exa -TD --icons'
alias lda 'exa -TDa --icons'
alias ll 'exa -lT -g --sort=type --icons --level=0 --no-user'
alias ll 'exa -lT -g --sort=type --icons --level=1 --no-user'
alias lla 'exa -alT -g --sort=type --icons --level=0 --no-user --octal-permissions'
alias lla 'exa -alT -g --sort=type --icons --level=1 --no-user --octal-permissions'

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
    ansible-playbook $HOME/automation/$argv
end

function sap
    ansible-playbook -K $HOME/automation/$argv
end

function source_config
    source $HOME/.config/fish/config.fish
end

# Git
function g
    git $argv
end

function gac
    git add . && git commit -m "$argv"
end

function gp
    git push origin $argv
end

function gcp
    git add . && git commit -m "$argv" && git push origin
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
    bind \cf peco_select_cd # Bind for peco change directory to Ctrl+F
end


# -------------------
# Plugin's functions
# -------------------

# Peco 
function peco_select_cd
    set -l query (commandline)
    if test -n $query
        set peco_flags --layout=bottom-up --query "$query"
    end

    set -l max_depth $PECO_SELECT_CD_MAX_DEPTH
    set -l ignore_case $PECO_SELECT_CD_IGNORE_CASE

    if test -z $max_depth
        set max_depth 1
    end

    if test -z $ignore_case
        find . -maxdepth $max_depth -type d | peco --layout=bottom-up $peco_flags | read line
    else
        find . -maxdepth $max_depth -type d | egrep -v $ignore_case | peco $peco_flags | read line
    end

    if test $line
        cd $line
        commandline -f repaint
    end
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
