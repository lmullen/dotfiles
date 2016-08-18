#!/usr/bin/env bash
pkg=`echo $1 | tr '[:upper:]' '[:lower:]'`
if apt-get install r-cran-$pkg; then
  echo "Successfully installed $pkg from c2d4u"
else
  Rscript -e "install.packages('$1', repo = 'https://cran.rstudio.com')"
fi

