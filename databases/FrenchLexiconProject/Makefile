# Time-stamp: <03-Feb-2010 18:11:52 pallier>

chronolex.zip: chronolex.words.csv chronolex.pseudowords.csv  
	zip chronolex.zip $^

chronolex.words.csv: process.words.R results.utf8.txt lexcfreq.csv 
	R CMD BATCH process.words.R

chronolex.pseudowords.csv: process.pseudowords.R results.utf8.txt
	R CMD BATCH process.pseudowords.R


.PHONY : clean srcfile

srcfile:
	zip chronolex.src.zip results.utf8.txt lexcfreq.csv process.words.R process.pseudowords.R Makefile README.txt chronolex.words.csv chronolex.pseudowords.csv

clean:
	rm *.pdf *.Rout chronolex*.csv chronolex.zip
