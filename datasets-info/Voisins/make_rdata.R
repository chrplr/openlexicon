#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:02:46 christophe@pallier.org>

require(readr)

voisins <- read_delim('voisins.txt', delim='\t')
save(voisins, file='Voisins.RData')

