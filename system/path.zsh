pathdirs=(
  /usr/local/bin
  /usr/local/sbin
  $HOME/.rbenv/shims
  $HOME/.rbenv/bin
  # $HOME/.pyenv/shims
  # $HOME/.pyenv/bin
  /usr/texbin
  /usr/X11/bin
  ~/.cabal/bin
  $ZSH/bin
)

for dir in $pathdirs; do
  if [ -d $dir ]; then
    PATH=$dir:$PATH
  fi
done

export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
