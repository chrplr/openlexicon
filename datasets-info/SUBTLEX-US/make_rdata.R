#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:32:56 christophe@pallier.org>

require(readr)

subtlexus <- read_delim('SUBTLEXus74286wordstextversion.tsv', delim='\t')
save(subtlexus, file='SUBTLEXus.RData')


