from django.urls import path

from . import views

app_name = "unipseudo"

urlpatterns = [
    path("", views.index, name="index"),
    path("api/language/", views.language_detail, name="language"),
    path("api/words/", views.words, name="words"),
    path("api/generate/", views.generate, name="generate"),
    path("api/download/", views.download, name="download"),
]
