updateFromDB <- function(current_databases,
                         previous_selected_columns,
                         dictionary_databases,
                         prefix_col,
                         suffix_col
                         ){
  selected_columns <- list()
  col_tooltips <- list()
  
  if (length(current_databases) >= 1) {
    
    for (i in 1:length(current_databases)){
      if (current_databases[i] %in% previous_selected_columns){
        selected_columns[[current_databases[i]]] <- previous_selected_columns[[current_databases[i]]]
        for (elt in names(selected_columns[[current_databases[i]]])){
          col_tooltips[[selected_columns[[current_databases[i]]][[elt]]]] <- dictionary_databases[[current_databases[[i]]]][["colnames_dataset"]][[elt]]
        }
      }
      else{
        selected_columns[[current_databases[i]]] <- list()
        for (j in names(dictionary_databases[[current_databases[i]]][['colnames_dataset']])) {
          original_name = j
          if (original_name %in% dictionary_databases[[current_databases[i]]][["dsmandcol"]]){
            if (length(current_databases) > 1){
              new_name <- paste0(prefix_col, current_databases[i],suffix_col, original_name)
            }
            else {
              new_name <- original_name
            }
            selected_columns[[current_databases[i]]][[original_name]] <- new_name
            col_tooltips[[new_name]] <- dictionary_databases[[current_databases[[i]]]][["colnames_dataset"]][[original_name]]
          }
        }
      }
    }
  }
  out <- list(selected_columns, col_tooltips)
  return(out)
}