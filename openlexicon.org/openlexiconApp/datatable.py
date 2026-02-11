# https://github.com/umesh-krishna/django_serverside_datatable
# https://pypi.org/project/django-serverside-datatable/2.1.0/#files
from django.views import View
from django.core.cache import cache
from django.http import JsonResponse, StreamingHttpResponse, HttpResponse
from django.core.exceptions import ImproperlyConfigured
from django.db import connection
from django.db.models import QuerySet, F, Q, Subquery, OuterRef, Max, Min
from django.db.models.fields.json import KeyTextTransform
from django.db.models.functions import Cast
from collections import namedtuple
import operator
from .models import ExportMode, ColType, DatabaseObject
from functools import reduce
from pyexcelerate import Workbook
import csv
import os
import io
import itertools
import base64, hashlib
from openlexicon.render_data import num_queries

order_dict = {'asc': '', 'desc': '-'}

class Echo:
    def write(self, value):
        return value

class DataTablesServer(object):
    def __init__(self, request, dbColMap):
        self.dbColMap = dbColMap
        self.databases = self.dbColMap.databases # we place self.dbColMap.databases in self.databases so we can getattr databases easily when getting cache
        self.cast_col_list = [column for column_list in self.dbColMap.column_dict.values() for column in column_list] # for cast
        self.column_list = ["ortho"] + [f"{col.database.code}__{col.code}__cast" for col in self.cast_col_list] # change pattern for column_name from database__col_name to database__col_name__cast
        # values specified by the datatable for filtering, sorting, paging
        self.request_values = request.GET
        # results from the db
        self.result_data = None
        # total in the table after filtering
        self.filtered_data_count = 0
        # total in the table unfiltered
        self.cardinality = 0
        self.user = request.user
        self.run_queries()

    def output_result(self):
        # Get min max post grouping to have less objects to aggregate
        self.get_min_max()

        # Get values
        filtered_values = self.filtered_data.values(*self.column_list)

        # Pagination
        # pages has 'start' and 'length' attributes
        pages = self.paging()
        # If index is in 20000 last ones, reverse queryset to get faster indexing. Inspired by : https://www.reddit.com/r/django/comments/4dn0mo/how_to_optimize_pagination_for_large_queryset/
        _index = int(pages.start)
        _nb_pages = int(pages.length - pages.start)
        _end_index = min(_index + _nb_pages, self.filtered_data_count)
        PAGE_THRESHOLD = 20000
        if self.filtered_data_count > PAGE_THRESHOLD * 2 and self.filtered_data_count - _index < PAGE_THRESHOLD:
            if self._sorting.startswith("-"):
                reverse_order = self._sorting[1:]
            else:
                reverse_order = f"-{self._sorting}"
            reversed_data = filtered_values.order_by(reverse_order)
            _old_index = _index
            _index = self.filtered_data_count - _end_index
            _end_index = self.filtered_data_count - _old_index
            reversed_data = reversed_data[_index:_end_index]
            data = reversed(reversed_data)
        else:
            data = filtered_values.order_by('%s' % self._sorting)
            data = data[_index:_end_index]

        self.result_data = data

        # length of filtered set
        self.cardinality = pages.length - pages.start

        output = dict()
        # output['sEcho'] = str(int(self.request_values['sEcho']))
        output['iTotalRecords'] = str(self.full_data_count)
        output['iTotalDisplayRecords'] = str(self.filtered_data_count)
        data_rows = []

        for row in self.result_data:
            data_row = []
            for i in range(len(self.column_list)):
                val = row[self.column_list[i]]
                data_row.append(val)
            data_rows.append(data_row)
        output['aaData'] = data_rows
        output["min_max_dict"] = self.min_max_dict
        return output

    # Data gets annotated with casted cols (useful for Integer and Float fields, to be able to compare and sort correctly)
    def annotate_cast(self, data, db = None):
        return data.annotate(
            **{f"{col.database.code}__{col.code}__cast":Cast(KeyTextTransform(col.code, "jsonData"), ColType.get_field_class(col.type)) for col in self.cast_col_list if (True if db == None else col.database == db)}
        )

    # Data gets annotated with cols from other databases (to have all info on one row)
    def annotate_subdb(self, data, db_qs, db):
        return data.annotate(
            **{f"{db.code}__{col.code}__cast":Subquery(db_qs.values(f"{db.code}__{col.code}__cast")[:1]) for col in self.cast_col_list if col.database == db}
        )

    def get_filtered_queryset(self):
        qs = DatabaseObject.objects.filter(database__in=self.databases)

        # Cast
        qs = self.annotate_cast(qs)

        # TODO : check if same column_names in several databases can be an issue
        # Group if several databases
        # https://stackoverflow.com/questions/68797164/how-to-merge-two-different-querysets-with-one-common-field-in-to-one-in-django
        # https://blog.gitguardian.com/10-tips-to-optimize-postgresql-queries-in-your-django-project/
        if len(self.databases) > 1:
            self.full_data = qs.filter(database=self.ref_db)
            for db in [db for db in self.databases if db != self.ref_db]:
                db_qs = qs.filter(database=db, ortho=OuterRef('ortho'))
                # filter out words not present in other databases
                self.full_data = self.full_data.filter(ortho__in=db_qs.values_list("ortho", flat=True))
                # ref_db is the only one for which rows will not change. If we have more than one database, we annotate the queryset of ref_db to add columns from other databases.
                self.full_data = self.annotate_subdb(self.full_data, db_qs, db)
        else:
            self.full_data = qs

        # filter after grouping
        if self._filter:
            if self._op == "or":
                self.filtered_data = self.full_data.filter(
                    reduce(operator.or_, self._filter))
            else:
                self.filtered_data = self.full_data.filter(
                    reduce(operator.and_, [x for x in self._filter])
                )
        else:
            self.filtered_data = self.full_data

        self.id_list = self.filtered_data.values_list("id", flat=True)

    def get_cache_pattern(self, compareKey):
        return f"{compareKey}={str(getattr(self, compareKey))}"

    # https://dev.to/pragativerma18/django-caching-101-understanding-the-basics-and-beyond-49p
    def get_cache_data(self):
        compareKeys = ["_filter", "databases"]
        cacheKeysOrdered = ["id_list", "full_data_count", "filtered_data_count"] # We need to get them in this order because each one depends on the other
        cacheKeys = {
            cacheKeysOrdered[0]: compareKeys[0], # id_list filter
            cacheKeysOrdered[2]: compareKeys[0], # filtered_data_count filter
            cacheKeysOrdered[1]: compareKeys[1], # full_data_count column_list
        }
        patterns = {}
        cache_data = {}
        patterns["databases"] = self.get_cache_pattern("databases")
        patterns["_filter"] = "&".join([patterns["databases"], self.get_cache_pattern("_filter")])
        listPattern = None
        for cacheKey in cacheKeysOrdered:
            pattern = base64.urlsafe_b64encode(hashlib.sha3_512(patterns[cacheKeys[cacheKey]].encode()).digest()) # use hash to have smaller cache key
            cachePattern = f"{pattern}_{cacheKey}"
            cache_data = cache.get(cachePattern)
            if cache_data is None: # set cache
                if cacheKey == "full_data_count":
                    try:
                        # Get count info
                        if len(self.databases) == 1:
                            self.full_data_count = self.ref_db.nbRows
                        else:
                            self.full_data_count = self.full_data.count()
                    except: # in case we are too late to get full_data_count from cache (and not too late for id_list)
                        self.full_data_count = self.ref_db.nbRows
                elif cacheKey == "id_list":
                    self.get_filtered_queryset()
                elif cacheKey == "filtered_data_count":
                    if not self._filter:
                        self.filtered_data_count = self.full_data_count
                    else:
                        self.filtered_data_count = self.filtered_data.count()

                # Save count info in cache
                keyVal = getattr(self, cacheKey)
                if cacheKey != "id_list":
                    cache.set(cachePattern, keyVal, timeout=3600)
                else:
                    listPattern = cachePattern # save list after we get count
            else: # get cache
                setattr(self, cacheKey, cache_data)
                if cacheKey == "id_list":
                    data = DatabaseObject.objects.filter(id__in=self.id_list)
                    data = self.annotate_cast(data, self.ref_db)
                    self.filtered_data = data
                    if len(self.databases) > 1:
                        for db in [db for db in self.databases if db != self.ref_db]:
                            db_qs = DatabaseObject.objects.filter(database=db, ortho=OuterRef('ortho'))
                            db_qs = self.annotate_cast(db_qs, db)
                            self.filtered_data = self.annotate_subdb(self.filtered_data, db_qs, db)
        if listPattern is not None: # need to set list
            if self._filter:
                self.id_list = list(self.id_list) # convert to full list of integers only if filtering (since caching is slow for big data, but filtering is even slower with jsonData)
            cache.set(listPattern, self.id_list, timeout=3600)

    def get_min_max(self):
        # Format to {"database__colName": {"min": 0, "max":0}}
        self.min_max_dict = {}
        for col in [col for col in self.cast_col_list if col.type != ColType.TEXT]:
            self.min_max_dict[f"{col.database.id}__{col.id}"] = {"min": col.min, "max": col.max}

    def run_queries(self):
        connection.close() # reset connection in case we imported database
        # the term you entered into the datatable search
        self._filter, self._op = self.filtering()
        # the document field you chose to sort
        self._sorting = self.sorting()
        if self._sorting == "":
            self._sorting = "ortho"

        # Determine database of reference (ref_db) for count and column grouping.
        if len(self.databases) > 0: # WARNING : if we deselect all columns, we will have no database left.
            # Try to take a favorite db as ref
            favorite_dbs = [x for x in self.databases if x.favorite]
            if len(favorite_dbs) > 0:
                self.ref_db = favorite_dbs[0]
            else:
                self.ref_db = self.databases[0]
        else:
            self.ref_db = None

        # Get count from cache
        self.get_cache_data()

    def filtering(self):
        # build your filter spec
        filter = []
        # search for single value (table search field)
        if (self.request_values.get('search[value]')) and (self.request_values['search[value]'] != ""):
            op = "or"
            for i in range(len(self.column_list)):
                if self.request_values['columns[%d][searchable]' % i] == 'true':
                    filter.append(
                        Q(**{'%s__regex' % self.column_list[i]: self.request_values['search[value]']}))
        # search for each column (column search field)
        else:
            op = "and"
            for i in range(len(self.column_list)):
                column_list = self.request_values.getlist(f'columns[{i}][search][value][]')
                col_elt = self.request_values.get(f'columns[{i}][search][value]')
                if (col_elt and col_elt != ""): # characters
                    is_list = False # TODO : combine regex in column filter and list in word list search
                    if self.column_list[i] == "ortho":
                        splitted_list = [x.strip().replace("\"", "").lower() for x in col_elt.splitlines()]
                        if len(splitted_list) > 1:
                            is_list = True
                            filter.append((f"{self.column_list[i]}__in", splitted_list))
                    if not is_list:
                        filter.append((f"{self.column_list[i]}__regex", col_elt))
                elif (column_list and len(column_list) == 2) : # numbers. WARNING : range does not work with JSONField on SQLite. It works with Postgresql. We need to use cast for numbers to be considered as such and not as text.
                    filter.append((f"{self.column_list[i]}__range", column_list))
        q_list = []
        for query in filter:
            q_list.append(Q(query))
        return q_list, op

    def sorting(self):
        order = ''
        if ("order[0][column]" in self.request_values.keys()):
            # column number
            column_number = int(self.request_values["order[0][column]"])
            # sort direction
            sort_direction = self.request_values['order[0][dir]']

            order = ('' if order == '' else ',') +order_dict[sort_direction]+self.column_list[column_number]

        return order

    def paging(self):
        pages = namedtuple('pages', ['start', 'length'])
        if (self.request_values['start'] != "") and (self.request_values['length'] != -1):
            pages.start = int(self.request_values['start'])
            pages.length = pages.start + int(self.request_values['length'])

        return pages


