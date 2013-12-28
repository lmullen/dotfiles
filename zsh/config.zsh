if [[ -n $SSH_CONNECTION ]]; then
  export PS1='%m:%3~$(git_info_for_prompt)%# '
else
  export PS1='%3~$(git_info_for_prompt)%# '
fi

export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

fpath=($ZSH/zsh/functions $fpath)

autoload -U $ZSH/zsh/functions/*(:t)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
# setopt HIST_VERIFY
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt AUTOPUSHD        # keep history of directories
setopt AUTO_LIST        # list ambiguous completions automatically

setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

# Vim key bindings and Vim-like line editor
bindkey -v
autoload -U   edit-command-line
zle -N        edit-command-line
bindkey -M vicmd v edit-command-line

# bindkey '^[^[[D' backward-word
# bindkey '^[^[[C' forward-word
# bindkey '^[[5D' beginning-of-line
# bindkey '^[[5C' end-of-line
# bindkey '^[[3~' delete-char
# bindkey '^[^N' newtab
# bindkey '^?' backward-delete-char

# vi style incremental search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
# bindkey '^P' history-search-backward
# bindkey '^N' history-search-forward  

unsetopt nomatch

cdpath=( . ~/ )

# Concatenated options ----------------------------

# Git
alias ga="git add"
# alias gb='git branch'
alias gc='git commit'
alias gca='git commit -a'
alias gcam='git commit -a -m'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
# alias gl='git pull --prune'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push origin HEAD'
# alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias glast='git diff HEAD^ HEAD' # diff of last commit

# Add a file to a .gitignore file
alias gi="echo $1 >> .gitignore"

# Prompt

autoload colors zsh/terminfo && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh


git_branch() {
  echo $(/usr/bin/git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  st=$(/usr/bin/git status 2>/dev/null | tail -n 1)
  if [[ $st == "" ]]
  then
    echo ""
  else
    if [[ $st == "nothing to commit, working directory clean" ]]
    then
      echo "%{$fg[green]%}$(git_prompt_info)%{$reset_color%}"
    else
      echo "%{$fg[red]%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info () {
 ref=$(/usr/bin/git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}

unpushed () {
  /usr/bin/git cherry -v @{upstream} 2>/dev/null
}

need_push () {
  if [[ $(unpushed) == "" ]]
  then
    echo ""
  else
    echo ":%{$fg[magenta]%}push%{$reset_color%}"
  fi
}

has_stash () {
  if [[ -n "$(git stash list 2>/dev/null)" ]]; then
    echo ":%{$fg[magenta]%}stash%{$reset_color%}"
  fi
}

rb_prompt(){
  if $(which rbenv &> /dev/null)
  then
    rb_v=$(rbenv version |awk '{print $1}')
    # if [[ $rb_v  == $(rbenv global) ]]
    # then
    #   echo ""
    # else
      echo "%{$fg[yellow]%}rb:$rb_v%{$reset_color%}"
    # fi
  else
    echo ""
  fi
  }

directory_name(){
  echo "%{$fg[blue]%}%~%{$reset_color%}"
}

user_machine(){
  echo "%{$fg[yellow]%}%n@%M%{$reset_color%}"
}

# A full, but slow version of the prompt
set_busy_prompt () {
  # export PROMPT=$'\n$(directory_name) $(git_dirty)$(has_stash)$(need_push) $(rb_prompt)\n%{$fg[red]%}›%{$reset_color%} '
  export PROMPT=$'\n$(directory_name) $(git_dirty)$(has_stash)$(need_push)\n%{$fg[red]%}›%{$reset_color%} '
  RPROMPT='%(?.. %?)'
}

# A full but slow prompt that uses zsh-git-prompt from olivierverdier
# git://github.com/olivierverdier/zsh-git-prompt.git
# source ~/dev/dotfiles/zsh/git-prompt/zshrc.sh
# set_busy_prompt () {
#   export PROMPT=$'\n$(directory_name) $(git_super_status) $(rb_prompt)\n%{$fg[red]%}›%{$reset_color%} '
#   RPROMPT='%(?.. %?)'
# }

# A speedy version of the prompt
set_prompt () {
  export PROMPT=$'\n$(user_machine):$(directory_name)\n%{$fg[red]%}›%{$reset_color%} '
  RPROMPT='%(?.. %?)'
}

# Which prompt to use by default
busy_prompt=false

# Flip the switch between prompts
toggle_prompt () {
  if [[ $busy_prompt == false ]] then
    busy_prompt=true
  else
    busy_prompt=false
  fi
}

# Set the correct prompt
precmd() {
  if [[ $busy_prompt == true ]] then
    set_busy_prompt
  else
    set_prompt
  fi
  print -Pn "\e]0;%~\a"
}



# Stolen from
#   https://github.com/sstephenson/rbenv/blob/master/completions/rbenv.zsh

if [[ ! -o interactive ]]; then
    return
fi

compctl -K _rbenv rbenv

_rbenv() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(rbenv commands)"
  else
    completions="$(rbenv completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}

# rehash shims
rbenv rehash 2>/dev/null

# shell thing
rbenv() {
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  shell)
    eval `rbenv "sh-$command" "$@"`;;
  *)
    command rbenv "$command" "$@";;
  esac
}



export EDITOR='vim'


pathdirs=(
  /usr/local/bin
  /usr/local/sbin
  $HOME/.rbenv/shims
  $HOME/.rbenv/bin
  $HOME/.pyenv/shims
  $HOME/.pyenv/bin
  /usr/texbin
  /usr/X11/bin
  ~/.cabal/bin
  $ZSH/bin
)

for dir in $pathdirs; do
  if [ -d $dir ]; then
    PATH=$dir:$PATH
  fi
done

export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"



# Project aliases
# -------------------------------------------------------------------
alias blog="cd ~/dev/lincolnmullen.com && gvim -S 2>/dev/null"
# alias demographics="cd ~/dev/demographics-religion && vim -S"
alias diss="cd ~/acad/dissertation && gvim -S 2>/dev/null"
alias dot="cd ~/dev/dotfiles && gvim -S 2>/dev/null"
alias jsr="cd ~/dev/jsr && gvim -S 2>/dev/null"
alias research="cd ~/acad/research/wiki/wikidata && gvim -S 2>/dev/null"
alias runwiki='cd ~/acad/research/wiki && gitit -f my.conf > /dev/null 2>&1 &'
alias timelog='tail ~/todo/time-use.txt'
alias todo="cd ~/todo && gvim -S 2>/dev/null"
alias omekaclient='cd ~/dev/omeka_client && gvim -S 2>/dev/null'
alias notes="cd ~/notes && gvim -S 2>/dev/null"

# File and system management
# -------------------------------------------------------------------
alias ack="ack-grep"
alias cpwd='pwd|tr -d "\n"|pbcopy'  # copy the working directory path
alias duh='du -hs * | sort -h -r'  # Sort files/dirs by size
alias findd="find . -type d -iname" # find a directory
alias findf="find . -type f -iname" # find a file 
alias ip="curl icanhazip.com"       # get current public IP
alias ll="ls -l -F --color --group-directories-first"
alias ls="ls -F --color --group-directories-first"
alias open="xdg-open"
alias more='more -R'                # give more colors
alias process="ps aux | grep"
alias tn="new-todo.rb"
alias tu="timeuse.rb"
alias zshreload='source ~/.zshrc'
alias alert='notify-send -i /usr/share/icons/gnome/32x32/apps/gnome-terminal.png "[$?] Your job is finished"'
alias scanlocal='nmap -sP 192.168.1.0/24'

# Gists
# -------------------------------------------------------------------
alias pastegist="jist -Ppo"  # paste copy of clipboard to public Gist
alias jist="jist -o"         # always open the Gist in the browser

# R
alias R="R --no-restore-data --no-save --quiet"
export R_PROFILE_USER="~/dev/dotfiles/r/Rprofile.symlink"

# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

