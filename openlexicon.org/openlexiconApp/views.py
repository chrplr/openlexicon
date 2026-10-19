from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.cache import cache
from django.db import connections, transaction
from django.http import JsonResponse
from django.shortcuts import render
from .datatable import ServerSideDatatableView
from .models import DatabaseObject, Database, DatabaseColumn, ColType, Tag, Lang
from .utils import *
import math
import os
import numpy as np
import pandas as pd
from django.db import connection

# https://datatables.net/examples/data_sources/server_side.html
def home(request):
    if request.method == 'POST':
        chosen_db, dbColMap, lang_databases = getLangDefault(request.POST.get('new_language', None))
        return JsonResponse({
            "columns": dbColMap.string_column_dict,
            "database_order": list(dbColMap.string_column_dict.keys()),
            "col_string": dbColMap.col_string,
            "lang_databases": lang_databases,
            "chosen_db": chosen_db
        })

    # default language is French for Lexique
    default_lang = Lang.FR
    all_columns = DatabaseColumn.objects.filter(database__visible=True).select_related("database").prefetch_related("database__tags").order_by("database__name", "id") # TODO : order_by id is important so that headers list will be in the same order than values list (see DbColMap and datatable). Find a more robust way ?
    all_columns_dict = {}
    all_tags_dict = {}
    all_languages_dict = {}
    all_favorites_dict = {"Favorites": {}}
    for col in all_columns:
        for tag in col.database.tags.all():
            if tag not in all_tags_dict:
                all_tags_dict[tag] = {col.database: []}
        if col.database.language not in all_languages_dict:
            all_languages_dict[col.database.language] = {col.database: []}
        if col.database not in all_columns_dict:
            all_columns_dict[col.database] = []
            all_tags_dict[tag][col.database] = []
            all_languages_dict[col.database.language][col.database] = []
            if col.database.favorite:
                all_favorites_dict["Favorites"][col.database] = []
        all_columns_dict[col.database].append(col)
        all_tags_dict[tag][col.database].append(col)
        all_languages_dict[col.database.language][col.database].append(col)
        if col.database.favorite:
            all_favorites_dict["Favorites"][col.database].append(col)

    all_languages = sortdict(all_languages_dict, sorted(all_languages_dict))
    primary_languages = [x for x in all_languages.keys() if x in [Lang.FR, Lang.EN, Lang.DE]]
    return render(request, 'openlexiconServer.html', {
        'table_name': settings.SITE_NAME,
        'all_columns': all_columns_dict,
        'all_languages': sortdict(all_languages_dict, sorted(all_languages_dict)),
        'primary_languages': primary_languages,
        'secondary_languages': [x for x in all_languages_dict.keys() if x not in primary_languages],
        'all_tags': sortdict(all_tags_dict, sorted(all_tags_dict, key=lambda x : x.name)),
        'all_favorites': sortdict(all_favorites_dict, sorted(all_favorites_dict)),
        'default_lang': default_lang
    })

