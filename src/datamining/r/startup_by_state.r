library(ggplot2)
library(scales)
library(dplyr)
library(ggrepel)

startup_growing_tax <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/startup_growing_tax_by_state.csv", sep=";")

startup_growing_tax %>%
  filter(Region == "Sul" & Ano == 2019) %>%
  arrange(desc(State)) %>%
  mutate(pct = QuantityStartups / sum(QuantityStartups)) %>%
  mutate(lab.ypos = cumsum(pct) - 0.5 * pct) %>%
  ggplot(aes(x = "", y = pct, fill = State)) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0) + theme_void() + labs(fill = "Estado") +
  geom_text_repel(aes(x = 1.4, y = lab.ypos, label = paste(QuantityStartups, " (", percent_format(accuracy = 0.01)(round(pct, digits = 4)), ")", sep = "")), 
    nudge_x = .3, 
    segment.size = .7, 
    show.legend = FALSE, color = "gray27")

# códigos antigos

startup_growing_tax = startup_growing_tax[startup_growing_tax$Region == "Norte",]

startup_growing_tax <- startup_growing_tax %>%
  arrange(desc(startup_growing_tax$State))

# evolucao_startups_2006_2019

#ano = seq(2006, 2019, 1)
#startups = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
#estado = c("Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas")
#df1 = data_frame(estado = factor(estado), startups, ano)
#df2 = data_frame(estado = startup_growing_tax$State, startups = startup_growing_tax$QuantityStartups, ano = startup_growing_tax$Ano)
#df = union(df1, df2)

df <- df %>%
  arrange(desc(df$estado))

l1 = summary(df$QuantityStartups)[1]
l2 = summary(df$QuantityStartups)[6]
plot <- ggplot(data = df, aes(x = df$ano, y = df$startups, group = df$estado))
plot <- plot + geom_line(aes(color = df$estado)) + geom_point(aes(color = df$estado))
#plot <- plot + scale_y_continuous(name = "Startups", trans = 'log10', breaks = c(1, 5, 10, 50, 100, 500, 1000, 2000, 3000)) + annotation_logticks(sides="l", base = 10, scaled = TRUE) + scale_x_continuous(name = "Ano", limits = c(2006, 2019), breaks = seq(2006, 2019, 2)) + labs(color = "Estado")
plot <- plot + scale_y_continuous(name = "Startups") + scale_x_continuous(name = "Ano", limits = c(2006, 2019), breaks = seq(2006, 2019, 2)) + labs(color = "Estado")
plot

View(df)

l1 = summary(startup_growing_tax$QuantityStartups)[1]
l2 = summary(startup_growing_tax$QuantityStartups)[6]
plot <- ggplot(data = startup_growing_tax, aes(x = startup_growing_tax$Ano, y = startup_growing_tax$QuantityStartups, group = startup_growing_tax$State))
plot <- plot + geom_line(aes(color = startup_growing_tax$State)) + geom_point(aes(color = startup_growing_tax$State))
#plot <- plot + scale_y_continuous(name = "Startups", trans = 'log10', breaks = c(1, 5, 10, 50, 100, 500, 1000, 2000, 3000)) + annotation_logticks(sides="l", base = 10, scaled = TRUE) + scale_x_continuous(name = "Ano", limits = c(2006, 2019), breaks = seq(2006, 2019, 2)) + labs(color = "Estado")
plot <- plot + scale_y_continuous(name = "Startups") + scale_x_continuous(name = "Ano", limits = c(2006, 2019), breaks = seq(2006, 2019, 2)) + labs(color = "Estado")
plot

df = startup_growing_tax[startup_growing_tax$Ano == 2019,]

df <- df %>%
  arrange(desc(df$State)) %>%
  mutate(pct = df$QuantityStartups / sum(df$QuantityStartups))

df <- df %>%
  mutate(lab.ypos = cumsum(df$pct) - 0.5 * df$pct)

# participacao_startups_2019

plot <- ggplot(data = df, aes(x = "", y = pct, fill = State))
plot <- plot + geom_bar(width = 1, stat = "identity", color = "white")
plot <- plot + coord_polar("y", start = 0) + theme_void() + labs(fill = "Estado")
plot <- plot + geom_text_repel(aes(x = 1.4, y = lab.ypos, label = percent_format(accuracy = 0.1)(round(pct, digits = 3))), 
                               nudge_x = .3, 
                               segment.size = .7, 
                               show.legend = FALSE, color = "gray27")
plot

plot <- ggplot(data = startup_growing_tax, aes(x = as.factor(startup_growing_tax$Ano), y = startup_growing_tax$QuantityStartups, fill = startup_growing_tax$Region))
plot <- plot + geom_boxplot() + xlab("Ano") + scale_y_continuous(name = "Crescimento anual de startups (%)", trans = "log10") + labs(fill = "Região")
plot <- plot + stat_summary(fun.y=mean, geom="point", shape=20, size=5, color="gray27", fill="gray27")
plot

plot <- ggplot(data = startup_growing_tax, aes(x = startup_growing_tax$Ano, y = 100 * startup_growing_tax$GrowingTaxStartups, group = startup_growing_tax$Region))
plot <- plot + geom_line(aes(color = startup_growing_tax$Region)) + geom_point(aes(color = startup_growing_tax$Region))
plot <- plot + scale_y_continuous(name = "Crescimento anual de startups (%)") + scale_x_continuous(name = "Ano", limits = c(2006, 2019), breaks = seq(2006, 2019, 2)) + labs(color = "Região")
plot

df = df[df$ano == 2019,]

df <- df %>%
  arrange(desc(df$estado)) %>%
  mutate(pct = df$startups / sum(df$startups))

df <- df %>%
  mutate(lab.ypos = cumsum(df$pct) - 0.5 * df$pct)

# participacao_startups_2019

plot <- ggplot(data = df, aes(x = "", y = pct, fill = estado))
plot <- plot + geom_bar(width = 1, stat = "identity", color = "white")
plot <- plot + coord_polar("y", start = 0) + theme_void() + labs(fill = "Estado")
plot <- plot + geom_text_repel(aes(x = 1.4, y = lab.ypos, label = percent_format(accuracy = 0.1)(round(pct, digits = 3))), 
                               nudge_x = .3, 
                               segment.size = .7, 
                               show.legend = FALSE, color = "gray27")
plot

