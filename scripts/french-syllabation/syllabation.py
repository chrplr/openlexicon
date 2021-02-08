#! /usr/bin/env python3
# Time-stamp: <2020-11-26 15:16:26 christophe@pallier.org>

"""
This script syllabifies words
"""

#  Note: This script is the translation to python of an awk script that I wrote for my Phd disseration in 1993.


import re
import fileinput


phonetic_alphabet = "Brulex"

if phonetic_alphabet == "Brulex":
    V = "[aiouyîâêôû^eEéAO_]"; # vowels
    C = "[ptkbdgfs/vzjmnN£]"; # consonants except liquids & semivowels
    C1 = "[pkbgfs/vzj]";
    L = "[lR]"; # liquids 
    Y = "[ïüÿ]"; # semi-vowels 
    X = "[ptkbdgfs/vzjmnN£xlRïüÿ]"; # all consonants 

if phonetic_alphabet == "LAIPTTS":
    V = "[iYeE2591a@oO§uy*]";   # Vowels
    C = "[pbmfvtdnNkgszxSZGh]";  # Consonants except liquids & semivowels
    C1 = "[pkbgfsSvzZ]";
    L = "[lR]"; # liquids
    Y = "[j8w]"; # semi-vowels
    X = "[pbmfvtdnNkgszSZGlRrhxGj8w]";   # all consonants, including semivowels



def syllabify(word):
    w = word
    w = re.sub(f'({V})({V})', r'\1-\2', w)
    w = re.sub(f'({V})({X}{V})', r'\1-\2', w)
    w = re.sub(f'({V}{Y})({Y}{V})', r'\1-\2', w)
    w = re.sub(f'({V})({C}{V}{Y})', r'\1-\2', w)
    w = re.sub(f'({V})({L}{Y}{V})', r'\1-\2', w)
    w = re.sub(f'({V})([td]R{V})', r'\1-\2', w)
    w = re.sub(f'({V})({C1}{L}{V})', r'\1-\2', w)
    w = re.sub(f'({V})({X}{X}{V})', r'\1-\2', w)
    w = re.sub(f'({V})({X}{X}{X}{V})', r'\1-\2', w)
    w = re.sub(f'({V})({X}{X}{X}{X}{V})', r'\1-\2', w)
    w = re.sub(f'({V})({X}{X}{X}{X}{X}{V})', r'\1-\2', w)
    return w

# TODO:
# suppress the final schwa (^) in some multisyllabic words
# notr^ -> notR
# ar-bR^   =>  aRbR
# b=gensub(/-([^-]+)\^$/,"\\1",1,a) ;
#   if (b!=a) { # there is a schwa to delete
#     a=b; 
#     $phons=substr($phons,1,length($phons)-1);
#     n--;
#       }
# # meme chose quand schwa='*'
#   b=gensub(/-([^-]+)\*$/,"\\1",1,a) ;  
#   if (b!=a) { # there is a schwa to delete
#     a=b; 
#     $phons=substr($phons,1,length($phons)-1);
#     n--;
#       }


if __name__ == '__main__':
    for line in fileinput.input():
        print(line + '\t' + syllabify(line))
