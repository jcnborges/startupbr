import time
import random
from selenium import webdriver
from selenium.webdriver import FirefoxProfile
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
from util.console import *
from bs4 import BeautifulSoup

#--------------------------------------------------------------------------------
# StartupBR
#--------------------------------------------------------------------------------
# Nome: util.py 
# Descricao: Script utilitario, aqui se encontram rotinas do web browser.
# Autor:      
#       Julio Cesar B. da Silveira Nardelli - julio.2018@alunos.utfpr.edu.br
# Versao: 0.1
# Data: 2019-10-09
# Historico:
#       Versao 0.1: Criacao do codigo.
#--------------------------------------------------------------------------------

#----------------------------------------------------------
# Declaracao de constantes
#----------------------------------------------------------
FIREFOX_PROFILE = '/home/julio/.mozilla/firefox/y2ctuql6.default'
FIREFOX_BINARY = ''
GECKODRIVER_EXE = ''
LINKEDIN_URL = 'https://www.linkedin.com'

#----------------------------------------------------------
# Definicao de procedures 
#----------------------------------------------------------

# Efetua um scroll no browser.
# n = número de passos do scroll
# t0 e t1 = intervalo (segundos) para gerar um delay randomico
# delta = tamanho de cada passo do scroll
# driver = driver do Selenium
def fazerBrowserScroll(n, t0, t1, delta, driver):
        i = 0  
        while (i < n):
            script = "window.scroll("+str(i*delta)+", "+str((i+1)*delta)+")"
            driver.execute_script(script)
            time.sleep(random.uniform(t0, t1))
            i += 1
            
# Congela o browser por um período de tempo randomico.
# t0 e t1 = intervalo (segundos) para gerar um delay randomico
def congelarBrowser(t0,  t1):
    time.sleep(random.uniform(t0, t1))

def criarDriver():
    profile = FirefoxProfile(FIREFOX_PROFILE)
    #binary = FirefoxBinary(FIREFOX_BINARY)
    #driver = webdriver.Firefox(firefox_profile=profile, firefox_binary=binary, executable_path=GECKODRIVER_EXE)
    #driver = webdriver.Firefox(firefox_binary=binary, executable_path=GECKODRIVER_EXE)
    driver = webdriver.Firefox(firefox_profile = profile)
    driver.get(LINKEDIN_URL)        
    if validarBloqueioPagina(driver.page_source):
        lerString("Digite login/senha do LinkedIn e pressione ENTER...")
    return driver

# Verifica se a pagina foi bloqueada, retorna True caso tenha sido
def validarBloqueioPagina(page_source):
    soup = BeautifulSoup(page_source, "lxml") #grab the content with beautifulsoup for parsing
    botaoLogin = soup.find("a",{"class":"nav__button-secondary"}, {"data-tracking-control-name":"signin"}) 
    limiteAlcancado = soup.find("h1",{"class":"t-20 t-black t-normal mb2"})
    return botaoLogin != None or limiteAlcancado != None   
