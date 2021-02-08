updateColFromTree <- function(current_tree, current_databases, prefix_col, suffix_col, dictionary_databases){
  selected_columns <- list()
  col_tooltips <- list()
  for (x in (get_selected(current_tree, format = "names"))){
    if (length(attr(x, "ancestry")) > 0){
      if (!(attr(x, "ancestry") %in% names(selected_columns))){
        selected_columns[[attr(x, "ancestry")]] <- list()
      }
      if (length(current_databases) > 1){
        new_name <- paste0(prefix_col, attr(x, "ancestry"),suffix_col, x)
      }
      else {
        new_name <- x
      }
      selected_columns[[attr(x, "ancestry")]][[x]] <- new_name
      col_tooltips[[new_name]] <- dictionary_databases[[attr(x, "ancestry")]][["colnames_dataset"]][[x]]
    }
  }
  out <- list(selected_columns, col_tooltips)
  return(out)
}