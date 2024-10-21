call "venv\Scripts\activate"
mkdir temp
move "openlexiconApp\migrations\__init__.py" temp
cd "openlexiconApp\migrations"
RD /S /Q "__pycache__"
del *.* /Q
cd ../..
move "temp\__init__.py" "openlexiconApp\migrations"
rmdir temp
del db.sqlite3
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py shell < initialize_su.py
call "deactivate"
