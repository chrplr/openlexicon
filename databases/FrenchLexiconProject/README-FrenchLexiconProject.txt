French Lexicon Project
======================

\% Time-stamp: \<2019-03-30 19:03:15 christophe\@pallier.org\>

The French Lexicon Project (FLP) provide lexical decision data for
38,840 French words and the same number of nonwords. The full data
represents 1942000 reactions times from 975 participants.

Publication:

Ferrand, Ludovic, Boris New, Marc Brysbaert, Emmanuel Keuleers, Patrick
Bonin, Alain Méot, Maria Augustinova, and Christophe Pallier. 2010. The
French Lexicon Project: Lexical Decision Data for 38,840 French Words
and 38,840 Pseudowords. *Behavior Research Methods* 42 (2): 488--96.
https://doi.org/10.3758/BRM.42.2.488.
[pdf](Ferrand%20et%20al.%20-%202010%20-%20The%20French%20Lexicon%20Project%20Lexical%20decision%20data%20.pdf)

<https://sites.google.com/site/frenchlexicon/>

This directory contains the raw lexical decision time data from the
French Lexicon Project and the R scripts to compute the by-item
averages:

-   Inputs:

    -   `results.utf8.csv` \# raw lexical decision data from chronolex
    -   `lexcfreq.csv` \# lexical statistics from Lexique355
    -   `process.words.R` and `process.pseudowords.R` \# R scripts to
        compute rt by items

-   Outputs: `FLP.words.csv` and `FLP.pseudowords.csv`

Intermediate `*.csv` files contains the raw data with an additional
column ('keep') signaling the items that are within the subject'
mean+-3stddev range.

On unix-like systems, the `Makefile` allows you to run the scripts by
just typing `make`

Christophe Pallier

LICENSE CC BY-SA 4.0
