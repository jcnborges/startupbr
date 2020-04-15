@echo off
cls

echo ================================================
echo                  Einsteinbot
echo      Robo de Automacao de Coleta de Dados
echo                      by
echo      Diretoria de Marketing e Planejamento
echo ================================================

set /p id_busca="id_busca = "
set query={\"_id_busca\": {\"$oid\": \"%id_busca%\"}}
mongoexport.exe --db=einsteinbot --collection=perfis_linkedin --query="%query%" --out=perfis.json --jsonArray
