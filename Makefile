default :
	@echo "There is no default for your own safety."

git :
	@echo "Symlinking git dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/git/gitconfig $(HOME)/.gitconfig 
	ln -s $(HOME)/github/lmullen/dotfiles/git/gitignore $(HOME)/.gitignore

R :
	@echo "Symlinking R dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/R/Rprofile.R $(HOME)/.Rprofile 
	ln -s $(HOME)/github/lmullen/dotfiles/R/Renviron $(HOME)/.Renviron 
	mkdir -p $(HOME)/.R
	ln -s $(HOME)/github/lmullen/dotfiles/R/Makevars $(HOME)/.R/Makevars

latex :
	@echo "Symlinking LaTeX dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/latex/texmf $(HOME)/texmf 

zsh :
	@echo "Symlinking ZSH dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/zsh/zshrc.zsh $(HOME)/.zshrc 

neovim :
	@echo "Symlinking Neovim dotfiles"
	mkdir -p $(HOME)/.config/
	ln -s $(HOME)/github/lmullen/dotfiles/neovim $(HOME)/.config/nvim

schaff-apps :
	brew bundle install --file=$(HOME)/github/lmullen/dotfiles/homebrew/Schaff.Brewfile

all : git R latex zsh neovim

.PHONY : all default git R latex zsh neovim

