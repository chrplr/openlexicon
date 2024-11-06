from django.shortcuts import render
from django.conf import settings
from django.http import StreamingHttpResponse, HttpResponse
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.db.models import Q
from .models import DatabaseObject, Database, ExportMode
from .datatable import ServerSideDatatableView
import json
import csv
import os
import io
from pyexcelerate import Workbook

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

def export_data(request, mode, search=""):
    # filter
    queryset = DatabaseObject.objects.values_list("ortho", "phon", "lemme", "cgram", "freqlemfilms2", "freqfilms2", "nblettres", "puorth", "puphon", "nbsyll", "cgramortho")
    if search != "":
        # NOTE : to change. We need to identify which columns are searchable, authorize filtering numbers etc
        queryset = queryset.filter(
            Q(ortho__contains=search) | Q(phon__contains=search) | Q(lemme__contains=search) | Q(cgram__contains=search) | Q(cgramortho__contains=search)

        )

    if mode == ExportMode.CSV:
        echo_buffer = Echo()
        csv_writer = csv.writer(echo_buffer)

        # By using a generator expression to write each row in the queryset python calculates each row as needed, rather than all at once.
        rows = (csv_writer.writerow(row) for row in queryset)

        response = StreamingHttpResponse(
            rows,
            content_type="text/csv",
            headers={"Content-Disposition": 'attachment; filename=Lexique.csv'}
        )

    # https://hakibenita.com/python-django-optimizing-excel-export
    elif mode == ExportMode.EXCEL:
        stream = io.BytesIO()

        workbook = Workbook()
        sheet = workbook.new_sheet("OpenLexicon", data=queryset)

        workbook.save(stream)
        stream.seek(0)
        # TODO : try to make this work with StreamingHttpResponse
        response = HttpResponse(stream.read(), content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
        response['Content-Disposition'] = 'attachment; filename=Lexique.xlsx'
    else:
        raise Exception("Invalid export format")

    return response

# https://github.com/umesh-krishna/django_serverside_datatable/tree/master
class ItemListView(ServerSideDatatableView):
	queryset = DatabaseObject.objects.all()
	columns = ['ortho', 'phon', 'lemme', 'cgram', 'freqlemfilms2', 'freqfilms2', 'nblettres', 'puorth', 'puphon', 'nbsyll', 'cgramortho']
