#! /usr/bin/env Rscript
# Time-stamp: <2019-05-01 10:55:00 christophe@pallier.org>

require(readr)

subtlexus <- read_delim('SUBTLEXus74286wordstextversion.tsv', delim='\t')
saveRDS(subtlexus, file='SUBTLEXus.rds')

corpus <- scan('Subtlex-US-corpus.txt.gz', what=character(), sep='\n', encoding='UTF-8', nlines=100000)
saveRDS(corpus, 'SUBTLEX-US-corpus.rds')

