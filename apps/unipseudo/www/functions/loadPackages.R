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

usePackage("lubridate")
usePackage("writexl")
usePackage("plyr")
usePackage("stringr")
usePackage("DT")
usePackage("shiny")
usePackage("shinyjs")
usePackage("shinyBS")
usePackage("shinyalert")
usePackage("shinyWidgets")
usePackageGit("shinycssloaders", "jbourgin/shinycssloaders@v0.2.1") #https://github.com/daattali/shinycssloaders/issues/22
usePackage("rvest") # To repair encoding
usePackage("rlist") # For list.filter
usePackage("shinyalert")
usePackage("tippy")
usePackage("RCurl") #To test if string is url
usePackage("stringr") # str_replace_all
usePackage("shinylogs") # logs
usePackage("shinybusy") # load icon on full page

# usePackage("dplyr")
# usePackage("stringi")
# usePackage("data.table")
# usePackage("comprehenr") # Comprehension list
# usePackageGit("shinyTree", "shinyTree/shinyTree")
