#! /usr/bin/env Rscript
# convert the tsv files in `databases` into R dataframes and save them in RData format in the `rdata` folder
# Time-stamp: <2019-04-13 14:39:42 christophe@pallier.org>


require(readr)

brulex <- read_csv('Brulex/Brulex-utf8.csv')
save(brulex, file='rdata/Brulex.RData')

lexique <- read_delim('Lexique382/Lexique382.tsv', delim='\t')
lexique$nblettres <- as.integer(lexique$nblettres)
lexique$nbphons <- as.integer(lexique$nbphons)
lexique$nbsyll <- as.integer(lexique$nbsyll)
lexique$voisorth <- as.integer(lexique$voisorth)
lexique$voisphon <- as.integer(lexique$voisphon)
lexique$nbhomogr <- as.integer(lexique$nbhomogr)
lexique$nbhomoph <- as.integer(lexique$nbhomoph)
lexique$islem <- as.integer(lexique$islem)
save(lexique, file='rdata/Lexique382.RData')

flp.words <- read_csv('FrenchLexiconProject/FLP.words.csv')
flp.pseudowords <- read_csv('FrenchLexiconProject/FLP.pseudowords.csv')

save(flp.words, file='rdata/flp-words.RData')
save(flp.pseudowords, file='rdata/flp-pseudowords.RData')

frantext <- read_delim('Frantext/Frantext.tsv', delim='\t', na='', quote='')
save(frantext, file='rdata/Frantext.RData')

images400 <- read_delim('images400/images400.tsv', delim='\t')
save(images400, file='rdata/images400.RData')

gougenheim <- read_delim('Gougenheim100/gougenheim.tsv', delim='\t')
save(gougenheim, file='rdata/gougenheim.RData')

chronolex <- read_delim('Chronolex/Chronolex.tsv', delim='\t')
save(chronolex, file='rdata/Chronolex.RData')

subtlexus <- read_delim('SUBTLEX-US/SUBTLEXus74286wordstextversion.tsv', delim='\t')
save(subtlexus, file='rdata/SUBTLEXus.RData')

megalex.auditory <- read_delim('Megalex/Megalex-items-auditory.tsv', delim='\t')
save(megalex.auditory, file='rdata/Megalex-auditory.RData')

megalex.visual <- read_delim('Megalex/Megalex-items-visual.tsv', delim='\t')
save(megalex.visual, file='rdata/Megalex-visual.RData')

voisins <- read_delim('Voisins/voisins.txt', delim='\t')
save(voisins, file='rdata/Voisins.RData')

frfam <- read_delim('Robert-Dorot-Mathey/Fr-familiarity660.tsv', delim='\t')
save(frfam, file='rdata/FrFam.RData')

