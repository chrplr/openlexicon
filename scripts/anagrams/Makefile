# Calcul les anagrammes des mots français listés dans Lexique382
# Time-stamp: <2019-05-04 15:04:21 christophe@pallier.org>

DICO=~/9_data/databases/Liste-de-mots-francais-Gutenberg/liste.de.mots.francais.frgut.txt

anagrammes.txt: ${DICO}
	cut -f 1 ${DICO} | python anagrams.py | sort > $@
