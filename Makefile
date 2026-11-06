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

fish :
	@echo "Symlinking fish dotfiles"
	ln -s $(HOME)/github/lmullen/dotfiles/fish/config.fish $(HOME)/.config/fish/config.fish
	ln -s $(HOME)/github/lmullen/dotfiles/fish/functions $(HOME)/.config/fish/functions
	ln -s $(HOME)/github/lmullen/dotfiles/fish/completions $(HOME)/.config/fish/completions

neovim :
	@echo "Symlinking Neovim dotfiles"
	mkdir -p $(HOME)/.config/
	ln -s $(HOME)/github/lmullen/dotfiles/neovim $(HOME)/.config/nvim

ghostty :
	@echo "Symlinking Ghostty dotfiles"
	mkdir -p $(HOME)/.config/ghostty
	ln -s $(HOME)/github/lmullen/dotfiles/ghostty/config $(HOME)/.config/ghostty/config

schaff-apps :
	brew bundle install --file=$(HOME)/github/lmullen/dotfiles/homebrew/Schaff.Brewfile

gaustad-apps :
	brew bundle install --file=$(HOME)/github/lmullen/dotfiles/homebrew/Gaustad.Brewfile

launchd :
	@echo "Symlinking launchd plists"
	mkdir -p $(HOME)/Library/LaunchAgents
	ln -sf $(HOME)/github/lmullen/dotfiles/launchd/com.lmullen.backup-notes.plist $(HOME)/Library/LaunchAgents/com.lmullen.backup-notes.plist
	ln -sf $(HOME)/github/lmullen/dotfiles/launchd/com.lmullen.remove-old-downloads.plist $(HOME)/Library/LaunchAgents/com.lmullen.remove-old-downloads.plist
	ln -sf $(HOME)/github/lmullen/dotfiles/launchd/com.lmullen.backup-pkm.plist $(HOME)/Library/LaunchAgents/com.lmullen.backup-pkm.plist

# Create (but do not start) each Docker sandbox declared in sandboxes/env/,
# skipping any whose name already appears in `sbx ls`.
SANDBOX_ENVS := $(wildcard $(HOME)/github/lmullen/dotfiles/sandboxes/env/*/sbxenv.yaml)

# Host environment variables to pass into a sandbox when it is created, as
# <sandbox>:<VARIABLE> pairs. Each becomes `--env-arg VARIABLE=<host value>`
# on `sbx env create`, so the sandbox's sbxenv.yaml must declare VARIABLE
# under args: and map it under env:. Creation fails if a listed variable is
# unset on the host, since a sandbox that already exists is skipped later.
SANDBOX_HOST_ENV := legal-modernism:LAW_CLAUDE

sandboxes :
	@echo "Creating Docker sandboxes that do not already exist"
	@existing="$$(sbx ls -q)" || exit 1; \
	for env in $(SANDBOX_ENVS); do \
		name=$$(awk '/^name:/ { print $$2 }' $$env | tr -d "\"'"); \
		if printf '%s\n' "$$existing" | grep -qxF "$$name"; then \
			echo "Sandbox $$name already exists; skipping"; \
			continue; \
		fi; \
		set --; \
		for pair in $(SANDBOX_HOST_ENV); do \
			[ "$${pair%%:*}" = "$$name" ] || continue; \
			var="$${pair#*:}"; \
			val="$$(printenv "$$var")" || { \
				echo "$$var is not set on the host; not creating sandbox $$name" >&2; \
				exit 1; \
			}; \
			echo "Passing host $$var to sandbox $$name"; \
			set -- "$$@" --env-arg "$$var=$$val"; \
		done; \
		echo "Creating sandbox $$name"; \
		sbx env create "$$@" $$env || exit 1; \
	done

.PHONY : all default git R latex zsh neovim ghostty fish launchd schaff-apps gaustad-apps sandboxes

