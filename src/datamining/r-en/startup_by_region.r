library(ggplot2)
library(scales)
library(dplyr)
library(ggrepel)

startup_growing_tax <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv-en/analysis/startup_growing_tax_by_region.csv", sep=";")

startup_growing_tax <- startup_growing_tax %>%
  arrange(desc(startup_growing_tax$Region))

l1 = summary(startup_growing_tax$QuantityStartups)[1]
l2 = summary(startup_growing_tax$QuantityStartups)[6]
plot <- ggplot(data = startup_growing_tax, aes(x = startup_growing_tax$Ano, y = startup_growing_tax$QuantityStartups, group = startup_growing_tax$Region))
plot <- plot + geom_line(aes(color = startup_growing_tax$Region)) + geom_point(aes(color = startup_growing_tax$Region))
plot <- plot + scale_y_continuous(name = "Startups", trans = 'log10', breaks = c(1, 5, 10, 50, 100, 500, 1000, 2000, 3000)) + annotation_logticks(sides="l", base = 10, scaled = TRUE) + scale_x_continuous(name = "Ano", limits = c(2006, 2019), breaks = seq(2006, 2019, 2)) + labs(color = "Região")
plot

df = startup_growing_tax[startup_growing_tax$Ano == 2019,]

df <- df %>%
  arrange(desc(df$Region)) %>%
  mutate(pct = df$QuantityStartups / sum(df$QuantityStartups))

df <- df %>%
  mutate(lab.ypos = cumsum(df$pct) - 0.5 * df$pct)

plot <- ggplot(data = df, aes(x = "", y = pct, fill = Region))
plot <- plot + geom_bar(width = 1, stat = "identity", color = "white")
plot <- plot + coord_polar("y", start = 0) + theme_void() + labs(fill = "Region")
plot <- plot + geom_text_repel(aes(x = 1.4, y = lab.ypos, label = paste(QuantityStartups, " (", percent_format(accuracy = 0.01)(round(pct, digits = 4)), ")", sep = "")), 
                               nudge_x = .3, 
                               segment.size = .7, 
                               show.legend = FALSE, color = "gray27")
plot

plot <- ggplot(data = startup_growing_tax, aes(x = as.factor(startup_growing_tax$Region), y = 100 * startup_growing_tax$GrowingTaxStartups, fill = startup_growing_tax$Region))
plot <- plot + geom_boxplot() + xlab("Região") + scale_y_continuous(name = "Crescimento anual de startups (%)", breaks = seq(5, 70, 5), limits = c(5, 70)) + labs(fill = "Região") + theme(plot.title = element_text(hjust = 0.5))
plot <- plot + stat_summary(fun.y=mean, geom="point", shape=20, size=5, color="gray27", fill="gray27")
plot

plot <- ggplot(data = startup_growing_tax, aes(x = startup_growing_tax$Ano, y = 100 * startup_growing_tax$GrowingTaxStartups, group = startup_growing_tax$Region))
plot <- plot + geom_line(aes(color = startup_growing_tax$Region)) + geom_point(aes(color = startup_growing_tax$Region))
plot <- plot + scale_y_continuous(name = "Crescimento anual de startups (%)") + scale_x_continuous(name = "Ano", limits = c(2006, 2019), breaks = seq(2006, 2019, 2)) + labs(color = "Região")
plot
