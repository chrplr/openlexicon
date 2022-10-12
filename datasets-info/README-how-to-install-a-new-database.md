# How to add a new dataset #

The procedure, in brief, is the following:

1. add the table(s) of the datasets on some server on the internet, preferably in `.tsv` (text with tab separated columns) and `.rds` (R binary) formats. Other formats are ok, but `.rds` is needed if you intend to make it accessible by the [R data fetcher](https://github.com/chrplr/openlexicon/blob/master/datasets-info/fetch_datasets.R).  Note that the files must be directly accessible with  URLs.
2. create a [`.json` file](_json/README_json.md) describing the datasets , and do a pull request on http://github.com/chrplr/openlexicon to have it added to the `datasets-info/_json`.
3. (optional) To make the dataset easily accessible from R, update the R data fetcher at  https://github.com/chrplr/openlexicon/blob/master/datasets-info/fetch_datasets.R (again using a pull request)
4. (optional) To make the dataset visible on the interactive page http://www.lexique.org/shiny/openlexicon , you must update https://github.com/chrplr/openlexicon/blob/master/apps/openlexicon/www/data/loadingDatasets.R  so that the table is loaded by the app (again using a pull request)

Here are more detailed explanations:

## Add the table(s) on a server ##

If the dataset is not yet on the Internet, you need to put it on a web server.



Here we show an example for <http://www.lexique.org> maintainers:

* Connect to the server and go to the databases directory

        cd /var/www/databases

* Create a folder for the database, for example `zzzz`

        cd zzz

* Copy there  the relevant files (csv, csv, xlsx, zip, ...)

* To generate a `.rds` file (a binary format for faster loading in R), create a script `make_rds.R` like the following:

        #! /usr/bin/env Rscript
        require(readr)
        yyyyyyyyyy <- read_delim('xxxxxxxxxxxxxxxxxxxxxxx.tsv', delim='\t')
        saveRDS(yyyyyyyyyy, file='xxxxxxxxxxxxxxxxxxxxxxx.rds')

* Run the script to generate the rds file:

        chmod +x make_rds.R
        ./make_rds.R

* Create a link towards the rds file in the `../rds` folder:

        cd ../rds
        ln -s ../zzzz/xxxxxxxxxxxxxxxx.rds .

* Restart the shiny server:

        sudo systemctl restart shiny-server.service


## create a json description file ##


If you plan to use the data fetchers, it is necessary to  create a `.json` file describing the dataset, and to push it to <http://github.com/chrplr/openlexicon/datasets-info/_json>.

**For the database to be accessible from a shiny app, the url pointing to the `.rds` file must absolutely be indicated in the `.json` file (see example below).**

Further, for the database to be visible in the [openlexicon app](http://github.com/chrplr/openlexicon/app.R), the first tag of the json file must be a language (e.g., _french_).

Here is, for example, the `.json` file associated to _Lexique3_

```{json}
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


See [_json/README_json.md](_json/README_json.md)

Note: the filesizes (bytes) and md5sum are obtained on the command line by running

     ls -l *.{rds,tsv}
     md5sum *.{rds,tsv}

The `create_json.py` script in `datasets-info/_json`can help generate a json file:

For example:

     python3 create_json.py databasefile1.csv databasefile2.rds


--------


* Go to your fork of <http://github.com/chrplr/openlexicon/> and add the json file describing the database in `datasets-info/_json`, as well as some documentation --- at a minimum a `README.md` file describing the database -- and issue a pull request.

## Add the dataset to the interactive openlexicon app at lexique.org ##

To make the database accessible in openlexicon:

1. Modify the openlexicon app that will use this database (issue a pull request).
More specifically, update the [loadingDatasets.R file](https://github.com/chrplr/openlexicon/blob/master/apps/openlexicon/www/data/loadingDatasets.R) by adding your dataset id to the vector `dataset_ids`.
**Note**: ideally, the id of your dataset must match the filename of your `.rds` and `.json` files (e.g., Lexique383, Lexique383.json, Lexique383.rds). If this is not the case, you may add in `ex_filenames_ds` the correspondence between your dataset id and a vector containing your `.json` and `.rds` files in that order (e.g., 'Manulex-Lemmes' = c('Manulex', 'Manulex-Lemmes')).

2. Connect to the lexique server by ssh and run:

        cd ~chrplr/shiny-server
        git pull

3. If some database has been modified (new md5 sum), you may have to clean the cache in ~/openlexicon_datasets/

--

Back to [OpenLexicon](https://chrplr.github.com/openlexicon)


Time-stamp: <2019-11-18 11:39:17 christophe@pallier.org>
