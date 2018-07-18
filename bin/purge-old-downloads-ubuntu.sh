#!/bin/sh

# http://manpages.ubuntu.com/manpages/precise/en/man1/empty-trash.1.html
find /home/lmullen/Downloads -type f -mtime +1 -exec gio trash {} \;
