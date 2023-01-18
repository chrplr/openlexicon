#json_folder = 'http://www.lexique.org/databases/_json/'
json_folder = '../../datasets-info/_json/'

join_column = "Word"

# Les datasets-id sont les noms des json
# Pb avec anagrammes
dataset_ids <- c('Lexique383','Lexique-Infra-bigrammes','Lexique-Infra-trigrammes','Lexique-Infra-lettres','Lexique-Infra-word_frequency')

datasets <- list()

# Fix encoding to UTF-8
fix.encoding <- function(df) {
  numCols <- ncol(df)
  numRows <- nrow(df)
  highProbaEncoding = guess_encoding(paste(df[ ,1], sep = " "))[[1]][1]
  if (grepl("UTF-16BE", highProbaEncoding)){
    highProbaEncoding = "latin1"
  }
  for (col in 1:numCols){
    if (!(is.numeric(df[, col]))){
      df[, col] <- as.character(df[, col])
      df[, col] <- iconv(df[, col], from = highProbaEncoding, to = "UTF-8")
      Encoding(colnames(df)[colnames(df)==col]) <- "UTF-8"
    }
  }
  colnames(df) <-  trimws(colnames(df))
  return(df)
}

for (ds in dataset_ids)
{
  #datasets[[ds]] <- fetch_dataset(ds, format='rds')
  rds_file <- ds
  json_file <- ds
  datasets[[ds]] = c(paste(json_folder,json_file,'.json', sep = ""),
                     paste(rds_file,'.rds', sep = ""))
}

dictionary_databases <- list()

# We try to load the databases
for (ds in names(datasets)) {
  tryCatch({
    json_url <- datasets[[ds]][1]
    rds_file <- datasets[[ds]][2]
    dictionary_databases[[ds]][["dstable"]] <- fix.encoding(readRDS(get_dataset_from_json(json_url, rds_file)))
  },
  error = function(e) {
    message(paste("Couldn't load database ", ds, ". Check json and rds files.", sep = ""))
  }
  )
}

# Removes not loaded datasets from the list
for (ds in names(datasets)) { if (is.null(dictionary_databases[[ds]][["dstable"]])) { datasets[[ds]] <- NULL}}

for (ds in names(datasets)) {
  json_url <- datasets[[ds]][1]
  info = get_info_from_json(json_url)
  dictionary_databases[[ds]][["colnames_dataset"]] <- list()
  colnames(dictionary_databases[[ds]][["dstable"]])[1] <- join_column
  if (ds == 'Lexique-Infra-word_frequency'){
      dictionary_databases[[ds]][["colnames_dataset"]][["TypeItem"]] = "Type Item"
  }
  # Column names description
  for (j in 2:length(colnames(dictionary_databases[[ds]][["dstable"]]))) {
    current_colname = colnames(dictionary_databases[[ds]][["dstable"]])[j]
    if (typeof(info$column_names[[current_colname]]) == "NULL"){
      dictionary_databases[[ds]][["colnames_dataset"]][[current_colname]] = ""
    }
    else{
      dictionary_databases[[ds]][["colnames_dataset"]][[current_colname]] = info$column_names[[current_colname]]
    }
  }
}

type_column = "TypeItem"

# Get whole databases, this is done only one time, when launching app. Then these variables are accessible to all users.
types_list <- c("let", "bigr", "trigr")
subtypes_list <- c("Ty", "To")
dt_info <- list()
dt_info[[types_list[[1]]]] <- dictionary_databases[['Lexique-Infra-lettres']][['dstable']]
dt_info[[types_list[[2]]]] <- dictionary_databases[['Lexique-Infra-bigrammes']][['dstable']]
dt_info[[types_list[[3]]]] <- dictionary_databases[['Lexique-Infra-trigrammes']][['dstable']]
whole_dt <- dictionary_databases[['Lexique-Infra-word_frequency']][['dstable']]
# Add TypItem column in second position
whole_dt[[type_column]] <- NA
whole_dt<-whole_dt[,c(1,ncol(whole_dt), 3:ncol(whole_dt)-1)]

hamming_distance_opt <- "Ortho Neighbors"
hamming_position <- 3

initialCols <- colnames(whole_dt)[colnames(whole_dt) != join_column]
initialSelectedCols <- list()
initialColTooltips <- list()
for (elt in colnames(whole_dt)){
  if (elt != join_column){
    initialSelectedCols[[elt]] <- elt
  }
  initialColTooltips[[elt]] <- dictionary_databases[["Lexique-Infra-word_frequency"]][["colnames_dataset"]][[elt]]
}
initialColTooltips[[hamming_distance_opt]] <- hamming_distance_opt
