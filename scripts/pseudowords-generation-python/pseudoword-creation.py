#! /usr/bin/env python3
# Time-stamp: <2020-02-07 12:35:39 christophe@pallier.org>

import os
import os.path as op
import numpy as np
import pandas as pd
import random

# location of Lexique383.tsv file:
LEXIQUE = op.join(os.getenv('HOME'), 'openlexicon_datasets/Lexique383.tsv')


lexique = pd.read_csv(LEXIQUE, sep='\t')

all_words = set(lexique.ortho)

names6 = lexique.loc[np.logical_and(lexique.nblettres==6 ,
                                    lexique.cgram=='NOM')]


# Transposition de lettres : parler à palrer

def transpose_letters(w):
    return set([w[:i-1] + w[i] + w[i-1] + w[i+1:] for i in range(1, len(w))])


for w in names6.ortho:
    print(w, ':', transpose_letters(w) - all_words)



# Addition/suppression de lettres : parler à paler  ou  pariler
def add_letters_at_random_locations(w, N=50):
    ALPHABET = 'abcdefghijklmnopqrstuvwxyzàâæçèéêëîïôùûüÿœ'
    # we could attribute a weight to each letter for the random selection
    pw = []
    for _ in range(N):
        i = random.randrange(len(w))
        pw.append(w[:i] + random.choice(ALPHABET) + w[i:])
    # Note: we should probably add a filter keeping only pseudowords containing possible bi or trigrams
    return set(pw)

for w in names6.ortho:
    print(w, ':', add_letters_at_random_locations(w, 5) - all_words)



# Inversion en miroir :  claque à clapue



# Pseudohomophones (erreurs de régularisation) : tasse à tase; bague à bage


# 12 de chaque sorte (avec 2x6 longueurs entre 3 et 8)

# Vérifier qu’ils ne sont pas dans le lexique !



        
