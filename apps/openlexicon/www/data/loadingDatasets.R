#json_folder = 'http://www.lexique.org/databases/_json/'
json_folder = '../../datasets-info/_json/'

join_column = "Word"

# Les datasets-id sont les noms des json
# Pb avec anagrammes
dataset_ids <- c('Lexique383','AoA_FreqSub_1493','AoA_FamConcept_1225','Assoc_520','Assoc_366','Concr_ContextAv_ValEmo_Arous_1659','Concr_Imag_FreqSub_Valemo_866',
                 'FrenchLexiconProject-words','FreqSub_Adulte_Senior_660','FreqSub_Imag_ParAge_1286','FreqSub_Imag_1916','FreqSub_Imag_3600','Img_AoA_..._400','Imag_1493','Manulex-Ortho','Manulex-Lemmes',
                 'Megalex-visual','Megalex-auditory','SUBTLEX-US','Aoa32lang',
                 'RT_LD_NMG_FLP_Mono_1482','SensoryExp_1659','SensoryExp_1659',
                 'ValEmo_Arous_Imag_835','ValEmo_Arous_1286',
                 'Valemo_Enfants_600','Valemo_Adultes_604', 'Voisins','WorldLex-English','FreqTwitter-WorldLex-French',
		 'SemantiQc_auditory', 'SemantiQc_familiarity_concept', 'SemantiQc_visual',
                 'WorldLex-Afrikaans',
                   'WorldLex-Albanian',
                   'WorldLex-Amharic',
                   'WorldLex-Arabic',
                   'WorldLex-Armenian',
                   'WorldLex-Azeri',
                   'WorldLex-Bengali',
                   'WorldLex-Bosnian',
                   'WorldLex-Catalan',
                   'WorldLex-Chinese-Simplified',
                   'WorldLex-Croatian',
                   'WorldLex-Czech',
                   'WorldLex-Danish',
                   'WorldLex-Dutch',
                   'WorldLex-Estonian',
                   'WorldLex-Finnish',
                   'WorldLex-Georgian',
                   'WorldLex-German',
                   'WorldLex-Greek',
                   'WorldLex-Greenlandic',
                   'WorldLex-Gujarati',
                   'WorldLex-Hebrew',
                   'WorldLex-Hindi',
                   'WorldLex-Hungarian',
                   'WorldLex-Icelandic',
                   'WorldLex-Indonesian',
                   'WorldLex-Italian',
                   'WorldLex-Japanese',
                   'WorldLex-Kannada',
                   'WorldLex-Kazakh',
                   'WorldLex-Khmer',
                   'WorldLex-Korean',
                   'WorldLex-Latvian',
                   'WorldLex-Lithuanian',
                   'WorldLex-Macedonian',
                   'WorldLex-Malayalam',
                   'WorldLex-Malaysian',
                   'WorldLex-Mongolian',
                   'WorldLex-Nepali',
                   'WorldLex-Norwegian',
                   'WorldLex-Persian',
                   'WorldLex-Polish',
                   'WorldLex-Portuguese-Brazil',
                   'WorldLex-Portuguese-Europe',
                   'WorldLex-Punjabi',
                   'WorldLex-Romanian',
                   'WorldLex-Russian',
                   'WorldLex-Serbian',
                   'WorldLex-Sinhala',
                   'WorldLex-Slovak',
                   'WorldLex-Slovenian',
                   'WorldLex-Spanish-South-America',
                   'WorldLex-Spanish-Spain',
                   'WorldLex-Swahili',
                   'WorldLex-Swedish',
                   'WorldLex-Tagalog',
                   'WorldLex-Tamil',
                   'WorldLex-Telugu',
                   'WorldLex-Turkish',
                   'WorldLex-Ukrainian',
                   'WorldLex-Urdu',
                   'WorldLex-Uzbek',
                   'WorldLex-Vietnamese',
                   'WorldLex-Welsh')

