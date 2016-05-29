default :
	@echo "There is no default for your own safety."

git :
	@echo "Symlinking git dotfiles"
	ln -s $(HOME)/dev/dotfiles/git/gitconfig $(HOME)/.gitconfig 
	ln -s $(HOME)/dev/dotfiles/git/gitignore $(HOME)/.gitignore

R :
	@echo "Symlinking R dotfiles"
	ln -s $(HOME)/dev/dotfiles/R/Rprofile.R $(HOME)/.Rprofile 

all : git R

.PHONY : all default git R
