# Makefile to create syllabified versions of brulex and lexique
# pallier@lscp.ehess.fr --- 17 nov. 1999 (last update: 15 may 2004)

all: brulex_syll.txt lexique260_graph_syll.txt
test: tests.txt

brulex_syll.txt: brulex.txt syllabation.awk
	gawk -vphons=2 -vcode=brulex -f syllabation.awk brulex.txt >$@

lexique260_graph_syll.txt: lexique260_graph.txt syllabation.awk
	gawk -vphons=2 -f syllabation.awk lexique260_graph.txt >$@

tests.txt: mots_test.txt brulex_syll.txt lexique260_graph_syll.txt
	grep -w -F -f mots_test.txt brulex_syll.txt >test_brulex.txt
	grep -w -F -f mots_test.txt lexique260_graph_syll.txt >test_lexique.txt
	join test_brulex.txt test_lexique.txt >tests.txt





















