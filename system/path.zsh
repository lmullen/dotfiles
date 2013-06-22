pathdirs=(
  ./bin
  $ZSH/bin
  /usr/local/bin
  /usr/local/sbin
  $HOME/.rbenv/shims
  $HOME/.rbenv/bin
  /usr/texbin
  /usr/X11/bin
  ~/.cabal/bin
)

for dir in $pathdirs; do
  if [ -d $dir ]; then
    PATH=$dir:$PATH
  fi
done

export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
