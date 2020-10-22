# -*- coding: utf-8 -*-
import csv
import googlemaps
from google.cloud import translate_v2 as translate

CSV_FILE = 'csv/igc_2018.csv'
CSV_OUT = 'csv/out.csv'
API_KEI = 'AIzaSyBD9HJ7YmHQ9wXauubZA4y0MClpiynzlyQ'
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

result = []
try:
    with open(CSV_FILE, newline = '') as csvfile:
        gmaps = googlemaps.Client(key = API_KEI)
        gtrans = translate.Client()    
        spamreader = csv.reader(csvfile, delimiter = ';')
    
        colunas = ["ano", "cod_ies", "nome_ies", "sigla_ies", "categoria_adm", "organizacao_acad", "uf", "igc_continuo", "igc_faixa", "nome_google_place", "latitude", "longitude", "endereco", "endereco_detalhe"]
        next(spamreader, None)
        for row in spamreader:
            
            # enriquecer geo_ref
            
            ano = row[0]
            cod_ies = row[1]
            nome_ies = row[2]
            sigla_ies = row[3]
            categoria_adm = row[4]
            organizacao_acad = row[5]
            uf = row[6]
            igc_continuo = row[7]
            igc_faixa = row[8]
            nome_google_place = ""
            latitude = ""
            longitude = ""
            endereco = ""
            endereco_detalhe = ""
            categoria_empresa_pt = ""
            
            gplace = localizar(gmaps, nome_ies)
            if gplace != None:
                nome_google_place = gplace["name"]
                latitude = gplace["geometry"]["location"]["lat"]
                longitude = gplace["geometry"]["location"]["lng"]
                endereco = gplace["formatted_address"] 
                try:
                    endereco_detalhe = gplace["plus_code"]["compound_code"]
                except Exception as e:
                    print(e)
            
            r = []
            r.append(ano)
            r.append(cod_ies)
            r.append(nome_ies)
            r.append(sigla_ies)
            r.append(categoria_adm)
            r.append(organizacao_acad)
            r.append(uf)
            r.append(igc_continuo)
            r.append(igc_faixa)
            r.append(nome_google_place)
            r.append(latitude)
            r.append(longitude)
            r.append(endereco)
            r.append(endereco_detalhe)
            
            result.append(r)    
finally:
    with open(CSV_OUT, mode = 'w', newline = '') as csvfile:
        spamwriter = csv.writer(csvfile, delimiter=';')
        spamwriter.writerow(colunas)
        for r in result:
            spamwriter.writerow(r)
