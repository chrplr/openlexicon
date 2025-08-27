from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.shortcuts import render
from .datatable import ServerSideDatatableView
from .models import DatabaseObject, Database, DatabaseColumn, ColType, Tag
from .utils import *
import json
import os
import pandas as pd

# https://datatables.net/examples/data_sources/server_side.html
def home(request, column_list=[]):
    # Get default database and columns for table header format
    if column_list == []:
        column_list = default_DbColList
    else:
        column_list = DbColMap.listify_string(column_list)
    dbColMap = DbColMap(column_list)
    all_columns = DatabaseColumn.objects.all().select_related("database").prefetch_related("database__tags").order_by("database__name", "id") # TODO : order_by id is important so that headers list will be in the same order than values list (see DbColMap and datatable). Find a more robust way ?
    all_columns_dict = {}
    all_tags_dict = {}
    all_languages_dict = {}
    all_favorites_dict = {"Favorites": {}}
    for col in all_columns:
        for tag in col.database.tags.all():
            if tag.name not in all_tags_dict:
                all_tags_dict[tag.name] = {col.database: []}
        if col.database.language not in all_languages_dict:
            all_languages_dict[col.database.language] = {col.database: []}
        if col.database not in all_columns_dict:
            all_columns_dict[col.database] = []
            all_tags_dict[tag.name][col.database] = []
            all_languages_dict[col.database.language][col.database] = []
            if col.database.favorite:
                all_favorites_dict["Favorites"][col.database] = []
        all_columns_dict[col.database].append(col)
        all_tags_dict[tag.name][col.database].append(col)
        all_languages_dict[col.database.language][col.database].append(col)
        if col.database.favorite:
            all_favorites_dict["Favorites"][col.database].append(col)
    return render(request, 'openlexiconServer.html', {
        'table_name': settings.SITE_NAME,
        'columns': json.dumps(dbColMap.string_column_dict),
        'col_string': dbColMap.col_string,
        'all_columns': all_columns_dict,
        "database_order": list(dbColMap.string_column_dict.keys()),
        'all_languages': sortdict(all_languages_dict),
        'all_tags': sortdict(all_tags_dict),
        'all_favorites': sortdict(all_favorites_dict)
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
            db_code = db_name.replace(" ", "")

            # Check if database exists, else create it
            db_filter = Database.objects.filter(code=db_code)
            if not db_filter.exists():
                db = Database.objects.create(code=db_code, name=db_name)
            else:
                db = db_filter[0]

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
            messages.success(request, ("Fichier importé !"))
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
