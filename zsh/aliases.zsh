# Editors
# -------------------------------------------------------------------
alias vim='nvim'

# Projects
# -------------------------------------------------------------------
# alias notebook="$EDITOR -S ~/acad/notebook/Session.vim" 
alias blog="code ~/Dropbox/lincolnmullen.com/lincolnmullen.code-workspace"
alias notebook="code ~/acad/notebook/notebook.code-workspace"

# File and system management
# -------------------------------------------------------------------
alias R="R --no-save --no-restore-data --quiet"
alias alertm="osascript -e 'display notification \"Long running process exited\" with title \"iTerm process\"'"
alias dirsize="du -sx ./* 2>/dev/null | sort -n"
alias ducks='du -cks * | sort -rn | head -n 20'
alias duh='du -hs * | sort -h -r'  # Sort files/dirs by size
alias dudir='du --max-depth=1 -hc'
alias findd="find . -type d -iname" # find a directory
alias findf="find . -type f -iname" # find a file 
alias gvim="gvim 2>/dev/null"
alias ip="curl icanhazip.com"       # get current public IP
alias ls="ls -FG"
alias more='more -R'                # give more colors
alias process="ps aux | grep -i"
alias scanlocal='nmap -sP 192.168.1.0/24'
alias serve='Rscript -e "servr::httw()" -b'
alias xcopy='xclip -selection c -i'
alias zshreload='source ~/.zshrc'
shiny() {
  if [ -z "$1" ]
  then
    Rscript -e "shiny::runApp(port = 3838)"
  else
    Rscript -e "shiny::runApp(port = $1)"
  fi
}
# Attach a tmux session if it exists; otherwise start a new one
tm() { tmux attach-session -t $1 || tmux new-session -s $1 }
# Git 
# -------------------------------------------------------------------
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gca='git commit -a'
alias gcam='git commit -a -m'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gwd='git diff --word-diff'
alias gi="echo $1 >> .gitignore"
alias gl='git pull --prune'
alias glast='git diff HEAD^ HEAD' # diff of last commit
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gs='git status -sb'

# Environment variables
# -------------------------------------------------------------------
source "$HOME/.env.zsh"

# Linux specific
# -------------------------------------------------------------------
# export GVIM="mvim" # Set MacVim by default; overwrite on Linux
if [[ `uname` == 'Linux' ]]; then
  alias open="xdg-open 2>/dev/null"
fi

