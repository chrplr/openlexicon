from django.db import models

class DatabaseObject(models.Model):
    ortho = models.CharField(max_length=50)
    phon = models.CharField(max_length=50)
    lemme = models.CharField(max_length=50)
    cgram = models.CharField(max_length=20)
    freqlemfilms2 = models.FloatField()
    freqfilms2 = models.FloatField()
    nblettres = models.IntegerField()
    puorth = models.IntegerField()
    puphon = models.IntegerField()
    nbsyll = models.IntegerField()
    cgramortho = models.CharField(max_length=100)
