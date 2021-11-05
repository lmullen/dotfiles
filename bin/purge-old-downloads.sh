#!/bin/sh

find /Users/lmullen/Downloads ! -path /Users/lmullen/Downloads -mmin +15 -exec mv {} /Users/lmullen/.Trash/ \;
