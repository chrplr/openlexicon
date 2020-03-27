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

usePackage("shiny")
usePackage("shinyBS")
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
usePackageGit("tippy", "JohnCoene/tippy")
usePackageGit("shinyTree", "shinyTree/shinyTree")