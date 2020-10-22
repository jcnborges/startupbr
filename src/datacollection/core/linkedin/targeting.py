import datetime
import uuid
import math
from util.console import *
from util.browser import *
from util.fileIO import *
from core.linkedin.webcrawler import *
from core.linkedin.preprocessing import *
from bs4 import BeautifulSoup

#--------------------------------------------------------------------------------
# StartupBR
#--------------------------------------------------------------------------------
# Nome: targeting.py 
# Descricao: Gestao de buscas do linkedin (geracao de seeds para o crawler).
# Autor:      
#       Julio Cesar B. da Silveira Nardelli - julio.2018@alunos.utfpr.edu.br
# Versao: 0.1
# Data: 2019-10-02
# Historico:
#       Versao 0.1: Criacao do codigo.
#--------------------------------------------------------------------------------

#----------------------------------------------------------
# Declaracao de constantes
#----------------------------------------------------------

LINKEDIN_URL = 'https://www.linkedin.com'
# suporta no máximo 5 operadores lógicos
TITLE_FILTER = '&origin=FACETED_SEARCH&title=(ceo%20OR%20founder%20OR%20owner%20OR%20fundador%20OR%20socio)%20NOT%20(product%20owner)'
QTD_BUSCA_DORMIR = 30

class situacaoBusca:
    NAO_PROCESSADO = 'Não processado'
    EM_EXECUCAO = 'Em execução'
    PROCESSADO_SUCESSO = 'Processado com sucesso'
    PROCESSADO_ERRO = 'Processado com erros'

#----------------------------------------------------------
# Definicao de procedures 
#----------------------------------------------------------

def fazerNovaBusca(listHistBuscas):
    writeConsole("=======================",  consoleType.WARNING,  False)
    writeConsole("    1. Nova busca      ",  consoleType.WARNING,  False)
    writeConsole("=======================",  consoleType.WARNING,  False)
    nome = lerString("nome = ")
    descricao = lerString("descricao = ")
    url = lerString("url = ")
    dataHora = datetime.datetime.now()
    try:
        consulta = {}
        consulta.update({"id":str(uuid.uuid1())})
        consulta.update({"nome":nome})
        consulta.update({"descricao": descricao})
        consulta.update({"url":url})
        consulta.update({"situacao":situacaoBusca.NAO_PROCESSADO})
        consulta.update({"data_hora_criacao":dataHora.strftime("%d-%m-%y %H:%M:%S")})
        listHistBuscas.append(consulta)
        gravarHistoricoBuscas(listHistBuscas)
        writeConsole(strBusca(consulta),  consoleType.SUCCESS,  False)
    except Exception as  e:
        writeConsole(str(e),  consoleType.ERROR)

def recuperarBuscasAnteriores(listHistBuscas):
    writeConsole("=========================",  consoleType.WARNING,  False)
    writeConsole("  2. Buscas anteriores   ",  consoleType.WARNING,  False)
    writeConsole("=========================",  consoleType.WARNING,  False)
    n = 1
    for dic in reversed(listHistBuscas):
         writeConsole("{0}.\n{1}".format(n, strBusca(dic)),  consoleType.SUCCESS,  False)
         n += 1
    writeConsole("{0}. Voltar".format(n),  consoleType.WARNING,  False)
    i = lerInteiro("Opção desejada: ")
    while i < 1 or i > n:
        writeConsole("Opção inválida!",  consoleType.ERROR)
        i = lerInteiro("Opção desejada: ")
    if i < n:
        menuBusca(listHistBuscas,listHistBuscas[len(listHistBuscas)-i])
        recuperarBuscasAnteriores(listHistBuscas)

def coletarSeedsTodasBuscas(listHistBuscas):
    writeConsole("==================================",  consoleType.WARNING,  False)
    writeConsole("  2. Coleta Seeds Todas Buscas    ",  consoleType.WARNING,  False)
    writeConsole("==================================",  consoleType.WARNING,  False)
    n = 1
    q = 1
    driver = None
    try:
        for dic in reversed(listHistBuscas):        
            writeConsole("Processando busca {0} de {1} ({2:.2f}%)...".format(n, len(listHistBuscas), 100 * (n / len(listHistBuscas))),  consoleType.WARNING)                
            writeConsole("{0}".format(strBusca(dic)),  consoleType.SUCCESS,  False)                
            if dic["situacao"] not in [situacaoBusca.PROCESSADO_SUCESSO, situacaoBusca.PROCESSADO_ERRO]:
                if q == QTD_BUSCA_DORMIR - 1:
                    # dorme (5 ~ 15 min) um tempo para evitar bloqueios
                    q = 1
                    writeConsole("\nWeb crawler em modo de suspensão (5 ~ 15 min)...",  consoleType.WARNING,  True)
                    congelarBrowser(300, 900)                        
                driver = coletarSeeds(listHistBuscas, dic, True, driver)
                q += 1
            n += 1
    except Exception as  e:
            writeConsole(str(e),  consoleType.ERROR)     
    finally:
        try:
            driver.close()
        except Exception as  e:
            writeConsole(str(e),  consoleType.ERROR)          

