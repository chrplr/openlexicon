#json_folder = 'http://www.lexique.org/databases/_json/'
json_folder = '../../../openlexicon/datasets-info/_json/'

join_column = "Word"

# Les datasets-id sont les noms des json
# Pb avec anagrammes
dataset_ids <- c('Lexique383','AoA_FreqSub_1493','AoA_FamConcept_1225','Assoc_520','Assoc_366','Concr_ContextAv_ValEmo_Arous_1659','Concr_Imag_FreqSub_Valemo_866',
                 'FrenchLexiconProject-words','FreqSub_Adulte_Senior_660','FreqSub_Imag_1916','FreqSub_Imag_3600','Img_AoA_..._400','Imag_1493','Manulex-Ortho','Manulex-Lemmes',
                 'Megalex-visual','Megalex-auditory','SUBTLEX-US','Aoa32lang',
                 'RT_LD_NMG_FLP_Mono_1482','SensoryExp_1659','SensoryExp_1659',
                 'ValEmo_Arous_Imag_835','ValEmo_Arous_1286',
                 'Valemo_Enfants_600','Valemo_Adultes_604', 'Voisins','WorldLex-English','FreqTwitter-WorldLex-French')

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

# We try to load the databases
for (ds in names(datasets)) {
  tryCatch({
    json_url <- datasets[[ds]][1]
    rds_file <- datasets[[ds]][2]
    dictionary_databases[[ds]][["dstable"]] <- readRDS(get_dataset_from_json(json_url, rds_file))
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
  dslanguage[[ds]]['name'] <- info$language
  dictionary_databases[[ds]][["dsdesc"]] <- info$description
  dictionary_databases[[ds]][["dsreadme"]] <- info$readme
  dictionary_databases[[ds]][["dsweb"]] <- info$website
  dictionary_databases[[ds]][["dsmandcol"]] <- get_mandatory_columns(ds, info, dictionary_databases)
  dictionary_databases[[ds]][["colnames_dataset"]] <- list()
  colnames(dictionary_databases[[ds]][["dstable"]])[1] <- join_column
  
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
  
  if (is.null(dictionary_databases[[ds]][["dsmandcol"]])) {
    dictionary_databases[[ds]][["dsmandcol"]] <- names(dictionary_databases[[ds]][["colnames_dataset"]])
  }
}