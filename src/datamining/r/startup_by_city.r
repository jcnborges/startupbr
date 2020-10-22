library(ggplot2)
library(scales)
library(dplyr)
library(ggrepel)
library(ggmap)

startup_growing_tax <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/startup_growing_tax_by_city.csv", sep=";")

df <- startup_growing_tax %>%
  filter(QuantityStartups > 0)

register_google(key = "AIzaSyBD9HJ7YmHQ9wXauubZA4y0MClpiynzlyQ")
#df$Geocode <- geocode(paste(df$City, df$State, sep = ' - '))
#write.table(df, "~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/startup_growing_tax_by_city.csv", sep=";", fileEncoding = "utf-8", row.names = FALSE)

summary(df$QuantityStartups)
sum(df$QuantityStartups)

startup_growing_tax %>%
  filter(QuantityStartups < 15) %>%
  ggplot(aes(QuantityStartups)) +
    geom_histogram(breaks = seq(1, 15, by=2), col = "white", fill = "mediumblue") + 
    scale_x_continuous("Número de startups", breaks = seq(1, 15, by = 2)) + ylab("Número de cidades")

startup_growing_tax %>%
  filter(QuantityStartups >= 15 & QuantityStartups < 75) %>%
  ggplot(aes(QuantityStartups)) +
    geom_histogram(breaks = seq(15, 75, by = 15), col = "white", fill = "mediumblue") + 
    scale_x_continuous("Número de startups", breaks = seq(15, 75, by = 15)) + ylab("Número de cidades")

startup_growing_tax %>%
  filter(QuantityStartups >= 75 & QuantityStartups < 550) %>%
  ggplot(aes(QuantityStartups)) +
  geom_histogram(breaks = seq(110, 2200, by = 100), col = "white", fill = "mediumblue") + 
  scale_x_continuous("Número de startups", breaks = seq(110, 2200, by = 100)) + ylab("Número de cidades")

startup_growing_tax %>%
  filter(QuantityStartups < 15) %>%
  summarize(n = n(), s = sum(QuantityStartups), m = mean(QuantityStartups), sd = sd(QuantityStartups), pct = sum(QuantityStartups)/5519)

startup_growing_tax %>%
  filter(QuantityStartups >= 15 & QuantityStartups < 75) %>%
  summarize(n = n(), s = sum(QuantityStartups), m = mean(QuantityStartups), sd = sd(QuantityStartups), pct = sum(QuantityStartups)/5519)

startup_growing_tax %>%
  filter(QuantityStartups >= 75 & QuantityStartups < 550) %>%
  summarize(n = n(), s = sum(QuantityStartups), m = mean(QuantityStartups), sd = sd(QuantityStartups), pct = sum(QuantityStartups)/5519)

startup_growing_tax %>%
  filter(QuantityStartups >= 551) %>%
  summarize(n = n(), s = sum(QuantityStartups), m = mean(QuantityStartups), sd = sd(QuantityStartups), pct = sum(QuantityStartups)/5519)

dd = df %>% filter(Region == "Sudeste")
  ggmap(get_map(location = "Southeast Brazil", zoom = 6, language = "pt-br")) +
    geom_point(data = dd, aes(x = Geocode.lon, y = Geocode.lat, size = QuantityStartups), alpha = 0.4, shape = 21, col = "black", fill = "blue") +
    scale_size_continuous(name = "Número de startups", breaks = c(3, 15, 60, 500, 2152), labels = c("1-3", "4-15", "16-60", "61-500", "501-2152"), range = c(3, 30)) +
    theme_void()

sm = summary(df$QuantityStartups)
sd(df$QuantityStartups)

df %>%
  arrange(desc(Region)) %>%
  ggplot(aes(x = Region, y = QuantityStartups, fill = Region)) +
    geom_boxplot() + xlab("Região") + scale_y_continuous(name = "Número de startups", trans = "log10") + labs(fill = "Região") +
    stat_summary(fun = mean, geom="point", shape=4, size=4, color="red", show.legend = FALSE) + annotation_logticks(sides="l", base = 10, scaled = TRUE) +
    geom_hline(yintercept = sm[4], color = "green2", linetype = "dashed", size = 0.7)

x = df %>%
  filter(Region == 'Sul') %>%
  select(City, IsCapital, StateAbbrev, Region, QuantityStartups) %>%
  mutate(pct = 100 * QuantityStartups/sum(QuantityStartups)) %>%
  arrange(desc(QuantityStartups))

x$str = paste(x$City, x$StateAbbrev, x$IsCapital, x$QuantityStartups, round(x$pct, 2), sep = " & ")

for (i in seq(1, nrow(x))) {
  print(x[i,7])
}