def iniciarWebCrawlerTodasBuscas(listHistBuscas):
    writeConsole("==================================",  consoleType.WARNING,  False)
    writeConsole("  3. Web Crawler Todas Buscas     ",  consoleType.WARNING,  False)
    writeConsole("==================================",  consoleType.WARNING,  False)
    n = 1
    q = 1
    driver = None
    try:
        for dic in reversed(listHistBuscas):        
            writeConsole("Processando busca {0} de {1} ({2:.2f}%)...".format(n, len(listHistBuscas), 100 * (n / len(listHistBuscas))),  consoleType.WARNING)                
            writeConsole("{0}".format(strBusca(dic)),  consoleType.SUCCESS,  False)                
            if dic["situacao"] == situacaoBusca.PROCESSADO_SUCESSO and ("situacaoWebCrawler" not in dic.keys() or dic["situacaoWebCrawler"] not in [situacaoWebCrawler.PROCESSADO_SUCESSO, situacaoWebCrawler.EM_EXECUCAO]) and n not in [2966, 3919]:
                if q == QTD_BUSCA_DORMIR - 1:
                    # dorme (5 ~ 15 min) um tempo para evitar bloqueios
                    q = 1
                    writeConsole("\nWeb crawler em modo de suspensão (5 ~ 15 min)...",  consoleType.WARNING,  True)
                    congelarBrowser(300, 900)                        
                driver = iniciarWebCrawler(listHistBuscas, dic, True, driver)
                q += 1
            n += 1
    except Exception as  e:
            writeConsole(str(e),  consoleType.ERROR)     
    finally:
        try:
            driver.close()
        except Exception as  e:
            writeConsole(str(e),  consoleType.ERROR)          

def iniciarProcessamentoTodasBuscas(listHistBuscas):
    writeConsole("=====================================",  consoleType.WARNING,  False)
    writeConsole("  4. Pré-processamento Todas Buscas  ",  consoleType.WARNING,  False)
    writeConsole("=====================================",  consoleType.WARNING,  False)
    n = 1
    try:
        for dic in reversed(listHistBuscas):        
            writeConsole("Pré-processando busca {0} de {1} ({2:.2f}%)...".format(n, len(listHistBuscas), 100 * (n / len(listHistBuscas))),  consoleType.WARNING)    
            writeConsole("{0}".format(strBusca(dic)),  consoleType.SUCCESS,  False)
            if dic["situacao"] == situacaoBusca.PROCESSADO_SUCESSO and "situacaoWebCrawler" in dic.keys():
                processarHistBusca(listHistBuscas, dic)
            n += 1
    except Exception as  e:
            writeConsole(str(e),  consoleType.ERROR)     
            
def strBusca(dicBusca):
    str = "{\n"
    for k in sorted(dicBusca):
        if (k != "lista_seeds"):
            str = str + "  {0}: {1}\n".format(k, dicBusca[k])
    return str + "}"

def strSeed(dicSeed):
    str = "{\n"
    for k in sorted(dicSeed):
        str = str + "  {0}: {1}\n".format(k, dicSeed[k])
    return str + "}"

def menuBusca(listHistBuscas, dicBusca):
    writeConsole("=========================",  consoleType.WARNING,  False)
    writeConsole("   Detalhes da busca     ",  consoleType.WARNING,  False)
    writeConsole("=========================",  consoleType.WARNING,  False)
    writeConsole(strBusca(dicBusca),  consoleType.SUCCESS,  False)
    writeConsole("1. Coletar seeds.",  consoleType.WARNING,  False)
    writeConsole("2. Iniciar web crawler.",  consoleType.WARNING,  False)
    writeConsole("3. Pré-processamento.",   consoleType.WARNING,  False)
    writeConsole("4. Excluir.",  consoleType.WARNING,  False)
    writeConsole("5. Voltar.",  consoleType.WARNING,  False)
    i = lerInteiro("Opção desejada: ")
    while i < 1 or i > 5:
        writeConsole("Opção inválida!",  consoleType.ERROR)
        i = lerInteiro("Opção desejada: ")
    if i == 1: 
        coletarSeeds(listHistBuscas, dicBusca)
    elif i == 2:
        iniciarWebCrawler(listHistBuscas, dicBusca)        
    elif i ==3:
        processarHistBusca(listHistBuscas, dicBusca)        
    elif i == 4:
        excluirBusca(listHistBuscas, dicBusca)

