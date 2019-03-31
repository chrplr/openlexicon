# How to add a new database #

% Time-stamp: <2019-03-31 10:48:29 christophe@pallier.org>

1. Create a subfolder where you put all the relevant files: Table(s), LICENSE, publications, ... in text format (no Excel!!).
2. Add a REAME-XXXX.md file in this folder. 
3. Edit the present `README.md` file to add a section describing the new database. (* Important* : Respect the [Markdown syntax](https://help.github.com/en/articles/basic-writing-and-formatting-syntax) when editing `.md` files!)
4. Update the `databases.zip` file:
   ```
       cd ..
       zip -u databases.zip databases/
   ```
5. Upload `databases.zip` to http://www.lexique.org web server root
6. Edit `databases2rdata.R` and run it generate the `.RData` file associated to the new database in the `rdata` subfolder
7. Modify `openlexique/app.R` to load the new table and have it listed in the menu.
