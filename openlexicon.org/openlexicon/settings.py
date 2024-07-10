"""
Django settings for openlexicon project.

Generated by 'django-admin startproject' using Django 3.2.15.

For more information on this file, see
https://docs.djangoproject.com/en/3.2/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.2/ref/settings/
"""

import os
from pathlib import Path
from openlexicon.prod_base_settings import db_pass, secret_key, passmail

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/3.2/howto/deployment/checklist/

# SECURITY WARNING: don't run with debug turned on in production!
LOG_LEVEL = 1
DEBUG = True
PRODUCTION = False

SITE_URL = "openlexicon.org"
SITE_NAME = "OpenLexicon"

# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'openlexicon.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        # TODO
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'openlexicon.wsgi.application'

##############################
########## Security ##########
##############################

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = secret_key

# To remove MIME type warning from firefox
# https://stackoverflow.com/questions/11811256/how-to-set-content-type-of-javascript-files-in-django
if DEBUG:
    import mimetypes
    mimetypes.add_type("application/javascript", ".js", True)

if DEBUG:
    ALLOWED_HOSTS = ["127.0.0.1", SITE_URL]
else:
    ALLOWED_HOSTS = [SITE_URL]

CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SAMESITE = None
SESSION_COOKIE_SAMESITE = None
if not PRODUCTION:
    SECURE_SSL_REDIRECT = False
else:
    SECURE_SSL_REDIRECT = True
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    BASE_URL = "https://"+SITE_URL

##############################
########## Database ##########
##############################
# https://docs.djangoproject.com/en/3.2/ref/settings/#databases

if not PRODUCTION:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
        }
    }
else:

    DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.mysql',
        	    'NAME': 'django_openlexicon',
                'USER': 'django_openlexicon',
                'PASSWORD': db_pass,
                'HOST': 'localhost',
                'PORT': '3306',
            }
        }


##############################
########## Password ##########
##############################
# https://docs.djangoproject.com/en/3.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


##############################
#### Internationalization ####
##############################
# https://docs.djangoproject.com/en/3.2/topics/i18n/

LANGUAGE_CODE = 'fr'

TIME_ZONE = 'Europe/Paris'

USE_I18N = True

USE_L10N = True

USE_TZ = True

##############################
########### Static ###########
##############################
# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/4.0/howto/static-files/

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')

# TODO
STATICFILES_DIRS = []

CONTACT_MAIL = "contact@lexique.org"

# Default primary key field type
# https://docs.djangoproject.com/en/3.2/ref/settings/#default-auto-field

##############################
########### Email ############
##############################
# FOR TESTING
if not PRODUCTION:
    EMAIL_BACKEND = "django.core.mail.backends.filebased.EmailBackend"
    EMAIL_FILE_PATH = str(os.path.join(BASE_DIR, 'sent_emails'))
else:
    # FOR REAL MAILS
    EMAIL_USE_TLS = True
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = "lexique.org"
    EMAIL_HOST_PASSWORD = passmail
    EMAIL_HOST_USER = 'zebulon'
    EMAIL_PORT = 587
    #https://stackoverflow.com/questions/26333009/how-do-you-configure-django-to-send-mail-through-postfix
    DEFAULT_FROM_EMAIL = "Contact LEXIQUE <contact@lexique.org>"
    EMAIL_SUBJECT_PREFIX = "[LEXIQUE]"

##############################
########### Models ###########
##############################

# Default primary key field type
# https://docs.djangoproject.com/en/4.0/ref/settings/#default-auto-field
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
