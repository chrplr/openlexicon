#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 10:52:09 christophe@pallier.org>

require(readr)

saveRDS(read_delim('./Lexique-Infra 1.00/Lexique.Infra.Corresp.Graphème.Phonème.tsv', delim='\t'), 
        file='Lexique.Infra.Corresp.Graphème.Phonème.rds')

saveRDS(read_delim('./Lexique-Infra 1.00/Lexique.Infra.Freq.Let.Bigr.Trig.Syl.Phon.Biph.tsv', delim='\t'),
        file='Lexique.Infra.Freq.Let.Bigr.Trig.Syl.Phon.Biph.rds')

