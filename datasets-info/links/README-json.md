Openlexicon json files
======================

`Time-stamp: <2024-12-04 08:29:03 christophe@pallier.org>`

The `.json` files in this folder provide descriptions and links to the various lexical databases tables.

They are used by the R and Python data-fetchers to download the tables locally. 

Here is, for example, the json file associated to Lexique383:

```{json}
{
  "name": "lexique383",
  "description": "Donne pour 140 000 mots français la <b>fréquences d’occurrences</b> dans différents corpus, la <b>représentation phonologique</b>, les <b>lemmes associés</b>, le <b>nombre de syllabes</b>, la <b>catégorie grammaticale</b>, etc.",
  "website": "http://www.lexique.org",
  "readme": "https://chrplr.github.io/openlexicon/datasets-info/Lexique383/README-Lexique.html",
  "url_rds": "http://www.lexique.org/databases/Lexique383/Lexique383.rds",
  "bytes": 5923649,
  "md5sum": "0f3329ff256333332bd0705e29b69e65"
}

```

To generate the  skeleton of a `.json` file, you can use the script `create_json.py`. For example:

      python3 create_json.py ../Lexique383/Lexique383.*


