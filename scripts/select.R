#! /usr/bin/env Rscript
# Time-stamp: <2019-04-05 07:23:59 christophe@pallier.org>

# select some items from the lexique382 table

items <- c('bateau', 'avion', 'maison', 'arbre')

require(readr)  # vous devrez peut-être l'installer avec `install.packages('readr')`

lex <- read_delim("../databases/Lexique382/Lexique382.tsv.gz", delim="\t")
# lex <- read_delim("http://www.lexique.org/shiny/databases/Lexique382/Lexique382.tsv", delim='\t')

selection <- subset(lex, ortho %in% items)

head(selection)

write_tsv(selection, 'selection.tsv')

################
require(tidyverse)
require(stringr)

# liste les mots qui finissent par "ion"

lex$ortho %>% str_subset("ion$")

# liste les mots qui contiennent trois voyelles successives

lex$ortho %>% str_subset('[aeiouy][aeiouy][aeiouy]')

# trouve les mots qui contiennent des groupes de 3 lettres répétés
lex$ortho %>% str_subset("(...)\\1")

# voir https://stringr.tidyverse.org/articles/regular-expressions.html
