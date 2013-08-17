# Project aliases
# -------------------------------------------------------------------
alias blog="cd ~/dev/lincolnmullen.com && vim -S"
alias demographics="cd ~/dev/demographics-religion && vim -S"
alias diss="cd ~/acad/dissertation && vim -S"
alias dot="cd ~/dev/dotfiles && vim -S"
alias jsr="cd ~/dev/jsr && vim -S"
alias research="cd ~/acad/research/wiki/wikidata && vim -S"
alias runwiki='cd ~/acad/research/wiki && gitit -f my.conf > /dev/null 2>&1 &'
alias timelog='tail ~/todo/time-use.txt'
alias todo='cd ~/todo && vim -S'
alias omekaclient='cd ~/dev/omeka_client && vim -S'

# File and system management
# -------------------------------------------------------------------
alias ack="ack-grep"
alias cpwd='pwd|tr -d "\n"|pbcopy'  # copy the working directory path
alias duh='du -hs * | sort -h -r'  # Sort files/dirs by size
alias findd="find . -type d -iname" # find a directory
alias findf="find . -type f -iname" # find a file 
alias git="hub"
alias ip="curl icanhazip.com"       # get current public IP
alias ll="ls -l -F --color --group-directories-first"
alias ls="ls -F --color --group-directories-first"
alias open="xdg-open"
alias more='more -R'                # give more colors
alias process="ps aux | grep"
alias synaptic="sudo synaptic"
alias tn="new-todo.rb"
alias tu="timeuse.rb"
alias zshreload='source ~/.zshrc'

# Gists
# -------------------------------------------------------------------
alias pastegist="jist -Ppo"  # paste copy of clipboard to public Gist
alias jist="jist -o"         # always open the Gist in the browser
