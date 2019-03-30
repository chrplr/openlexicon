OpenLexicon: Access to lexical databases

% Time-stamp: <2019-03-30 18:38:10 christophe@pallier.org>

This package provides various lexical databases, and some code to access them, either online (e.g. at <http://lexique.org:81/openlexique>) or offline (see [scripts](scripts/README.md))

Important: To get the  actual source tables of the databases, you need to download and unzip the file [databases.zip](http://lexique.org/databases.zip) (They are not saved on the github repository as they take too mush disk space)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Currently available databases](#currently-available-databases)
    - [Lexique382](#lexique382)
    - [Frantext](#frantext)
    - [French Lexicon Project](#french-lexicon-project)
    - [Megalex](#megalex)
    - [Chronolex](#chronolex)
    - [Gougenheim100](#gougenheim100)
    - [SUBTLEXus](#subtlexus)
- [How to add a new database](#how-to-add-a-new-database)
- [Installation](#installation)
    - [Shiny server](#shiny-server)
        - [Installation of R](#installation-of-r)
        - [Installaion of RShiny and Shiny server](#installaion-of-rshiny-and-shiny-server)
    - [Running:](#running)
    - [Add the openlexicon shiny apps to the shiny-server:](#add-the-openlexicon-shiny-apps-to-the-shiny-server)

<!-- markdown-toc end -->


# Currently available databases #

## Lexique382 ##

_Lexique382_ est une base de données lexicales du français qui fournit pour ~140000 mots du français: les représentations orthographiques et phonémiques, les lemmes associés, la syllabation, la catégorie grammaticale, le genre et le nombre, les fréquences dans un corpus de livres et dans un corpus de sous-titres de filems, etc. 

 - Table: [databases/Lexique382.tsv](databases/Lexique382/Lexique382.tsv)
 - README: [databases/README-Lexique382](databases/Lexique382/README-Lexique.md) 
 - Website: <http://www.lexique.org>


## Frantext ##

La table _Frantext_ fournit la liste de tous les types orthographiques README-Gougenheimobtenus après tokenization du sous-corpus de Frantext utilisé pour calculer les fréquences "livres"" de Lexique. 

 - Table: [Frantext.tsv](databases/Frantext/Frantext.tsv)
 - README: [README-Frantext](databases/Frantext/README-Frantext.md)


## French Lexicon Project ##

The _French Lexicon Project_ (FLP) provides visual lexical decision time for about 39000 French words, obtained from 1,000 participants from different universities (Each participant read XXX items).

 - Tables:  
      * [FLP.words.csv](databases/FrenchLexiconProject/FLP.words.csv)  
      * [FLP.pseudowords.csv](databases/FrenchLexiconProject/FLP.pseudowords.csv)
 - README: [README-FrenchLexiconProject](databases/FrenchLexiconProject/README-FrenchLexiconProject.md))
 - Website: <https://sites.google.com/site/frenchlexicon/>


## Megalex ##

_Megalex_ provides visual and auditory lexical decision times and accuracy rates several thousands of words: Visual lexical decision data are available for 28466 French words and the same number of pseudowords, and auditory lexical decision data are available for 17876 French words and the same number of pseudowords. 

   - Table: ???
   - README: [README-Megalex](databases/Megalex/README-Megalex.md)
   - Website:

## Chronolex ##

_Chronolex_ provides naming times, lexical decision times and progressive demasking scores on most monosyllabic monomorphemic French (about 1500 items).

Thirty-seven participants (psychology students from Blaise Pascal University in Clermont-Ferrand) were tested in the naming task, 35 additionnal participants in the lexical decision task and 33 additionnal participants (from the same pool) were tested in the progressive demasking task.

   - Table: [Chronolex.tsv](databases/Chronolex/Chronolex.tsv)
   - README: [README-Chronolex](databases/Chronolex/README-Chronolex.md)
   - Website:

## Gougenheim100 ##

La base _Gougenheim100_ présente, pour 1064 mots, leur fréquence et leur répartition (nombre de textes dans lesquels ils apparaissent). Le corpus sur lequel, il est basé est un corpus de langue oral basé sur un ensembles d'entretiens avec 275 personnes. C'est donc non seulement un corpus de langue orale mais aussi de langue produite. Le corpus original comprend 163 textes, 312.135 mots et 7.995 lemmes différents. 

   - Table: [gougenheim.tsv](databases/Gougenheim100/gougenheim.tsv)
   - README: [README-Gougenheim](databases/Gougenheim100/README-Gougenheim.md)


## SUBTLEXus ##

_SUBTLEXus_ provide frequency measures based on American movies subtitles (51 million words in total). There are two measures:

- The frequency per million words, called SUBTLEXWF (Subtitle frequency: word form frequency)
- The percentage of films in which a word occurs, called SUBTLEXCD (Subtitle frequency: contextual diversity; see Adelman, Brown, & Quesada (2006) for the qualities of this measure).

   - Table: [SUBTLEXus74286wordstextversion.tsv](databases/SUBTLEXus/SUBTLEXus74286wordstextversion.tsv)
   - README: [README-SUBTLEXus](databases/SUBTLEXus/README-SUBTLEXus.md)
   - Website: <https://www.ugent.be/pp/experimentele-psychologie/en/research/documents/subtlexus>

-------------------------------------------------------------------------------

# Usage #

* The tables are plain text files in `.tsv` (tab-separated values) or `.csv` (comma separated values) which can easily be imported into R with `readr::read_delim`, or in Python with `pandas.read_csv`. We provide a few examples in [scripts](scripts/README.md).

  To open a `.tsv` or a `.csv` file with Excel, check out [How do I open a tsv file in Excel](https://rievent.zendesk.com/hc/en-us/articles/360000029172-FAQ-How-do-I-open-a-tsv-file-in-Excel-)

* The databases can also be queried on-line at <http://www.lexique.org:81/openlexique>


-------------------------------------------------------------------------------

# How to add a new database #

1. Create a subfolder where you put all the relevant files: Table(s), LICENSE, publications, ... in text format (no Excel!!!**
2. Add a REAME-XXXX.md file in this folder. O
3. Edit the present `README.md` file to add a section describing the new database. 
 
 * Important* : Respect [Markdown syntax](https://help.github.com/en/articles/basic-writing-and-formatting-syntax) when editing `.md` files!
4. Update the `databases.zip` file:
   ```
       cd ..
       zip -u databases.zip databases/
   ```
5. Upload `databases.zip` to http://www.lexique.org web server root
6. Edit `databases2rdata.R` and run it generate the `.RData` file associated to the new database in the `rdata` subfolder
7. Modify `openlexique/app.R` to load the new table and have it listed in the menu.

----------------------------------------------------------

# Installation 

1. Either install the package using git: 

   ```
       git clone https://github.com/chrplr/shiny-server-lexique.git
   ```

  *Or* download and unzip <https://github.com/chrplr/shiny-server-lexique/archive/master.zip>

2. Download and unzip  <http://lexique.org/databases.zip> in the directory of the project. This should unpack the tables in the `databases` subfolder.`

## Shiny server

These instructions explain how to deploy a [shiny server](https://www.rstudio.com/products/shiny/shiny-server/) on a Ubuntu 18.04 Linux server, and how to install the openlexique databases on it.

The following commands must be executed on the computer that will be used as the server.

### Installation of R

    sudo apt install -y apt-transport-https software-properties-common
    sudo apt install -y build-essential
    
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

    sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

    sudo apt update
    sudo apt install -y r-base

### Installaion of RShiny and Shiny server

Following the instructions at <https://www.rstudio.com/products/shiny/download-server/>

    sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
    sudo su - -c "R -e \"install.packages('DT','rmarkdown')\""

    sudo apt-get install -y gdebi-core
    sudo wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb
    sudo gdebi shiny-server-1.5.9.923-amd64.deb

## Running:

You run the server by accessing `http://servername:3838` where `servername` it the name or the IP address of your server. For a local installation, it would be `localhost`.

If you want to setup the server main page (http://servername) to point on
rshiny, you need to edit `/etc/shiny-server/shiny-server.conf` to modify the
port from `3838` to `80`

    nano /etc/shiny-server/shiny-server.conf  # change port from 3838 to 80
    systemctl restart shiny-server

Alternativly, if you use a web server like apache2 or nginx, you can configure them to proxy the shiny-server. For nginx, for example, I added the following inside the `http` directive in `/etc/nginx/nginx.conf`

     map $http_upgrade $connection_upgrade {
     default upgrade;
        ''      close;
                }

    server {
      listen 81;
    
    
    location / {
      proxy_pass http://localhost:3838;
      proxy_redirect / $scheme://$http_host/;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
      proxy_read_timeout 20d;
      proxy_buffering off;
     }
    }


## Add the openlexicon shiny apps to the shiny-server:

Execute:

    cd 
    git clone https://github.com/chrplr/openlexicon.git shiny-server
    cd shiny-server/
    ./get_databases.R

Edit `/etc/shiny-server/shiny-server.conf`:

    server {
    listen 3838;

    # For root shiny server (in shinyapps user home folder)
    location / {

    # The shiny-server process would run by user `chrplr`
    run_as chrplr;

    # Save logs here
    log_dir /var/log/shiny-server;

    # Path to shiny server for separate apps
    site_dir /home/chrplr/shiny-server;

    # List contents of a (non-Shiny-App) directory when clients visit corresponding URIs
    directory_index on;
    }

    # Allow users to host their own apps in `~/ShinyApps`
    location /users {
      run_as :HOME_USER:;
      user_dirs;
     }
    }

    
---

This work is distributed under a CC BY-SA 4.0 LICENSE
(see <https://creativecommons.org/licenses/by-sa/4.0/>)

Please cite us if you use our work !

Christophe@Pallier.org & Boris.New@gmail.com



