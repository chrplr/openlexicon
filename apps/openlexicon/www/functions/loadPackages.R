usePackage <- function(i){
  if(! i %in% installed.packages()){
    install.packages(i, dependencies = TRUE)
  }
  require(i, character.only = TRUE)
}

usePackageGit <- function(i, github_repo){
  if(! i %in% installed.packages()){
    library(devtools)
    install_github(github_repo)
  }
  require(i, character.only = TRUE)
}

# Load packages

usePackage("stringi")
usePackage("shiny")
usePackage("shinyBS")
usePackage("shinyalert")
usePackage("shinyjs")
usePackage("DT")
usePackage("stringr")
usePackage("shinyWidgets")
usePackage("writexl")
usePackage("plyr")
usePackage("data.table")
usePackage("rlist")
usePackage("RCurl") #To test if string is url
usePackage("comprehenr") # Comprehension list
usePackage("rjson")
usePackage("tippy") #package is now available in CRAN (version 0.1.0). Dev version still available through github usePackage ("JohnCoene/tippy") but seems buggy as of 14/05/24
usePackageGit("shinyTree", "shinyTree/shinyTree")
usePackageGit("shinycssloaders", "jbourgin/shinycssloaders@v0.2.1") #https://github.com/daattali/shinycssloaders/issues/22
usePackage("rvest") # To repair encoding
usePackage("shinybusy") # load icon on full page
