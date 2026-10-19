from django.urls import path

from . import views

app_name = "infra_query"

urlpatterns = [
    path("", views.index, name="index"),
    path("api/query/", views.query, name="query"),
]
