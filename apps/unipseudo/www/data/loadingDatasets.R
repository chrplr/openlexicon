#json_folder = 'http://www.lexique.org/databases/_json/'
json_folder = '../../datasets-info/_json/'

join_column = "Word"

non_latin_languages = c(
  "Amharic",
  "Arabic",
  "Armenian",
  "Azeri",
  "Bengali", # high number of speakers
  "Bosnian",
  "Georgian",
  "Greek",
  "Gujarati",
  "Hebrew",
  "Hindi", # high number of speakers
  "Japanese", # high number of speakers
  "Kannada",
  "Kazakh",
  "Khmer",
  "Macedonian",
  "Malayalam",
  "Malaysian",
  "Mongolian",
  "Nepali",
  "Persian",
  "Punjabi",
  "Russian", # high number of speakers
  "Sinhala",
  "Tamil",
  "Telugu",
  "Ukrainian",
  "Urdu",
  "Uzbek",
  "Vietnamese"
)

latin_languages = c(
  "Afrikaans",
  "Albanian",
  "Catalan",
  "Croatian",
  "Czech",
  "Danish",
  "Dutch",
  "English",
  "Estonian",
  "Finnish",
  "French",
  "German",
  "Greenlandic",
  "Hungarian",
  "Icelandic",
  "Indonesian",
  "Italian",
  "Latvian",
  "Lithuanian",
  "Norwegian",
  "Polish",
  "Portuguese Brazil",
  "Portuguese Europe",
  "Romanian",
  "Serbian",
  "Slovak",
  "Slovenian",
  "Spanish Latin America",
  "Spanish Spain",
  "Swahili",
  "Swedish",
  "Tagalog",
  "Turkish",
  "Welsh"
)

# Les datasets-id sont les noms des json
dataset_ids <- c(
      'Lexique383',
      'WorldLex-English',
      'WorldLex-Afrikaans',
      'WorldLex-Albanian',
      'WorldLex-Amharic',
      'WorldLex-Arabic',
      'WorldLex-Armenian',
      'WorldLex-Azeri',
      'WorldLex-Bengali',
      'WorldLex-Bosnian',
      'WorldLex-Catalan',
      # 'WorldLex-Chinese-Simplified',
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
      # 'WorldLex-Korean',
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
      'WorldLex-Spanish-Latin-America',
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
      'WorldLex-Welsh'
  )

datasets <- list()

# Exception for WordLex : json and rds names are different
ex_filenames_ds <- list('WorldLex-English' = c('WorldLex-English', 'WorldLex_EN'))

# Capitalize word
capFirst <- function(s) {
    paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "")
}

load_dataset_table <- function(ds){
  if (is.null(dictionary_databases[[ds]][['dstable']])){
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
    if (is.null(dictionary_databases[[ds]][["dstable"]])) { datasets[[ds]] <- NULL} else {
        colnames(dictionary_databases[[ds]][["dstable"]])[1] <<- join_column
    }
  }
}

load_language <- function(language){
  # Call garbage collector
  gc()
  # Unload all dataset tables. Required datasets will be loaded in get_dataset_words directly
  for (ds in names(datasets)){
    # Exception for Lexique since we need dstable to determine cgram list
    if (ds == "Lexique383" && tolower(language) %in% tolower(dslanguage[["Lexique383"]][["name"]])){
      load_dataset_table(ds)
    }else{
      dictionary_databases[[ds]][["dstable"]] <<- NULL
    }
  }
}

for (ds in dataset_ids)
{
  rds_file <- ds
  json_file <- ds
  # If no exception, rds and json file have the same name
  if (!is.null(ex_filenames_ds[[ds]])) {
    json_file <- ex_filenames_ds[[ds]][1]
    rds_file <- ex_filenames_ds[[ds]][2]
  }
  datasets[[ds]] = c(paste(json_folder,json_file,'.json', sep = ""),
                     paste(rds_file,'.rds', sep = ""))
}

dictionary_databases <- list() # global variable
dslanguage <- list()
# Initialize language list with default_other (choice Other)
language_choices <- c(default_other)

# We load datasets info
# Initialize list to check for duplicate databases (databases with same lang_id or tag 1)
duplicate_ds <- c()
for (ds in names(datasets)) {
    json_url <- datasets[[ds]][1]
    info = get_info_from_json(json_url)
    # ID needs to be unique, otherwise databases with id already in use will not be loaded. ID may be tag 1 (language) or id_lang in .json file.
    dslanguage[[ds]]['name'] <- if (is.null(info$id_lang)) info$language else info$id_lang
    if (!(capFirst(dslanguage[[ds]]['name']) %in% language_choices)){
      language_choices <- c(language_choices, capFirst(dslanguage[[ds]]['name']))
      dictionary_databases[[ds]] <- list()
      dictionary_databases[[ds]][["dsdesc"]] <- info$description
      dictionary_databases[[ds]][["dsweb"]] <- info$website
    }else{
        duplicate_ds <- c(duplicate_ds, ds)
    }
}

# Language tooltip is here to resolve dependencies
lang_tooltip = paste("<span",tooltip_style,">Choose a language amongst the", length(dataset_ids), "available. Choosing a language allows to use the<b>", generator_name, "</b>(see",generator_name,"button tooltip for more details).If you don't want to use the<b>", generator_name, "</b> choose the first option, \"Other\".</span>")
