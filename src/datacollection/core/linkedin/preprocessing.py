import json
from util.console import *
from util.fileIO import *
from core.linkedin.cleaning import *
from bs4 import BeautifulSoup
from pymongo import MongoClient


#--------------------------------------------------------------------------------
# StartupBR
#--------------------------------------------------------------------------------
# Nome: targeting.py 
# Descricao: Rotinas de pre-processamento de dados.
# Autor:      
#       Julio Cesar B. da Silveira Nardelli - julio.2018@alunos.utfpr.edu.br
# Versao: 0.1
# Data: 2020-01-28
# Historico:
#       Versao 0.1: Criacao do codigo.
#--------------------------------------------------------------------------------

#----------------------------------------------------------
# Declaracao de constantes
#----------------------------------------------------------

MONGODB_SERVER = "localhost"
MONGODB_PORT = 27017
CARGOS = ["ceo", "founder", "owner", "fundador", "socio", "sócio"]

#----------------------------------------------------------
# Definicao de procedures 
#----------------------------------------------------------

def processarHistBusca(listHistBuscas, dicBusca):
    try:
        writeConsole("Iniciando pré-processamento... aguarde.",  consoleType.INFO)
        id = salvarBuscaMongoDB(dicBusca)
        for seed in dicBusca["lista_seeds"]:
            if "file_path" not in seed.keys():
                continue
            file_path = seed["file_path"]
            writeConsole("Abrindo arquivo {0}...".format(file_path),  consoleType.INFO,  False)
            with open(file_path, 'r',  encoding='utf8') as f:
                soup = BeautifulSoup(f.read(), "lxml") #grab the content with beautifulsoup for parsing
                listCodes = soup.find_all("code")                
                dicProfile = None
                for aux in listCodes:
                    text = aux.text
                    dicProfile = extrairProfile(text)
                    if dicProfile != None:
                        break
            if dicProfile != None:                      
                dicProfile.update({"_id_busca":id.inserted_id})                
                if validarCargo(seed["titulo_profissional"]) or validarCargo(dicProfile["titulo_profissional"]):
                    limparProfile(dicProfile)
                    salvarPerfilLinkedinMongoDB(dicProfile)
    except Exception as  e:
        writeConsole(str(e),  consoleType.ERROR)

def extrairProfile(text):    
    try:        
        jsonProfile = json.loads(text)   
        jsonProfile.pop("data")
        jsonProfile.pop("meta")
        listObject = jsonProfile["included"]
        iterdict(listObject)
        dicProfile = {}
        dicProfile.update({"perfil":[x for x in listObject if "com.linkedin.voyager.dash.deco.identity.profile.FullProfileWithEntities" in x["recipeTypes"]][0]})
        dicProfile.update({"resumo":dicProfile["perfil"]["summary"]})
        dicProfile.update({"titulo_profissional":dicProfile["perfil"]["headline"]})
        dicProfile.update({"localidade":dicProfile["perfil"]["locationName"]})
        dicProfile.update({"certificacoes":[x for x in listObject if x["type"] == "com.linkedin.voyager.dash.identity.profile.Certification"]})
        dicProfile.update({"cursos":[x for x in listObject if x["type"] == "com.linkedin.voyager.dash.identity.profile.Course"]})
        dicProfile.update({"educacao":[x for x in listObject if x["type"] == "com.linkedin.voyager.dash.identity.profile.Education"]})
        dicProfile.update({"linguas":[x for x in listObject if x["type"] == "com.linkedin.voyager.dash.identity.profile.Language"]})
        dicProfile.update({"carreira_profissional":[x for x in listObject if x["type"] == "com.linkedin.voyager.dash.identity.profile.Position"]})
        dicProfile.update({"projetos":[x for x in listObject if x["type"] == "com.linkedin.voyager.dash.identity.profile.Project"]})
        dicProfile.update({"publicacoes":[x for x in listObject if x["type"] == "com.linkedin.voyager.dash.identity.profile.Publication"]})
        dicProfile.update({"habilidades":[x for x in listObject if x["type"] == "com.linkedin.voyager.dash.identity.profile.Skill"]})
        return dicProfile
    except:
        return None                

def iterdict(d):
    if type(d) is dict:    
        if "$type" in d.keys():
            d["type"] = d.pop("$type")
        if "$recipeTypes" in d.keys():
            d["recipeTypes"] = d.pop("$recipeTypes")
        for k in d.keys():
            iterdict(d[k])
    elif type(d) is list:
        for i in d:
            iterdict(i)
    else:
        return
 
def salvarBuscaMongoDB(dicBusca):
    client = MongoClient(MONGODB_SERVER, MONGODB_PORT)
    db = client.startupbr
    result = db.historico_buscas.find_one_and_delete({"id":dicBusca["id"]})
    if result != None and "_id" in result:
        db.perfis_linkedin.delete_many({"_id_busca":result["_id"]})
    return db.historico_buscas.insert_one(dicBusca)
    
def salvarPerfilLinkedinMongoDB(dicProfile):
    client = MongoClient(MONGODB_SERVER, MONGODB_PORT)
    db = client.startupbr
    return db.perfis_linkedin.insert_one(dicProfile)    

def validarCargo(cargo):    
    for c in CARGOS:
        if c in cargo.lower():
            return True
    return False