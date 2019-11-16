# How to add a new dataset #


## Add the table(s) on a server ##


If the dataset is not yet on the Internet, you need to put it on a web server.

Here we show an example for <http://www.lexique.org> maintainers:

* Connect to the server and go to the databases directory 

        cd /var/www/databases

* Create a folder for the database, for example `zzzz`
    
        cd zzz

* Copy there  the relevant files (csv, tcsv, xlsx, zip, ...)

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


If you plan to use the data fetchers, it is necessary to  create a `.json` file describing the dataset, and to push it to <http://github.com/chrplr/openlexicon/datasets-info/_json>

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



Note: the filesizes (bytes) and md5sum are obtained on the command line by running

     ls -l *.{rds,tsv}
     md5sum *.{rds,tsv}

The `_create_json.py` script in `datasets-info/_json`can help generate a json file:

For example:

     python3 create_json.py databasefile1.csv databasefile2.rds

See [_json/README_json.md]

--------


* Go to your fork of <http://github.com/chrplr/openlexicon/> and add the json file describing the database in `datasets-info/_json`, as well as some documentation --- at a minimum a `README.md` file describing the database -- and issue a pull request.

* Optionaly, if you want to make the database accessible in openlexicon:
   * Modify the [openlexicon apps](http://github.com/chrplr/openlexicon/app.R) that will use this database (issue a pull request).
   * Connect to the server and run: 
   
        cd ~chrplr/shiny-server
        git pull

--

Back to [OpenLexicon](https://chrplr.github.com/openlexicon)


Time-stamp: <2019-11-16 19:05:17 christophe@pallier.org>
