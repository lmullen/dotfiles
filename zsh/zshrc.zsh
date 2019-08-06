# ZSH configuration, Lincoln Mullen <lincoln@lincolnmullen.com>

# Environment variables
export EDITOR='nvim'
export PROJECTS=~/dev # c + <tab> for autocomplete
export ZSH=$HOME/dev/lmullen/dotfiles
export GOPATH=$HOME/go
export MAKEFLAGS="-j 7"
export HOMEBREW_NO_ANALYTICS=1

# Aliases
source $ZSH/zsh/aliases.zsh

# Functions
fpath=($ZSH/zsh/functions /usr/local/share/zsh-completions $fpath)
autoload -U $ZSH/zsh/functions/*(:t)


# Options
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY # add timestamps to history
export CLICOLOR=true
export TERM="xterm-256color"
setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt AUTOPUSHD        # keep history of directories
setopt AUTO_LIST        # list ambiguous completions automatically
setopt complete_aliases
# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending
# Vim key bindings and Vim-like line editor
bindkey -v
autoload -U   edit-command-line
zle -N        edit-command-line
bindkey -M vicmd v edit-command-line
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
unsetopt nomatch
autoload colors zsh/terminfo && colors

# Prompt
# -------------------------------------------------------------------
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
      echo ":%{$fg[green]%}$(git_prompt_info)%{$reset_color%}"
    else
      echo ":%{$fg[red]%}$(git_prompt_info)%{$reset_color%}"
    fi
  fi
}

git_prompt_info() {
 ref=$(/usr/bin/git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo ":%{$fg[magenta]%}${ref#refs/heads/}${reset_color%}"
}

unpushed() {
  /usr/bin/git cherry -v @{upstream} 2>/dev/null
}

need_push() {
  if [[ $(unpushed) == "" ]]
  then
    echo ""
  else
    echo ":%{$fg[magenta]%}unpushed%{$reset_color%}"
  fi
}

has_stash() {
  if [[ -n "$(git stash list 2>/dev/null)" ]]; then
    echo ":%{$fg[magenta]%}stash%{$reset_color%}"
  fi
}

directory_name(){
  echo "%{$fg[blue]%}%~%{$reset_color%}"
}

user_machine(){
  echo "%{$fg[yellow]%}%n@%M%{$reset_color%}"
}

python_venv() {
   if [[ -z $VIRTUAL_ENV ]] then
     echo ""
   else
     echo ":%{$fg[green]%}venv$reset_color%}"
   fi
}

set_prompt() {
  export PROMPT=$'\n$(user_machine):$(directory_name)$(python_venv)$(git_prompt_info)\n%{$fg[red]%}›%{$reset_color%} '
  RPROMPT='%(?.. %?)'
}

# Set the correct prompt
precmd() {
  set_prompt
  print -Pn "\e]0;%~\a"
}

# Path
# -------------------------------------------------------------------
pathdirs=(
  # /usr/texbin
  /usr/X11/bin
  /usr/local/bin
  /usr/local/sbin
  /usr/local/clang6/bin 
  /usr/local/opt/ruby/bin
  $HOME/go/bin
  /snap/bin
  # ~/.rbenv/shims
  # /usr/local/opt/python/libexec/bin
  # $HOME/dev/dotfiles/bin
)


for dir in $pathdirs; do
  if [ -d $dir ]; then
    PATH=$dir:$PATH
  fi
done

# initialize autocomplete here, otherwise functions won't be loaded
autoload -U compinit
compinit


# Dead to me settings
# -------------------------
# Ruby
# eval "$(rbenv init -)"
# GPG
# export GPG_TTY=$(tty)
# cdpath=( . ~ ~/dev )
