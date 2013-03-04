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
    if [[ $st == "nothing to commit (working directory clean)" ]]
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

rb_prompt(){
  if $(which rbenv &> /dev/null)
  then
    rb_v=$(rbenv version |awk '{print $1}')
    if [[ $rb_v  == $(rbenv global) ]]
    then
      echo ""
    else
      echo "%{$fg[yellow]%}$rb_v%{$reset_color%}"
    fi
  else
    echo ""
  fi
  }

# This keeps the number of todos always available the right hand side of 
# my command line.
# todo(){
#   if $(which todo.sh &> /dev/null)
#   then
#     total_todos=$(echo $(todo.sh ls | wc -l))
#     pri_A=$(echo $(todo.sh lsp A | wc -l))
#     let today_todos=pri_A-2
#     if [ $total_todos != 0 ]
#     then
#       echo "T:$today_todos"
#     else
#       echo ""
#     fi
#   else
#     echo ""
#   fi
# }

directory_name(){
  echo "%{$fg[blue]%}%~%{$reset_color%}"
}

# user_machine(){
#   echo "%{$fg[yellow]%}%n@%M%{$reset_color%}"
# }

set_prompt () {
  export PROMPT=$'\n$(directory_name) $(git_dirty)$(need_push) $(rb_prompt)\n%{$fg[red]%}›%{$reset_color%} '
  # export PROMPT=$'\n$(directory_name) '
  # show exit code only if it is non-zero
  RPROMPT='%(?.. %?)'
}

precmd() {
  # title "zsh" "%m" "%55<...<%~"
  set_prompt
}
