#! /usr/bin/env Rscript
# Time-stamp: <2019-05-01 09:32:22 christophe@pallier.org>

# set the location of the *.RData files for openlexicon apps

#############################################
# DEPRECATED: use fetch_datasets.R instead  #
#############################################

DATABASES='/var/www/databases/'
RDATA='/var/www/databases/rdata'  # on the server

if (Sys.info()['user'] == 'cp983411') # on Christophe's machine
{
    DATABASES = '/home/cp983411/9_data/databases/';
    RDATA = '/home/cp983411/9_data/databases/rdata'
}

