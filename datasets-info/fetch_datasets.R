#! /usr/bin/env Rscript
# Time-stamp: <2019-12-17 11:25:00 christophe@pallier.org>

#  Download a datasets from a json file using 'dafter' syntax (see https://github.com/vinzeebreak/dafter/)

require("rjson")
require("tools") # Required for md5sum


get_data.home <- function()
  # return the path of the local folder where to put datasets
{
  data.home <- Sys.getenv('OPENLEXICON_DATASETS')
  xdg.data.home <- Sys.getenv('XDG_DATA_HOME')

  if (data.home == "")
  {
    if (xdg.data.home == "")
    {
      data.home <- file.path(path.expand('~'), 'openlexicon_datasets')
    } else {
      data.home <- file.path(xdg.data.home, 'openlexicon_datasets')
    }
  }
  dir.create(data.home, showWarnings = FALSE, recursive = TRUE)
  data.home
}


get_info_from_json <- function(json_url)
  # extract information fields from a json file
{
  json_data <- fromJSON(file = json_url)
  return(
    list(
      description = json_data$description,
      readme = json_data$readme,
      website = json_data$website,
      language = json_data$tags[1],
      mandatory_columns = json_data$mandatory_columns,
      column_names = json_data$column_names
    )
  )
}


get_dataset_from_json <- function(json_url, filename)
  # download (only if needed), the dataset 'filename' indicated from the json description file
  # returns the path to the local version of the dataset
                                        # Example:
    # lexique = readRDS(get_dataset_from_json("http://www.lexique.org/databases/_json/Lexique383.json", "Lexique383.rds"))
{
  destname <- file.path(get_data.home(), filename)

  json_data <- fromJSON(file = json_url)

  for (u in json_data$urls)
  {
    fname <- basename(u$url)

    if (fname != filename)
      next

    if (!file.exists(destname))  {
      download.file(u$url, destname, mode = 'wb')
    }  else if (md5sum(destname) != u$md5sum) {
      download.file(u$url, destname, mode = 'wb')
    }

    if (md5sum(destname) != u$md5sum)
    {
      warning(
        "Something is wrong: the md5sums don't match. Either the upstream files are inconsistent or someone is messing with your internet connection."
      )
      return(NULL)
    }
    return(destname)
  }
}


