library(dplyr)
library(tidytext)
library(topicmodels)
library(ggplot2)
library(tidyr)
library(tidyverse)
library(wordcloud)
library(SnowballC)
library(textmineR)
library(tm)
library(ggpubr)

startups <- read.csv("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/startups.csv", sep=";")

startup <- as.character(startups$OrganizationID)
text <- as.character(startups$Categories)
text_df <- tibble(line = 1:length(text), text = text, startup = startup)
text_df <- text_df %>%
  mutate(text = tolower(text)) %>%
  mutate(text = str_replace_all(text, " \\(erp\\)", "")) %>%
  mutate(text = str_replace_all(text, " \\(ict\\)", "")) %>%
  mutate(text = str_replace_all(text, "e-commerce", "ecommerce")) %>%
  mutate(text = str_replace_all(text, "e-learning", "elearning")) %>%
  mutate(text = str_replace_all(text, "information and communications technology", "tic")) %>%
  mutate(text = str_replace_all(text, "information technology", "tic")) %>%
  mutate(text = str_replace_all(text, "enterprise resource planning", "erp")) %>%
  mutate(text = str_replace_all(text, "peer to peer", "p2p")) %>%
  mutate(text = str_replace_all(text, "internet of things", "iot")) %>%
  mutate(text = str_replace_all(text, "information services", "info_services")) %>%
  unnest_tokens(word, text)

words <- text_df %>%
  count(word, sort = TRUE)

head(words)
dev.new()
wordcloud(words$word, words$n, max.words = 100, colors=brewer.pal(8, "Dark2"))

words[1:30,] %>%
  arrange(n) %>%
  mutate(word = factor(word, levels = word)) %>%
  ggplot(aes(x = word, y = n)) + geom_bar(stat="identity") + coord_flip() +
  theme(axis.text.x = element_text(size = 16)) +
  theme(axis.text.y = element_text(size = 16)) +
  theme(axis.title.x = element_text(size = 20)) +
  theme(axis.title.y = element_text(size = 20))


stop_words = c("software", "tic", "internet", stopwords(kind = "en"))
stop_words <- tibble(word = stop_words)
text_df <- text_df %>%
  anti_join(stop_words) %>%
  mutate(word = SnowballC::wordStem(word))

text_df <- text_df %>%
  count(startup, word, sort = TRUE)

startup_tdm <- text_df %>%
  cast_dtm(startup, word, n)

# Choosing the best number of topics
#Transform our data into dgcMatrix to use this feature
dgcMatrix <- Matrix::sparseMatrix(i=startup_tdm$i, 
                                   j=startup_tdm$j, 
                                   x=startup_tdm$v, 
                                   dims=c(startup_tdm$nrow, startup_tdm$ncol),
                                   dimnames = startup_tdm$dimnames)
k_list <- seq(10,100, by=10)
model_dir <- paste0("models_", digest::digest(colnames(dgcMatrix), algo = "sha1"))
model_list <- TmParallelApply(X = k_list, FUN = function(k){
  m <- FitLdaModel(dtm = dgcMatrix, 
                   k = k, # number of topics
                   iterations = 1000, 
                   burnin = 180,
                   alpha = 0.1,
                   beta = colSums(dgcMatrix) / sum(dgcMatrix) * 100,
                   optimize_alpha = TRUE,
                   calc_likelihood = FALSE,
                   calc_coherence = TRUE,
                   calc_r2 = FALSE,
                   cpus = 1)
  m$k <- k
  m
}, export= ls(), cpus = 2) 

# Get average coherence for each model
coherence_mat <- data.frame(k = sapply(model_list, function(x) nrow(x$phi)), 
                            coherence = sapply(model_list, function(x) mean(x$coherence)), 
                            stringsAsFactors = FALSE)

# On larger (~1,000 or greater documents) corpora, you will usually get a clear peak
plot(coherence_mat, type = "o")
abline(v = 30, col = "blue", lty = 2)

topicos_lda <- LDA(startup_tdm, k = 30, control = list(seed = 1234))

ap_topics <- tidy(topicos_lda, matrix = "beta")

