from django.urls import path, re_path
from .views import *

app_name = 'openlexiconApp'
urlpatterns = [
    path('', home, name="homeServer"),
    path('<str:column_list>', home, name="homeServer"),
    path('import_data', import_data, name="import_data"),
    path('data/<str:column_list>', ItemListView.as_view(), name="data"),
    path('data/', ItemListView.as_view(), name="data")
]
