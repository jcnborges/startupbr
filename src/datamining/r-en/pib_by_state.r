library(ggplot2)
library(scales)
library(dplyr)
library(ggrepel)

pib_growing_tax <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/pib_growing_tax_by_state.csv", header=TRUE, sep=";")
pib_growing_tax$PIB <- pib_growing_tax$PIB / 1e6

pib_growing_tax = pib_growing_tax[pib_growing_tax$Region == "Sul",]

pib_growing_tax <- pib_growing_tax %>%
  arrange(desc(pib_growing_tax$State))

plot <- ggplot(data = pib_growing_tax, aes(x = pib_growing_tax$Ano, y = pib_growing_tax$PIB, group = pib_growing_tax$State)) #+ ggtitle("Evolução do PIB (R$ bilhões) de 2002 até 2017")
plot <- plot + geom_line(aes(color = pib_growing_tax$State)) + geom_point(aes(color = pib_growing_tax$State))
plot <- plot + scale_y_continuous(name = "PIB (R$ bilhões)", trans = 'log10', breaks = c(60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000)) + annotation_logticks(sides="l", base = 10, scaled = TRUE) + scale_x_continuous(name = "Ano", limits = c(2001, 2018), breaks = c(2002, 2007, 2012, 2017)) + labs(color = "Região")
plot

df = pib_growing_tax[pib_growing_tax$Ano == 2017,]

df <- df %>%
  arrange(desc(df$State)) %>%
  mutate(pct = df$PIB / sum(df$PIB))

df <- df %>%
  mutate(lab.ypos = cumsum(df$pct) - 0.5 * df$pct)

# participacao_pib_2017

plot <- ggplot(data = df, aes(x = "", y = pct, fill = State))
plot <- plot + geom_bar(width = 1, stat = "identity", color = "white")
plot <- plot + coord_polar("y", start = 0) + theme_void() + labs(fill = "Estado")
plot <- plot + geom_text_repel(aes(x = 1.4, y = lab.ypos, label = percent_format(accuracy = 0.1)(round(pct, digits = 3))), 
                               nudge_x = .3, 
                               segment.size = .7, 
                               show.legend = FALSE, color = "gray27")
plot