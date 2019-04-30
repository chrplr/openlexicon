#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:04:45 christophe@pallier.org>

require(readr)

frfam <- read_delim('Fr-familiarity660.tsv', delim='\t')
saveRDS(frfam, file='FrFam.rds')

