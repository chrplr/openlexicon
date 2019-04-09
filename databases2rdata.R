#! /usr/bin/env Rscript
# convert the tsv files in `databases` into R dataframes and save them in RData format in the `rdata` folder
# Time-stamp: <2019-04-09 11:29:43 christophe@pallier.org>


require(readr)

brulex <- read_csv('databases/Brulex/Brulex-utf8.csv')
save(brulex, file='rdata/Brulex.RData')

lexique <- read_delim('databases/Lexique382/Lexique382.tsv', delim='\t')
save(lexique, file='rdata/Lexique382.RData')

flp.words <- read_csv('databases/FrenchLexiconProject/FLP.words.csv')
flp.pseudowords <- read_csv('databases/FrenchLexiconProject/FLP.pseudowords.csv')

save(flp.words, file='rdata/flp-words.RData')
save(flp.pseudowords, file='rdata/flp-pseudowords.RData')

frantext <- read_delim('databases/Frantext/Frantext.tsv', delim='\t', na='', quote='')
save(frantext, file='rdata/Frantext.RData')

images400 <- read_delim('databases/images400/images400.tsv', delim='\t')
save(images400, file='rdata/images400.RData')

gougenheim <- read_delim('databases/Gougenheim100/gougenheim.tsv', delim='\t')
save(gougenheim, file='rdata/gougenheim.RData')

chronolex <- read_delim('databases/Chronolex/Chronolex.tsv', delim='\t')
save(chronolex, file='rdata/Chronolex.RData')

subtlexus <- read_delim('databases/SUBTLEX-USSUBTLEXus74286wordstextversion.tsv', delim='\t')
save(subtlexus, file='rdata/SUBTLEXus.RData')

megalex.auditory <- read_delim('databases/Megalex/Megalex-items-auditory.tsv', delim='\t')
save(megalex.auditory, file='rdata/Megalex-auditory.RData')

megalex.visual <- read_delim('databases/Megalex/Megalex-items-visual.tsv', delim='\t')
save(megalex.visual, file='rdata/Megalex-visual.RData')

voisins <- read_delim('databases/Voisins/voisins.txt', delim='\t')
save(voisins, file='rdata/Voisins.RData')

frfam <- read_delim('databases/Robert-Dorot-Mathey/Fr-familiarity660.tsv', delim='\t')
save(frfam, file='rdata/FrFam.RData')

