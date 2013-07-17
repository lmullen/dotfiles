#!/bin/sh

# trash command is provided by the Ubuntu trash-cli package
# http://manpages.ubuntu.com/manpages/precise/en/man1/empty-trash.1.html
find /home/lmullen/Downloads/* -mtime +7 -exec trash {} \;
