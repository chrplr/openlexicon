#! /usr/bin/env python3

""" Generate phonetic strings and searches for matches and non matches in [Lexique](www.lexique.org)"""

import pandas as pd

LEXIQUE = pd.read_csv('/home/cp983411/databases/Lexique382.tsv', sep='\t')

voyelles = 'aeiouy2'
consonants = 'ptkbdgfsSvzZnmlR'

CV = [ C + V for C in consonants for V in voyelles]

# find all words matching a syllable from CV
LEXIQUE[LEXIQUE.phon.isin(CV)]

# find syllables that do not match any word in Lexique
set(CV) - set(LEXIQUE.phon)
