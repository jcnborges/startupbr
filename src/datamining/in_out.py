# -*- coding: utf-8 -*-
import csv

CSV_FILE = "csv/igc_2018_enriquecido.csv"
CSV_OUT = "csv/out.csv"

with open(CSV_FILE, newline = '', errors = 'ignore') as csvfile:
    spamreader = csv.reader(csvfile, delimiter = ';')
    with open(CSV_OUT, mode = 'w', newline = '', encoding='latin-1', errors = 'ignore') as csvfile_out:
        spamwriter = csv.writer(csvfile_out, delimiter=';')
        for row in spamreader:
            spamwriter.writerow(row)            


