#! /usr/bin/env Rscript
# Time-stamp: <2019-03-30 15:46:34 christophe@pallier.org>

# select some items from the lexique382 table

items <- c('bateau', 'avion', 'maison', 'arbre')

require(readr)

lex <- read_delim("http://www.lexique.org:81/databases/Lexique382/Lexique382.tsv", delim='\t')

selection <- subset(lex, ortho %in% items)

head(selection)

write_tsv(selection, 'selection.tsv')



