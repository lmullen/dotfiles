# PATH
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/go/bin

# Environment variables
source $HOME/.env.fish

# Prompt
function fish_prompt --description "Display the main prompt"
  # Get the user and hostname
  set -l user (set_color green)(prompt_login)(set_color normal)

  # Get the current working directory, shortened
  set -l dir (prompt_pwd --full-length-dirs 3)

  # Set the suffix displayed immediately before user entry
  set -l suffix "›"
  if functions -q fish_is_root_user; and fish_is_root_user
    set suffix "#"
  end
  set suffix (set_color red)$suffix(set_color normal)

  printf "\n%s:%s\n%s " $user $dir $suffix
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

