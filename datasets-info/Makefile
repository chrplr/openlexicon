# Time-stamp: <2019-04-30 13:02:06 christophe@pallier.org>

JSONFILES=$(wildcard *.json)

list-of-datasets.md: $(JSONFILES)
	./json2md *.json > list-of-datasets.md

rdatas:
# create rds files (R binary format) from raw tsv files (must be run on the server)
	for f in */make_rds.R; do cd $$( dirname $$f ); ./make_rds.R; cd ..; done
# link them in rdata
	mkdir -p rds; cd rds; for f in ../*/*.rds; do ln -s $$f ./; done
