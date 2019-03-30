#! /usr/bin/env python
# Time-stamp: <2019-03-30 15:51:27 christophe@pallier.org>

""" Exemple de sélection d'items dans la base Lexique382 """

import pandas as pd

TABLE = "../databases/Lexique382/Lexique382.tsv"

lex = pd.read_csv(TABLE, sep='\t')

lex.head()

# restreint la recherche à des mots de longueur comprises entre 5 et 8 lettres
subset = lex.loc[(lex.nblettres >= 5) & (lex.nblettres <=8)]

# separe les noms et les verbes dans deux dataframes:
noms = subset.loc[subset.cgram == 'NOM']
verbs = subset.loc[subset.cgram == 'VER']

# sectionne sur la bases de la fréquence lexicale
noms_hi = noms.loc[noms.freqlivres > 50.0]
noms_low = noms.loc[(noms.freqlivres < 10.0) & (noms.freqlivres > 1.0)]

verbs_hi = verbs.loc[verbs.freqlivres > 50.0]
verbs_low = verbs.loc[(verbs.freqlivres < 10.0) & (verbs.freqlivres > 1.0)]

# choisi des items tirés au hasard dans chacun des 4 sous-ensembles:
N = 20
noms_hi.sample(N).ortho.to_csv('nomhi.txt', index=False)
noms_low.sample(N).ortho.to_csv('nomlo.txt', index=False)
verbs_hi.sample(N).ortho.to_csv('verhi.txt', index=False)
verbs_hi.sample(N).ortho.to_csv('verlo.txt', index=False)