ap_top_terms <- ap_topics %>%
  group_by(topic) %>%
  top_n(7, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

ap_top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  scale_x_reordered() + theme(axis.title.x=element_blank(),
                              axis.text.x=element_blank(),
                              axis.ticks.x=element_blank())

lda_gamma <- tidy(topicos_lda, matrix = "gamma")
lda_gamma <- lda_gamma %>%
  separate(document, c("startup"), sep = "_", convert = TRUE)

classificacao <- lda_gamma %>%
  group_by(startup) %>%
  top_n(1, gamma) %>%
  ungroup %>%
  arrange(gamma)

startup_topic <- select(classificacao, -c(gamma)) %>%
  group_by(startup) %>%
  summarize(topic = min(topic)) %>%
  ungroup %>%
  arrange(startup) %>%
  mutate(OrganizationID = startup)

startups <- left_join(startups, startup_topic)

write.csv(startups, "~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/startups_topic.csv")

png("~/Documentos/Source-Python/startupbr/src/datamining/csv/analysis/startups_topic.png", width = 900, height = 1276)
myplots <- list()
for (i in 1:30) {
  startup <- startups[startups$topic == i & !is.na(startups$topic),]$OrganizationID
  text <- startups[startups$topic == i & !is.na(startups$topic),]$Categories
  text_df <- tibble(line = 1:length(text), text = text, startup = startup)
  
  text_df <- text_df %>%
    mutate(text = tolower(text)) %>%
    mutate(text = str_replace_all(text, " \\(erp\\)", "")) %>%
    mutate(text = str_replace_all(text, " \\(ict\\)", "")) %>%
    mutate(text = str_replace_all(text, "e-commerce", "ecommerce")) %>%
    mutate(text = str_replace_all(text, "e-learning", "elearning")) %>%
    mutate(text = str_replace_all(text, "information and communications technology", "tic")) %>%
    mutate(text = str_replace_all(text, "information technology", "tic")) %>%
    mutate(text = str_replace_all(text, "enterprise resource planning", "erp")) %>%
    mutate(text = str_replace_all(text, "peer to peer", "p2p")) %>%
    mutate(text = str_replace_all(text, "internet of things", "iot")) %>%
    mutate(text = str_replace_all(text, "information services", "info_services")) %>%
    unnest_tokens(word, text) %>%
    anti_join(stop_words)
  
  words <- text_df %>%
    count(word, sort = TRUE)
  
  myplots[[i]] <- 
    words[1:10,] %>%
      arrange(n) %>%
      mutate(word = factor(word, levels = word)) %>%
      ggplot(aes(x = word, y = n)) + geom_bar(stat="identity") + coord_flip() +
      theme(axis.title.x = element_blank(), axis.text.x=element_blank(), 
            axis.title.y = element_blank(), axis.text.y = element_text(size = 10),
            title = element_text(size = 8)) + ggtitle(label = paste("Tópico", i, sep = " - "))
}
ggarrange(plotlist = myplots, ncol = 5, nrow = 6)
dev.off()

startup <- startups[is.na(startups$topic),]$OrganizationID
text <- startups[is.na(startups$topic),]$Categories
text_df <- tibble(line = 1:length(text), text = text, startup = startup)

text_df <- text_df %>%
  mutate(text = tolower(text)) %>%
  mutate(text = str_replace_all(text, " \\(erp\\)", "")) %>%
  mutate(text = str_replace_all(text, " \\(ict\\)", "")) %>%
  mutate(text = str_replace_all(text, "e-commerce", "ecommerce")) %>%
  mutate(text = str_replace_all(text, "e-learning", "elearning")) %>%
  mutate(text = str_replace_all(text, "information and communications technology", "tic")) %>%
  mutate(text = str_replace_all(text, "information technology", "tic")) %>%
  mutate(text = str_replace_all(text, "enterprise resource planning", "erp")) %>%
  mutate(text = str_replace_all(text, "peer to peer", "p2p")) %>%
  mutate(text = str_replace_all(text, "internet of things", "iot")) %>%
  mutate(text = str_replace_all(text, "information services", "info_services")) %>%
  unnest_tokens(word, text)

text_df <- text_df %>%
  count(startup, word, sort = TRUE)

startup_tdm <- text_df %>%
  cast_dtm(startup, word, n)

words <- text_df %>%
  count(word, sort = TRUE)

head(words)
dev.new()
wordcloud(words$word, words$n, max.words = 100, colors=brewer.pal(8, "Dark2"))

words[1:30,] %>%
  arrange(n) %>%
  mutate(word = factor(word, levels = word)) %>%
  ggplot(aes(x = word, y = n)) + geom_bar(stat="identity") + coord_flip()


topicos_lda <- LDA(startup_tdm, k = 2, control = list(seed = 1234))

ap_topics <- tidy(topicos_lda, matrix = "beta")

ap_top_terms <- ap_topics %>%
  group_by(topic) %>%
  top_n(7, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

ap_top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  scale_x_reordered() + theme(axis.title.x=element_blank(),
                              axis.text.x=element_blank(),
                              axis.ticks.x=element_blank())