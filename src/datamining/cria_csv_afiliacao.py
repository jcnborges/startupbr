#!/usr/bin/env python3

import json
import csv

ARQ_HIST_BUSCAS = 'json/buscas.json'
ARQ_PERFIS = 'json/perfis.json'
CSV_OUT = 'csv/afiliacao.csv'

def buscarHistBusca(buscaid, histBuscas):
    for busca in histBuscas:
        if busca["_id"] == buscaid:
            return busca
    return None

histBuscas = None
with open(ARQ_HIST_BUSCAS, 'r') as f:
    histBuscas = json.load(f)
    
perfis = None
with open(ARQ_PERFIS, 'r') as f:
    perfis = json.load(f)    


colunas = ["startupId", "startup", "founder", "fieldOfStudy", "degreeName", "fieldOfStudy_pt", "degreeName_pt", "start", "end", "schoolName", "google_place_name", "latitude", "longitude", "endereco", "endereco_detalhe"]
result = []
for perfil in perfis:  
    busca = buscarHistBusca(perfil["_id_busca"], histBuscas)
    for ed in perfil["educacao"]:
        r = []
        r.append(busca["nome"])
        r.append(busca["descricao"])
        r.append(perfil["_id"]["$oid"])
        r.append(ed["fieldOfStudy"] if "fieldOfStudy" in ed.keys() else "")
        r.append(ed["degreeName"] if "degreeName" in ed.keys() else "")
        r.append(ed["fieldOfStudy_pt"] if ed["fieldOfStudy_pt"] != None else "")
        r.append(ed["degreeName_pt"] if ed["degreeName_pt"] != None else "")
        if "dateRange" in ed.keys():
            r.append(ed["dateRange"]["start"]["year"] if "start" in ed["dateRange"].keys() else "")
            r.append(ed["dateRange"]["end"]["year"] if "end" in ed["dateRange"].keys() else "")
        else:
            r.append("")
            r.append("")
        r.append(ed["schoolName"] if "schoolName" in ed.keys() else "")
        if ed["google_place"] != None:
            r.append(ed["google_place"]["name"] if "name" in ed["google_place"].keys() else "")
            if "geometry" in ed["google_place"].keys():
                r.append(ed["google_place"]["geometry"]["location"]["lat"])
                r.append(ed["google_place"]["geometry"]["location"]["lng"])
            r.append(ed["google_place"]["formatted_address"] if "formatted_address" in ed["google_place"].keys() else "")
            r.append(ed["google_place"]["plus_code"]["compound_code"] if "plus_code" in ed["google_place"].keys() else "")
        else:
            r.append("")
            r.append("")
            r.append("")
            r.append("")
            r.append("")
        result.append(r)
            
with open(CSV_OUT, mode = 'w', newline = '', encoding='latin-1', errors = 'ignore') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=';')
    spamwriter.writerow(colunas)
    for r in result:
        spamwriter.writerow(r)            
