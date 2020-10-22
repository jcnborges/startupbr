library(ggplot2)
library(scales)
library(dplyr)

idh_by_state <- idh_by_state <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/idh_by_state.csv", sep=";")

idh_by_state <- idh_by_state %>%
  arrange(desc(idh_by_state$Region))

idh_by_state = idh_by_state[idh_by_state$Region == "Sul",]

plot <- ggplot(data = idh_by_state, aes(x = idh_by_state$Ano, y = idh_by_state$IDHM, group = idh_by_state$State)) #+ ggtitle("Evolução do PIB (R$ bilhões) de 2002 até 2017")
plot <- plot + geom_line(aes(color = idh_by_state$State)) + geom_point(aes(color = idh_by_state$State))
plot <- plot + scale_y_continuous(name = "IDHM", limits = c(0.5, 0.9), breaks = seq(0.5, 0.9, by = 0.1)) + scale_x_continuous(name = "Ano", limits = c(1990, 2018), breaks = c(1991, 2000, 2010, 2017)) + labs(color = "Região")
plot

idh_by_state = idh_by_state[idh_by_state$Ano == 2017,]

# idhm_2017

plot <- ggplot(data = idh_by_state, aes(x = idh_by_state$State, y = idh_by_state$IDHM, fill = idh_by_state$State)) #+ ggtitle("Evolução do PIB (R$ bilhões) de 2002 até 2017")
plot <- plot + geom_bar(stat = "identity")
plot <- plot + scale_y_continuous(name = "IDH", limits = c(0, 0.9), breaks = seq(0, 0.9, by = 0.1)) + xlab("Estado") + labs(fill = "Estado")
plot <- plot + theme(axis.text.x = element_text(angle = 45, hjust = 1))
plot