from django.shortcuts import render
from django.conf import settings
from django.http import JsonResponse
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.db.models import Max, Min
from .models import DatabaseObject, Database
from .datatable import ServerSideDatatableView
import json

# https://datatables.net/examples/data_sources/server_side.html
def home(request):
    return render(request, 'openlexiconServer.html', {'table_name': settings.SITE_NAME})

@login_required
def import_data(request):
    # TODO : Do some filters on files uploaded (json only, injection, etc.)
    if request.method == 'POST' and request.FILES['json_file']:
        json_file = request.FILES['json_file']
        db_name = os.path.splitext(json_file.name)[0]
        db_filter = Database.objects.filter(name=db_name)
        if not db_filter.exists():
            db = Database.objects.create(name=db_name)
        else:
            db = db_filter[0]
        data = json.load(json_file)
        objs = []
        for item in data["data"]:
            jsonDict = {}
            dbObj = DatabaseObject()
            for attr in item.keys():
                if attr == "Word":
                    attr = "ortho"
                try:
                    setattr(dbObj, attr, item[attr])
                    jsonDict[attr] = item[attr]
                except:
                    continue
            objs.append(dbObj)
            dbObj.jsonData = jsonDict
            dbObj.database = db
        DatabaseObject.objects.bulk_create(objs) # bulk to avoid multiple save requests
        messages.success(request, ("Fichier importé !"))
    return render(request, 'importForm.html')

# https://github.com/umesh-krishna/django_serverside_datatable/tree/master
class ItemListView(ServerSideDatatableView):
	queryset = DatabaseObject.objects.all()
	columns = ['ortho', 'phon', 'lemme', 'cgram', 'freqlemfilms2', 'freqfilms2', 'nblettres', 'puorth', 'puphon', 'nbsyll', 'cgramortho']


def filter_data(request):
    if request.method == 'POST':
        # TODO : need to filter for selected db only
        # NOTE : to return min/max for slider creation
        col_data = DatabaseObject.objects.values_list(request.POST.get("colName"), flat=True).distinct()
        return JsonResponse({"min": min(col_data), "max": max(col_data)})
