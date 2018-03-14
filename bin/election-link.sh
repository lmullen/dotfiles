#!/usr/bin/env bash

link="- [ ] [$1](http://elections.lib.tufts.edu/catalog/tufts:$1): "
echo $link
if [ "$(uname)" == "Darwin" ]; then
  echo $link | pbcopy
else
  echo $link | xclip -selection c
fi