def excluirBusca(listHistBuscas, dicBusca):
    writeConsole("Confirmar a exclusão da busca selecionada?",  consoleType.WARNING,  False)
    writeConsole("1. Sim.",  consoleType.WARNING,  False)
    writeConsole("2. Não.",  consoleType.WARNING,  False)
    i = lerInteiro("Opção desejada: ")
    while i < 1 or i > 2:
        writeConsole("Opção inválida!",  consoleType.ERROR)
        i = lerInteiro("Opção desejada: ")
    if i == 2:
        return
    try:
        removerDir(HTML_DIR + dicBusca["id"])
        listHistBuscas.remove(dicBusca)
        gravarHistoricoBuscas(listHistBuscas)
        writeConsole("Busca excluída com sucesso!",  consoleType.SUCCESS,  False)
    except Exception as  e:
        writeConsole(str(e),  consoleType.ERROR)  

def coletarSeeds(listHistBuscas,  dicBusca, continua = False, driver = None):
    if not continua:
        writeConsole("Deseja iniciar a coleta de seeds?",  consoleType.WARNING,  False)
        writeConsole("1. Sim.",  consoleType.WARNING,  False)
        writeConsole("2. Não.",  consoleType.WARNING,  False)
        i = lerInteiro("Opção desejada: ")
        while i < 1 or i > 2:
            writeConsole("Opção inválida!",  consoleType.ERROR)
            i = lerInteiro("Opção desejada: ")
        if i == 2: 
            return
    try:
        if (driver == None):
            driver = criarDriver()
        dataHora = datetime.datetime.now()
        
        totalResults = None
        totalPaginas = None
        pageStart = 1
        flagInicio = False
        if (dicBusca["situacao"] in [situacaoBusca.EM_EXECUCAO, situacaoBusca.PROCESSADO_ERRO] and "ultima_pagina_processada_exito" in dicBusca.keys()):
            if not continua:
                writeConsole("Aparentemente uma execução anterior foi interrompida. Deseja continuar no ponto em que ela parou?",  consoleType.INFO,  False)
                writeConsole("1. Sim, desejo continuar do ponto em que parou.",  consoleType.WARNING,  False)
                writeConsole("2. Não, quero que a coleta reinicie do começo.",  consoleType.WARNING,  False)
                i = lerInteiro("Opção desejada: ")
                while i < 1 or i > 2:
                    writeConsole("Opção inválida!",  consoleType.ERROR)
                    i = lerInteiro("Opção desejada: ")
                if (i == 1):
                    totalResults = dicBusca["totalSeeds"]
                    totalPaginas = dicBusca["totalPaginas"]
                    pageStart = dicBusca["ultima_pagina_processada_exito"] + 1                
                else:
                    flagInicio = True
            else:
                totalResults = dicBusca["totalSeeds"]
                totalPaginas = dicBusca["totalPaginas"]
                pageStart = dicBusca["ultima_pagina_processada_exito"] + 1                                
        else:
            flagInicio = True        

        if ("url" not in dicBusca.keys()):                
            driver.get(dicBusca["url_empresa"])
            page_source = driver.page_source
            soup = BeautifulSoup(page_source, "lxml") #grab the content with beautifulsoup for parsing
            url = soup.find("a", {"class":"link-without-visited-state inline-block ember-view"})
            url = url["href"]
            dicBusca.update({"url": LINKEDIN_URL + url + TITLE_FILTER})
            
        if flagInicio:                            
            driver.get(dicBusca["url"])
            # para descer a pagina um pouco para carregar todos os elementos que temos interesse        
            fazerBrowserScroll(6, 1.5, 2.5, 300, driver)
            # get the page source
            page_source = driver.page_source    
            soup = BeautifulSoup(page_source, "lxml") #grab the content with beautifulsoup for parsing
            # numero total de resultados retornados
            totalResultsBruto = soup.find("h3",{"class":"search-results__total"}) 
            totalResults = totalResultsBruto.text
            totalResults = totalResults.replace("Showing ","")
            totalResults = totalResults.replace(" results","")
            totalResults = totalResults.replace("Exibindo ","")
            totalResults = totalResults.replace(" resultados","")
            totalResults = totalResults.replace("+ de","")            
            totalResults = totalResults.replace(".","")
            totalResults = totalResults.replace("Cerca de","")
            totalResults = totalResults.replace(" resultado","")
            totalResults = totalResults.replace(" result","")
            totalResults = totalResults.strip()
            totalPaginas = math.ceil(int(totalResults)/10.0)  
            dicBusca.update({"totalSeeds":totalResults})
            dicBusca.update({"totalPaginas":totalPaginas})
            dicBusca.update({"lista_seeds":[]})
            writeConsole("{0} seeds encontrados em {1} páginas.".format(totalResults, totalPaginas),  consoleType.SUCCESS,  False) 
        
        dicBusca.update({"situacao":situacaoBusca.EM_EXECUCAO})
        dicBusca.update({"data_hora_execucao":dataHora.strftime("%d-%m-%y %H:%M:%S")})
        for page in range(pageStart, totalPaginas + 1):
            processarPagina(dicBusca,  page,  driver)
            gravarHistoricoBuscas(listHistBuscas)
        dicBusca.update({"situacao":situacaoBusca.PROCESSADO_SUCESSO})
        gravarHistoricoBuscas(listHistBuscas)
    except Exception as  e:
        writeConsole(str(e),  consoleType.ERROR) 
        dicBusca.update({"situacao":situacaoBusca.PROCESSADO_ERRO})
    finally:
        gravarHistoricoBuscas(listHistBuscas)
        if not continua:
            try:
                driver.close()
            except Exception as  e:
                writeConsole(str(e),  consoleType.ERROR)          
            return None
        else:
            if validarBloqueioPagina(driver.page_source):
                driver.close()
                raise Exception('A página foi bloqueada! Finalizando o web crawler...')
            else:
                return driver

