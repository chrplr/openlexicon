#! /usr/bin/env Rscript
# Time-stamp: <2019-11-26 08:00:36 christophe@pallier.org>

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
      mandatory_columns = json_data$mandatory_columns
    )
  )
}


get_dataset_from_json <- function(json_url, filename)
  # download (only if needed), the dataset 'filename' indicated from the json description file
  # returns the path to the local version of the dataset
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



get_all_datasets <- function(list_url)
  # list_url points to a tsv file with two columns. Each row contains a json_url and a filename 
{
  bases = read.table(list_url, sep='\t')
  for (i in 1:nrow(bases))
     get_dataset_from_json(bases[i, 1], bases[i, 2])
}


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


##########################################################################################
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

get_subtlex.us <- function()
{
  readRDS(get_dataset_from_json(paste(lexique_remote, 'SUBTLEX-US.json', sep='/'),
                                "SUBTLEX-us.rds"))
}

get_aoa32 <- function()
{
  info <-  fetch_dataset('AoA-32lang', format = 'tsv')
  read.table(info$datatables[[1]], header = TRUE, sep = '\t')
}