class ServerSideDatatableView(View):
    dbColMap = None
    model = None

    def export(self, table, mode):
        qs = table.filtered_data.values_list(*table.column_list).order_by('%s' % table._sorting) # for export

        headers = [x.replace("__cast", "") for x in table.column_list]
        if mode == ExportMode.TSV:
            echo_buffer = Echo()
            delimiter = "\t"
            csv_writer = csv.writer(echo_buffer, delimiter=delimiter)

            # By using a generator expression to write each row in the queryset python calculates each row as needed, rather than all at once.
            rows = (csv_writer.writerow(row) for row in qs)
            rows = itertools.chain(f"{delimiter.join(headers)}\n", rows)

            response = StreamingHttpResponse(
                rows,
                content_type="text/tab-separated-values",
                headers={"Content-Disposition": 'attachment; filename=OpenLexicon.tsv'}
            )

        # https://hakibenita.com/python-django-optimizing-excel-export
        # https://github.com/kz26/PyExcelerate
        elif mode == ExportMode.EXCEL:
            stream = io.BytesIO()

            workbook = Workbook()

            data = [headers] + list(qs)
            sheet = workbook.new_sheet("OpenLexicon", data=data)

            workbook.save(stream)
            stream.seek(0)
            # TODO : try to make this work with StreamingHttpResponse
            response = HttpResponse(stream.read(), content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
            response['Content-Disposition'] = 'attachment; filename=OpenLexicon.xlsx'
        else:
            raise Exception("Invalid export format")

        return response


    def get(self, request, *args, **kwargs):
        export_mode = request.GET.get("export_mode")
        if export_mode != None and not request.GET.get("export_post"): # get ajax url for real export
            return JsonResponse({"url": request.build_absolute_uri()}, safe=False)
        table = DataTablesServer(
            request, self.dbColMap)
        if export_mode != None:
            return self.export(table, export_mode)
        else:
            return JsonResponse(table.output_result(), safe=False)
