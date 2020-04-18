# -*- coding: utf-8 -*-
import csv
import uuid
import datetime
import json

CSV_FILE = 'csv/dimorganization.csv'
ARQ_HIST_BUSCAS = 'historico_buscas_linkedin.json'

dataHora = datetime.datetime.now()
listHistBuscas = []

with open(CSV_FILE, newline = '') as csvfile:
    spamreader = csv.reader(csvfile, delimiter = ';')
    next(spamreader, None)
    for row in spamreader:
        consulta = {}
        consulta.update({"id":str(uuid.uuid1())})
        consulta.update({"nome":row[0]})
        consulta.update({"descricao":row[1]})
        consulta.update({"url_empresa":row[2]})
        consulta.update({"situacao":'Não processado'})
        consulta.update({"data_hora_criacao":dataHora.strftime("%d-%m-%y %H:%M:%S")})
        listHistBuscas.append(consulta)
        
with open(ARQ_HIST_BUSCAS, 'w') as f:
    json.dump(listHistBuscas, f)



