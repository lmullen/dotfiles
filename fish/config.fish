# PATH
fish_add_path /usr/local/texlive/2024/bin/universal-darwin
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/go/bin

# Environment variables
source $HOME/.env.fish

# Prompt
function fish_prompt --description "Display the main prompt"
  # Get the user and hostname
  set -l user (set_color green)(whoami)(set_color normal)
  set -l host (set_color green)(hostname)(set_color normal)

  # Get the current working directory, shortened
  set -l dir (set_color blue)(prompt_pwd --full-length-dirs 3)(set_color normal)

  # Set the suffix displayed immediately before user entry
  set -l suffix "›"
  if functions -q fish_is_root_user; and fish_is_root_user
    set suffix "#"
  end
  set suffix (set_color red)$suffix(set_color normal)

  printf "\n%s@%s:%s\n%s " $user $host $dir $suffix
end

function fish_right_prompt --description "Display the right prompt" 
  # Display the exit code in red brackets only if it is non-zero
  set -l last_status $status
  set -l stat
  if test $last_status -ne 0
      set stat (set_color red)"[$last_status]"(set_color normal)
  end 
  echo $stat
end

# Don't display the Vim mode prompt
function fish_mode_prompt; end

# Don't display a greeting
set -g fish_greeting ""

# Commands to run in interactive sessions
if status is-interactive
    set -g fish_key_bindings fish_vi_key_bindings
end

# Abbreviations
abbr --add editenv --position command '$EDITOR ~/.env.fish && source ~/.env.fish && echo "Reloaded environment variables"'
abbr --add findd --position command "find . -type d -iname"
abbr --add findf --position command "find . -type f -iname"
abbr --add ga --position command "git add"
abbr --add gc --position command "git commit"
abbr --add gca --position command "git commit -a"
abbr --add gcam --position command "git commit -a -m"
abbr --add gcm --position command "git commit -m"
abbr --add ghcd --position command "cd ~/github/lmullen/"
abbr --add gl --position command "git pull --ff-only"
abbr --add glog --position command "git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
abbr --add gp --position command "git push --all"
abbr --add grep --position command "grep -i"
abbr --add gs --position command "git status -sb"
abbr --add ip --position command "curl icanhazip.com"
abbr --add process --position command "ps aux | grep -i"
abbr --add scanlocal --position command "nmap -sP 192.168.1.0/24"
abbr --add vim --position command "nvim"
