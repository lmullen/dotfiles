#!/usr/bin/env bash

link="- [ ] [$1](http://elections.lib.tufts.edu/catalog/tufts:$1): "
echo $link
echo $link | xclip -selection c

