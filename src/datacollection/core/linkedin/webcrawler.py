import os
from util.console import *
from util.browser import *
from util.fileIO import *

#--------------------------------------------------------------------------------
# StartupBR
#--------------------------------------------------------------------------------
# Nome: targeting.py 
# Descricao: Rotinas do web crawler.
# Autor:      
#       Julio Cesar B. da Silveira Nardelli - julio.2018@alunos.utfpr.edu.br
# Versao: 0.1
# Data: 2019-10-28
# Historico:
#       Versao 0.1: Criacao do codigo.
#--------------------------------------------------------------------------------

#----------------------------------------------------------
# Declaracao de constantes
#----------------------------------------------------------
QTD_SEED_DORMIR = 20

#----------------------------------------------------------
# Definicao de procedures 
#----------------------------------------------------------
def iniciarWebCrawler(listHistBuscas, dicBusca):
    if not "lista_seeds" in dicBusca:
        writeConsole("Busca não possui seeds, não se pode iniciar o web crawler.",  consoleType.ERROR,  True)    
        return
    
    n = len(dicBusca["lista_seeds"])
    if n == 0:
        return    
    
    if not os.path.exists(HTML_DIR):
        os.mkdir(HTML_DIR)
    
    out_put_dir = HTML_DIR + dicBusca["id"] + "/"   
    if not os.path.exists(out_put_dir):
        os.mkdir(out_put_dir)
        
    driver = None
    try:
        driver = criarDriver()        
        writeConsole("Iniciando o web crawler... aguarde. O procedimento poderá levar muitas horas!",  consoleType.WARNING,  True)
        
        c = 1
        q = 1
        for seed in dicBusca["lista_seeds"]:
            if q == QTD_SEED_DORMIR - 1:
                # dorme (5 ~ 15 min) um tempo para evitar bloqueios
                q = 1
                writeConsole("\nWeb crawler em modo de suspensão (5 ~ 15 min)...",  consoleType.WARNING,  True)
                congelarBrowser(300, 900)
            
            if "file_path" in seed.keys() and os.path.exists(seed["file_path"]):
                # writeConsole("Perfil já foi coletado e gravado em {0}. Buscando próximo perfil...".format(seed["file_path"]),  consoleType.INFO,  False)
                c += 1
                continue
            
            url = LINKEDIN_URL + seed["seed_url"]
            writeConsole("\nAbrindo URL {0}... {1} de {2} ({3}%)".format(url, c,  n,  round(100 * c / n)),  consoleType.INFO,  False)                                    
            driver.get(url)            
            
            # dorme (10 ~ 30 seg) um tempo para evitar bloqueios
            # congelarBrowser(20,  40)
            # faz um scroll para evitar bloqueios
            fazerBrowserScroll(15, 1, 2.5, 300, driver)
                
            # get the page source
            page_source = driver.page_source
            if validarBloqueioPagina(page_source):
                raise Exception('A página foi bloqueada! Finalizando o web crawler...')
            
            file_path = out_put_dir + seed["seed_url"].replace("/in", "").replace("/", "") + ".html"
            gravarHTML(page_source, file_path)

            seed.update({"file_path":file_path})            
            gravarHistoricoBuscas(listHistBuscas)                
            writeConsole("Arquivo gravado com sucesso em {0}!".format(file_path),  consoleType.SUCCESS,  False)
            c += 1
            q += 1
    except Exception as  e:
        writeConsole(str(e), consoleType.ERROR) 
    finally:
        try:
            driver.close()
        except Exception as  e:
            writeConsole(str(e), consoleType.ERROR)
    
