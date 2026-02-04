# OpenLexicon.org (powered by Django)

## Requirements

### On Windows

1. __[Python 3.11.3](https://www.python.org/downloads/release/python-3113/)__

2. __[PIP](https://pypi.org/project/pip/)__

    If pip is not installed, download [get-pip.py](https://bootstrap.pypa.io/get-pip.py) and run:

```
python get-pip.py
```

3. __[VirtualEnv](https://virtualenv.pypa.io/en/latest/)__

```
pip install virtualenv
```

### On Debian

1. __[Python 3.11.3](https://www.python.org/downloads/release/python-3113/)__

2. __[PIP](https://pypi.org/project/pip/)__

    Further dependencies will be handled by the Pipenv, which requires the PIP package manager of Python.
    To install pip:
```
apt install pip
```

3. __[VirtualEnv](https://virtualenv.pypa.io/en/latest/)__

```
pip install virtualenv
```

## Installation

### On Windows

```
python -m venv venv
.\venv\Scripts\activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic
.\venv\Scripts\deactivate
```

### On Debian

```
python -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic
deactivate
```

## Usage

### On Debian

```
run.sh
```

### On Windows

```
run.bat
```

## Database

Database engine is Postgresql. Locally, we need to install PostgreSQL and to run it using pgAdmin.

## Notes for update on server

```
git pull
source venv/bin/activate
python manage.py collectstatic
python manage.py makemigrations
python manage.py migrate
deactivate
```

Note : for reload, just edit the wsgi configuration file (avoid to reload whole server)

## Production

Follow [How To Set Up Django with Postgres, Nginx, and Gunicorn on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu)

During postgres step, do
```
GRANT postgres TO django_openlexicon;
```

During django step, go to /etc/nginx/nginx.conf and change user www-data; for user zebulon;

After edit on /etc/systemd/system/gunicorn.service, run
```
sudo systemctl daemon-reload
sudo systemctl restart gunicorn
sudo systemctl restart nginx
```

gunicorn.service content:
```
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target


[Service]
User=zebulon
Group=www-data
WorkingDirectory=/home/zebulon/openlexicon/openlexicon.org
ExecStart=/home/zebulon/openlexicon/openlexicon.org/venv/bin/gunicorn \
          #--access-logfile /home/zebulon/openlexicon_access.log \
          #--reload --reload-extra-file /home/zebulon/openlexicon/openlexicon.org/openlexicon/gunicorn_openlexicon.reload \ # does not work
          --preload \
          --timeout 900 \
          --max-requests 1000 --max-requests-jitter 100 \
          --error-logfile /home/zebulon/openlexicon_error.log \
          --workers 16 \
          # To avoid error request line is too large (since datatable ajax request can be pretty long)
          --limit-request-line 0 \
          --capture-output \
          #--enable-stdio-inheritance \
          --log-level DEBUG \
          --bind unix:/run/gunicorn.sock \
          openlexicon.wsgi:application
ExecReload=/bin/kill -s HUP $MAINPID

[Install]
WantedBy=multi-user.target
```

### Cache

Since we are using several workers for gunicorn, we need a data structure to handle cache share. For this, we use Redis.

```
sudo apt-get update
sudo apt-get install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

## Add new database

- Download RDS files from /home/chrplr/openlexicon_datasets using filezilla client
- Convert to TSV using R script :
```
files = list.files()
for (file in files) {
    if (grepl(".rds", file)) {
        tryCatch({
            df <- readRDS(file)
            write.table(df, paste(tools::file_path_sans_ext(file), "tsv", sep="."), row.names=FALSE, quote=FALSE, sep='\t', na="")
        }, error=function(e){print(file)})
    }
}
```
- Create config .txt file in english language
- Go to http://5.39.73.115/openlexicon/import_data and import .tsv and .txt
- Reload server for new database to appear correctly (if no reload, we get error "No matching records found")
