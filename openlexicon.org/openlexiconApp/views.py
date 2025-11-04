from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import JsonResponse
from django.shortcuts import render
from .datatable import ServerSideDatatableView
from .models import DatabaseObject, Database, DatabaseColumn, ColType, Tag, Lang
from .utils import *
import math
import os
import pandas as pd

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
    all_columns = DatabaseColumn.objects.all().select_related("database").prefetch_related("database__tags").order_by("database__name", "id") # TODO : order_by id is important so that headers list will be in the same order than values list (see DbColMap and datatable). Find a more robust way ?
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
    return render(request, 'openlexiconServer.html', {
        'table_name': settings.SITE_NAME,
        'all_columns': all_columns_dict,
        'all_languages': sortdict(all_languages_dict, sorted(all_languages_dict)),
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

                # Database columns
                if len(data_df) > 0:
                    col_dict = get_column_info(data_df, db, database_info, col_info, word_col_idx)
                objs = []

                ################################
                #### Create DatabaseObjects ####
                ################################

                for index, row in data_df.iterrows():
                    jsonDict = {}
                    dbObj = DatabaseObject()
                    for col_count, col_name in enumerate(data_df.columns.values):
                        dbattr = DatabaseColumn.cleanColName(col_name)
                        itemAttr = row[col_name]
                        if isinstance(itemAttr, str):
                            itemAttr = itemAttr.strip() # remove unwanted space at the start and end of string
                        if pd.isnull(itemAttr):
                            itemAttr = None
                        if col_count == word_col_idx:
                            dbattr = "ortho"
                        else:
                            col = col_dict[col_name]
                            if itemAttr is not None and col.type in [ColType.INT, ColType.FLOAT]:
                                if math.isinf(itemAttr):
                                    itemAttr = None
                                else:
                                    if col.min == None or itemAttr < col.min:
                                        col.min = itemAttr
                                    if col.max == None or itemAttr > col.max:
                                        col.max = itemAttr
                        if col_count != word_col_idx:
                            jsonDict[dbattr] = itemAttr
                        else:
                            setattr(dbObj, dbattr, itemAttr)
                    objs.append(dbObj)
                    dbObj.jsonData = jsonDict
                    dbObj.database = db
                DatabaseObject.objects.bulk_create(objs, ignore_conflicts=True) # bulk to avoid multiple save requests. Ignore conflicts to ignore duplicates.
                DatabaseColumn.objects.bulk_update(col_dict.values(), fields=["min", "max"])
                # Update database number of rows
                db.nbRows = DatabaseObject.objects.filter(database=db).count()
                db.save()
            messages.success(request, (f"{db_name} importée !"))
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
