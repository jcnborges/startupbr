library(ggplot2)
library(dplyr)

metrics <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/metrics.csv", sep=";")
metrics = metrics %>%
  mutate(linha = paste(ano, nós, arestas, componentes, round(densidade, 5), round(avg_degree_ies, 5), round(avg_degree_startup, 5), round(avg_clustering_ies, 5), round(avg_clustering_startup, 5), "\\\\", "\n\r", sep = " & "))

cat(metrics$linha)

assortativity <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/assortativity.csv", sep=";")
assortativity = assortativity %>%
  mutate(linha = paste(ano, round(cidade, 5), round(estado, 5), round(regiao,5 ), "\\\\", "\n\r", sep = " & "))

cat(assortativity$linha)

centralities <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/centralities.csv", sep=";")
centralities %>%
  filter(bipartite == 1 & ano %in% c(2006, 2010, 2014, 2019)) %>%
  group_by(ano) %>%
  summarize(
    avg_sdg_0_1 = mean(sdg_0_1),
    avg_sdg_1_2 = mean(sdg_1_2),
    avg_sdg_2_3 = mean(sdg_2_3),
    avg_sdg_3_4 = mean(sdg_3_4),
    avg_sdg_4_5 = mean(sdg_4_5),
    avg_sdg_5_6 = mean(sdg_5_6),
    avg_sdg_6_7 = mean(sdg_6_7),
    avg_sdg_7_8 = mean(sdg_7_8),
    avg_sdg_8_9 = mean(sdg_8_9),
    avg_sdg_9_10 = mean(sdg_9_10)
  ) %>% ggplot() +
    geom_line(aes(x = ano, y = avg_sdg_0_1, color = "a. 0-10"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_1_2, color = "b. 10-50"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_2_3, color = "c. 50-100"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_3_4, color = "d. 100-250"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_4_5, color = "e. 250-500"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_5_6, color = "f. 500-750"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_5_6, color = "g. 750-1000"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_6_7, color = "h. 1000-2000"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_7_8, color = "i. 2000-3000"), size = 1.6) +
    geom_line(aes(x = ano, y = avg_sdg_8_9, color = "j. 3000-4000"), size = 1.6) +
    geom_point(aes(x = ano, y = avg_sdg_0_1, color = "a. 0-10"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_1_2, color = "b. 10-50"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_2_3, color = "c. 50-100"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_3_4, color = "d. 100-250"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_4_5, color = "e. 250-500"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_5_6, color = "f. 500-750"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_5_6, color = "g. 750-1000"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_6_7, color = "h. 1000-2000"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_7_8, color = "i. 2000-3000"), size = 3) +
    geom_point(aes(x = ano, y = avg_sdg_8_9, color = "j. 3000-4000"), size = 3) +
    scale_x_continuous(name = "Ano", breaks = c(2006, 2010, 2014, 2019), limits = c(2006, 2019)) +
    ylab("Grau Espacial Médio") + labs(color = "Faixa (km)") +
    theme_classic() + 
    theme(axis.text.x = element_text(size = 16)) +
    theme(axis.text.y = element_text(size = 16)) +
    theme(axis.title.x = element_text(size = 20)) +
    theme(axis.title.y = element_text(size = 20)) +
    theme(legend.text = element_text(size = 16)) +
    theme(legend.title = element_text(size = 20))

df <- centralities %>%
  filter(bipartite == 0 & ano == 2019)
pearson <- cor.test(x = df$ranking1, y = df$degree, use = "complete.obs")
df %>%
  ggplot(aes(y = degree, x = ranking1)) + geom_point() +
  geom_smooth(method = "lm", color = "red", size = 0.8) +
  ggtitle(paste("Pearson = ", signif(pearson$estimate, 3), " p-valor = ", signif(pearson$p.value, 3))) +
  ylab("Centralidade de Grau") + xlab("IGC Contínuo") + 
  theme_classic()

df <- centralities %>%
  filter(bipartite == 1 & ano == 2019 & !is.na(ranking1)) %>%
  mutate(ranking_norm = (ranking1 - min(ranking1)) / (max(ranking1) - min(ranking1)))
pearson <- cor.test(x = df$degree, y = df$ranking1, use = "complete.obs")
df %>%
  ggplot(aes(y = ranking_norm, x = degree)) + geom_point() +
  geom_smooth(method = "lm", color = "red", size = 0.8) +
  ggtitle(paste("Pearson = ", signif(pearson$estimate, 3), " p-valor = ", signif(pearson$p.value, 3))) +
  theme_classic()

c <- centralities %>%
  filter(bipartite == 0 & ano == 2019) %>%
  group_by(categoria1) %>%
  summarize(avg_degree = mean(degree), avg_betweenness = mean(betweenness), avg_closeness = mean(closeness)) %>%
  mutate(linha = paste(categoria1, round(avg_degree, 5), round(avg_betweenness, 5), round(avg_closeness,5 ), "\\\\", "\n\r", sep = " & "))

cat(c$linha)

d <- centralities %>%
  filter(bipartite == 0 & ano == 2019) %>%
  arrange(desc(degree)) %>%
  top_n(30, degree) %>%
  select(node)
  
b <- centralities %>%
  filter(bipartite == 0 & ano == 2019) %>%
  arrange(desc(betweenness)) %>%
  top_n(30, betweenness) %>%
  select(node)

c <- centralities %>%
  filter(bipartite == 0 & ano == 2019) %>%
  arrange(desc(closeness)) %>%
  top_n(30, closeness) %>%
  select(node)

df <- data.frame(posicao = seq(1, 30), degree = d, betweeness = b, closeness = c)
colnames(df) <- c("posicao", "degree", "betweeness", "closeness")
df <- df %>% 
  mutate(linha = paste(posicao, degree, betweeness, closeness, "\\\\", "\n\r", sep = " & "))
  
cat(df$linha)
  