datasets <- list()
# ex_filenames_ds dictionnaire associe dataset_ids et le nom du json puis du rds
ex_filenames_ds <- list('FrenchLexiconProject-words' = c('RT_FrenchLexiconProject-words', 'flp-words'),
                        'FreqTwitter-WorldLex-French' = c('WorldLex-French','WorldLex_FR'),
                        'WorldLex-English' = c('WorldLex-English', 'WorldLex_EN'),
                        'Manulex-Ortho' = c('Manulex', 'Manulex-Ortho'),
                        'Manulex-Lemmes' = c('Manulex', 'Manulex-Lemmes'),
                        'Aoa32lang' = c('AoA-32lang', 'AoA32lang'),
                        'SUBTLEX-US' = c('SUBTLEX-US', 'SUBTLEXus'),
                        'anagrammes' = c('anagrammes', 'Anagrammes')
)

# Capitalize word
capFirst <- function(s) {
    paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "")
}

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


load_dataset_table <- function(ds){
  tryCatch({
    json_url <- datasets[[ds]][1]
    rds_file <- datasets[[ds]][2]
    dictionary_databases[[ds]][["dstable"]] <<- fix.encoding(readRDS(get_dataset_from_json(json_url, rds_file)))
  },
  error = function(e) {
    message(paste("Couldn't load database ", ds, ". Check json and rds files.", sep = ""))
  }
  )
  # Removes not loaded datasets from the list
  if (is.null(dictionary_databases[[ds]][["dstable"]])) { datasets[[ds]] <<- NULL} else {
    colnames(dictionary_databases[[ds]][["dstable"]])[1] <<- join_column

    # Column names description
    for (j in 2:length(colnames(dictionary_databases[[ds]][["dstable"]]))) {
      current_colname = colnames(dictionary_databases[[ds]][["dstable"]])[j]
      if (typeof(info$column_names[[current_colname]]) == "NULL"){
        dictionary_databases[[ds]][["colnames_dataset"]][[current_colname]] <<- ""
      }
      else{
        dictionary_databases[[ds]][["colnames_dataset"]][[current_colname]] <<- info$column_names[[current_colname]]
      }
    }

    if (is.null(dictionary_databases[[ds]][["dsmandcol"]])) {
      dictionary_databases[[ds]][["dsmandcol"]] <<- names(dictionary_databases[[ds]][["colnames_dataset"]])
    }
  }
}

load_language <- function(language){
  gc()
  for (ds in names(datasets)){
    if (tolower(language) %in% tolower(dslanguage[[ds]][["name"]])){
      load_dataset_table(ds)
    }else{
      dictionary_databases[[ds]][["dstable"]] <<- NULL
    }
  }
}

for (ds in dataset_ids)
{
  #datasets[[ds]] <- fetch_dataset(ds, format='rds')
  rds_file <- ds
  json_file <- ds
  if (!is.null(ex_filenames_ds[[ds]])) {
    json_file <- ex_filenames_ds[[ds]][1]
    rds_file <- ex_filenames_ds[[ds]][2]
  }
  datasets[[ds]] = c(paste(json_folder,json_file,'.json', sep = ""),
                     paste(rds_file,'.rds', sep = ""))
}

dictionary_databases <- list()
dslanguage <- list()


language_choices <- c("\n")

for (ds in names(datasets)) {
  json_url <- datasets[[ds]][1]
  info = get_info_from_json(json_url)
  dslanguage[[ds]]['name'] <- info$language
  if (!(dslanguage[[ds]]['name'] %in% language_choices)){
    language_choices <- c(language_choices, capFirst(dslanguage[[ds]]['name']))
  }
  dictionary_databases[[ds]] <- list()
  dictionary_databases[[ds]][["dsdesc"]] <- info$description
  dictionary_databases[[ds]][["dsreadme"]] <- info$readme
  dictionary_databases[[ds]][["dsweb"]] <- info$website
  dictionary_databases[[ds]][["colnames_dataset"]] <- list()
  # load_dataset_table(ds)
  dictionary_databases[[ds]][["dsmandcol"]] <- get_mandatory_columns(ds, info, dictionary_databases)
}
language_choices <- unique(language_choices)
