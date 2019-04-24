#! /usr/bin/env Rscript
# Time-stamp: <2019-04-24 21:40:10 christophe@pallier.org>

# function to download openlexicon's datasets

require("rjson")

# localdir where datasets are saved
data.home <- file.path(path.expand('~'), 'databases')
dir.create(data.home, showWarnings=FALSE, recursive=TRUE)

# remote dir containing the json files describing the datasets
remote <- "https://github.com/chrplr/openlexicon/blob/master/databases-docs/"



fetch_dataset <- function(dataset_id)
{
    json_file <- paste(remote, dataset_id, '.json')
    json_data <- fromJSON(file=json_file)

    for (u in json_data$urls)
    {
        fname <- basename(u$url)
        destname <- file.path(data.home, fname)
        if (!file.exists(destname)) {
            download.file(u$url, destname)
        }
        else {
            warning('The file \"', destname, '\" already exists. Erase it first if you want to update it')
        }
    }
}

# example:
# fetch_dataset('Lexique382')
