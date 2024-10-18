from django.shortcuts import render
from django.conf import settings
from django.http import StreamingHttpResponse
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .models import DatabaseObject
from django_serverside_datatable.views import ServerSideDatatableView
import json
import csv

class Echo:
    def write(self, value):
        return value

# https://datatables.net/examples/data_sources/server_side.html
def home(request):
    return render(request, 'openlexiconServer.html', {'table_name': settings.SITE_NAME})

def homeClient(request):
    return render(request, 'openlexiconClient.html', {'table_name': settings.SITE_NAME})

@login_required
def import_data(request):
    if request.method == 'POST' and request.FILES['json_file']:
        json_file = request.FILES['json_file']
        data = json.load(json_file)
        objs = []
        for item in data["data"]:
            dbObj = DatabaseObject()
            for attr in item.keys():
                try:
                    setattr(dbObj, attr, item[attr])
                except:
                    continue
            objs.append(dbObj)
        DatabaseObject.objects.bulk_create(objs) # bulk to avoid multiple save requests
        messages.success(request, ("Fichier importé !"))
    return render(request, 'importForm.html')

def export_data(request):
    queryset = DatabaseObject.objects.values_list("ortho", "phon", "lemme")
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
