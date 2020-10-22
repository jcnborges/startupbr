#!/usr/bin/env python3
import csv
import json
import networkx as nx
from networkx.algorithms import bipartite
from geopy.distance import great_circle

CSV_FILE = 'csv/analysis/escolaridade.csv'

with open(CSV_FILE, newline = '', encoding = 'utf-8') as csvfile:
    reader = csv.DictReader(csvfile, delimiter = ';')
    escolaridades = json.dumps([row for row in reader], ensure_ascii=False)
    escolaridades = json.loads(escolaridades)
    
result_centrality = []    
result_metrics = []   
result_assortativity = [] 
for ano in range(2006, 2020):
    print("Ano = {0}".format(ano))
    G = nx.Graph()
    for e in escolaridades:
        if (int(e["AnoCriacao"]) <= ano and e["Momento"] == "Antes"):
        #if (int(e["AnoCriacao"]) <= ano and e["Momento"] != "NULL"):
            u = {}
            u.update({"cidade":e["CidadeIES"]})
            u.update({"estado":e["EstadoIES"]})
            u.update({"regiao":e["RegiaoIES"]})
            u.update({"latitude":"" if e["LatitudeIES"] == "NULL" else e["LatitudeIES"]})
            u.update({"longitude":"" if e["LongitudeIES"] == "NULL" else e["LongitudeIES"]})            
            u.update({"categoria1":e["OrganizacaoAcademica"]})
            u.update({"categoria2":e["Categoria"]})
            u.update({"Polygon":3 if e["OrganizacaoAcademica"] == "Universidade" else 4 if e["OrganizacaoAcademica"] == "Faculdade" else 5 if e["OrganizacaoAcademica"] == "Centro Universitário" else 6})            
            u.update({"ranking1":"" if e["IGCContinuo"] == "NULL" else e["IGCContinuo"]})
            u.update({"ranking2":"" if e["IGCFaixa"] == "NULL" else e["IGCFaixa"]})
            s = {}
            s.update({"cidade":e["CidadeStartup"]})
            s.update({"estado":e["EstadoStartup"]})
            s.update({"regiao":e["RegiaoStartup"]})
            s.update({"latitude":"" if e["LatitudeStartup"] == "NULL" else e["LatitudeStartup"]})
            s.update({"longitude":"" if e["LongitudeStartup"] == "NULL" else e["LongitudeStartup"]})                        
            s.update({"categoria1":"Startup"})
            s.update({"categoria2":""})
            s.update({"Polygon":""})
            s.update({"ranking1":"" if e["P"] == "NULL" else e["P"]})
            s.update({"ranking2":""})
            G.add_node(e["SiglaIES"], **u, bipartite = 0)
            G.add_node(e["OrganizationID"], **s, bipartite = 1)            
            ed = None
            try:
                ed = G[e["SiglaIES"]][e["OrganizationID"]]
            except:
                G.add_edge(e["SiglaIES"], e["OrganizationID"], weight = 1)
    
            if ed != None:
                ed["weight"] += 1
                
    #G = nx.Graph(G.subgraph(max(nx.connected_components(G), key=len)))
    sMax = len(max(nx.connected_components(G), key=len))
    sMin = len(min(nx.connected_components(G), key=len))
    ies_nodes = {n for n, d in G.nodes(data=True) if d['bipartite'] == 0}                
    startup_nodes = set(G) - ies_nodes
    sd = []
    sc = []
    sb = []

    for n in ies_nodes:
        G.add_node(n, **{"ies":n})
        
    l = bipartite.degree_centrality(G, ies_nodes)
    for c, v in sorted(l.items(), key=lambda kv: kv[1], reverse = True):
        G.add_node(c, **{"degree":v})
        if c in ies_nodes:
            sd.append("{0} & {1:.5f}".format(c, v))
            G.add_node(c, **{"degree_ies":v})
    
    l = bipartite.closeness_centrality(G, ies_nodes, True)
    for c, v in sorted(l.items(), key=lambda kv: kv[1], reverse = True):
        s = len(nx.node_connected_component(G, c))
        v = v * (s - sMin) / (sMax - sMin)
        G.add_node(c, **{"closeness":v})
        if c in ies_nodes:            
            sc.append("{0} & {1:.5f}".format(c, v))
            G.add_node(c, **{"closeness_ies":v})
                
    l = bipartite.betweenness_centrality(G, ies_nodes)
    for c, v in sorted(l.items(), key=lambda kv: kv[1], reverse = True):
        G.add_node(c, **{"betweenness":v})
        if c in ies_nodes:                    
            sb.append("{0} & {1:.5f}".format(c, v))
            G.add_node(c, **{"betweenness_ies":v})
    
    # Spatial degree
    d0 = 0
    i = 0
    for d1 in [10, 50, 100, 250, 500, 750, 1000, 2000, 3000, 4000]:
        for node in G.nodes:
            degree = 0
            point = (G.nodes[node]["latitude"], G.nodes[node]["longitude"])
            for n in G.neighbors(node):
                p = (G.nodes[n]["latitude"], G.nodes[n]["longitude"])
                d = great_circle(point, p).km
                if d >= d0 and d <= d1:
                    degree += 1
            G.add_node(node, **{"sdg_{0}_{1}".format(i, i + 1): degree})
        d0 = d1
        i += 1
                          
    for c in G.nodes:
        r = []    
        n = G.nodes[c]
        r.append(ano)
        r.append(c)
        r.append(n['bipartite'])
        r.append(n['cidade'])
        r.append(n['estado'])
        r.append(n['regiao'])
        r.append(n['categoria1'])
        r.append(n['categoria2'])
        r.append(n['degree'])
        r.append(n['closeness'])
        r.append(n['betweenness'])
        r.append(n['sdg_0_1'])
        r.append(n['sdg_1_2'])
        r.append(n['sdg_2_3'])
        r.append(n['sdg_3_4'])
        r.append(n['sdg_4_5'])
        r.append(n['sdg_5_6'])
        r.append(n['sdg_6_7'])
        r.append(n['sdg_7_8'])
        r.append(n['sdg_8_9'])
        r.append(n['sdg_9_10'])
        r.append(n['ranking1'])
        r.append(n['ranking2'])
        result_centrality.append(r)
            
    r = []
    r.append(ano)
    r.append(len(G.nodes))
    r.append(len(G.edges))
    r.append(nx.is_connected(G))
    r.append(nx.number_connected_components(G))
    r.append(bipartite.density(G, ies_nodes))
    dg_startups, dg_ies = bipartite.degrees(G, ies_nodes, weight = "weight")
    s = 0
    for c, v in dg_ies:
        s += v
    r.append(s / len(ies_nodes))
    s = 0
    for c, v in dg_startups:
        s += v
    r.append(s / len(startup_nodes))
    r.append(bipartite.average_clustering(G))
    r.append(bipartite.average_clustering(G, ies_nodes))
    r.append(bipartite.average_clustering(G, startup_nodes))
    result_metrics.append(r)
    
    r = []
    r.append(ano)
    r.append(nx.attribute_assortativity_coefficient(G, 'cidade'))
    r.append(nx.attribute_assortativity_coefficient(G, 'estado'))
    r.append(nx.attribute_assortativity_coefficient(G, 'regiao'))
    result_assortativity.append(r)
    
    nx.write_gexf(G, "gexf/rede_{0}.gexf".format(ano), encoding = 'utf-8')

colunas = ["ano","node","bipartite","cidade","estado","regiao","categoria1","categoria2","degree","closeness","betweenness","sdg_0_1","sdg_1_2","sdg_2_3","sdg_3_4","sdg_4_5","sdg_5_6","sdg_6_7","sdg_7_8","sdg_8_9","sdg_9_10","ranking1","ranking2"]    
with open("csv/centralities.csv".format(ano), mode = 'w', newline = '') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=';')
    spamwriter.writerow(colunas)
    for r in result_centrality:
        spamwriter.writerow(r)

colunas = ["ano","nós","arestas","conexo","componentes","densidade","avg_degree_ies","avg_degree_startup","avg_clustering","avg_clustering_ies","avg_clustering_startup"]
with open("csv/metrics.csv".format(ano), mode = 'w', newline = '') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=';')
    spamwriter.writerow(colunas)
    for r in result_metrics:
        spamwriter.writerow(r)

colunas = ["ano","cidade","estado","regiao"]
with open("csv/assortativity.csv".format(ano), mode = 'w', newline = '') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=';')
    spamwriter.writerow(colunas)
    for r in result_assortativity:
        spamwriter.writerow(r)