def processarPagina(dicBusca,  page,  driver):
    writeConsole("\nProcessando página {0} de {1}...".format(page, dicBusca["totalPaginas"]),  consoleType.INFO,  False)
    if (page > 1):
        driver.get(dicBusca["url"] + "&page=" + str(page))
        fazerBrowserScroll(6, 1.5, 2.5, 300, driver)
        
    page_source = driver.page_source

    if validarBloqueioPagina(page_source):
        raise Exception('A página foi bloqueada! Finalizando o procedimento de targeting...')
    
    soup = BeautifulSoup(page_source, "lxml") #grab the content with beautifulsoup for parsing
    allResultsBruto = soup.find_all("div",{"class":"search-result__info pt3 pb4 ph0"}) 

    listSeeds = []
    if "lista_seeds" in dicBusca.keys():
        listSeeds = dicBusca["lista_seeds"]
    for resultBruto in allResultsBruto:
        dicSeed = processarSeed(resultBruto)
        if (dicSeed != None):
            listSeeds.append(dicSeed)
    
    dicBusca.update({"lista_seeds":listSeeds})
    dicBusca.update({"ultima_pagina_processada_exito":page})
    
def processarSeed(resultBruto):

    linkDetails = resultBruto.find("a",{"class":"search-result__result-link ember-view"}) 
    nomeDetails = resultBruto.find("span",{"class":"name actor-name"})
    tituloProfissionalDetails = resultBruto.find("p",{"class":"subline-level-1 t-14 t-black t-normal search-result__truncate"})
    localidadeDetails = resultBruto.find("p",{"class":"subline-level-2 t-12 t-black--light t-normal search-result__truncate"})
    profileDetail = resultBruto.find("p",{"class":"mt2 t-12 t-black--light t-normal search-result__snippets"})
        
    nome = None
    if (nomeDetails != None) :
        nome = nomeDetails.text.strip()
 
    tituloProfissional = None
    if (tituloProfissionalDetails != None) :
        tituloProfissional = tituloProfissionalDetails.text.strip()
        tituloProfissional = tituloProfissional.replace("\n", "")

    localidade = None
    if (localidadeDetails != None) :
        localidade = localidadeDetails.text.strip()
        localidade = localidade.replace("\n", "")
        
    detalhes = None
    if (profileDetail != None) :
        detalhes = profileDetail.text.strip()
        detalhes = detalhes.replace("\n", "")   
    
    link = None
    try:
       link = linkDetails['href']            
    except:
        writeConsole("Nao foi possivel recuperar link! Ignorando registro...", consoleType.ERROR)
        writeConsole(resultBruto, consoleType.ERROR)
        return None
        
    dicSeed = {}
    dicSeed.update({"nome":nome})
    dicSeed.update({"titulo_profissional":tituloProfissional})
    dicSeed.update({"localidade":localidade})
    dicSeed.update({"detalhes":detalhes})
    dicSeed.update({"seed_url":link})
    
    writeConsole("\n{0}".format(strSeed(dicSeed)),  consoleType.SUCCESS,  False)
    
    return dicSeed
