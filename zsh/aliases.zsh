alias duh='du -h -d 0'
alias top='top -a -o cpu'
alias vim='/Users/lmullen/Applications/MacVim.app/Contents/MacOS/Vim'
alias zshconfig="mvim ~/.zshrc"
alias zshreload='source ~/.zshrc'
alias dot="mvim -c ':cd ~/dev/dotfiles'"   # open Vim to dotfiles directory
alias notes="mvim -c ':cd ~/notes'"        # open Vim to notes directory

alias bib="mvim -c ':cd ~/bib' ~/bib/history.bib"
alias scan="cd ~/Scans/`date +'%F'`"      # open scan directory for today
alias more='more -R'                      # give more colors


# change to the research directory, run the wiki process in the 
# background, sending all output to the bit bucket
alias runwiki='cd ~/acad/research && gitit -f my.conf > /dev/null 2>&1 &'

# open Vim in the directory with files for the research wiki
alias research="mvim -c ':cd ~/acad/research/wikidata'"

alias diss='cd ~/acad/dissertation/'
alias home='cd ~'
alias posts="mvim -c ':cd ~/dev/lincolnmullen.com/source/_posts/'"
alias jsr="mvim -c ':cd ~/dev/jsr'"
alias brewu="brew update && brew outdated"
alias R="R --no-restore"

alias ll="ls -l"

# Gists
# -------------------------------------------------------------------
# paste copy of clipboard to public Gist
alias pastegist="jist -Ppo"
alias jist="jist -o"

