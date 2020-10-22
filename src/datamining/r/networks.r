library(dplyr)
library(ggplot2)
library(scales)
library(ggrepel)
library(ggpubr)

escolaridade <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/escolaridade.csv", sep=";")

escolaridade %>%
  filter(Momento == 'Antes') %>%
  group_by(GrauAcademico) %>%
  summarise(n = n()) %>%
  mutate(pct = n / sum(n)) %>%
  arrange(desc(GrauAcademico)) %>%  
  mutate(lab.ypos = cumsum(pct) - 0.5 * pct) %>%
  ggplot(aes(x = "", y = pct, fill = GrauAcademico)) + 
  geom_bar(stat = "identity") + coord_polar("y", start = 0) + 
  theme_void() + labs(fill = "Grau Acadêmico") + geom_text_repel(aes(x = 1.4, y = lab.ypos, label = percent_format(accuracy = 0.1)(round(pct, digits = 3))), 
                                                                 nudge_x = .3, 
                                                                 segment.size = .7, 
                                                                 show.legend = FALSE, color = "gray27")
  
escolaridade %>%
  filter(Momento != 'NULL') %>%
  group_by(Momento, GrauAcademico) %>%
  summarise(n = n()) %>%
  mutate(pct = n / sum(n)) %>%
  arrange(desc(GrauAcademico)) %>%  
  ggplot(aes(x = Momento, y = 100 * pct, fill = GrauAcademico, label = paste(percent_format(accuracy = 0.1)(round(pct, digits = 3)), " (", n, ")", sep = ""))) + 
  geom_bar(stat = "identity") + geom_text(position = position_stack(vjust = 0.5), size = 3.5, color = "gray20") +
  ylab("% de Titulações (quantidade)") + labs(fill = "Grau Acadêmico") +
  theme_classic()

nrow(escolaridade %>%
  filter(Momento == 'Depois'))