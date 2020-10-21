#json_folder = 'http://www.lexique.org/databases/_json/'
json_folder = '../../datasets-info/_json/'

join_column = "Word"

# Les datasets-id sont les noms des json
# Pb avec anagrammes
dataset_ids <- c('Lexique-Infra-bigrammes','Lexique-Infra-trigrammes','Lexique-Infra-lettres','Lexique-Infra-word_frequency')

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
  colnames(dictionary_databases[[ds]][["dstable"]])[1] <- join_column
}
