source venv/bin/activate
mkdir temp
mv openlexiconApp/migrations/__init__.py temp
rm -r openlexiconApp/migrations/*
mv temp/__init__.py openlexiconApp/migrations
rmdir temp
sudo -u postgres psql
# \c django_openlexicon;
# TRUNCATE TABLE "openlexiconApp_databaseobject";
python manage.py makemigrations
python manage.py migrate
deactivate
