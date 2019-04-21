How to add a new database
=========================

1 Connect to the server and go to the database directory

    cd /var/www/databases

2.  Create a folder for the newdatabase, and add there the relevant
    files (csv, tcsv, xlsx, zip, ...)

3.  Go to you fork of
    <http://github.com/chrplr/openlexicon/databases-docs> and add some
    documentation --- at a minimum a README.md file) describing the
    database -- and issue a pull request.

4.  Optionaly, if you want to make the database accessible in
    openlexique:
    -   Add lines to convert the tables(s) into a `.RData` objects in
        the folder `rdata` in the script `databases2rdata.R` on the
        server and run it.
    -   Modify the [openlexicon
        apps](http://github.com/chrplr/openlexicon/apps) that will use
        this database.
    -   Connect to the server and run:

        cd \~chrplr/shiny-server git pull

--

Back to [OpenLexicon](https://chrplr.github.com/openlexicon)

Time-stamp: \<2019-04-21 15:22:22 christophe\@pallier.org\>
