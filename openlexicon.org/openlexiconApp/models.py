from django.db import models
from django_ckeditor_5.fields import CKEditor5Field

class ExportMode(models.TextChoices):
    CSV = "CSV"
    EXCEL = "EXCEL"

class Lang(models.TextChoices):
    FR = "French"
    EN = "English"
    DE = "Dutch"
    MULT = "Multiple languages"

class Database(models.Model):
    name = models.CharField(max_length=50, unique=True)
    info = CKEditor5Field(blank=True, null=True) # for tooltip
    language = models.CharField(max_length=20, choices=Lang.choices, default=Lang.FR)

class DatabaseObject(models.Model):
    database = models.ForeignKey(Database, on_delete=models.CASCADE)
    ortho = models.CharField(max_length=50, verbose_name="Word")
    phon = models.CharField(max_length=50, verbose_name="Phonology", null=True)
    lemme = models.CharField(max_length=50, verbose_name="Lemme", null=True)
    cgram = models.CharField(max_length=20, verbose_name="Grammatical category", null=True)
    freqlemfilms2 = models.FloatField(verbose_name="Lemme frequency in movies", null=True)
    freqfilms2 = models.FloatField(verbose_name="Frequency in movies", null=True)
    nblettres = models.IntegerField(verbose_name="Number of letters", null=True)
    puorth = models.IntegerField(null=True)
    puphon = models.IntegerField(null=True)
    nbsyll = models.IntegerField(verbose_name="Number of syllabs", null=True)
    cgramortho = models.CharField(max_length=100, verbose_name="Grammatical category", null=True)
    jsonData = models.JSONField(null=True)
