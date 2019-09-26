default :
	@echo "There is no default for your own safety."

git :
	@echo "Symlinking git dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/git/gitconfig $(HOME)/.gitconfig 
	ln -s $(HOME)/github/lmullen/dotfiles/git/gitignore $(HOME)/.gitignore

R :
	@echo "Symlinking R dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/R/Rprofile.R $(HOME)/.Rprofile 

latex :
	@echo "Symlinking LaTeX dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/latex/texmf $(HOME)/texmf 

zsh :
	@echo "Symlinking ZSH dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/zsh/zshrc.zsh $(HOME)/.zshrc 

neovim :
	@echo "Symlinking Neovim dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/neovim $(HOME)/.config/nvim

vscode-mac :
	@echo "Symlinking Visual Studio Code settings for Mac"
	ln -s $(HOME)/github/lmullen/dotfiles/vscode/settings.json $(HOME)/Library/Application\ Support/Code/User/settings.json
	ln -s $(HOME)/github/lmullen/dotfiles/vscode/snippets $(HOME)/Library/Application\ Support/Code/User/snippets

all : git R latex zsh neovim vscode-mac

.PHONY : all default git R latex zsh neovim vscode-mac

