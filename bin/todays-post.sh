#!/usr/bin/env bash

# A shell script to open a newly generated Octopress/Jekyll post with 
# today's date

# Lincoln Mullen <lincoln@lincolnmullen.com>
# MIT License <http://lmullen.mit-license.org/>

POSTS=/Users/lmullen/dev/lincolnmullen.com/source/_posts/$(date +'%Y-%m-%d')*.markdown
mvim $POSTS
