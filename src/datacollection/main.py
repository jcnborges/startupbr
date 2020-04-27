import time
from util.console import *
from util.fileIO import *
from core.linkedin.targeting import *

#--------------------------------------------------------------------------------
# StartupBR
#--------------------------------------------------------------------------------
# Nome: main.py 
# Descricao: App principal.
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

#----------------------------------------------------------
# Definicao de procedures 
#----------------------------------------------------------
def titulo():
    writeConsole("==========================================================",  consoleType.WARNING,  False)
    writeConsole("                       StartupBR                          ",  consoleType.WARNING,  False)
    writeConsole("          Robô de Automação de Coleta de Dados            ",  consoleType.WARNING,  False)
    writeConsole("                           by                             ",  consoleType.WARNING,  False)
    writeConsole("     Programa de Pós-Graduação em Computação Aplicada     ",  consoleType.WARNING,  False)
    writeConsole("        Universidade Tecnológica Federal do Paraná        ",  consoleType.WARNING,  False)
    writeConsole("==========================================================",  consoleType.WARNING,  False)    

def menuPrincipal():
    writeConsole("\nMenu de Opções:",  consoleType.WARNING,  False)
    writeConsole("1. Fazer nova busca.",  consoleType.WARNING,  False)
    writeConsole("2. Recuperar buscas anteriores.",  consoleType.WARNING,  False)
    writeConsole("3. Coletar seeds de todas as buscas.",  consoleType.WARNING,  False)
    writeConsole("4. Iniciar web crawler para todas as buscas.",  consoleType.WARNING,  False)    
    writeConsole("5. Sair.",  consoleType.WARNING,  False)
    i = lerInteiro("Opção desejada: ")
    while i < 1 or i > 5:
        writeConsole("Opção inválida!",  consoleType.ERROR)
        i = lerInteiro("Opção desejada: ")
    return i
    
#----------------------------------------------------------
# Rotina principal
#----------------------------------------------------------
listHistBuscas = None
try:
    listHistBuscas = lerHistoricoBuscas()
except:
    listHistBuscas = []
    
titulo()
i = 0
while i != 5:
    i = menuPrincipal()
    if i == 1: 
        fazerNovaBusca(listHistBuscas)
    elif i == 2:
        recuperarBuscasAnteriores(listHistBuscas)
    elif i == 3:
        coletarSeedsTodasBuscas(listHistBuscas)
    elif i == 4:
        iniciarWebCrawlerTodasBuscas(listHistBuscas)        
writeConsole("Programa encerrado. Espero que tenham gostado!", consoleType.INFO,  False)
time.sleep(1.5)
