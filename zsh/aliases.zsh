# Projects
# -------------------------------------------------------------------
alias blog='gvim -S ~/dev/lincolnmullen.com/Session.vim'
alias course='gvim -S ~/acad/teaching/religion-19c-dh/Session.vim'
alias diss='gvim -S ~/acad/dissertation/Session.vim'
alias dot='gvim -S ~/dev/dotfiles/Session.vim'
alias jsr='gvim -S ~/dev/jsr/Session.vim'
alias notes='gvim -S ~/notes/Session.vim'
alias research='gvim -S ~/acad/research/wiki/wikidata/Session.vim' 
alias todo='gvim ~/Desktop/*.txt'

# File and system management
# -------------------------------------------------------------------
alias R="R --no-restore-data --no-save --quiet"
alias ack="ack-grep"
alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] Your job is finished"'
function cs() { cd "$@" && ls; }
alias duh='du -hs * | sort -h -r'  # Sort files/dirs by size
alias findd="find . -type d -iname" # find a directory
alias findf="find . -type f -iname" # find a file 
alias gvim="gvim 2>/dev/null"
alias ip="curl icanhazip.com"       # get current public IP
alias ll="ls -l -F --color --group-directories-first"
alias ls="ls -F --color --group-directories-first"
alias more='more -R'                # give more colors
alias open="xdg-open 2>/dev/null"
alias process="ps aux | grep"
alias runwiki='cd ~/acad/research/wiki && gitit -f my.conf > /dev/null 2>&1 &'
alias scanlocal='nmap -sP 192.168.1.0/24'
alias timelog='tail ~/todo/time-use.txt'
alias tn="new-todo.rb"
alias tu="timeuse.rb"
alias update='sudo apt-get update && sudo apt-get upgrade; alert'
alias xcopy='xclip -selection c -i'
alias zshreload='source ~/.zshrc'

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
alias gi="echo $1 >> .gitignore"
alias gl='git pull --prune'
alias glast='git diff HEAD^ HEAD' # diff of last commit
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push origin HEAD'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gs='git status -sb'

