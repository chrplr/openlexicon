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
#usePackage("dplyr")
usePackage("DT")
usePackage("shiny")
usePackage("shinyjs")
usePackage("shinyalert")
usePackageGit("shinycssloaders", "jbourgin/shinycssloaders@v0.2.1") #https://github.com/daattali/shinycssloaders/issues/22
usePackage("rvest") # To repair encoding
usePackage("tippy")
usePackage("vwr")
usePackageGit("shinyTree", "shinyTree/shinyTree")
usePackage("comprehenr") #list comprehension
usePackage("rlist") # for list.append
usePackage("shinyBS") # for bs button
usePackage("shinybusy") # load icon on full page

# usePackage("stringi")
# usePackage("DT")
# usePackage("stringr")
# usePackage("data.table")
# usePackage("shinyWidgets")
# usePackage("RCurl") #To test if string is url
