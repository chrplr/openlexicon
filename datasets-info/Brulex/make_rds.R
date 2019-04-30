#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:30:35 christophe@pallier.org>

require(readr)

brulex <- read_csv('Brulex-utf8.csv')
saveRDS(brulex, file='Brulex.rds')

