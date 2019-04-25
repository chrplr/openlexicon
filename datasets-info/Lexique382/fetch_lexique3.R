URL='http://www.lexique.org/databases/Lexique382/Lexique382.tsv'

DATADIR=file.path(path.expand('~'), 'databases')
DESTDIR=file.path(DATADIR, 'Lexique382')
NAME='Lexique382.tsv'


if (!dir.exists(DESTDIR))
{ dir.create(DESTDIR, recursive=TRUE) }

if (!file.exists(file.path(DESTDIR, NAME)))
{ download.file(URL, file.path(DESTDIR, NAME)) }




