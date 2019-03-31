# OpenLexicon: Access to lexical databases

% Time-stamp: <2019-03-31 11:01:25 christophe@pallier.org>

_Openlexicon_ provides tables from various lexical databases and some code to manipulate them. 

For example, it allows to query the datababases online at <http://www.lexique.org:81/openlexique>

*Important note*: If you want to get the tables of the databases, you need to download and unzip [databases.zip](http://lexique.org/databases.zip) (The tables are not saved in the [github repository](https://github.com/chrplr/openlexicon) as they take up too mush disk space)

The tables are plain text files in `.tsv` (tab-separated values) or `.csv` (comma separated values) which can easily be imported into R with `readr::read_delim`, or in Python with `pandas.read_csv`. We provide a few examples in [scripts](scripts/README.md). To open a `.tsv` or a `.csv` file with Excel, check out [How do I open a tsv file in Excel](https://rievent.zendesk.com/hc/en-us/articles/360000029172-FAQ-How-do-I-open-a-tsv-file-in-Excel-)


**Table of Contents**

- [Currently available databases](databases/README.md)
- [How to add a new database](README-how-to-add-a-new-database.md)
- [Installation](README-Install.md)


-----

The address of this webpage is <https://chrplr.github.io/openlexicon> and the source code is available at <https://github.com/chrplr/openlexicon>. 

This work is distributed under a CC BY-SA 4.0 LICENSE
(see <https://creativecommons.org/licenses/by-sa/4.0/>)

Please cite us if you use our work:

* Pallier, Christophe & New, Boris (2019) Openlexicon, GitHub repository, <https://github.com/chrplr/openlexicon>


If you want to contribute, by adding a database, or sending some corrections, please contact `christophe@pallier.org` and `boris.new@gmail.com`




