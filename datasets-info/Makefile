# Time-stamp: <2019-04-30 12:29:19 christophe@pallier.org>

JSONFILES=$(wildcard *.json)

list-of-datasets.md: $(JSONFILES)
	./json2md *.json > list-of-datasets.md

rdatas:
# create RData files from raw tsv files (must be run on the server)
	for f in */make_rdata.R; do cd $$( dirname $$f ); ./make_rdata.R; cd ..; done
# link them in rdata
	mkdir -p rdata; cd rdata; for f in ../*/*.RData; do ln -s $$f ./; done
