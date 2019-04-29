# To be executed on the server that contains the datasets' sources files 
# Time-stamp: <2019-04-25 13:12:38 christophe@pallier.org>

rdatas:
# create RData files
	for f in */make_rdata.R; do cd $$( dirname $$f ); ./make_rdata.R; cd ..; done
# link them in rdata
	mkdir -p rdata; cd rdata; for f in ../*/*.RData; do ln -s $$f ./; done

README2.md:
	rm -f README2.md
	for f in */*.json; do ./json2md $$f >> README2.md; done