locations <- list(
    Anagrammes=c("http://www.lexique.org/databases/_json/anagrammes.json", "Anagrammes.rds"),
    AoA32=c("http://www.lexique.org/databases/_json/AoA-32lang.json", "AoA32lang.rds"),
    AoA_FamConcept_1225=c("http://www.lexique.org/databases/_json/AoA_FamConcept_1225.json", "AoA_FamConcept_1225.rds"),
    AoA_FreqSub_1493=c("http://www.lexique.org/databases/_json/AoA_FreqSub_1493.json", "AoA_FreqSub_1493.rds"),
    Assoc_366=c("http://www.lexique.org/databases/_json/Assoc_366.json", "Assoc_366.rds"),
    Assoc_520=c("http://www.lexique.org/databases/_json/Assoc_520.json", "Assoc_520.rds"),
#    Concr_ContextAv_ValEmo_Arous_1659=c("http://www.lexique.org/databases/_json/Concr_ContextAv_ValEmo_Arous_1659.json", "Concr_ContextAv_ValEmo_Arous_1659/Concr_ContextAv_ValEmo_Arous_1659.rds"),
#    Concr_Imag_FreqSub_Valemo_866=c("http://www.lexique.org/databases/_json/Concr_Imag_FreqSub_Valemo_866.json", "Concr_Imag_FreqSub_Valemo_866/Concr_Imag_FreqSub_Valemo_866.rds"),
    #XX=c("http://www.lexique.org/databases/_json/FrenchLexiconProject-words.json", "flp-words.rds"),
    FreqSub_Adulte_Senior_660=c("http://www.lexique.org/databases/_json/FreqSub_Adulte_Senior_660.json", "FreqSub_Adulte_Senior_660.rds"),
    FreqSub_Imag_1916=c("http://www.lexique.org/databases/_json/FreqSub_Imag_1916.json", "FreqSub_Imag_1916.rds"),
    FreqSub_Imag_3600=c("http://www.lexique.org/databases/_json/FreqSub_Imag_3600.json", "FreqSub_Imag_3600.rds"),
    Imag_1493=c("http://www.lexique.org/databases/_json/Imag_1493.json", "Imag_1493.rds"),
    #XX=c("http://www.lexique.org/databases/_json/Lexique382.json", "Lexique382.rds"),
    Lexique3=c("http://www.lexique.org/databases/_json/Lexique383.json", "Lexique383.rds"),
#   LexiqueInfraGP=c("http://www.lexique.org/databases/_json/LexiqueInfra-Graphèmes-Phonèmes.json", "Lexique.Infra.Corresp.Graphème.Phonème.rds"),
#    XX=c("http://www.lexique.org/databases/_json/Lexique-Infra-Stats-Infra.json", ""),
#    XX=c("http://www.lexique.org/databases/_json/Manulex.json", ""),
    Megalex_auditory=c("http://www.lexique.org/databases/_json/Megalex-auditory.json", "Megalex-auditory.rds"),
    Megalex_visual=c("http://www.lexique.org/databases/_json/Megalex-visual.json", "Megalex-visual.rds"),
    SemantiQc_auditory=c("http://www.lexique.org/databases/_json/SemantiQc_auditory.json", "SemantiQc_auditory.rds"),
    SemantiQc_familiarity_concept=c("http://www.lexique.org/databases/_json/SemantiQc_familiarity_concept.json", "SemantiQc_familiarity_concept.rds"),
    SemantiQc_visual=c("http://www.lexique.org/databases/_json/SemantiQc_visual.json", "SemantiQc_visual.rds"),
    SensoryExp_1659=c("http://www.lexique.org/databases/_json/SensoryExp_1659.json", "SensoryExp_1659.rds"),
    #XX=c("http://www.lexique.org/databases/_json/SUBTLEX-US-corpus.json", "SUBTLEX-US-corpus.rds"),
    SubtlexUS=c("http://www.lexique.org/databases/_json/SUBTLEX-US.json", "SUBTLEXus.rds"),
    Valemo_Adultes_604=c("http://www.lexique.org/databases/_json/Valemo_Adultes_604.json", "Valemo_Adultes_604.rds"),
    ValEmo_Arous_1286=c("http://www.lexique.org/databases/_json/ValEmo_Arous_1286.json", "ValEmo_Arous_1286.rds"),
    ValEmo_Arous_Imag_835=c("http://www.lexique.org/databases/_json/ValEmo_Arous_Imag_835.json", "ValEmo_Arous_Imag_835.rds"),
    Valemo_Enfants_600=c("http://www.lexique.org/databases/_json/Valemo_Enfants_600.json", "Valemo_Enfants_600.rds"),
    Voisins=c("http://www.lexique.org/databases/_json/Voisins.json", "Voisins.rds"),
    WorldLex_EN=c("http://www.lexique.org/databases/_json/WorldLex-English.json", "WorldLex_EN.rds"),
    WorldLex_FR=c("http://www.lexique.org/databases/_json/WorldLex-French.json", "WorldLex_FR.rds"),
    WorldLex_AF=c("http://www.lexique.org/databases/_json/WorldLex-Afrikaans.json", "WorldLex-Afrikaans.rds"),
    WorldLex_ALB=c("http://www.lexique.org/databases/_json/WorldLex-Albanian.json", "WorldLex-Albanian.rds"),
    WorldLex_AMH=c("http://www.lexique.org/databases/_json/WorldLex-Amharic.json", "WorldLex-Amharic.rds"),
    WorldLex_ARA=c("http://www.lexique.org/databases/_json/WorldLex-Arabic.json", "WorldLex-Arabic.rds"),
    WorldLex_ARM=c("http://www.lexique.org/databases/_json/WorldLex-Armenian.json", "WorldLex-Armenian.rds"),
    WorldLex_AZE=c("http://www.lexique.org/databases/_json/WorldLex-Azeri.json", "WorldLex-Azeri.rds"),
    WorldLex_BEN=c("http://www.lexique.org/databases/_json/WorldLex-Bengali.json", "WorldLex-Bengali.rds"),
    WorldLex_BOS=c("http://www.lexique.org/databases/_json/WorldLex-Bosnian.json", "WorldLex-Bosnian.rds"),
    WorldLex_CAT=c("http://www.lexique.org/databases/_json/WorldLex-Catalan.json", "WorldLex-Catalan.rds"),
    WorldLex_CHI=c("http://www.lexique.org/databases/_json/WorldLex-Chinese-Simplified.json", "WorldLex-Chinese-Simplified.rds"),
    WorldLex_CRO=c("http://www.lexique.org/databases/_json/WorldLex-Croatian.json", "WorldLex-Croatian.rds"),
    WorldLex_CZE=c("http://www.lexique.org/databases/_json/WorldLex-Czech.json", "WorldLex-Czech.rds"),
    WorldLex_DK=c("http://www.lexique.org/databases/_json/WorldLex-Danish.json", "WorldLex-Danish.rds"),
    WorldLex_NL=c("http://www.lexique.org/databases/_json/WorldLex-Dutch.json", "WorldLex-Dutch.rds"),
    WorldLex_EST=c("http://www.lexique.org/databases/_json/WorldLex-Estonian.json", "WorldLex-Estonian.rds"),
    WorldLex_FI=c("http://www.lexique.org/databases/_json/WorldLex-Finnish.json", "WorldLex-Finnish.rds"),
    WorldLex_GE=c("http://www.lexique.org/databases/_json/WorldLex-Georgian.json", "WorldLex-Georgian.rds"),
    WorldLex_DE=c("http://www.lexique.org/databases/_json/WorldLex-German.json", "WorldLex-German.rds"),
    WorldLex_GRE=c("http://www.lexique.org/databases/_json/WorldLex-Greek.json", "WorldLex-Greek.rds"),
    WorldLex_GL=c("http://www.lexique.org/databases/_json/WorldLex-Greenlandic.json", "WorldLex-Greenlandic.rds"),
    WorldLex_GU=c("http://www.lexique.org/databases/_json/WorldLex-Gujarati.json", "WorldLex-Gujarati.rds"),
    WorldLex_HE=c("http://www.lexique.org/databases/_json/WorldLex-Hebrew.json", "WorldLex-Hebrew.rds"),
    WorldLex_HI=c("http://www.lexique.org/databases/_json/WorldLex-Hindi.json", "WorldLex-Hindi.rds"),
    WorldLex_HU=c("http://www.lexique.org/databases/_json/WorldLex-Hungarian.json", "WorldLex-Hungarian.rds"),
    WorldLex_ICE=c("http://www.lexique.org/databases/_json/WorldLex-Icelandic.json", "WorldLex-Icelandic.rds"),
    WorldLex_ID=c("http://www.lexique.org/databases/_json/WorldLex-Indonesian.json", "WorldLex-Indonesian.rds"),
    WorldLex_ITA=c("http://www.lexique.org/databases/_json/WorldLex-Italian.json", "WorldLex-Italian.rds"),
    WorldLex_JAP=c("http://www.lexique.org/databases/_json/WorldLex-Japanese.json", "WorldLex-Japanese.rds"),
    WorldLex_KN=c("http://www.lexique.org/databases/_json/WorldLex-Kannada.json", "WorldLex-Kannada.rds"),
    WorldLex_KZ=c("http://www.lexique.org/databases/_json/WorldLex-Kazakh.json", "WorldLex-Kazakh.rds"),
    WorldLex_KHM=c("http://www.lexique.org/databases/_json/WorldLex-Khmer.json", "WorldLex-Khmer.rds"),
    WorldLex_KR=c("http://www.lexique.org/databases/_json/WorldLex-Korean.json", "WorldLex-Korean.rds"),
    WorldLex_LV=c("http://www.lexique.org/databases/_json/WorldLex-Latvian.json", "WorldLex-Latvian.rds"),
    WorldLex_LIT=c("http://www.lexique.org/databases/_json/WorldLex-Lithuanian.json", "WorldLex-Lithuanian.rds"),
    WorldLex_MK=c("http://www.lexique.org/databases/_json/WorldLex-Macedonian.json", "WorldLex-Macedonian.rds"),
    WorldLex_ML=c("http://www.lexique.org/databases/_json/WorldLex-Malayalam.json", "WorldLex-Malayalam.rds"),
    WorldLex_MY=c("http://www.lexique.org/databases/_json/WorldLex-Malaysian.json", "WorldLex-Malaysian.rds"),
    WorldLex_MN=c("http://www.lexique.org/databases/_json/WorldLex-Mongolian.json", "WorldLex-Mongolian.rds"),
    WorldLex_NEP=c("http://www.lexique.org/databases/_json/WorldLex-Nepali.json", "WorldLex-Nepali.rds"),
    WorldLex_NOB=c("http://www.lexique.org/databases/_json/WorldLex-Norwegian.json", "WorldLex-Norwegian.rds"),
    WorldLex_PER=c("http://www.lexique.org/databases/_json/WorldLex-Persian.json", "WorldLex-Persian.rds"),
    WorldLex_PL=c("http://www.lexique.org/databases/_json/WorldLex-Polish.json", "WorldLex-Polish.rds"),
    WorldLex_POR_BR=c("http://www.lexique.org/databases/_json/WorldLex-Portuguese-Brazil.json", "WorldLex-Portuguese-Brazil.rds"),
    WorldLex_POR_EU=c("http://www.lexique.org/databases/_json/WorldLex-Portuguese-Europe.json", "WorldLex-Portuguese-Europe.rds"),
    WorldLex_PAN=c("http://www.lexique.org/databases/_json/WorldLex-Punjabi.json", "WorldLex-Punjabi.rds"),
    WorldLex_RO=c("http://www.lexique.org/databases/_json/WorldLex-Romanian.json", "WorldLex-Romanian.rds"),
    WorldLex_RU=c("http://www.lexique.org/databases/_json/WorldLex-Russian.json", "WorldLex-Russian.rds"),
    WorldLex_SER=c("http://www.lexique.org/databases/_json/WorldLex-Serbian.json", "WorldLex-Serbian.rds"),
    WorldLex_SIN=c("http://www.lexique.org/databases/_json/WorldLex-Sinhala.json", "WorldLex-Sinhala.rds"),
    WorldLex_SK=c("http://www.lexique.org/databases/_json/WorldLex-Slovak.json", "WorldLex-Slovak.rds"),
    WorldLex_SL=c("http://www.lexique.org/databases/_json/WorldLex-Slovenian.json", "WorldLex-Slovenian.rds"),
    WorldLex_ES_SA=c("http://www.lexique.org/databases/_json/WorldLex-Spanish-South-America.json", "WorldLex-Spanish-South-America.rds"),
    WorldLex_ES=c("http://www.lexique.org/databases/_json/WorldLex-Spanish-Spain.json", "WorldLex-Spanish-Spain.rds"),
    WorldLex_SWA=c("http://www.lexique.org/databases/_json/WorldLex-Swahili.json", "WorldLex-Swahili.rds"),
    WorldLex_SWE=c("http://www.lexique.org/databases/_json/WorldLex-Swedish.json", "WorldLex-Swedish.rds"),
    WorldLex_TGL=c("http://www.lexique.org/databases/_json/WorldLex-Tagalog.json", "WorldLex-Tagalog.rds"),
    WorldLex_TA=c("http://www.lexique.org/databases/_json/WorldLex-Tamil.json", "WorldLex-Tamil.rds"),
    WorldLex_TEL=c("http://www.lexique.org/databases/_json/WorldLex-Telugu.json", "WorldLex-Telugu.rds"),
    WorldLex_TUR=c("http://www.lexique.org/databases/_json/WorldLex-Turkish.json", "WorldLex-Turkish.rds"),
    WorldLex_UK=c("http://www.lexique.org/databases/_json/WorldLex-Ukrainian.json", "WorldLex-Ukrainian.rds"),
    WorldLex_URD=c("http://www.lexique.org/databases/_json/WorldLex-Urdu.json", "WorldLex-Urdu.rds"),
    WorldLex_UZ=c("http://www.lexique.org/databases/_json/WorldLex-Uzbek.json", "WorldLex-Uzbek.rds"),
    WorldLex_VIE=c("http://www.lexique.org/databases/_json/WorldLex-Vietnamese.json", "WorldLex-Vietnamese.rds"),
    WorldLex_CY=c("http://www.lexique.org/databases/_json/WorldLex-Welsh.json", "WorldLex-Welsh.rds")
    )


