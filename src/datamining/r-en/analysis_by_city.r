library(ggplot2)
library(scales)
library(dplyr)
library(ggthemes)
library(cluster) 
library(fpc)

regions = c("Centro-oeste", "Nordeste", "Norte", "Sudeste", "Sul")
states = read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/state.csv", sep=";")

if (exists("dados"))
  remove(dados)

for (i in 1:nrow(states)) {
  state = states[i,]
  
  startup_growing_tax <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/startup_growing_tax_by_city.csv", sep=";")
  
  startup_growing_tax <- startup_growing_tax[startup_growing_tax$State == state,]
  
  startup_growing_tax <- startup_growing_tax %>%
    mutate(pct_startups = startup_growing_tax$QuantityStartups / sum(startup_growing_tax$QuantityStartups)) %>%
    mutate(pct_pib = startup_growing_tax$PIB / sum(startup_growing_tax$PIB)) %>%
    mutate(pct_pop = startup_growing_tax$Population / sum(startup_growing_tax$Population))

  df = data.frame(
    pct_startup = startup_growing_tax$pct_startups
    ,idh = startup_growing_tax$IDHM
    ,pct_pib = startup_growing_tax$pct_pib
    ,pct_pop = startup_growing_tax$pct_pop
    ,cidade = startup_growing_tax$City
    ,estado = startup_growing_tax$State
    ,regiao = startup_growing_tax$Region
    ,is_capital = startup_growing_tax$IsCapital
  )
  
  if (exists("dados")) {
    dados = union(dados, df)
  } else {
    dados = df
  }
}

dados[is.na(dados$pct_startup),1] <- 0
c1 <- dados[dados$pct_startup > 0,]
c2 <- dados[dados$pct_startup == 0,]
c2 <- c2[sample(nrow(c2), 374),]

dados <- union(c1, c2)

#summary(dados)
#plot(dados)
l = lm(pct_startup ~ idh + pct_pib + pct_pop, data = dados)
summary(l)

plot <- ggplot(data = dados, aes(x = idh, y = pct_startup)) + geom_point()
plot <- plot + geom_abline(slope = l$coefficients[2], intercept = l$coefficients[1], color = "blue", size = 1)
plot <- plot + ggtitle(paste("R² = ", signif(summary(l)$adj.r.squared, 5), " p-valor = ", signif(summary(l)$coef[2,4], 5)))
plot <- plot + theme(plot.title = element_text(size = 10)) + xlab("IDH") + ylab("Startups")
plot

conjunto <- data.frame(c1$pct_startup, c1$pct_pib, c1$pct_pop)
conjunto <- na.omit(conjunto) # listwise deletion of missing
conjunto <- scale(conjunto) # standardize variables

wss <- (nrow(conjunto)-1)*sum(apply(conjunto,2,var))
for (i in 2:10) wss[i] <- sum(kmeans(conjunto,centers=i)$withinss)
plot(1:10, wss, type="b", xlab="Clusteres", ylab="SQE", xlim = c(1, 10))
axis(side = 1, at = 1:10)

fit <- kmeans(conjunto, 5)
sum(fit$withinss)
clusplot(conjunto, fit$cluster, color=TRUE, shade=TRUE, 
         labels=2, lines=0)
plotcluster(conjunto, fit$cluster)

aggregate(conjunto, by=list(fit$cluster), FUN=mean)
# append cluster assignment
c1 <- data.frame(c1, cluster = fit$cluster)

plot <- ggplot(data = c1, aes(x = as.factor(c1$cluster), y = 100 * c1$pct_startup, fill = as.factor(c1$cluster)))
plot <- plot + geom_boxplot() + xlab("Cluster") + scale_y_continuous(name = "Startups (%)", limits = c(0, 100), breaks = seq(0, 100, by = 10)) + labs(fill = "Cluster")
plot <- plot + stat_summary(fun.y=mean, geom="point", shape=20, size=5, color="gray27", fill="gray27")
plot

plot <- ggplot(data = c1, aes(x = as.factor(c1$cluster), y = 100 * c1$pct_pib, fill = as.factor(c1$cluster)))
plot <- plot + geom_boxplot() + xlab("Cluster") + scale_y_continuous(name = "PIB (%)", limits = c(0, 100), breaks = seq(0, 100, by = 10)) + labs(fill = "Cluster")
plot <- plot + stat_summary(fun.y=mean, geom="point", shape=20, size=5, color="gray27", fill="gray27")
plot

plot <- ggplot(data = c1, aes(x = as.factor(c1$cluster), y = 100 * c1$pct_pop, fill = as.factor(c1$cluster)))
plot <- plot + geom_boxplot() + xlab("Cluster") + scale_y_continuous(name = "População (%)", limits = c(0, 100), breaks = seq(0, 100, by = 10)) + labs(fill = "Cluster")
plot <- plot + stat_summary(fun.y=mean, geom="point", shape=20, size=5, color="gray27", fill="gray27")
plot

df <- c1[c1$cluster == 5,]
df[df$is_capital == 1,]$is_capital <- "Sim"
df[df$is_capital == 0,]$is_capital <- "Não"

df <- df %>%
  arrange(df$cidade)

for (i in 1:nrow(df)) {
  d = df[i,]
  str = paste(d$cidade, d$estado, d$regiao, d$is_capital, sep = " & ")
  print(str)
}
  
