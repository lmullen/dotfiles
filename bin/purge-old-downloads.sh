#!/bin/sh

# http://manpages.ubuntu.com/manpages/precise/en/man1/empty-trash.1.html
find /Users/lmullen/Downloads ! -path /Users/lmullen/Downloads -mmin +240 -exec mv {} /Users/lmullen/.Trash/ \;
