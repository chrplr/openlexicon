#! /usr/bin/env python3
# Time-stamp: <2019-05-04 14:45:09 christophe@pallier.org>
# License: GPL-2

"""
Input: a list with *one* word per line on the standard input

Output: all anagrams on the standard output 
"""

import sys

dictionary = sys.stdin.readlines()

# 'ana' will contain lists of anagrams, indexed by their letters
ana = {}

for word in dictionary:
    w = word.rstrip()
    # the key is the sorted letters from 'w'
    l = list(w)  # make a list from the characters in 'w'
    l.sort()     # and sort them
    key = "".join(l)  # to create 'key'

    # insert w in the list indexed by 'key'
    if key in ana.keys():
        if w not in ana[key]:
            ana[key].append( w )
    else:
        ana[key] = [ w ]

# prints the anagrams
liste = []

for k in ana.keys():
    if len(ana[k]) > 1:
        ana[k].sort()
        liste.append(" ".join(ana[k]))

liste.sort()

for w in set(liste):
     print(w)