get_datasets <- function(listofdatasets, locations)
  # returns the local locations of datasets listed in listdatasets (downloading them from the internet if needed)
  # Example:
  #    get_datasets(c('Lexique3', 'Voisins', 'Anagrammes'), locations)
{
    locs = list()
    for (name in listofdatasets)
        locs = append(locs, get_dataset_from_json(locations[[name]][1],locations[[name]][2]))
    names(locs) = listofdatasets
    return(locs)
}



get_all_datasets <- function(locations)
   # download all the datasets listed in location (only oif not already downloaded)
{
    return(get_datasets(names(locations), locations))
}



load_rds <- function(list_rds)
  # load in memory the rds files listed in list_rds, in variables with the names matching names(list_rds)
{
    for (n in names(list_rds))
    {
        warning(paste('Loading ', n, ' from ', list_rds[[n]]))
        assign(n, readRDS(list_rds[[n]]), envir= .GlobalEnv)
    }
}



##########################################################################################
# No: the following functions should be obsolete now that there is `get_datasets` `


default_remote <-
  "https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/_json/"

lexique_remote <-
  "http://www.lexique.org/databases/_json"


get_lexique383_rds <- function()

{
  readRDS(get_dataset_from_json(paste(lexique_remote, "Lexique383.json", sep="/"),
                                "Lexique383.rds"))
}


