#! /usr/bin/env Rscript
# convert the tsv files in `databases` into R dataframes and save them in RData format in the `rdata` folder
# Time-stamp: <2019-04-25 11:03:55 christophe@pallier.org>

require(readr)

frantext <- read_delim('Frantext.tsv', delim='\t', na='', quote='')
save(frantext, file='Frantext.RData')
