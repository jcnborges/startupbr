library(ggplot2)
library(scales)
library(dplyr)
library(ggthemes)

regions = c("Centro-Oeste", "Nordeste", "Norte" , "Sudeste", "Sul")

if (exists("dados"))
  remove(dados)

for (i in 1:length(regions)) {
  region = regions[i]
  
  idh_by_state <- idh_by_state <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/idh_by_state.csv", sep=";")
  startup_growing_tax <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/startup_growing_tax_by_state.csv", sep=";")
  pib_growing_tax <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/pib_growing_tax_by_state.csv", header=TRUE, sep=";")
  pop_by_state <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/pop_by_state.csv", sep=";")
  
  idh_by_state = idh_by_state[idh_by_state$Region == region & idh_by_state$Ano == 2017,]
  startup_growing_tax = startup_growing_tax[startup_growing_tax$Region == region & startup_growing_tax$Ano == 2019,]
  pib_growing_tax = pib_growing_tax[pib_growing_tax$Region == region & pib_growing_tax$Ano == 2017,]
  pop_by_state = pop_by_state[pop_by_state$Region == region,]
  
  idh_by_state <- idh_by_state %>%
    arrange(desc(idh_by_state$State))
  
  startup_growing_tax <- startup_growing_tax %>%
    arrange(desc(startup_growing_tax$State))
  
  pib_growing_tax <- pib_growing_tax %>%
    arrange(desc(pib_growing_tax$State))
  
  pop_by_state <- pop_by_state %>%
    arrange(desc(pop_by_state$State))
  
  startup_growing_tax <- startup_growing_tax %>%
    mutate(pct = startup_growing_tax$QuantityStartups / sum(startup_growing_tax$QuantityStartups))
  
  pib_growing_tax <- pib_growing_tax %>%
    mutate(pct = pib_growing_tax$PIB / sum(pib_growing_tax$PIB))
  
  pop_by_state <- pop_by_state %>%
    mutate(pct = pop_by_state$Population / sum(pop_by_state$Population))
  
  df = data.frame(
    pct_startup = startup_growing_tax$pct
    ,idh = idh_by_state$IDHM
    ,idh_edu = idh_by_state$IDHMEducacao
    ,idh_long = idh_by_state$IDHMLongividade
    ,idh_renda = idh_by_state$IDHMRenda
    ,pct_pib = pib_growing_tax$pct
    ,pct_pop = pop_by_state$pct
    ,estado = idh_by_state$State
  )
  
  if (exists("dados")) {
    dados = union(dados, df)
  } else {
    dados = df
  }
}

summary(dados)
plot(dados)
l = lm(pct_startup ~ idh + pct_pib + pct_pop, data = dados)
summary(l)

plot <- ggplot(data = dados, aes(x = idh, y = pct_startup)) + geom_point()
plot <- plot + geom_abline(slope = l$coefficients[2], intercept = l$coefficients[1], color = "blue", size = 1)
plot <- plot + ggtitle(paste("R² = ", signif(summary(l)$adj.r.squared, 5), " p-valor = ", signif(summary(l)$coef[2,4], 5)))
plot <- plot + theme(plot.title = element_text(size = 10)) + xlab("IDH") + ylab("Startups")
plot