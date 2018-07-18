default :
	@echo "There is no default for your own safety."

git :
	@echo "Symlinking git dotfiles"
	ln -s $(HOME)/dev/lmullen/dotfiles/git/gitconfig $(HOME)/.gitconfig 
	ln -s $(HOME)/dev/lmullen/dotfiles/git/gitignore $(HOME)/.gitignore

R :
	@echo "Symlinking R dotfiles"
	ln -s $(HOME)/dev/lmullen/dotfiles/R/Rprofile.R $(HOME)/.Rprofile 

latex :
	@echo "Symlinking LaTeX dotfiles"
	ln -s $(HOME)/dev/lmullen/dotfiles/latex/texmf $(HOME)/texmf 

zsh :
	@echo "Symlinking ZSH dotfiles"
	ln -s $(HOME)/dev/lmullen/dotfiles/zsh/zshrc.zsh $(HOME)/.zshrc 

neovim :
	@echo "Symlinking Neovim dotfiles"
	ln -s $(HOME)/dev/lmullen/dotfiles/neovim $(HOME)/.config/nvim

vscode-mac :
	@echo "Symlinking Visual Studio Code settings for Mac"
	ln -s $(HOME)/dev/dotfiles/vscode/settings.json $(HOME)/Library/Application\ Support/Code/User/settings.json
	ln -s $(HOME)/dev/dotfiles/vscode/snippets $(HOME)/Library/Application\ Support/Code/User/snippets

vscode-ubuntu :
	@echo "Symlinking Visual Studio Code settings for Ubuntu"
	ln -s $(HOME)/dev/lmullen/dotfiles/vscode/settings.json $(HOME)/.config/Code/User/settings.json
	ln -s $(HOME)/dev/lmullen/dotfiles/vscode/snippets $(HOME)/.config/Code/User/snippets

all : git R latex zsh neovim 

.PHONY : all default git R latex zsh neovim

