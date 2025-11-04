from django.conf import settings
from .models import Database, DatabaseColumn, ColType, ColSize, Lang
from openlexicon.render_data import debug_log
import chardet
from io import StringIO
from pandas.api.types import is_string_dtype, is_float_dtype, is_numeric_dtype
import pandas as pd
import re

text_file_keys = {
    "nom": "name",
    "ancien nom": "oldname",
    "description": "info",
    "site web": "website",
    "langue": "language",
    "auteurs": "authors",
    "favori": "favorite",
    "ref": "biblio",
    "nb words": "nbWords"
}

# NOTE : we give sorted_d because sort does not always involve same lambda function
def sortdict(d, sorted_d):
    # **opts so any currently supported sorted() options can be passed
    sorted_dict = {}
    for k in sorted_d:
        sorted_dict[k] = d[k]
    return sorted_dict

def save_many_relations(db_name, container, selected_items):
    selected = set(selected_items)
    db = getattr(container, db_name)
    saved = set(db.all())

    items_to_delete = saved.difference(selected)
    items_to_save = selected.difference(saved)

    # Deleting unselected items
    if len(items_to_delete) > 0:
        db.remove(*items_to_delete)

    db.add(*items_to_save)

    return items_to_delete

def get_database_info(text_file):
    lines = text_file.read().splitlines()
    database_info = {}
    col_info = {}
    getting_col_info = False
    for line in lines:
        line_split = line.decode("utf-8").split("\t")
        line_key = line_split[0].lower()
        if getting_col_info: # currently getting columns description
            col_info[line_key] = line_split[1].strip()
        elif line_key in ["tags", "champs oblig"]: # list fields
            try: database_info[line_key] = [x.lower().strip() for x in line_split[1].split(",")]
            except IndexError: database_info[line_key] = []
        elif line_key == "champs": # encountered champs. All lines after that should be columns description
            getting_col_info = True
        else: # name, description, website and language fields
            for key in text_file_keys.keys():
                if line_key.casefold() == key.casefold():
                    try: key_content = line_split[1].strip()
                    except IndexError: key_content = None
                    if text_file_keys[key] == "nbWords":
                        key_content = int(key_content.replace(",",""))
                    database_info[text_file_keys[key]] = key_content
                    break
    return database_info, col_info

def get_column_info(df, db, database_info, col_info, word_col_idx):
    mandatory_columns = database_info["champs oblig"]
    col_dict = {}
    for col_count, col in enumerate(df.columns):
        clean_col = DatabaseColumn.cleanColName(col)
        if col_count != word_col_idx:
            col_type = df[col].dtype
            col_filter = DatabaseColumn.objects.filter(database=db, code=col)
            if not col_filter.exists(): # Create column
                size = ColSize.MEDIUM
                if is_string_dtype(col_type):
                    type = ColType.TEXT
                elif is_float_dtype(col_type):
                    type = ColType.FLOAT
                elif is_numeric_dtype(col_type):
                    type = ColType.INT
                    size = ColSize.SMALL
                else:
                    raise Exception(f"No valid type for column {col}, type detected {col_type}")
                col_obj = DatabaseColumn.objects.create(
                    database=db,
                    code=clean_col,
                    name=clean_col,
                    type=type,
                    size=size,
                    mandatory=col.lower() in mandatory_columns,
                    description=None if col.lower() not in col_info else col_info[col.lower()]
                )
                col_dict[col] = col_obj
            else: # Get existing column
                col_dict[col] = col_filter[0]
    return col_dict

def remove_spaces(x):
    if isinstance(x, str):
        if re.match("^-?[\d ]{1,}(\.\d{1,})?$", x): # match float or int
            x = x.replace(" ", "")
            try: return int(x)
            except: return float(x)
    return x

