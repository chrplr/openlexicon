# Time-stamp: <2019-07-18 11:31:54 christophe@pallier.org>

JSONFILES=$(wildcard _json/*.json)

list-of-datasets.md: $(JSONFILES)
	python3 json2md $^ > list-of-datasets.md

rds:
# create rds files (R binary format) from raw tsv files (must be run on the server)
	for f in */make_rds.R; do cd $$( dirname $$f ); Rscript --vanilla ./make_rds.R; cd ..; done
# link them in rds
	mkdir -p rds; find -type f -name '*.rds' -exec do ln -s '{}' rds ';'
