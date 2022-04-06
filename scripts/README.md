# Querying and manipulating of open lexical databases

Most lexical databases consist of plain text files in `.tsv`  or `.csv` formats which can easily be imported into R using `readr::read_delim`, or into Python with `pandas.read_csv`. To open a `.tsv` or a `.csv` file with Excel, check out "[How to open a tsv file in Excel](https://rievent.zendesk.com/hc/en-us/articles/360000029172-FAQ-How-do-I-open-a-tsv-file-in-Excel-)".

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

  - [Selecting lexical items using R](#selecting-lexical-items-using-r)
  - [Selecting lexical items with Python](#selecting-lexical-items-with-python)
  - [Pseudoword creations](#pseudoword-creations)
  - [French syllabation](#french-syllabation)

<!-- markdown-toc end -->


## Selecting lexical items using R ##

To extract the rows of Lexique382.tsv corresponding to a list of words:


    items <- c('bateau', 'avion', 'maison', 'arbre')

    require(readr)

    lex <- read_delim("http://www.lexique.org/databases/Lexique382/Lexique382.tsv.gz", delim='\t')
    # lex <- read_delim('Lexique382.tsv.gz', delim='\t')  # if you have the file

    selection <- subset(lex, ortho %in% items)

    head(selection)

    write_tsv(selection, 'selection.tsv')

    ### Using regular expressions
   require(tidyverse)
   require(stringr)

   # liste les mots qui finissent par "ion"
   lex$ortho %>% str_subset("ion$")

   # liste les mots qui contiennent trois voyelles successives
   lex$ortho %>% str_subset('[aeiouy][aeiouy][aeiouy]')

   # trouve les mots qui contiennent des groupes de 3 lettres répétés
   lex$ortho %>% str_subset("(...)\\1")

   # see https://stringr.tidyverse.org/articles/regular-expressions.html



Download [select-words-from-lexique.R](select-words-from-lexique.R). (If you have not already, to install [_R_](https://cran.r-project.org/) and [_Rstudio Desktop_](https://www.rstudio.com))

Remark that this code reads `Lexique382.tsv` directly from the web. 
If the server or the connection is too slow, you will get a message
"`Error in open.connection(con, "rb") : Timeout was reached`".

In this case, you should first download [Lexique382.tsv](http://wwww.lexique.org/shiny/databases/Lexique382/Lexique382.tsv) on your local hard drive and change the file path passed as argument to `read_delim`. 

More generally, you can download the source tables of a number of databases from [our list of open databases](../databases/README.md).

## Selecting lexical items with Python ##

This example shows how to select four random sets of twenty nouns and verbs of low and high frequencies from Lexique382, using Python. (If you have not already, install Python: Go to <https://www.anaconda.com/distribution/> ; Select your OS (Windows, MacOS or Linux) and download the Python 3.7 installer.)


    """ Exemple de sélection d'items dans la base Lexique382 """

    import pandas as pd

    lex = pd.read_csv("http://www.lexique.org/databases/Lexique382/Lexique382.tsv", sep='\t')

    lex.head()

    # restreint la recherche à des mots de longueur comprises entre 5 et 8 lettres
    subset = lex.loc[(lex.nblettres >= 5) & (lex.nblettres <=8)]

    # separe les noms et les verbes dans deux dataframes:
    noms = subset.loc[subset.cgram == 'NOM']
    verbs = subset.loc[subset.cgram == 'VER']

    # selectionne sur la base de la fréquence lexicale
    noms_hi = noms.loc[noms.freqlivres > 50.0]
    noms_low = noms.loc[(noms.freqlivres < 10.0) & (noms.freqlivres > 1.0)]

    verbs_hi = verbs.loc[verbs.freqlivres > 50.0]
    verbs_low = verbs.loc[(verbs.freqlivres < 10.0) & (verbs.freqlivres > 1.0)]

    # choisi des items tirés au hasard dans chacun des 4 sous-ensembles:
    N = 20
    noms_hi.sample(N).ortho.to_csv('nomhi.txt', index=False)
    noms_low.sample(N).ortho.to_csv('nomlo.txt', index=False)
    verbs_hi.sample(N).ortho.to_csv('verhi.txt', index=False)
    verbs_hi.sample(N).ortho.to_csv('verlo.txt', index=False)

Download [select-words-from-lexique.py](select-words-from-lexique.py) 



## Pseudoword creations 

Several methods to generate pseudowords are implemented. Check the folder.

For example: [pseudoword-generation-by-markov-on-trigrams](pseudoword-generation-by-markov-on-trigrams/pseudoword-generation-by-markov-on-trigrams.R)

## French syllabation ##

[french-syllabation](french-syllabation/README.md) provides the scripts that were used to syllabify the phonological representations in Brulex and Lexique.


----

Back to [main page](../README.md)

----

Time-stamp: <2019-03-31 14:01:37 christophe@pallier.org>