def load_tsv_file(tsv_file):
    # check encoding and decode if needed
    rawdata = tsv_file.read()
    chardet_data = chardet.detect(rawdata)
    encoding = chardet_data["encoding"]
    enc_confidence = chardet_data["confidence"]
    default_encoding = "utf-8"

    if encoding != default_encoding:
        # TODO : return error
        if encoding is None:
            debug_log(f"Could not detect file {tsv_file.name} encoding -> skip", -1)
        elif enc_confidence < 0.7:
            debug_log(f"Chardet confidence {enc_confidence} for file {tsv_file.name} -> skip", -1)
        else:
            # go back to file first row to read again and decode
            tsv_file.seek(0)
            tsv_file = tsv_file.read().decode(encoding)
            df = pd.read_csv(StringIO(tsv_file), sep='\t', keep_default_na=False, na_values=[''])
    else:
        tsv_file.seek(0)
        df = pd.read_csv(tsv_file, sep="\t", keep_default_na=False, na_values=['']) # TODO : is it enough to consider just '' as nan ?
    # Remove spaces from cells with numbers only
    for col in list(df.columns):
        df[col] = df[col].apply(remove_spaces)
    return df

# Object with pattern column_list ["database__column1", "database__column2"] and pattern column_dict {"database": ["column1", "column2"]}
class DbColMap:
    def __init__(self, column_list):
        self.column_list = column_list
        self.set_column_dict()

    # From column_list with pattern ["database__column1", "database__column2"], create column_dict with pattern {DatabaseObject: ["column1", "column2"]}
    def set_column_dict(self):
        self.column_dict = {} # for datatable
        self.string_column_dict = {} # for template
        self.col_string = [] # for template (format will be 1__2,1__3, first number is db.id and second col.id)
        last_db_pk = None
        self.databases = []
        for col in self.column_list:
            db_pk, col_pk = DbColMap.get_db_col_from_string(col)
            # Avoid making multiple requests to get same database
            if db_pk != last_db_pk:
                try:database = Database.objects.get(id=db_pk)
                except:database = Database.objects.get(code=db_pk)
                last_db_pk = db_pk
            if database not in self.column_dict:
                self.databases.append(database)
                self.string_column_dict[database.id] = []
                self.column_dict[database] = [col_pk]
            else:
                self.column_dict[database].append(col_pk)
        # Get DatabaseColumn objects
        for db in self.databases:
             # TODO : order_by id is important so that headers list (see views home) will be in the same order than values list. Find a more robust way ?
            try:column_queryset = DatabaseColumn.objects.filter(database=db, id__in=self.column_dict[db]).order_by("id").select_related("database")
            except:column_queryset = DatabaseColumn.objects.filter(database=db, code__in=self.column_dict[db]).order_by("id").select_related("database")
            self.column_dict[db] = []
            for col in column_queryset:
                col_dict = {}
                for attr in ["id", "code", "size", "type", "description"]:
                    col_dict[attr] = getattr(col, attr)
                self.string_column_dict[db.id].append(col_dict)
                self.column_dict[db].append(col)
                self.col_string.append(f"{db.id}__{col.id}")
        self.col_string = ",".join(self.col_string)

    @staticmethod
    def get_db_col_from_string(string):
        # string has pattern database__column. Split and return the elements
        col_elts = string.split("__", 1)
        db_pk = col_elts[0]
        col_pk = col_elts[1]
        return db_pk, col_pk

    @staticmethod
    def listify_string(string):
        return string.split(export_sep)

def getLangDefault(lang):
    defaultDbs = {
        Lang.FR: {
            "chosen_db": Database.objects.get(name="Lexique3"),
            "column_list": [f"Lexique3__{col_name}" for col_name in DatabaseColumn.objects.filter(database__name="Lexique3", mandatory=True).values_list(flat=True)]
        }
    }

    lang_databases = Database.objects.filter(language=lang)

    if lang in defaultDbs.keys():
        column_list = defaultDbs[lang]["column_list"]
        chosen_db = defaultDbs[lang]["chosen_db"]
    else: # get first favorite db of language, or first db of language as default
        lang_favorites = lang_databases.filter(favorite=True)
        if len(lang_favorites) > 0:
            chosen_db = lang_favorites[0]
        else:
            chosen_db = lang_databases[0]
        column_list = [f"{chosen_db.name}__{col_name}" for col_name in DatabaseColumn.objects.filter(database=chosen_db).values_list("name", flat=True)]
    return chosen_db.name, DbColMap(column_list), list(lang_databases.values_list("name", flat=True))

export_sep = ","
