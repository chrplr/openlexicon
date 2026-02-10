from django.db import models
from django.db.models.signals import pre_delete
from django.dispatch import receiver
from django_ckeditor_5.fields import CKEditor5Field

class ColSize(models.TextChoices):
    LARGE = "large"
    MEDIUM = "medium"
    SMALL = "small"

class ColType(models.TextChoices):
    TEXT = "text"
    FLOAT = "float"
    INT = "int"

    @staticmethod
    def get_field_class(type):
        if type == ColType.TEXT:
            return models.CharField()
        elif type == ColType.INT:
            return models.IntegerField()
        elif type == ColType.FLOAT:
            return models.FloatField()

class ExportMode(models.TextChoices):
    TSV = "TSV"
    EXCEL = "EXCEL"

class Lang(models.TextChoices):
    FR = "French"
    EN = "English"
    DE = "Dutch"
    MULT = "Multiple languages"

class Tag(models.Model):
    name = models.CharField(max_length=100, unique=True)

class Database(models.Model):
    id = models.AutoField(primary_key=True, db_index=True)
    code = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=50, unique=True)
    info = CKEditor5Field(blank=True, null=True) # for tooltip
    website = models.URLField(blank=True, null=True)
    authors = models.CharField(blank=True, null=True, max_length=400)
    biblio = models.CharField(blank=True, null=True, max_length=1000)
    language = models.CharField(max_length=20, choices=Lang.choices, default=Lang.FR)
    nbRows = models.IntegerField(default=0)
    nbWords = models.IntegerField(blank=True, null=True)
    favorite = models.BooleanField(default=False)
    tags = models.ManyToManyField(
        Tag,
        related_name="databases"
    )

    def __str__(self):
        return self.name

class DatabaseObject(models.Model):
    id = models.AutoField(primary_key=True, db_index=True)
    database = models.ForeignKey(Database, on_delete=models.CASCADE)
    ortho = models.CharField(max_length=400, verbose_name="Word", db_index=True) # db_index speeds up filter and ordering a lot !
    jsonData = models.JSONField(null=True, db_index=True) # not sure db_index works on jsonField. TODO : retest with standard columns against jsonData. It should be faster with standard columns with db_index, but to which point ?

    class Meta:
        unique_together = ('database', 'ortho', 'jsonData',)

class DatabaseColumn(models.Model):
    id = models.AutoField(primary_key=True, db_index=True)
    database = models.ForeignKey(Database, on_delete=models.CASCADE)
    code = models.CharField(max_length=50, verbose_name="Code")
    name = models.CharField(max_length=50, verbose_name="Nom")
    description = models.CharField(max_length=300, null=True, blank=True)
    size = models.CharField(max_length=10, verbose_name="Taille", default=ColSize.MEDIUM)
    type = models.CharField(max_length=10, verbose_name="Type de données", default=ColType.TEXT) # try to assume type if not given ?
    mandatory = models.BooleanField(default=False)
    min = models.FloatField(null=True, blank=True)
    max = models.FloatField(null=True, blank=True)

    def __str__(self):
        return self.name

    @staticmethod
    def cleanColName(colName):
        for c in "\"';., `":
            colName = colName.replace(c, "_")
        return colName

    class Meta:
        unique_together = ('database', 'code',)

@receiver(pre_delete, sender=Database)
def handle_tag_delete(sender, instance, *args, **kwargs):
    tags = instance.tags.all()
    for tag in tags:
        if len(tag.databases.all()) <= 1:
            tag.delete()
