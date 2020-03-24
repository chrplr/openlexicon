The .json files provide descriptions and links to the various databases tables.

They are used by the data-fetchers to download the tables locally. 

Here is, for example, the json file associated to Lexique383:

```{json}
{
    "_comment": "# Time-stamp: <2019-06-04 21:43:22 christophe@pallier.org>",
    "name": "lexique383",
    "description": "Lexique383 est une base de données lexicales du français qui fournit pour ~140000 mots du français: les représentations orthographiques et phonémiques, les lemmes associés, la syllabation, la catégorie grammaticale, le genre et le nombre, les fréquences dans un corpus de livres et dans un corpus de sous-titres de films, etc.",
    "website": "http://www.lexique.org",
    "readme": "https://chrplr.github.io/openlexicon/datasets-info/Lexique383/README-Lexique.html",
    "urls": [{
            "url": "http://www.lexique.org/databases/Lexique383/Lexique383.tsv",
            "bytes": 25850780,
            "md5sum": "a742a88cb00759c1ebed34995aed9904"
        },
        {
            "url": "http://www.lexique.org/databases/Lexique383/Lexique383.rds",
            "bytes": 5923649,
            "md5sum": "0f3329ff256333332bd0705e29b69e65"
        }
    ],
    "type": "tsv",
    "tags": ["french", "frequencies"]
}
`̀``



To generate the  skeleton of a .json` file, one can use the script `create_json.py`. For example:

      python3 create_json.py ../Lexique383/Lexique383.*

