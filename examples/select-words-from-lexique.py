#! /usr/bin/env python
# Time-stamp: <2019-03-28 08:41:59 christophe@pallier.org>

""" Exemple de sélection d'items dans la base Lexique382 """

import pandas as pd

TABLE = "../databases/Lexique382/Lexique382.tsv"

lex = pd.read_csv(TABLE, sep='\t')

lex.head()

subset = lex.loc[(lex.nblettres >= 5) & (lex.nblettres <=8)]

noms = subset.loc[subset.cgram == 'NOM']
verbs = subset.loc[subset.cgram == 'VER']

noms_hi = noms.loc[noms.freqlivres > 50.0]
noms_low = noms.loc[(noms.freqlivres < 10.0) & (noms.freqlivres > 1.0)]

verbs_hi = verbs.loc[verbs.freqlivres > 50.0]
verbs_low = verbs.loc[(verbs.freqlivres < 10.0) & (verbs.freqlivres > 1.0)]

N = 20

# sauve les items tirés au hasard
noms_hi.sample(N).ortho.to_csv('nomhi.txt', index=False)
noms_low.sample(N).ortho.to_csv('nomlo.txt', index=False)
verbs_hi.sample(N).ortho.to_csv('verhi.txt', index=False)
verbs_hi.sample(N).ortho.to_csv('verlo.txt', index=False)

