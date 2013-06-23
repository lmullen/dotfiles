# Project aliases
# -------------------------------------------------------------------
alias bib="subl --new-window --project ~/Dropbox/Sublime\ projects/bib.sublime-project"
alias blog="subl --new-window --project ~/Dropbox/Sublime\ projects/lincolnmullen.com.sublime-project"
alias demographics="subl --new-window --project ~/Dropbox/Sublime\ projects/Demographics\ of\ Religion.sublime-project"
alias diss="subl --new-window --project ~/Dropbox/Sublime\ projects/dissertation.sublime-project"
alias dot="subl --new-window --project ~/Dropbox/Sublime\ projects/dotfiles.sublime-project"
alias jsr="subl --new-window --project ~/Dropbox/Sublime\ projects/JSR.sublime-project"
alias research="subl --new-window --project ~/Dropbox/Sublime\ projects/research-notes.sublime-project"

alias runwiki='cd ~/acad/research/wiki && gitit -f my.conf > /dev/null 2>&1 &'

# Change application behavior
# -------------------------------------------------------------------
alias R="R --no-restore"
alias chrome="open -a \"Google Chrome\""

# File and system management
# -------------------------------------------------------------------
alias ack="ack-grep"
alias cpwd='pwd|tr -d "\n"|pbcopy'  # copy the working directory path
alias duh='du -hs * | sort -h -r'  # Sort files/dirs by size
alias findd="find . -type d -iname" # find a directory
alias findf="find . -type f -iname" # find a file 
alias ip="curl icanhazip.com"       # get current public IP
alias ll="ls -l -F --color"
alias ls="ls -F --color"
alias more='more -R'                # give more colors
alias synaptic="sudo synaptic"
alias tu="timeuse.rb"
alias zshreload='source ~/.zshrc'
alias process="ps aux | grep"

# Gists
# -------------------------------------------------------------------
alias pastegist="jist -Ppo"  # paste copy of clipboard to public Gist
alias jist="jist -o"         # always open the Gist in the browser
