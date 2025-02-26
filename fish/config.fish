# PATH
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/go/bin

# Commands to run in interactive sessions can go here
if status is-interactive
    set -g fish_key_bindings fish_vi_key_bindings
end

