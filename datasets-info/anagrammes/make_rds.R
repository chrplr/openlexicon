#! /usr/bin/env Rscript
# Time-stamp: <2019-05-04 14:05:39 christophe@pallier.org>

require(readr)

ana <- read_delim('anagrammes.txt', delim='\t')
saveRDS(ana, file='Anagrammes.rds')

