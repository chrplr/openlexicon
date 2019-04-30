#! /usr/bin/env Rscript
# Time-stamp: <2019-04-30 10:05:20 christophe@pallier.org>


require("rjson")
require("tools") # Required for md5sum

#  Download openlexicon's datasets from json file using 'dafter' syntax (see https://github.com/vinzeebreak/dafter/)

### Example of a json file:

## {
##   "name": "lexique3",
##   "urls": [
##     {
##       "url": "http://www.lexique.org/databases/Lexique382/Lexique382.tsv",
##       "bytes": 25850842,
##       "md5sum": "28d18d7ac1464d09e379f30995d9d605"
##     }
##   ],
##   "type": "tsv",
##   "tags": ["french", "frequencies"],
##   "description": "Lexique382 est une base de données lexicales du français qui fournit pour ~140000 mots du français: les représentations orthographiques et phonémiques, les lemmes associés, la syllabation, la catégorie grammaticale, le genre et le nombre, les fréquences dans un corpus de livres et dans un corpus de sous-titres de filems, etc.",
##   "readme": "http://chrplr.github.io/openlexicon/datasets-info/Lexique382/README"
## }


# Usage:
# fetch_dataset('Lexique382')

# remote dir containing the json files describing the datasets, use *raw* github
default_remote <- "https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/"

fetch_dataset <- function(dataset_id, location=default_remote, format=NULL)
{
    destname <- ''

    json_file <- paste(location, dataset_id, '.json', sep="")

    json_data <- fromJSON(file=json_file)
    description <- json_data$description
    readme <- json_data$readme

    for (u in json_data$urls)
    {
        fname <- basename(u$url)
        print(fname)
        if (!is.null(format) && tools::file_ext(fname) != format)   # check if format (extension) matches
                break  # skip this file

        destname <- file.path(data.home, fname)
        print(destname)
        if (!file.exists(destname))
        {
            download.file(u$url, destname)
            if (md5sum(destname) != u$md5sum)
            {
              warning("Something is wrong: the md5sums don't match. Either the upstream files are inconsistent or someone is messing with your internet connection.")
            } else
            {
              print("File downloaded without issue.")
            }
        }  else
        {
            if (md5sum(destname) != u$md5sum) {
                warning("Your local file doesn't match the distant version. Aborting.")
            }
            else
            {
              warning('You already have the file and seem up to date.')
            }
        }
    }
    list(name=dataset_id,
         datatable=destname,
         description=description,
         readme=readme)
}

get_datahome <- function()
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


