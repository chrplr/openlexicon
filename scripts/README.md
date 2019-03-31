# Scripts to manipulate lexical databases

It may be convenient to download the tables from the databases you are interested in (see the [full list](../databases/README.md)) and to process them on your own computer.

Most tables are plain text files in `.tsv` (tab-separated values) or `.csv` (comma separated values) format. These can easily be imported into R with `readr::read_delim`, or into Python with `pandas.read_csv`. To open a `.tsv` or a `.csv` file with Excel, check out [How do I open a tsv file in Excel](https://rievent.zendesk.com/hc/en-us/articles/360000029172-FAQ-How-do-I-open-a-tsv-file-in-Excel-)

**Example of scripts:**

* [select.R](select.R) demonstrates how to extract a subset of items from Lexique382 with R.

* [select-words-from-lexique.py](select-words-from-lexique.py) demonstrates how to select four random sets of twenty nouns and verbs of low and high frequencies from Lexique382, using Python.

* [french-syllabation](french-syllabation/README.md) provides the scripts that were used to syllabify the phonological representations in Brulex and Lexique.


----

Back to [main page](../README.md)

----

Time-stamp: <2019-03-31 14:01:37 christophe@pallier.org>

