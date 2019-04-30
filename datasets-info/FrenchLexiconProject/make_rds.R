#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 10:56:08 christophe@pallier.org>

require(readr)

flp.words <- read_csv('FLP.words.csv')
flp.pseudowords <- read_csv('FLP.pseudowords.csv')

saveRDS(flp.words, file='flp-words.rds')
saveRDS(flp.pseudowords, file='flp-pseudowords.rds')

