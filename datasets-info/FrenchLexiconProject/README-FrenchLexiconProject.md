# French Lexicon Project

The French Lexicon Project (FLP) provides lexical decision data for 38,840 French words and the same number of nonwords. The full data represents 1942000 reactions times from 975 participants.

Tables: [FLP.words.csv](http://www.lexique.org/databases/FrenchLexiconProject//FLP.words.csv) and 
        [FLP.pseudowords.csv](http://www.lexique.org/databases/FrenchLexiconProject/FLP.pseudowords.csv)

Web site: <https://sites.google.com/site/frenchlexicon/>

Publication:

Ferrand, Ludovic, Boris New, Marc Brysbaert, Emmanuel Keuleers, Patrick Bonin, Alain Méot, Maria Augustinova, and Christophe Pallier. 2010. The French Lexicon Project: Lexical Decision Data for 38,840 French Words and 38,840 Pseudowords. _Behavior Research Methods_ 42 (2): 488–96. https://doi.org/10.3758/BRM.42.2.488. [pdf](Ferrand\ et\ al.\ -\ 2010\ -\ The\ French\ Lexicon\ Project\ Lexical\ decision\ data\ .pdf)


--------------


Running `make` executes the commands in `Makefile`: the scripts [process.words.R](process.words.R) and [process.pseudowords.R](process.pseudowords.R) compute the by-item averages from the [raw lexical decision time](http://www.lexique.org/databases/FrenchLexiconProject/results.utf8.csv) data and produce the final tables.

Intermediate `*.csv` files contain the raw data with an additional
column ('keep') signaling the items that are within the subject'
mean+-3stddev range. 

Christophe Pallier

LICENSE CC BY-SA 4.0

[Online access](http://www.lexique.org/shiny/openlexique) | [Openlexicon](http://chrplr.github.io/openlexicon)
