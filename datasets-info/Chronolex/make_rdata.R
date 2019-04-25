#! /usr/bin/env Rscript
# convert the tsv files in `databases` into R dataframes and save them in RData format in the `rdata` folder
# Time-stamp: <2019-04-25 10:58:48 christophe@pallier.org>

require(readr)

chronolex <- read_delim('Chronolex.tsv', delim='\t')
save(chronolex, file='Chronolex.RData')
