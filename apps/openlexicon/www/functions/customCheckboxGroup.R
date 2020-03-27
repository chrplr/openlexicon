extendedCheckboxGroup <- function(..., extensions = list()) {
  cbg <- checkboxGroupInput(...)
  nExtensions <- length(extensions)
  nChoices <- length(cbg$children[[2]]$children[[1]])
  
  if (nExtensions > 0 && nChoices > 0) {
    lapply(1:min(nExtensions, nChoices), function(i) {
      # For each Extension, add the element as a child (to one of the checkboxes)
      cbg$children[[2]]$children[[1]][[i]]$children[[2]] <<- extensions[[i]]
    })
  }
  cbg
}