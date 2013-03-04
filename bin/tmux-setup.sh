#!/usr/bin/env sh

# define the session name
SESSION=work

# if the session is already running, just attach to it.
tmux -C start-server
tmux -C has-session -t $SESSION
if [ $? -eq 0 ]; then
  echo "Session $SESSION already exists. Attaching."
  sleep 1
  tmux -C -2 attach -t $SESSION
  exit 0;
fi

# create the session but don't open it
tmux -C new-session -d -s $SESSION

# open windows, set their directories, and sometimes their layouts

# mail etc.
tmux -C rename-window -t $SESSION:0 misc
tmux -C split-window -d -t $SESSION:0 
tmux -C select-layout -t $SESSION:0 main-vertical

# dissertation
tmux -C new-window -t $SESSION:1 -d -n dissertation
tmux -C split-window -d -t $SESSION:1 

# journal of southern religion
tmux -C new-window -t $SESSION:2 -d -n jsr
tmux -C split-window -t $SESSION:2 
tmux -C split-window -t $SESSION:2 
tmux -C select-layout -t $SESSION:2 main-vertical

# website
tmux -C new-window -t $SESSION:3 -d -n lincolnmullen.com
tmux -C split-window -d -t $SESSION:3 
tmux -C split-window -d -t $SESSION:3 
tmux -C select-layout -t $SESSION:3 main-vertical

# uws
tmux -C new-window -t $SESSION:4 -d -n uws

# dotfiles
tmux -C new-window -t $SESSION:5 -d -n dotfiles
tmux -C split-window -d -t $SESSION:5
tmux -C select-layout -t $SESSION:5 main-vertical

# open the session to the first window
tmux -C select-window -t $SESSION:0
tmux -C -2 attach -t $SESSION
