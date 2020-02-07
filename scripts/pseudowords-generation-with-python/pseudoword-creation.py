#! /usr/bin/env python3


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


#             Transposition de lettres : parler à palrer

def transpose_letters(w):
    return set([w[:i-1] + w[i] + w[i-1] + w[i+1:] for i in range(1, len(w))])


for w in names6.ortho:
    print(w, ':', transpose_letters(w) - all_words)



# Addition/suppression de lettres : parler à paler  ou  pariler


def add_letters_at_random_locations(w, N=50):
    ALPHABET = 'abcdefghijklmnopqrstuvwxyzàâæçèéêëîïôùûüÿœ'
    pw = []
    for _ in range(N):
        i = random.randrange(len(w))
        pw.append(w[:i] + random.choice(ALPHABET) + w[i:])
    return set(pw)



# Inversion en miroir :  claque à clapue



# Pseudohomophones (erreurs de régularisation) : tasse à tase; bague à bage

# 12 de chaque sorte (avec 2x6 longueurs entre 3 et 8)

# Vérifier qu’ils ne sont pas dans le lexique !



        
