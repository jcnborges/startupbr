import os
import json
import codecs
import shutil

#--------------------------------------------------------------------------------
# StartupBR
#--------------------------------------------------------------------------------
# Nome: util.py 
# Descricao: Script utilitario, aqui se encontram rotinas de I/O e manipulacao de arquivos.
# Autor:      
#       Julio Cesar B. da Silveira Nardelli - julio.2018@alunos.utfpr.edu.br
# Versao: 0.1
# Data: 2019-10-29
# Historico:
#       Versao 0.1: Criacao do codigo.
#--------------------------------------------------------------------------------

#----------------------------------------------------------
# Declaracao de constantes
#----------------------------------------------------------
ARQ_HIST_BUSCAS = 'historico_buscas_linkedin.json'
HTML_DIR = "./html/"

#----------------------------------------------------------
# Definicao de procedures 
#----------------------------------------------------------
def gravarHistoricoBuscas(listHistBuscas):
    with open(ARQ_HIST_BUSCAS, 'w') as f:
        json.dump(listHistBuscas, f)

def lerHistoricoBuscas():
    with open(ARQ_HIST_BUSCAS, 'r') as f:
        return json.load(f)
        
def gravarHTML(page_source,  file_path):
    with codecs.open(file_path, 'w',  "utf-8") as f:
        f.write(page_source)
        
def removerDir(dir_path):
    if os.path.exists(dir_path):
        shutil.rmtree(dir_path)
