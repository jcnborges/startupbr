import googlemaps
from google.cloud import translate_v2 as translate
from util.console import *

#--------------------------------------------------------------------------------
# StartupBR
#--------------------------------------------------------------------------------
# Nome: cleaning.py 
# Descricao: Rotinas de limpeza de dados.
# Autor:      
#       Julio Cesar B. da Silveira Nardelli - julio.2018@alunos.utfpr.edu.br
# Versao: 0.1
# Data: 2020-03-23
# Historico:
#       Versao 0.1: Criacao do codigo.
#--------------------------------------------------------------------------------

#----------------------------------------------------------
# Declaracao de constantes
#----------------------------------------------------------

API_KEI = "AIzaSyBD9HJ7YmHQ9wXauubZA4y0MClpiynzlyQ"
API_LANGUAGE = "pt"

#----------------------------------------------------------
# Definicao de procedures 
#----------------------------------------------------------

def limparProfile(dicProfile):
    gmaps = googlemaps.Client(key = API_KEI)
    gtrans = translate.Client()
 
    #writeConsole("Limpando resumo...",  consoleType.INFO)   
    #if "resumo" in dicProfile.keys():
    #    dicProfile.update({"resumo_pt":traduzir_pt(gtrans, getAtributo(dicProfile, "resumo"))})
    
    #writeConsole("Limpando título profissional...",  consoleType.INFO)   
    #if "titulo_profissional" in dicProfile.keys():
    #    dicProfile.update({"titulo_profissional_pt":traduzir_pt(gtrans, getAtributo(dicProfile, "titulo_profissional"))})

    #writeConsole("Limpando localidade...",  consoleType.INFO)   
    #if "localidade" in dicProfile.keys():
    #    dicProfile.update({"localidade_pt":traduzir_pt(gtrans, getAtributo(dicProfile, "localidade"))})

    #writeConsole("Limpando certificações...",  consoleType.INFO)   
    #if "certificacoes" in dicProfile.keys():
    #    for certificacao in dicProfile["certificacoes"]:
    #        certificacao.update({"name_pt":traduzir_pt(gtrans, getAtributo(certificacao, "name"))})

    #writeConsole("Limpando cursos...",  consoleType.INFO)   
    #if "cursos" in dicProfile.keys():
    #    for curso in dicProfile["cursos"]:
    #        curso.update({"name_pt":traduzir_pt(gtrans, getAtributo(curso, "name"))})

    #writeConsole("Limpando línguas...",  consoleType.INFO)   
    #if "linguas" in dicProfile.keys():
    #    for lingua in dicProfile["linguas"]:
    #        lingua.update({"name_pt":traduzir_pt(gtrans, getAtributo(lingua, "name"))})

    #writeConsole("Limpando habilidades...",  consoleType.INFO)   
    #if "habilidades" in dicProfile.keys():
    #    for habilidade in dicProfile["habilidades"]:
    #        habilidade.update({"name_pt":traduzir_pt(gtrans, getAtributo(habilidade, "name"))})

    #writeConsole("Limpando projetos...",  consoleType.INFO)   
    #if "projetos" in dicProfile.keys():
    #    for projeto in dicProfile["projetos"]:
    #        projeto.update({"title_pt":traduzir_pt(gtrans, getAtributo(projeto, "title"))})
    #        projeto.update({"description_pt":traduzir_pt(gtrans, getAtributo(projeto, "description"))})

    #writeConsole("Limpando publicações...",  consoleType.INFO)   
    #if "publicacoes" in dicProfile.keys():
    #    for publicacao in dicProfile["publicacoes"]:
    #        publicacao.update({"name_pt":traduzir_pt(gtrans, getAtributo(publicacao, "name"))})
    #        publicacao.update({"description_pt":traduzir_pt(gtrans, getAtributo(publicacao, "description"))})

    writeConsole("Limpando dados educacionais...",  consoleType.INFO)
    if "educacao" in dicProfile.keys():
        for educacao in dicProfile["educacao"]:
            educacao.update({"google_place":localizar(gmaps, getAtributo(educacao, "schoolName"))})
            educacao.update({"degreeName_pt":traduzir_pt(gtrans, getAtributo(educacao, "degreeName"))})
            educacao.update({"fieldOfStudy_pt":traduzir_pt(gtrans, getAtributo(educacao, "fieldOfStudy"))})
                    
    #writeConsole("Limpando dados de experiência profissional...",  consoleType.INFO)   
    #if "carreira_profissional" in dicProfile.keys():
    #    for carreira_profissional in dicProfile["carreira_profissional"]:
    #        carreira_profissional.update({"google_place":localizar(gmaps, getAtributo(carreira_profissional, "companyName"))})
    #        carreira_profissional.update({"title_pt":traduzir_pt(gtrans, getAtributo(carreira_profissional, "title"))})
    #        carreira_profissional.update({"description_pt":traduzir_pt(gtrans, getAtributo(carreira_profissional, "description"))})
    
def localizar(gmaps, nomeLocalidade):
    try:
        if nomeLocalidade == None:
            return None
        place_result = gmaps.places(nomeLocalidade, language = API_LANGUAGE)
        if (place_result["status"] != "ZERO_RESULTS"):
            writeConsole("{0} -> {1}".format(nomeLocalidade, place_result["results"][0]["name"]), consoleType.SUCCESS, False)
            return place_result["results"][0]
        else:
            return None
    except Exception as  e:
        writeConsole(str(e),  consoleType.ERROR)
        return None
                
def traduzir_pt(gtrans, origem):
    try:
        if origem == None:
            return None
        trans_result = gtrans.translate(origem, API_LANGUAGE)
        writeConsole("{0} -> {1}".format(origem, trans_result["translatedText"]), consoleType.SUCCESS, False)
        return trans_result["translatedText"]
    except Exception as  e:
        writeConsole(str(e),  consoleType.ERROR)
        return None
    
def getAtributo(dic, nomeAtributo):
    if (nomeAtributo in dic.keys()):
        return dic[nomeAtributo]
    else:
        return None