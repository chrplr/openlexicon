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
usePackageGit("shinycssloaders", "jbourgin/shinycssloaders") #https://github.com/daattali/shinycssloaders/issues/22
usePackage("rvest") # To repair encoding
usePackage("shinyalert")

# usePackage("stringi")
# usePackage("shinyBS")
# usePackage("DT")
# usePackage("stringr")
# usePackage("shinyWidgets")
# usePackage("data.table")
# usePackage("rlist")
# usePackage("RCurl") #To test if string is url
# usePackage("comprehenr") # Comprehension list
# usePackageGit("tippy", "JohnCoene/tippy")
# usePackageGit("shinyTree", "shinyTree/shinyTree")
