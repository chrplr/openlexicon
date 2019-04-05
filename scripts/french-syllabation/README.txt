Ce repertoire contient le script de syllabation de Brulex et de Lexique.

syllabation.pdf:  description (sommaire) des regles de syllabation
syllabation.awk:  script proprement dit
Makefile:         sur un système disposant de 'make', genere

mots_test.txt  :  liste de mots dont on veut verifier les syllabations
tests.txt      :  resultats de la syllabation (selon brulex, puis selon lexique)
Pour syllaber brulex ou lexique, il faut avoir le programme 'gawk'.
Si on aussi 'make', il suffit de taper 'make', puis 'make test'


Sinon, pour syllaber brulex.txt:


       gawk -vphons=2 -vcode=brulex -f syllabation.awk brulex.txt 


et pour syllaber lexique260_graph.txt:

	gawk -vphons=2 -f syllabation.awk lexique260_graph.txt >$@
 






