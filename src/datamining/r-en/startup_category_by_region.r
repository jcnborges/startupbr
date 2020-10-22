library(ggplot2)
library(scales)
library(dplyr)
library(ggrepel)

startups_topic <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv-en/analysis/startups_topic.csv", sep=";")

startups_topic %>%
  filter(Region == "Sul") %>%
  group_by(categoria_lda) %>%
  summarize(n = n()) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(n) %>%
  mutate(categoria_lda = factor(categoria_lda, levels = categoria_lda)) %>%
  ggplot(aes(x = categoria_lda, y = n))+  geom_bar(stat="identity", color = "white", fill = "deepskyblue") + coord_flip() +
  theme(axis.title = element_blank()) + 
  geom_text(aes(
    label = paste(n, " (", percent_format(accuracy = 0.01)(round(prop, digits = 4)), ")", sep = ""), 
    y = prop, group = categoria_lda),
    position = position_dodge(width = 0.9),
    vjust = 0.5, hjust = -1, size = 3)

dd = startups_topic %>%
  filter(Region == "Centro-oeste" & Longitude.Google.Place != "NULL" & Latitude.Google.Place != "NULL")

ggmap(get_map(location = "Goiânia Brazil", zoom = 12, language = "pt-br")) +
  geom_point(data = dd, aes(x = as.numeric(as.character(Longitude.Google.Place)), y = as.numeric(as.character(Latitude.Google.Place))), alpha = 1.0, shape = 21, col = "black", fill = "blue") + 
  theme_void()

  