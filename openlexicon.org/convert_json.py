import csv
import json
import chardet
from pathlib import Path
import warnings
import codecs
import os
BLOCKSIZE = 1048576

# https://www.askpython.com/python/examples/convert-csv-to-json

def tsv_to_json(tsv_file_path):
    #create a dictionary
    data_list = []

    #check encoding and convert to utf-8 if needed
    rawdata=open(tsv_file_path, 'rb').read()
    chardet_data = chardet.detect(rawdata)
    encoding = chardet_data["encoding"]
    enc_confidence = chardet_data["confidence"]
    if encoding != "utf-8":
        if encoding is None:
            warnings.warn("Could not detect file {0} encoding -> skip".format(tsv_file_path), Warning)
            return
        elif enc_confidence < 0.7:
            warnings.warn("Chardet confidence {1} for file {0} -> skip".format(tsv_file_path, enc_confidence), Warning)
        else:
            old_tsv = os.path.join(os.path.splitext(tsv_file_path) + "_old", ".tsv")
            os.rename(tsv_file_path, old_tsv)
            with codecs.open(old_tsv, "r", encoding) as sourceFile:
                with codecs.open(tsv_file_path, "w", "utf-8") as targetFile:
                    while True:
                        contents = sourceFile.read(BLOCKSIZE)
                        if not contents:
                            break
                        targetFile.write(contents)

    #open converted tsv as dict and add each row to data_list
    with open(tsv_file_path, encoding = 'utf-8') as csv_file_handler:
        csv_reader = csv.DictReader(csv_file_handler, delimiter="\t")
        for row in csv_reader:
            data_list.append(row)

    # write to JSON using utf-8 encoding
    json_file_path = os.path.splitext(tsv_file_path)[0] + ".json"
    print(json_file_path)
    with open(json_file_path, 'w', encoding = 'utf-8') as json_file_handler:
        json_file_handler.write(json.dumps({"data": data_list}, indent = 4))

tsv_file_path = input('Enter the absolute path of the TSV file: ')

tsv_to_json(tsv_file_path)
