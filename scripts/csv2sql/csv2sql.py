#!/usr/bin/env python3
# Time-stamp: <2020-02-07 10:43:59 christophe@pallier.org>

""" Convert lexique383.tsv into a msqlite dabase """

import sys
import os.path as op
from pandas import read_csv
import sqlite3
#from tqdm import tqdm


if not op.isfile('Lexique383.csv'):
    try:
        a = read_csv('http://www.lexique.org/databases/Lexique383/Lexique383.tsv', delimiter='\t')
    except:
        sys.exit(1)
    a.to_csv('Lexique383.tsv', sep='\t')

a = read_csv('Lexique383.tsv', delimiter='\t')

conn = sqlite3.connect('lexique383.db')
c = conn.cursor()

# create table
#c.execute('''CREATE TABLE Lexique (ortho text, cgram text, freq real)''')
# or
#c.execute('''OPEN Lexique''')

for r in a.iterrows():
    cmd = f'INSERT INTO Lexique VALUES ("{r[1].ortho}", "{r[1].cgram}", {r[1].freqlivres})'
    print(cmd)
    c.execute(cmd)

# save the changes and close the connection
conn.commit()
conn.close()

