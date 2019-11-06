#! /usr/bin/env Rscript
# Time-stamp: <2019-11-06 13:34:05 christophe@pallier.org>


require("rjson")
require("tools") # Required for md5sum

#  Download openlexicon's datasets from a json file using 'dafter' syntax (see https://github.com/vinzeebreak/dafter/)

# Remote dir containing the json files describing the datasets, use *raw* github
default_remote <- "https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/_json/"


# Usage:
# source('https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/fetch_datasets.R')
# lexique <- get_lexique382()
#  or
# uscorpus <- readRDS(fetch_dataset('SUBTLEX-US-corpus', format='rds')$datatables[[1]])




fetch_dataset <- function(dataset_id, location=default_remote, filename=NULL, format=NULL)
# download, only if needed, a dataset from openlexicon databases
# returns a list with information about the dataset and a list of local filenames containing the datatables):
## list(name=dataset_id,
##      datatables=tables,
##      description=description,
##      readme=readme,
##      website=website)
{
    destname <- ''

    json_file <- paste(location, dataset_id, '.json', sep="")

    json_data <- fromJSON(file=json_file)
    description <- json_data$description
    readme <- json_data$readme
    website <- json_data$website

    tables = list()
    for (u in json_data$urls)
    {
        fname <- basename(u$url)

        if (!is.null(filename) && (filename != fname))
            next  # skip this file

        if (!is.null(format) && tools::file_ext(fname) != format)   # check if format (extension) matches
            next  # skip this file

        destname <- file.path(get_data.home(), fname)
        warning(paste("Downloading in ", destname))

        if (!file.exists(destname))
        {
            download.file(u$url, destname, mode='wb')
            if (md5sum(destname) != u$md5sum)
            {
              warning("Something is wrong: the md5sums don't match. Either the upstream files are inconsistent or someone is messing with your internet connection.")
            } else
            {
                print(paste("File", destname, "downloaded without issue."))
                tables <- append(tables, destname)
            }
        }  else  # The local file exists
        {
            if (md5sum(destname) != u$md5sum) {
                warning(paste("the md5 sum of your local file", destname, md5sum(destname), "doesn't match the distant version", u$md5sum, ". Aborting. Delete the local file if necessary"))
            }
            else
            {
                warning(paste("You already have the file", destname, "which is up to date."))
                tables <- append(tables, destname)
            }
        }
    }
    if (length(tables) == 0)
    {
        warning("could not find a file with a matching format")
    }
    list(name=dataset_id,
         datatables=tables,
         description=description,
         readme=readme,
         website=website)
}

get_data.home <- function()
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
    dir.create(data.home, showWarnings=FALSE, recursive=TRUE)
    data.home
}


get_lexique382 <- function()
{
    info <- fetch_dataset('Lexique382', format='rds')
    readRDS(info$datatables[[1]])
}

get_lexique383 <- function()
{
    info <- fetch_dataset('Lexique383', format='rds')
    readRDS(info$datatables[[1]])
}

get_lexique3 <- function()
{
    info <- fetch_dataset('Lexique383', format='rds')
    readRDS(info$datatables[[1]])
}


get_worldlex.french <- function()
{
    info <- fetch_dataset('WorldLex-French', format='rds')
    readRDS(info$datatables[[1]])
}

get_worldlex.english <- function()
{
    info <- fetch_dataset('WorldLex-English', format='rds')
    readRDS(info$datatables[[1]])
}

get_subtlex.us <- function()
{
    info <- fetch_dataset('SUBTLEX-US', format='rds')
    readRDS(info$datatables[[1]])

}

get_aoa32 <- function()
{
    info <-  fetch_dataset('AoA-32lang', format='tsv')
    read.table(info$datatables[[1]], header=TRUE, sep='\t')
}
