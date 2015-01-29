# Projects
# -------------------------------------------------------------------
alias blog='mvim -S ~/dev/lincolnmullen.com/Session.vim'
alias course='mvim -S ~/acad/teaching/religion-19c-dh/Session.vim'
alias diss='mvim -S ~/acad/dissertation/Session.vim'
alias book='mvim -S ~/acad/varieties/Session.vim'
alias whattime='mvim -S ~/dev/what-time-is-it/Session.vim'
alias dot='mvim -S ~/dev/dotfiles/Session.vim'
alias jsr='mvim -S ~/dev/jsr/Session.vim'
alias notes='mvim -S ~/notes/Session.vim'
alias research='mvim -S ~/acad/research/wiki/wikidata/Session.vim' 
alias todo='mvim ~/acad/research/wiki/wikidata/TODO.page -c "BG"'
alias clio='mvim -S ~/acad/teaching/clio3.2014/Session.vim'
alias church-state='mvim -S ~/acad/teaching/church-state.2014.syllabus/Session.vim'
alias capitalism='mvim -S ~/acad/teaching/religion-and-capitalism/Session.vim'

# File and system management
# -------------------------------------------------------------------
alias R="R --no-restore-data"
alias ack="ack-grep"
# alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] Your job is finished"'
alias alert="osascript -e 'display notification \"Long running process exited\" with title \"iTerm process\"'"
function cs() { cd "$@" && ls; }
alias duh='du -hs * | sort -h -r'  # Sort files/dirs by size
alias findd="find . -type d -iname" # find a directory
alias findf="find . -type f -iname" # find a file 
# alias gvim="gvim 2>/dev/null"
alias ip="curl icanhazip.com"       # get current public IP
alias ls="ls -FG"
alias more='more -R'                # give more colors
# alias open="xdg-open 2>/dev/null"
# alias opinion="echo >> ~/dev/noopinion/opinions.txt"
opinion() {
sed -i "1i$1" ~/dev/noopinion/opinions.txt
}
alias process="ps aux | grep"
alias runwiki='cd ~/acad/research/wiki && gitit -f my.conf > /dev/null 2>&1 &'
alias scanlocal='nmap -sP 192.168.1.0/24'
alias serve='ruby -run -e httpd . -p 4000'
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

# Environment variables
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

# Environment variables
# -------------------------------------------------------------------
source "/Users/lmullen/.env.zsh"
