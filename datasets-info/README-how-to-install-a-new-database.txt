How to add a new dataset
========================

It is as simple as creating a `.json` file describing the dataset and
pushing it to <http://github.com/chrplr/openlexicon/datasets-info>

Here is for example the `.json` file associated to *Lexique3*

``` {.{json}}
{
    "_comment": "# Time-stamp: <2019-04-30 17:01:41 christophe@pallier.org>",
    "name": "lexique3",
    "description": "Lexique382 est une base de données lexicales du français qui fournit pour ~140000 mots du français: les représentations orthographiques et phonémiques, les lemmes associés, la syllabation, la catégorie grammaticale, le genre et le nombre, les fréquences dans un corpus de livres et dans un corpus de sous-titres de filems, etc.",
    "website": "http://www.lexique.org",
    "readme": "https://chrplr.github.io/openlexicon/datasets-info/Lexique382/README-Lexique.html",
    "urls": [{
            "url": "http://www.lexique.org/databases/Lexique382/Lexique382.tsv",
            "bytes": 25850842,
            "md5sum": "28d18d7ac1464d09e379f30995d9d605"
        },
        {
            "url": "http://www.lexique.org/databases/Lexique382/Lexique382.rds",
            "bytes": 5923674,
            "md5sum": "e3e5f47409b91fdb620edfdd960dd7a5"
        }
    ],
    "type": "tsv",
    "tags": ["french", "frequencies"]
}
```

------------------------------------------------------------------------

If the dataset is not yet on the Internet, you need to put it on a web
server.

For example, for <http://www.lexique.org> maintainers:

-   Connect to the server and go to the databases directory

        cd /var/www/databases

-   Create there a folder for the database:
-   put there the relevant files (csv, tcsv, xlsx, zip, ...)
-   create a `make_rds.R` script in this folder

        yyyyyyyyyy <- read_delim('xxxxxxxxxxxxxxxxxxxxxxx.tsv', delim='\t')
        saveRDS(yyyyyyyyyy, file='xxxxxxxxxxxxxxxxxxxxxxx.rds')

-   generate a `rds` file containing the datasets:

         cd /var/www/databases
         make rds

    -   make sure the links has been created in `rds` and run: \` sudo
        systemctl restart shiny-server.service

-   Go to your fork of <http://github.com/chrplr/openlexicon/> and add
    the json files describing the database, as well as some
    documentation --- at a minimum a README.md file) describing the
    database -- and issue a pull request.

-   Optionaly, if you want to make the database accessible in
    openlexicon:\
-   Modify the [openlexicon
    apps](http://github.com/chrplr/openlexicon/apps) that will use this
    database (issue a pull request).
-   Connect to the server and run:

        cd ~chrplr/shiny-server
        git pull

--

Back to [OpenLexicon](https://chrplr.github.com/openlexicon)

Time-stamp: &lt;2019-05-01 09:39:19 christophe@pallier.org&gt;
