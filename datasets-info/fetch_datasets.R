#! /usr/bin/env Rscript
# Time-stamp: <2019-04-26 13:45:31 christophe@pallier.org>

# script to download openlexicon's datasets using dafter json syntax (see https://github.com/vinzeebreak/dafter/)

# example of usage:
# fetch_dataset('Lexique382')

require("rjson")
require("tools") # Required for md5sum

# TODO: add an option to read the json file name from the command line
# args = commandArgs(trailingOnly=TRUE)  

# localdir where datasets are saved
data.home = Sys.getenv('DATASETS')
if (data.home == "") {
  data.home <-  file.path(path.expand('~'), 'datasets')
}
dir.create(data.home, showWarnings=FALSE, recursive=TRUE)

# remote dir containing the json files describing the datasets, use *raw* github
remote <- "https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/"

fetch_dataset <- function(dataset_id)
{
    json_file <- paste(remote, dataset_id, '.json', sep="")
    print(json_file)
    json_data <- fromJSON(file=json_file)

    for (u in json_data$urls)
    {
        fname <- basename(u$url)
        destname <- file.path(data.home, fname)
        if (!file.exists(destname)) {
            download.file(u$url, destname)
            if (md5sum(destname) != u$md5sum) {
              warning("Something is wrong: the md5sums don't match. Either the upstream files are inconsistent or someone is messing with your internet connection.")
            }
            else {
              print("File downloaded without issue.")
            }
        }
        else {
            if (md5sum(destname) != u$md5sum) {
              warning("Your local file doesn't march the distant version. Aborting.")
            }
            else {
              warning('You already have the file and seem up to date.')
            }
        }
    }
}
