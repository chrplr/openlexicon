#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:31:36 christophe@pallier.org>

require(readr)

images400 <- read_delim('images400.tsv', delim='\t')
saveRDS(images400, file='images400.rds')

