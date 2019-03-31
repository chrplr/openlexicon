# Scripts to manipulate lexical databases

% Time-stamp: <2019-03-31 11:36:56 christophe@pallier.org>

The tables from the [databases](../databases/README.md) are plain text files in `.tsv` (tab-separated values) or `.csv` (comma separated values) which can easily be imported into R with `readr::read_delim`, or in Python with `pandas.read_csv`. We provide a few examples in [scripts](scripts/README.md). To open a `.tsv` or a `.csv` file with Excel, check out [How do I open a tsv file in Excel](https://rievent.zendesk.com/hc/en-us/articles/360000029172-FAQ-How-do-I-open-a-tsv-file-in-Excel-)

**Scripts:**

* [select.R](select.R) demonstrates how to extract a subset of items from Lexique382 with R.

* [select-words-from-lexique.py](select-words-from-lexique.py) demonstrates how to select four random sets of twenty nouns and verbs of low and high frequencies from Lexique382, using Python.

* [french-syllabation](french-syllabation/README.md) provides the scripts that were used to syllabify the phonological representations in Brulex and Lexique.


----

Back to [main page](../README.md)
