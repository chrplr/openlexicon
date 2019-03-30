#!/usr/bin/env Rscript
# Time-stamp: <2019-03-27 17:10:50 christophe@pallier.org>

# If the subdirectory "databases" does not exist,
# download the zip containing the lexical databases from Lexique server
# and unzip it

if (!file.exists("databases")) {
    download.file(url="http://37.59.55.222/databases.zip",
                  destfile="databases.zip",
                  mode = "wb")
    unzip(zipfile="databases.zip", exdir="./")
    }
