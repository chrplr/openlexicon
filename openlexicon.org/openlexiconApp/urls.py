from django.urls import path
from .views import *

app_name = 'openlexiconApp'
urlpatterns = [
    path('serverTest', home, name="homeServer"),
    path('import_data', import_data, name="import_data"),
    path('data', ItemListView.as_view(), name="data"),
    path('export_data', export_data, name="export_data"),
]
