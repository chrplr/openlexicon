from django.shortcuts import render
from django.conf import settings
from django.http import StreamingHttpResponse
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .models import DatabaseObject, Database
from .datatable import ServerSideDatatableView
import json
import csv
import os

class Echo:
    def write(self, value):
        return value

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
        jsonDict = {}
        for item in data["data"]:
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

def export_data(request):
    queryset = DatabaseObject.objects.values_list("ortho", "phon", "lemme", "cgram", "freqlemfilms2", "freqfilms2", "nblettres", "puorth", "puphon", "nbsyll", "cgramortho")
    echo_buffer = Echo()
    csv_writer = csv.writer(echo_buffer)

    # By using a generator expression to write each row in the queryset
    # python calculates each row as needed, rather than all at once.
    # Note that the generator uses parentheses, instead of square
    # brackets – ( ) instead of [ ].
    rows = (csv_writer.writerow(row) for row in queryset)

    return StreamingHttpResponse(
        rows,
        content_type="text/csv",
        headers={"Content-Disposition": 'attachment; filename="Lexique.csv"'},
    )

# https://github.com/umesh-krishna/django_serverside_datatable/tree/master
class ItemListView(ServerSideDatatableView):
	queryset = DatabaseObject.objects.all()
	columns = ['ortho', 'phon', 'lemme', 'cgram', 'freqlemfilms2', 'freqfilms2', 'nblettres', 'puorth', 'puphon', 'nbsyll', 'cgramortho']
