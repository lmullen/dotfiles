#!/bin/sh

# http://manpages.ubuntu.com/manpages/precise/en/man1/empty-trash.1.html
find /Users/lmullen/Downloads/* -mtime +1 -exec mv {} /Users/lmullen/.Trash/ \;
