# Editors and languages
# -------------------------------------------------------------------
alias vim='nvim'
alias R="R --no-save --no-restore-data --quiet"

# System management
# -------------------------------------------------------------------
alias alertm="osascript -e 'display notification \"Long running process exited\" with title \"iTerm process\"'"
alias findd="find . -type d -iname" # find a directory
alias findf="find . -type f -iname" # find a file 
alias ip="curl icanhazip.com"       # get current public IP
alias more='more -R'                # give more colors
alias process="ps aux | grep -i"
alias scanlocal='nmap -sP 192.168.1.0/24'
alias dfd='df -h -x squashfs -x tmpfs -x devtmpfs'

# Git 
# -------------------------------------------------------------------
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a'
alias gcam='git commit -a -m'
alias gcm='git commit -m'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gs='git status -sb'
alias gl='git pull --ff-only'

# Environment variables
# -------------------------------------------------------------------
source "$HOME/.env.zsh"

# Linux specific
# -------------------------------------------------------------------
if [[ `uname` == 'Linux' ]]; then
  alias open="xdg-open 2>/dev/null"
fi

