# -*- coding: utf-8 -*-
import csv
import googlemaps
from google.cloud import translate_v2 as translate

CSV_FILE = 'csv/dimorganization_test.csv'
CSV_OUT = 'csv/out.csv'
API_KEI = 'AIzaSyCPDnOfBz4rH1xfBTdwof7m1of2nuA3CiU'
API_LANGUAGE = "pt"
        
def localizar(gmaps, nomeLocalidade):
    try:
        if nomeLocalidade == None:
            return None
        place_result = gmaps.places(nomeLocalidade, language = API_LANGUAGE)
        if (place_result["status"] != "ZERO_RESULTS"):
            print("{0} -> {1}".format(nomeLocalidade, place_result["results"][0]["name"]))
            return place_result["results"][0]
        else:
            return None
    except Exception as  e:
        print(str(e))
        return None
                
def traduzir_pt(gtrans, origem):
    try:
        if origem == None:
            return None
        trans_result = gtrans.translate(origem, API_LANGUAGE)
        print("{0} -> {1}".format(origem, trans_result["translatedText"]))
        return trans_result["translatedText"]
    except Exception as  e:
        print(str(e))
        return None

with open(CSV_FILE, newline = '') as csvfile:
    gmaps = googlemaps.Client(key = API_KEI)
    gtrans = translate.Client()    
    spamreader = csv.reader(csvfile, delimiter = ';')
    result = []
    colunas = {"id_empresa;nome_empresa;cidade_empresa;categoria_empresa;latitude;longitude;endereco;categoria_pt"}
    next(spamreader, None)
    for row in spamreader:
        
        # enriquecer geo_ref
        
        id_empresa = row[0]
        nome_empresa = row[1]
        cidade_empresa = row[2]
        categoria_empresa = row[3]
        latitude = ""
        longitude = ""
        endereco = ""
        categoria_pt = ""
        
        gplace = localizar(gmaps, "{0} {1}".format(nome_empresa, cidade_empresa))
        if gplace != None:
            latitude = gplace["geometry"]["location"]["lat"]
            longitude = gplace["geometry"]["location"]["lng"]
            endereco = gplace["formatted_address"]       
        
        # translate categorias
        
        categoria_empresa_pt = traduzir_pt(gtrans, categoria_empresa)
        result.append("{0};{1};{2};{3};{4};{5};{6}:{7}".format(id_empresa, nome_empresa, cidade_empresa, categoria_empresa, latitude, longitude, endereco, categoria_empresa_pt))    

with open(CSV_OUT, mode = 'w', newline = '') as csvfile:
    spamwriter = csv.writer(csvfile)
    spamwriter.writerow(colunas)
    for r in result:
        spamwriter.writerow(r)