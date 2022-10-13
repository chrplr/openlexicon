updateColFromTree <- function(current_tree, dictionary_databases){
  selected_columns <- list()
  for (x in (get_selected(current_tree, format = "names"))){
    selected_columns[[x]] <- x
  }
  return(selected_columns)
}
