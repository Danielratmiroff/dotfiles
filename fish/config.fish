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
alias vim nvim
#alias fd (which fdfind)
#alias lg lazygit

# Navigation
alias rm 'rm -i'
alias .. 'cd ..'
alias cda 'cd $HOME/automation'
alias cdd 'cd $HOME/code/bycs-messenger-android/'
alias cds 'cd $HOME/.ssh/'
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

# Extras
alias catp='batcat --paging=never'
alias cat='batcat --style=plain --paging=never'
alias ips='ip -c -br addr'
alias del='trash -vrf'
alias py='python3'

# Multipass
alias mp='multipass'

# Kubernetes
alias minik='minikube'
alias kubectl='minikube kubectl --'
alias k='kubectl'
kubectl completion fish | source

# Git
alias g='git'
alias ga='git add . '
alias gc='git commit -a -m '
alias gp='git push origin '
alias gt='git tag -a '


# -------------------
# Helper functions
# -------------------


# Not idle
function idle
    sh $HOME/automation/avoid_idle_time.sh
end

# Ansible
function ap
    ansible-playbook $HOME/automation/$argv
end

function sap
    ansible-playbook -K $HOME/automation/$argv
end

# Git
function gcp
    git commit -am "$argv" && git push origin
end

function clean_gitignore
    git rm -r --cached .
    git add .
    git commit -m ".gitignore is now working"
    echo "## Deleted git cache and committed the changes"
end

# Kubernetes
function kx
    if set -q argv[1]
        kubectl config use-context $argv[1]
    else
        kubectl config current-context
    end
end

function kn
    if set -q argv[1]
        kubectl config set-context --current --namespace $argv[1]
    else
        kubectl config view --minify | grep namespace | cut -d" " -f6
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

# Start projects GO env with Direnv
function setgoenv
    echo "export GOPATH=(pwd)" >>.envrc
    direnv allow .
end

# Extras
function mkcd
    mkdir $argv
    cd $argv
end

function copy
    xclip -selection clipboard
end

function source_config
    source $HOME/.config/fish/config.fish
end

function fish_remove_path
    if set -l ind (contains -i -- $argv $fish_user_paths)
        set -e fish_user_paths[$ind]
    end
end

jump shell fish | source

# -------------------
# Start/Stop functions
# -------------------
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

function work
    set cmd $argv[1]

    switch $cmd
        case start
            /usr/bin/bash $HOME/automation/start_work_apps.sh
        case stop
            pkill slack
            pkill simplenote
        case '*'
            echo "Unknown command '$cmd'"
    end
end

function study
    set cmd $argv[1]

    switch $cmd
        case start
            /usr/bin/bash $HOME/automation/arrange_study_desktop.sh
        case stop
            pkill brave
        case '*'
            echo "Unknown command '$cmd'"
    end
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
    bind \ca peco_select_automation_script # Bind for peco change directory to Ctrl+F
end


# -------------------
# Plugin's functions
# -------------------

# Peco 
function peco_select_automation_script
    set -l query (commandline)
    if test -n $query
        set peco_flags --layout=bottom-up --query "$query"
    end

    set -l automation_dir "$HOME/automation"
    set -l hosts_file "$HOME/automation/config/hosts.ini" # Hosts file for ansible
    set -l max_depth 1

    find $automation_dir -maxdepth $max_depth -not -path '*/\.*' -type f -printf '%P\n' | peco --layout=bottom-up $peco_flags | read line

    if test $line
        # Choose the command based on the extension
        set -l extension (string split "." $line)[-1]

        if test "$extension" = sh
            echo "Running $line..."
            /usr/bin/bash $host_file/$line

        else if test "$extension" = yml || test "$extension" = yaml
            # Choose the host to run the script on
            grep -oP '\[\K[^]]+' $hosts_file | peco --layout=bottom-up $peco_flags | read host

            echo "Running $line on $host..."
            ansible-playbook -K -i $hosts_file $automation_dir/$line -l $host

        else
            echo "Unknown file type: $line with extension $extension"
        end

        commandline -f repaint
    end
end

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