get_worldlex.french_rds <- function()
{
  readRDS(get_dataset_from_json(paste(lexique_remote, 'WorldLex-French.json', sep='/'),
                                "WorldLex_FR.rds"))
}


get_worldlex.english_rds <- function()
{
  readRDS(get_dataset_from_json(paste(lexique_remote, 'WorldLex-English.json', sep='/'),
                                "WorldLex_EN.rds"))
}

get_subtlex.us_rds <- function()
{
  readRDS(get_dataset_from_json(paste(lexique_remote, 'SUBTLEX-US.json', sep='/'),
                                "SUBTLEX-us.rds"))
}

get_aoa32_rds <- function()
{
    readRDS(get_dataset_from_json(paste(lexique_remote, 'AoA-32lang.json', sep='/'),
                                  "AoA-32lang.rds"))
}


################################################################################

# Usage:
# source('https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/fetch_datasets.R')
# lexique <- get_lexique382()
#  or
# uscorpus <- readRDS(fetch_dataset('SUBTLEX-US-corpus', format='rds')$datatables[[1]])


## OBSOLETE:

## fetch_dataset <-
##   function(dataset_id,
##            location = default_remote,
##            filename = NULL,
##            format = NULL)
##     # download, only if needed, a dataset from openlexicon databases
##     # returns a list with information about the dataset and a list of local filenames containing the datatables):
##     ## list(name=dataset_id,
##     ##      datatables=tables,
##     ##      description=description,
##     ##      readme=readme,
##     ##      website=website)
##   {
##     destname <- ''

