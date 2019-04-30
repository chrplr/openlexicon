#! /usr/bin/env Rscript
# convert the tsv files in `databases` into R dataframes and save them in rds format
# Time-stamp: <2019-04-30 13:03:41 christophe@pallier.org>

require(readr)

frantext <- read_delim('Frantext.tsv', delim='\t', na='', quote='')
saveRDS(frantext, file='Frantext.rds')
