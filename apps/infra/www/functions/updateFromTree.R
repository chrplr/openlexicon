updateColFromTree <- function(current_tree, dictionary_databases){
  selected_columns <- list()
  col_tooltips <- list()
  for (x in (get_selected(current_tree, format = "names"))){
    selected_columns[[x]] <- x
    col_tooltips[[x]] <- dictionary_databases[["Lexique-Infra-word_frequency"]][["colnames_dataset"]][[x]]
  }
  out <- list(selected_columns, col_tooltips)
  return(out)
}
