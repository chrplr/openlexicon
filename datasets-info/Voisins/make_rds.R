#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:02:46 christophe@pallier.org>

require(readr)

voisins <- read_delim('voisins.txt', delim='\t')
saveRDS(voisins, file='Voisins.rds')

