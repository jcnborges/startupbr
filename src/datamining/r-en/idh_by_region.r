library(ggplot2)
library(scales)
library(dplyr)

idh_region <- read.csv2("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/idh_region.csv")

idh_region <- idh_region %>%
  arrange(desc(idh_region$Region))

l1 = summary(idh_region$IDHRenda)[1]
l2 = summary(idh_region$IDHRenda)[6]
plot <- ggplot(data = idh_region, aes(x = idh_region$Ano, y = idh_region$IDHRenda, group = idh_region$Region)) #+ ggtitle("Evolução do PIB (R$ bilhões) de 2002 até 2017")
plot <- plot + geom_line(aes(color = idh_region$Region)) + geom_point(aes(color = idh_region$Region))
plot <- plot + scale_y_continuous(name = "IDH Renda", limits = c(0.5, 0.8), breaks = seq(round(l1, digits = 1), round(l2, digits = 1), by = 0.1)) + scale_x_continuous(name = "Ano", limits = c(1990, 2011), breaks = c(1991, 2000, 2010)) + labs(color = "Região")
plot