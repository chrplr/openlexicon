# How to add a new database #

Connect to the server and go to the database directory ( `/var/www/databases`)

1. Create a folder for it and  add the relevant files (csv, tcsv, xlsx, zip, ...)
2. Add some documentation (at a minimum a README.md file) describing the
   database to <http://github.com/chrplr/openlexicon/databases-docs>
3. Optionnaly, if you want to make the database accessible by openlexique:
   * Add lines to convert the tables(s) into a `.RData` objects in the folder
     `rdata` in the script `databases2rdata.R` on the server and run it.
   * Modify the [openlexicon apps](http://github.com/chrplr/openlexicon/apps) that will use this database,
     and run `git pull` to update the openlexicon repository on the server (currently in ~chrplr/shiny-server).

--

Back to [main page](README.md)

% Time-stamp: <2019-04-13 14:52:57 christophe@pallier.org>
