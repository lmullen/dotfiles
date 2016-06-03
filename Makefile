default :
	@echo "There is no default for your own safety."

git :
	@echo "Symlinking git dotfiles"
	ln -s $(HOME)/dev/dotfiles/git/gitconfig $(HOME)/.gitconfig 
	ln -s $(HOME)/dev/dotfiles/git/gitignore $(HOME)/.gitignore

R :
	@echo "Symlinking R dotfiles"
	ln -s $(HOME)/dev/dotfiles/R/Rprofile.R $(HOME)/.Rprofile 

latex :
	@echo "Symlinking LaTeX dotfiles"
	ln -s $(HOME)/dev/dotfiles/latex/texmf $(HOME)/texmf 

zsh :
	@echo "Symlinking ZSh dotfiles"
	ln -s $(HOME)/dev/dotfiles/zsh/zshrc.zsh $(HOME)/.zshrc 

all : git R latex zsh

.PHONY : all default git R latex zsh
