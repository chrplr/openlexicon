#! /usr/bin/env Rscript
# Time-stamp: <2019-04-22 13:41:34 christophe@pallier.org>

# set the location of the *.RData files for openlexicon apps


DATABASES='/var/www/databases/'
RDATA='/var/www/databases/rdata'  # on the server

if (Sys.info()['user'] == 'cp983411') # on Christophe's machine
{
    DATABASES = '/home/cp983411/9_data/databases/';
    RDATA = '/home/cp983411/9_data/databases/rdata'
}

