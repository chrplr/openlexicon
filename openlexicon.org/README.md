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