@login_required
def import_data(request):
    # TODO : Do some filters on files uploaded (json only, injection, etc.)
    if request.method == 'POST':

        #######################
        #### Database info ####
        #######################

        isvalid = True
        if 'text_file' in request.FILES:
            database_info, col_info = get_database_info(request.FILES['text_file'])
            db_name = database_info["name"]
        elif 'tsv_file' in request.FILES:
            database_info, col_info = {}, {}
            db_name = os.path.splitext(request.FILES['tsv_file'].name)[0]
        else:
            messages.error(request, ("Aucun fichier fourni !"))
            isvalid = False

        if isvalid:
            # Handle changing database name
            db_new_code = db_name.replace(" ", "")
            if "oldname" in database_info.keys():
                db_old_code = database_info["oldname"].replace(" ", "")
            else:
                db_old_code = db_new_code

            # Check if database exists, else create it
            db_filter = Database.objects.filter(code=db_old_code)
            if not db_filter.exists():
                db = Database.objects.create(code=db_new_code, name=db_name)
            else:
                db = db_filter[0]
                db.name = db_name
                db.code = db_new_code

            # Set database info from text file
            for key in database_info:
                if key == "tags":
                    tags = []
                    for tag in database_info["tags"]:
                        tag_filter = Tag.objects.filter(name=tag.capitalize())
                        if not tag_filter.exists(): # Create tag
                            tag = Tag.objects.create(name=tag.capitalize())
                            tags.append(tag)
                        else:
                            tags.append(tag_filter[0])
                    # Delete old many to many tags and save new ones
                    save_many_relations("tags", db, tags)
                elif key != "champs oblig":
                    setattr(db, key, database_info[key])
            db.save()

            # Load TSV file
            if 'tsv_file' in request.FILES:
                data_df = load_tsv_file(request.FILES['tsv_file'])
                word_col_idx = int(request.POST.get("word_col"))

                # Re-importing a TSV with the same name overwrites the existing database (columns and words),
                # all in one transaction: nothing is lost if the import fails.
                with transaction.atomic():
                    # Database columns
                    col_dict = {}
                    if len(data_df) > 0:
                        # Overwrite: drop the old columns first, otherwise get_column_info tries to re-create
                        # columns whose code differs from the file header (e.g. "NewsCDPc." -> "NewsCDPc_")
                        # and hits the unique (database, code) constraint.
                        DatabaseColumn.objects.filter(database=db).delete()
                        col_dict = get_column_info(data_df, db, database_info, col_info, word_col_idx)

                    ################################
                    #### Create DatabaseObjects ####
                    ################################

                    word_col = data_df.columns[word_col_idx]

                    # 1. Vectorised cleaning (replaces cell-by-cell strip / isnull / isinf)
                    # (.str.strip() would turn every non-string value of a mixed column into NaN,
                    # so only real strings are stripped, as the old cell-by-cell loop did)
                    for c in data_df.select_dtypes(include=["object", "string"]).columns:
                        data_df[c] = data_df[c].map(lambda v: v.strip() if isinstance(v, str) else v) # remove unwanted space at the start and end of string
                    num_cols = [c for c in data_df.columns
                                if c != word_col and c in col_dict and col_dict[c].type in (ColType.INT, ColType.FLOAT)]
                    data_df[num_cols] = data_df[num_cols].replace([np.inf, -np.inf], np.nan)

                    # 2. min / max of each numeric column
                    for c in num_cols:
                        if data_df[c].notna().any():
                            col_dict[c].min = data_df[c].min()
                            col_dict[c].max = data_df[c].max()

                    # 3. jsonData : one conversion to dicts (NaN -> None)
                    clean_names = {c: DatabaseColumn.cleanColName(c) for c in data_df.columns if c != word_col}
                    values = data_df.drop(columns=word_col).rename(columns=clean_names)
                    values = values.astype(object).where(values.notna(), None)
                    objs = [
                        DatabaseObject(database=db, ortho=ortho, jsonData=json_data)
                        for ortho, json_data in zip(data_df[word_col], values.to_dict("records"))
                        if not pd.isnull(ortho)
                    ]
                    nb_skipped = len(data_df) - len(objs)
                    if nb_skipped:
                        messages.warning(request, f"{nb_skipped} ligne(s) sans mot ignorée(s).")

                    DatabaseObject.objects.filter(database=db).delete()
                    # batch_size avoids one gigantic INSERT. Ignore conflicts to ignore duplicates within the file.
                    DatabaseObject.objects.bulk_create(objs, ignore_conflicts=True, batch_size=5000)
                    DatabaseColumn.objects.bulk_update(col_dict.values(), fields=["min", "max"])
                # Update database number of rows
                db.nbRows = DatabaseObject.objects.filter(database=db).count()
                db.save()
            # Update column mandatory/description fields as they can be updated in text file
            mandatory_columns = database_info["champs oblig"]
            col_to_update = DatabaseColumn.objects.filter(database=db)
            for col in col_to_update:
                col.mandatory = col.name.lower() in mandatory_columns
                col.description=None if col.name.lower() not in col_info else col_info[col.name.lower()]
            DatabaseColumn.objects.bulk_update(col_to_update, fields=["mandatory", "description"])
            messages.success(request, (f"{db_name} importée !"))
            cache.clear()  # Clear cache to avoid strange request handling in datatable (strange interaction between cache and new data in postgresql). If issue persists, consider reloading gunicorn (not recommended from client side on production)
            connections.close_all() # fresh connections
            optimizer = DatabaseIndexOptimizer(connection)
            optimizer.full_optimization('openlexiconApp_databaseobject', 'ortho')
            reloadGunicorn() # reload workers
    return render(request, 'importForm.html')

# https://github.com/umesh-krishna/django_serverside_datatable/tree/master
class ItemListView(ServerSideDatatableView):
    def get(self, request, *args, **kwargs):
        try:
            column_list = kwargs.get('column_list') # column_list is provided by home view, we always have a column_list in ItemListView
            column_list = column_list.split(",")
        except AttributeError: # no column_list -> no columns selected
            column_list = []
        self.dbColMap = DbColMap(column_list)
        return super(ItemListView, self).get(request, *args, **kwargs)
