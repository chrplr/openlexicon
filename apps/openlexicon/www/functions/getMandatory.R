get_mandatory_columns <- function(dataset_name, info, dictionary_databases) {
  if (!is.null(info$mandatory_columns)) {
    return(info$mandatory_columns)
  }
  else {
    return (colnames(dictionary_databases[[dataset_name]][["dstable"]]))
  }
}