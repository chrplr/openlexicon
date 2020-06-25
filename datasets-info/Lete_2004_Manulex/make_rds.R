#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:31:36 christophe@pallier.org>

require(readr)

images400 <- read_delim('Manulex-Lemmes.tsv', delim='\t')
saveRDS(images400, file='Manulex-Lemmes.rds')

