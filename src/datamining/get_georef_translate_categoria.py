# -*- coding: utf-8 -*-
import csv
import googlemaps
from google.cloud import translate_v2 as translate

CSV_FILE = 'csv/dimorganization.csv'
CSV_OUT = 'csv/out.csv'
API_KEI = 'AIzaSyBTZaKCSfAbbltig9-y2gQPHAurjvcK4yA'
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

result = []
try:
    with open(CSV_FILE, newline = '') as csvfile:
        gmaps = googlemaps.Client(key = API_KEI)
        gtrans = translate.Client()    
        spamreader = csv.reader(csvfile, delimiter = ';')
    
        colunas = ["id_empresa", "nome_empresa", "cidade_empresa", "categoria_empresa", "nome_google_place", "latitude", "longitude", "endereco", "endereco_detalhe", "categoria_empresa_pt"]
        next(spamreader, None)
        for row in spamreader:
            
            # enriquecer geo_ref
            
            id_empresa = row[0]
            nome_empresa = row[1]
            cidade_empresa = row[2]
            categoria_empresa = row[3]
            nome_google_place = ""
            latitude = ""
            longitude = ""
            endereco = ""
            endereco_detalhe = ""
            categoria_empresa_pt = ""
            
            gplace = localizar(gmaps, "{0} {1}".format(nome_empresa, cidade_empresa))
            if gplace == None:
                gplace = localizar(gmaps, nome_empresa)
            if gplace != None:
                nome_google_place = gplace["name"]
                latitude = gplace["geometry"]["location"]["lat"]
                longitude = gplace["geometry"]["location"]["lng"]
                endereco = gplace["formatted_address"] 
                try:
                    endereco_detalhe = gplace["plus_code"]["compound_code"]
                except Exception as e:
                    print(e)
            
            # translate categorias
            
            categoria_empresa_pt = traduzir_pt(gtrans, categoria_empresa)
            
            r = []
            r.append(id_empresa)
            r.append(nome_empresa)
            r.append(cidade_empresa)
            r.append(categoria_empresa)
            r.append(nome_google_place)
            r.append(latitude)
            r.append(longitude)
            r.append(endereco)
            r.append(endereco_detalhe)
            r.append(categoria_empresa_pt)
            
            result.append(r)    
finally:
    with open(CSV_OUT, mode = 'w', newline = '') as csvfile:
        spamwriter = csv.writer(csvfile, delimiter=';')
        spamwriter.writerow(colunas)
        for r in result:
            spamwriter.writerow(r)
