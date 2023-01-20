newDFColumn <- function(line, row, position, value, name){
  line[row, position] <- value
  colnames(line)[position] <- name
  return(line)
}

populateEachRow <- function(line, value, name, desired_position){
  position <- ncol(line)+1
  for (row in 1:nrow(line)){
    line <- newDFColumn(line, row, position, value, name)
  }
  line <- line[,c(1:(desired_position-1), ncol(line), desired_position:(ncol(line)-1))]
  return(line)
}

addToSelectedColumns <- function(v, column, position){
  # We need to add -1 to placement compared with populateEachRow since we do not consider first column Item for selection
  if (!(column %in% names(v$selected_columns))){
    v$selected_columns[[column]] <- column
    # Reorder names in selected_columns so the columns are shown in the right order
    new_order <- c(names(v$selected_columns)[1:(max(1, position-2))], names(v$selected_columns)[length(names(v$selected_columns))], names(v$selected_columns)[(position-1):(length(names(v$selected_columns))-1)])
    v$selected_columns <- v$selected_columns[new_order]
  }
}

removeFromSelectedColumns <- function(v, column){
  if (column %in% names(v$selected_columns)){
    v$selected_columns[[column]] <- NULL
  }
}