##     json_file <- paste(location, dataset_id, '.json', sep = "")

##     json_data <- fromJSON(file = json_file)
##     description <- json_data$description
##     readme <- json_data$readme
##     website <- json_data$website
##     language <- json_data$tag[1]
##     mandatory_columns <- json_data$mandatory_columns

##     tables = list()
##     for (u in json_data$urls)
##     {
##       fname <- basename(u$url)

##       if (!is.null(filename) && (filename != fname))
##         next  # skip this file

##       if (!is.null(format) &&
##           tools::file_ext(fname) != format)
##         # check if format (extension) matches
##         next  # skip this file

##       destname <- file.path(get_data.home(), fname)
##       warning(paste("Downloading in ", destname))

##       if (!file.exists(destname))
##       {
##         download.file(u$url, destname, mode = 'wb')
##         if (md5sum(destname) != u$md5sum)
##         {
##           warning(
##             "Something is wrong: the md5sums don't match. Either the upstream files are inconsistent or someone is messing with your internet connection."
##           )
##         } else
##         {
##           print(paste("File", destname, "downloaded without issue."))
##           tables <- append(tables, destname)
##         }
##       }  else
##         # The local file exists
##       {
##         if (md5sum(destname) != u$md5sum) {
##           warning(
##             paste(
##               "the md5 sum of your local file",
##               destname,
##               md5sum(destname),
##               "doesn't match the distant version",
##               u$md5sum,
##               ". Aborting. Delete the local file if necessary"
##             )
##           )
##         }
##         else
##         {
##           warning(paste(
##             "You already have the file",
##             destname,
##             "which is up to date."
##           ))
##           tables <- append(tables, destname)
##         }
##       }
##     }
##     if (length(tables) == 0)
##     {
##       warning("could not find a file with a matching format")
##     }
##     list(
##       name = dataset_id,
##       datatables = tables,
##       description = description,
##       readme = readme,
##       language = language,
##       website = website,
##       mandatory_columns=mandatory_columns
##     )
##   }
