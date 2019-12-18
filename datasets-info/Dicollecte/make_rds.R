#! /usr/bin/env Rscript
# Time-stamp: <2019-11-26 15:21:12 christophe@pallier.org>

require(readr)

megalex.auditory <- read_delim('lexique-dicollecte-fr-v6.4.1.txt', delim='\t')
saveRDS(megalex.auditory, file='dicollecte.rds')

