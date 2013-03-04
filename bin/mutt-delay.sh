#!/bin/bash

# A shell script to convince me not to check my e-mail.
# Lincoln Mullen | http://lincolnmullen.com | lincoln@lincolnmullen.com

read -p "Do you really need to check your e-mail (y/n)? " yn
case $yn in
  y|Y ) echo "You'll have to wait. CTRL+C to get back to work."; sleep 180; mutt;;
  n|N  ) exit;;
esac
