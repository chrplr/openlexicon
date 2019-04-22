#! /usr/bin/env Rscript
# Time-stamp: <2019-04-22 10:11:59 christophe@pallier.org>

# set the location of the *.RData files for openlexicon apps

RDATA='/var/www/databases/rdata'  # on the server

if (Sys.info()['user'] == 'cp983411') # on Christophe's machine
   { RDATA = '/home/cp983411/9_data/databases/rdata' }

