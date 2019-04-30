#! /usr/bin/env Rscript
# convert the tsv files in `databases` into R dataframes and save them in.rds format in the `rdata` folder
# Time-stamp: <2019-04-25 11:35:20 christophe@pallier.org>

require(readr)

gougenheim <- read_delim('gougenheim.tsv', delim='\t')
saveRDS(gougenheim, file='gougenheim.rds')

