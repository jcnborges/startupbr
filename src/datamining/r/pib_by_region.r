library(ggplot2)
library(scales)
library(dplyr)

theme_update(plot.title = element_text(hjust = 0.5))

pib_growing_tax <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/pib_growing_tax_by_region.csv", header=TRUE, sep=";")
pib_growing_tax$PIB <- pib_growing_tax$PIB / 1e6

pib_growing_tax <- pib_growing_tax %>%
  arrange(desc(pib_growing_tax$Region))

plot <- ggplot(data = pib_growing_tax, aes(x = pib_growing_tax$Ano, y = pib_growing_tax$PIB, group = pib_growing_tax$Region)) #+ ggtitle("Evolução do PIB (R$ bilhões) de 2002 até 2017")
plot <- plot + geom_line(aes(color = pib_growing_tax$Region)) + geom_point(aes(color = pib_growing_tax$Region))
plot <- plot + scale_y_continuous(name = "PIB (R$ bilhões)", trans = 'log10', breaks = c(60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000)) + annotation_logticks(sides="l", base = 10, scaled = TRUE) + scale_x_continuous(name = "Ano", limits = c(2001, 2018), breaks = c(2002, 2007, 2012, 2017)) + labs(color = "Região")
plot

pct_pib = c(5.6, 10.0, 14.5, 17.0, 52.9) / 100
r = c("Norte", "Centro-Oeste", "Nordeste", "Sul", "Sudeste")
df = data.frame(pct_pib, r)

df <- df %>%
  arrange(desc(df$r)) %>%
  mutate(lab.ypos = cumsum(df$pct_pib) - 0.5 * df$pct_pib)

plot <- ggplot(data = df, aes(x = "", y = pct_pib, fill = r)) #+ ggtitle("Participação (%) do PIB em 2017")
plot <- plot + geom_bar(width = 1, stat = "identity", color = "white")
plot <- plot + coord_polar("y", start = 0) + theme_void() + labs(fill = "Região")
plot <- plot + geom_text(aes(y = lab.ypos, label = percent(pct_pib)), color = "white") + theme(plot.title = element_text(hjust = 0.5))
plot

plot <- ggplot(data = pib_growing_tax, aes(x = as.factor(pib_growing_tax$Region), y = 100 * pib_growing_tax$Growing.Tax, fill = pib_growing_tax$Region)) #+ ggtitle("Variação Anual do PIB (%) entre 2002 e 2017")
plot <- plot + geom_boxplot() + xlab("Região") + ylab("Variação do PIB (%)") + labs(fill = "Região") + theme(plot.title = element_text(hjust = 0.5))
plot <- plot + stat_summary(fun.y=mean, geom="point", shape=20, size=5, color="gray27", fill="gray27")
plot

plot <- ggplot(data = pib_growing_tax, aes(x = pib_growing_tax$Ano, y = 100 * pib_growing_tax$Growing.Tax, group = pib_growing_tax$Region)) #+ ggtitle("Variação Anual do PIB (%) entre 2002 e 2017")
plot <- plot + geom_line(aes(color = pib_growing_tax$Region)) + geom_point(aes(color = pib_growing_tax$Region))
plot <- plot + scale_y_continuous(name = "Variação do PIB (%)") + scale_x_continuous(name = "Ano", limits = c(2003, 2017), breaks = c(2003, 2007, 2010, 2014, 2017)) + labs(color = "Região")
plot


summary(pib_growing_tax$Growing.Tax)
