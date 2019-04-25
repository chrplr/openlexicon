#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 10:57:29 christophe@pallier.org>

require(readr)

megalex.auditory <- read_delim('Megalex-items-auditory.tsv', delim='\t')
save(megalex.auditory, file='Megalex-auditory.RData')

megalex.visual <- read_delim('Megalex-items-visual.tsv', delim='\t')
save(megalex.visual, file='Megalex-visual.RData')

