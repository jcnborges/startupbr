import datetime
import platform

#--------------------------------------------------------------------------------
# StartupBR
#--------------------------------------------------------------------------------
# Nome: util.py 
# Descricao: Script utilitario, aqui se encontram rotinas de console.
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

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class consoleType:
    INFO = 0
    SUCCESS = 1
    ERROR = 2
    WARNING = 3

#----------------------------------------------------------
# Definicao de procedures 
#----------------------------------------------------------
           
def lerInteiro(msg):
    try:
        return int(input(msg).lower())
    except:
        return -1
        
def lerString(msg):
    return input(msg)

def writeConsole(msg,  type,  time = True):	
	sistema = platform.system()
	if sistema == "Linux":
		writeConsoleLinux(msg,  type,  time)
	else:
		writeConsoleOther(msg, time)
	
def writeConsoleLinux(msg,  type,  time):
    color = bcolors.ENDC
    if type == 0:
        color = bcolors.OKBLUE
    elif type == 1:
        color = bcolors.OKGREEN
    elif type == 2:
        color = bcolors.FAIL
    elif type == 3:
        color = bcolors.WARNING      
    if time:
        print(color+"[{0}] {1}".format(datetime.datetime.now(), msg)+bcolors.ENDC)
    else:
        print(color+"{0}".format(msg)+bcolors.ENDC)
	
def writeConsoleOther(msg, time):          
    if time:
        print("[{0}] {1}".format(datetime.datetime.now(), msg))
    else:
        print("{0}".format(msg))
