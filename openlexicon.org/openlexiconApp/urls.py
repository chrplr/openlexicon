from django.urls import path, re_path
from .views import *

app_name = 'openlexiconApp'
urlpatterns = [
    path('', home, name="homeServer"),
    path('<str:column_list>', home, name="homeServer")
]
