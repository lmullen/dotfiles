# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
# hub_path=$(which hub)
# if [[ -f $hub_path ]]
# then
#   alias git=$hub_path
# fi

# The rest of my fun git aliases
alias ga="git add"
alias gb='git branch'
alias gc='git commit'
alias gca='git commit -a'
alias gcam='git commit -a -m'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git pull --prune'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push origin HEAD'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias glast='git diff HEAD^ HEAD' # diff of last commit

# Add a file to a .gitignore file
alias gi="echo $1 >> .gitignore"
