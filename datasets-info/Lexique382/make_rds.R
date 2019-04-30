#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 10:52:09 christophe@pallier.org>

require(readr)

lexique <- read_delim('Lexique382.tsv', delim='\t')
lexique$nblettres <- as.integer(lexique$nblettres)
lexique$nbphons <- as.integer(lexique$nbphons)
lexique$nbsyll <- as.integer(lexique$nbsyll)
lexique$voisorth <- as.integer(lexique$voisorth)
lexique$voisphon <- as.integer(lexique$voisphon)
lexique$nbhomogr <- as.integer(lexique$nbhomogr)
lexique$nbhomoph <- as.integer(lexique$nbhomoph)
lexique$islem <- as.integer(lexique$islem)
saveRDS(lexique, file='Lexique382.rds')

