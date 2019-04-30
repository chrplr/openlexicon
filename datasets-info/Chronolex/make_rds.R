#! /usr/bin/env Rscript
# convert the tsv files in `databases` into R dataframes and save them in.rds format 
# Time-stamp: <2019-04-30 13:04:14 christophe@pallier.org>

require(readr)

chronolex <- read_delim('Chronolex.tsv', delim='\t')
saveRDS(chronolex, file='Chronolex.rds')
