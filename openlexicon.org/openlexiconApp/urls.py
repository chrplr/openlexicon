from django.urls import path
from .views import *

app_name = 'openlexiconApp'
urlpatterns = [
    path('serverTest', home, name="homeServer"),
    path('import_data', import_data, name="import_data"),
    path('data', ItemListView.as_view(), name="data"),
    path('export_data/<str:mode>/', export_data, name="export_data"),
    path('export_data/<str:mode>/<str:search>', export_data, name="export_data"),
]
