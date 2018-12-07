# Rprofile settings

# Lincoln A. Mullen | lincoln@lincolnmullen.com | http://lincolnmullen.com
# MIT License <http://lmullen.mit-license.org/>

# Helpful tips and borrowed settings from
# http://kevinushey.github.io/blog/2015/02/02/rprofile-essentials/
# https://github.com/hadley/devtools#other-tips
# http://inundata.org/2011/09/29/customizing-your-rprofile/

options(
    width = 80,
    repos = c(
              # ROPENSCI = "http://packages.ropensci.org",
              CRAN = "https://cloud.r-project.org"
              ),
    download.file.method = "libcurl",
    useFancyQuotes = FALSE,
    menu.graphics = FALSE,
    editor = "vim",
    browserNLdisabled = TRUE,
    # max.print = 1e2,
    Ncpus = 8L,
    devtools.name = "Lincoln Mullen",
    devtools.desc= list(
      "Authors@R" = 'c(person("Lincoln", "Mullen", 
      role = c("aut", "cre"), email = "lincoln@lincolnmullen.com",
      comment = c(ORCID = "0000-0001-5103-6917")))',
      License    = "MIT + file LICENSE",
      Version    = "0.0.0.9000",
      VignetteBuilder = "knitr",
      URL        = "https://github.com/lmullen/pkgname",
      BugReports = "https://github.com/lmullen/pkgname/issues",
      LazyData   = "yes")
    )
utils::rc.settings(ipck = TRUE)

Sys.setenv(R_PACKRAT_CACHE_DIR = '~/R/packrat/')
Sys.setenv(R_HISTSIZE = '1000')
Sys.setenv(TZ = "America/New_York")

if(interactive()){

  # Create a new invisible environment for all the functions to go
  # in so it doesn't clutter the workspace.
  .env <- new.env()

  # Wrapper around object.size to print it with human readable units
  .env$os <- function(object) pryr::object_size(object)

  # Override q() to not save by default. Same as saying q("no").
  .env$q <- function(save = "no", ...) {
    quit(save = save, ...)
  }

  # Open the current working directory in Nautilus/Finder
  .env$o <- function() {
    if(Sys.info()[1]=="Linux") system("xdg-open .")
    if(Sys.info()[1]=="Darwin") system("open .")
  }

  .env$pnum <- function(x) prettyNum(x, big.mark = ",")

  .env$print.data.frame <- function(x) { 
    if (requireNamespace("tibble", quietly = TRUE)) {
      tibble:::print.tbl_df(tibble::as_tibble(x)) 
    } else {
      print(x)
    }
  }

  # Attach all the variables above
  attach(.env, warn.conflicts = FALSE)

}

.First <- function() {
  if (interactive()) {
    cat("\nLoaded .Rprofile at", base::date(), "\n\n")
  }
}

.Last <- function() {
  if (interactive()) {
    cat("\nExiting R at", base::date(), "\n\n")
  }
}

