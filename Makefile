default :
	@echo "There is no default for your own safety."

git :
	@echo "Symlinking git dotfiles"
	ln -s $(HOME)/dev/dotfiles/git/gitconfig $(HOME)/.gitconfig 
	ln -s $(HOME)/dev/dotfiles/git/gitignore $(HOME)/.gitignore

all : git

.PHONY : all default git
