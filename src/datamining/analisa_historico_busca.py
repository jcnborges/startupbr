# -*- coding: utf-8 -*-
import json

ARQ_HIST_BUSCAS = 'historico_buscas_linkedin_processado.json'
CARGOS = ["ceo", "founder", "owner", "fundador", "socio", "sócio"]

def fundador(cargo):
    for c in CARGOS:
        if c in cargo.lower():
            return True
    return False

histBuscas = None
with open(ARQ_HIST_BUSCAS, 'r') as f:
    histBuscas = json.load(f)
    
c = 0   
s = 0 
d = 0
p = 0
f = 0
for busca in histBuscas:
    if (busca["situacao"] == "Processado com sucesso" and "situacaoWebCrawler" in busca.keys()):
        s += 1   
        d += len(busca["lista_seeds"])
        for seed in busca["lista_seeds"]:
            cargo = seed["titulo_profissional"]            
            if "file_path" in seed.keys():
                p += 1           
                if fundador(cargo):
                    f += 1
    c += 1    
    
print("Total: {0}".format(c))
print("Sucesso: {0}".format(s))
print("Seeds: {0}".format(d))
print("HTML: {0}".format(p))
print("Fundador: {0}".format(f))


