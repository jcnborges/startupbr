library(rjson)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(dplyr)
library(ggplot2)
library(igraph)
library(rgexf)
library(googleway)

# ------------------------------------------------------------
# Sophia, Inteligência Artificial
# Autor: Júlio César (julio.nardelli@pucpr.br)
# Data: 06/03/2020
# Descrição: Análise word cloud, afiliação
# ------------------------------------------------------------

SOPHIA_BASE_DIR = "C:\\repo\\dmp-source\\04_PYTHON\\Einsteinbot\\sophIA\\"
JSON_FILE_NAME = "psicologia_cwb.json"
CORPUS_TXT = "corpus.txt"
REMOVE_WORDS_TXT = "remove_words.txt"
GEXF_FILE = "rede.gexf"
API_KEY <- 'AIzaSyBhWM0raXVoXZwHg7WrjAeGMOtSMeorCZo'

# ------------------------------------------------------------
# 
# Word Cloud
#
# ------------------------------------------------------------

# ESCOLHA A OPCAO:
# 1 - carreira_profissional > descricao_cargo
# 2 - habilidades
# 3 - certificacoes
# 4 - cursos
# 5 - educacao > nome_curso
# 6 - educacao > area_conhecimento
# 7 - educacao > nome_instituicao_ensino
# 8 - idiomas
# 9 - carreira_profissional > nome_empresa
opcao = 2
cargo = "clínic"
title = "<<escolha opção>>"
filtro_carreira = TRUE
homogeneizacao = TRUE

jsonPerfis <- fromJSON(,paste(SOPHIA_BASE_DIR, JSON_FILE_NAME, sep = ''))

# ------------------------------------------------------------
# 
# Homogeneização dos nomes
#
# ------------------------------------------------------------

if (homogeneizacao) {

  # ------------------------------------------------------------
  # Nome de instituições de ensino
  # ------------------------------------------------------------
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$educacao) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$educacao)) {
        if (!is.null(jsonPerfis[[i]]$educacao[[j]]$schoolName)) {
          res <- google_places(search_string = jsonPerfis[[i]]$educacao[[j]]$schoolName, key = API_KEY, language = "pt-br")
          if (res$status != "ZERO_RESULTS") {
            jsonPerfis[[i]]$educacao[[j]]$schoolName <- res$results[1,]$name
            jsonPerfis[[i]]$educacao[[j]]$location <- res$results[1,]$geometry$location
            print(res$results[1,]$name)
          }
        }
      }
    }
  }
  
  # ------------------------------------------------------------
  # Nome de empresas
  # ------------------------------------------------------------
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$carreira_profissional) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$carreira_profissional)) {
        if (!is.null(jsonPerfis[[i]]$carreira_profissional[[j]]$companyName)) {
          res <- google_places(search_string = jsonPerfis[[i]]$carreira_profissional[[j]]$companyName, key = API_KEY, language = "pt-br")
          if (res$status != "ZERO_RESULTS") {
            jsonPerfis[[i]]$carreira_profissional[[j]]$companyName <- res$results[1,]$name
            jsonPerfis[[i]]$carreira_profissional[[j]]$location <- res$results[1,]$geometry$location
            print(res$results[1,]$name)
          }
        }
      }
    }
  }
  write(toJSON(jsonPerfis), paste(SOPHIA_BASE_DIR, JSON_FILE_NAME, sep = ''))
}

skills = NULL

if (opcao == 1) {
  # carreira_profissional > descricao_cargo
  title = "Descrição do Cargo"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$carreira_profissional) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$carreira_profissional)) {
        if (!filtro_carreira || grepl(pattern = cargo, x = jsonPerfis[[i]]$carreira_profissional[[j]]$title, ignore.case = TRUE)) {
          skills = paste(skills, jsonPerfis[[i]]$carreira_profissional[[j]]$description, sep ="\n")
        }
      }
    }
  }
} else if (opcao == 2) {
  # habilidades
  title = "Habilidades"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$habilidades) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$habilidades)) {
        skills = paste(skills, jsonPerfis[[i]]$habilidades[[j]]$name, sep ="\n")
      }
    }
  }
} else if (opcao == 3) {
  # certificacoes
  title = "Certificações"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$certificacoes) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$certificacoes)) {
        skills = paste(skills, jsonPerfis[[i]]$certificacoes[[j]]$name, sep ="\n")
      }
    }
  }  
} else if (opcao == 4) {
  # cursos
  title = "Curso de Curta Duração"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$cursos) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$cursos)) {
        skills = paste(skills, jsonPerfis[[i]]$cursos[[j]]$name, sep ="\n")
      }
    }
  }  
} else if (opcao == 5) {
  # educacao > nome_curso
  title = "Formação Acadêmica"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$educacao) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$educacao)) {
        skills = paste(skills, jsonPerfis[[i]]$educacao[[j]]$degreeName, sep ="\n")
      }
    }
  }  
} else if (opcao == 6) {
  # educacao > area_conhecimento
  title = "Área do Conhecimento"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$educacao) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$educacao)) {
        skills = paste(skills, jsonPerfis[[i]]$educacao[[j]]$fieldOfStudy, sep ="\n")
      }
    }
  }  
} else if (opcao == 7) {
  # educacao > nome_instituicao_ensino
  title = "Instituição de Ensino"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$educacao) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$educacao)) {
        skills = paste(skills, jsonPerfis[[i]]$educacao[[j]]$schoolName, sep ="\n")
      }
    }
  }  
} else if (opcao == 8) {
  # educacao > linguas
  title = "Idiomas"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$linguas) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$linguas)) {
        skills = paste(skills, jsonPerfis[[i]]$linguas[[j]]$name, sep ="\n")
      }
    }
  }  
} else  if (opcao == 9) {
  # carreira_profissional > nome_empresa
  title = "Empresas"
  for (i in 1:length(jsonPerfis)) {
    if (length(jsonPerfis[[i]]$carreira_profissional) > 0) {
      for (j in 1:length(jsonPerfis[[i]]$carreira_profissional)) {
        if (!filtro_carreira || grepl(pattern = cargo, x = jsonPerfis[[i]]$carreira_profissional[[j]]$title, ignore.case = TRUE)) {
          skills = paste(skills, jsonPerfis[[i]]$carreira_profissional[[j]]$companyName, sep ="\n")
        }
      }
    }
  }
}

fileConn <- file(paste(SOPHIA_BASE_DIR, CORPUS_TXT, sep = ''), encoding="UTF-8")
writeLines(skills, fileConn)
close(fileConn)

text <- readLines(paste(SOPHIA_BASE_DIR, CORPUS_TXT, sep = ''), encoding="UTF-8")
corpus <- iconv(text, from="UTF-8", to="ASCII//TRANSLIT")
docs <- Corpus(VectorSource(corpus))
# inspect(docs)

remove_words <- readLines(paste(SOPHIA_BASE_DIR, REMOVE_WORDS_TXT, sep = ''), encoding="UTF-8")

# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
# Remove portuguese common stopwords
docs <- tm_map(docs, removeWords, iconv(stopwords("portuguese"), from="UTF-8", to="ASCII//TRANSLIT"))
# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, remove_words) 
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# Text stemming
#docs <- tm_map(docs, stemDocument)

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 100)

dev.new()

set.seed(1234)
plot.new()
layout(matrix(c(1, 2), nrow=2), heights=c(1, 4))
par(mar=rep(0, 4))
plot.new()
text(x=0.5, y=0.5, paste(title, cargo, sep = " - "))
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=100, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"), main="Title")

# ------------------------------------------------------------
# 
# Afiliação Instituições de Ensino
#
# ------------------------------------------------------------
degree <- data.frame()
for (i in 1:length(jsonPerfis)) {
  if (length(jsonPerfis[[i]]$educacao) > 0) {
    for (j in 1:length(jsonPerfis[[i]]$educacao)) {
      aux <- data.frame(
        "schoolName" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$schoolName), jsonPerfis[[i]]$educacao[[j]]$schoolName, "N/I") 
        ,"degreeName" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$degreeName), jsonPerfis[[i]]$educacao[[j]]$degreeName, "N/I")
        ,"fieldOfStudy" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$fieldOfStudy), jsonPerfis[[i]]$educacao[[j]]$fieldOfStudy, "N/I") 
        ,"start" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$dateRange$start$year), jsonPerfis[[i]]$educacao[[j]]$dateRange$start$year, 0)
        ,"end" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$dateRange$end$year), jsonPerfis[[i]]$educacao[[j]]$dateRange$end$year, 0)
        ,stringsAsFactors = TRUE
      )      
      degree = rbind(degree, aux)
    }
  }
}  
top10 <- data.frame(summarize(group_by(degree, schoolName), n()))
top10 <- top10[top10$schoolName != "N/I",]
top10 <- top10[order(-top10$n..),]
top10 <- top10[1:10,]
dev.new()
p <- ggplot(data = top10)
p <- p + geom_bar(mapping = aes(x = reorder(top10$schoolName, top10$n..), y = top10$n..), stat = "identity", fill = "steelblue")
p <- p + ggtitle(paste("TOP 10 Instituições de Ensino", cargo, sep = " - ")) + xlab("Instituição de Ensino") + ylab("Frequência")
p <- p + coord_flip()
p

top10 <- data.frame(summarize(group_by(degree, degreeName), n()))
top10 <- top10[top10$degreeName != "N/I",]
top10 <- top10[order(-top10$n..),]
top10 <- top10[1:10,]
dev.new()
p <- ggplot(data = top10)
p <- p + geom_bar(mapping = aes(x = reorder(top10$degreeName, top10$n..), y = top10$n..), stat = "identity", fill = "steelblue")
p <- p + ggtitle(paste("TOP 10 Formação Acadêmica", cargo, sep = " - ")) + xlab("Formação Acadêmica") + ylab("Frequência")
p <- p + coord_flip()
p

top10 <- data.frame(summarize(group_by(degree, fieldOfStudy), n()))
top10 <- top10[top10$fieldOfStudy != "N/I",]
top10 <- top10[order(-top10$n..),]
top10 <- top10[1:10,]
dev.new()
p <- ggplot(data = top10)
p <- p + geom_bar(mapping = aes(x = reorder(top10$fieldOfStudy, top10$n..), y = top10$n..), stat = "identity", fill = "steelblue")
p <- p + ggtitle(paste("TOP 10 Formação Acadêmica", cargo, sep = " - ")) + xlab("Formação Acadêmica") + ylab("Frequência")
p <- p + coord_flip()
p

# ------------------------------------------------------------
# 
# Experiência Profissional
#
# ------------------------------------------------------------
job <- data.frame()
for (i in 1:length(jsonPerfis)) {
  if (length(jsonPerfis[[i]]$carreira_profissional) > 0) {
    for (j in 1:length(jsonPerfis[[i]]$carreira_profissional)) {
      if (!filtro_carreira || grepl(pattern = cargo, x = jsonPerfis[[i]]$carreira_profissional[[j]]$title, ignore.case = TRUE)) {
        aux <- data.frame(
          "companyName" = ifelse(!is.null(jsonPerfis[[i]]$carreira_profissional[[j]]$companyName), jsonPerfis[[i]]$carreira_profissional[[j]]$companyName, "N/I") 
          ,"title" = ifelse(!is.null(jsonPerfis[[i]]$carreira_profissional[[j]]$title), jsonPerfis[[i]]$carreira_profissional[[j]]$title, "N/I")
          ,"start" = ifelse(!is.null(jsonPerfis[[i]]$carreira_profissional[[j]]$dateRange$start$year), jsonPerfis[[i]]$carreira_profissional[[j]]$dateRange$start$year, 0)
          ,"end" = ifelse(!is.null(jsonPerfis[[i]]$carreira_profissional[[j]]$dateRange$end$year), jsonPerfis[[i]]$carreira_profissional[[j]]$dateRange$end$year, 0)        
        )      
        job = rbind(job, aux)
      }
    }
  }
} 

# TOP 10 empresas
if (cargo == "direito") {
  job[grepl(pattern = "advogados", x = job$companyName, ignore.case = TRUE) & grepl(pattern = "associados", x = job$companyName, ignore.case = TRUE), ]$companyName <- "Escritório Advocacia"
}
top10 <- data.frame(summarize(group_by(job, companyName), n()))
top10 <- top10[top10$companyName != "N/I",]
top10 <- top10[order(-top10$n..),]
top10 <- top10[1:10,]
dev.new()
p <- ggplot(data = top10)
p <- p + geom_bar(mapping = aes(x = reorder(top10$companyName, top10$n..), y = top10$n..), stat = "identity", fill = "steelblue")
p <- p + ggtitle(paste("TOP 10 Empresas", cargo, sep = " - ")) + xlab("Nome da Empresa") + ylab("Frequência")
p <- p + coord_flip()
p

# TOP 10 cargos
top10 <- data.frame(summarize(group_by(job, title), n()))
top10 <- top10[top10$title != "N/I",]
top10 <- subset(top10, !grepl("estagiá", top10$title, ignore.case = TRUE))
top10 <- top10[order(-top10$n..),]
top10 <- top10[1:10,]
View(top10)
dev.new()
p <- ggplot(data = top10)
p <- p + geom_bar(mapping = aes(x = reorder(top10$title, top10$n..), y = top10$n..), stat = "identity", fill = "steelblue")
p <- p + ggtitle(paste("TOP 10 Cargos", cargo, sep = " - ")) + xlab("Nome do Cargo") + ylab("Frequência")
p <- p + coord_flip()
p

# ------------------------------------------------------------
# 
# Certificações
#
# ------------------------------------------------------------
certification <- data.frame()
for (i in 1:length(jsonPerfis)) {
  if (length(jsonPerfis[[i]]$certificacoes) > 0) {
    for (j in 1:length(jsonPerfis[[i]]$certificacoes)) {
      aux <- data.frame(
        "name" = ifelse(!is.null(jsonPerfis[[i]]$certificacoes[[j]]$name), jsonPerfis[[i]]$certificacoes[[j]]$name, "N/I") 
        ,stringsAsFactors = TRUE
      )      
      certification = rbind(certification, aux)
    }
  }
}  
top10 <- data.frame(summarize(group_by(certification, name), n()))
top10 <- top10[top10$name != "N/I",]
top10 <- top10[order(-top10$n..),]
top10 <- top10[1:10,]
dev.new()
p <- ggplot(data = top10)
p <- p + geom_bar(mapping = aes(x = reorder(top10$name, top10$n..), y = top10$n..), stat = "identity", fill = "steelblue")
p <- p + ggtitle(paste("TOP 10 Certificados", cargo, sep = " - ")) + xlab("Certificados") + ylab("Frequência")
p <- p + coord_flip()
p

# ------------------------------------------------------------
# 
# Cursos
#
# ------------------------------------------------------------
courses <- data.frame()
for (i in 1:length(jsonPerfis)) {
  if (length(jsonPerfis[[i]]$cursos) > 0) {
    for (j in 1:length(jsonPerfis[[i]]$cursos)) {
      aux <- data.frame(
        "name" = ifelse(!is.null(jsonPerfis[[i]]$cursos[[j]]$name), jsonPerfis[[i]]$cursos[[j]]$name, "N/I") 
        ,stringsAsFactors = TRUE
      )      
      courses = rbind(courses, aux)
    }
  }
}  
top10 <- data.frame(summarize(group_by(courses, name), n()))
top10 <- top10[top10$name != "N/I",]
top10 <- top10[order(-top10$n..),]
top10 <- top10[1:10,]
dev.new()
p <- ggplot(data = top10)
p <- p + geom_bar(mapping = aes(x = reorder(top10$name, top10$n..), y = top10$n..), stat = "identity", fill = "steelblue")
p <- p + ggtitle(paste("TOP 10 Cursos", cargo, sep = " - ")) + xlab("Cursos") + ylab("Frequência")
p <- p + coord_flip()
p

# ------------------------------------------------------------
# 
# Competências e Recomendações
#
# ------------------------------------------------------------
competences <- data.frame()
for (i in 1:length(jsonPerfis)) {
  if (length(jsonPerfis[[i]]$habilidades) > 0) {
    for (j in 1:length(jsonPerfis[[i]]$habilidades)) {
      aux <- data.frame(
        "name" = ifelse(!is.null(jsonPerfis[[i]]$habilidades[[j]]$name), jsonPerfis[[i]]$habilidades[[j]]$name, "N/I") 
        ,stringsAsFactors = TRUE
      )      
      competences = rbind(competences, aux)
    }
  }
}  
top10 <- data.frame(summarize(group_by(competences, name), n()))
top10 <- top10[top10$name != "N/I" & !(top10$name %in% c("Microsoft Excel", "Microsoft Office", "Microsoft PowerPoint", "Microsoft Word")),]
top10 <- top10[order(-top10$n..),]
top10 <- top10[1:20,]
dev.new()
p <- ggplot(data = top10)
p <- p + geom_bar(mapping = aes(x = reorder(top10$name, top10$n..), y = top10$n..), stat = "identity", fill = "steelblue")
p <- p + ggtitle(paste("TOP 20 Competências", cargo, sep = " - ")) + xlab("Competências") + ylab("Frequência")
p <- p + coord_flip()
p

# ------------------------------------------------------------
# 
# Rede Instituição de Ensino e Empresa
#
# ------------------------------------------------------------
g <- make_empty_graph(directed = FALSE)
for (i in 1:length(jsonPerfis)) {
  if (length(jsonPerfis[[i]]$educacao) > 0) {
    for (j in 1:length(jsonPerfis[[i]]$educacao)) {
      degree <- data.frame(
        "schoolName" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$schoolName), jsonPerfis[[i]]$educacao[[j]]$schoolName, "N/I") 
        ,"degreeName" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$degreeName), jsonPerfis[[i]]$educacao[[j]]$degreeName, "N/I")
        ,"fieldOfStudy" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$fieldOfStudy), jsonPerfis[[i]]$educacao[[j]]$fieldOfStudy, "N/I") 
        ,"start" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$dateRange$start$year), jsonPerfis[[i]]$educacao[[j]]$dateRange$start$year, 0)
        ,"end" = ifelse(!is.null(jsonPerfis[[i]]$educacao[[j]]$dateRange$end$year), jsonPerfis[[i]]$educacao[[j]]$dateRange$end$year, 0)
        ,stringsAsFactors = FALSE
      ) 
      if (length(jsonPerfis[[i]]$carreira_profissional) > 0) {
        for (k in 1:length(jsonPerfis[[i]]$carreira_profissional)) {
          if (!filtro_carreira || grepl(pattern = cargo, x = jsonPerfis[[i]]$carreira_profissional[[k]]$title, ignore.case = TRUE)) {
            job <- data.frame(
              "companyName" = ifelse(!is.null(jsonPerfis[[i]]$carreira_profissional[[k]]$companyName), jsonPerfis[[i]]$carreira_profissional[[k]]$companyName, "N/I") 
              ,"title" = ifelse(!is.null(jsonPerfis[[i]]$carreira_profissional[[k]]$title), jsonPerfis[[i]]$carreira_profissional[[k]]$title, "N/I")
              ,"start" = ifelse(!is.null(jsonPerfis[[i]]$carreira_profissional[[k]]$dateRange$start$year), jsonPerfis[[i]]$carreira_profissional[[k]]$dateRange$start$year, 0)
              ,"end" = ifelse(!is.null(jsonPerfis[[i]]$carreira_profissional[[k]]$dateRange$end$year), jsonPerfis[[i]]$carreira_profissional[[k]]$dateRange$end$year, 0)
              ,stringsAsFactors = FALSE
            )      
            if (degree$end != 0 && degree$end <= job$start) {
              schoolName <- iconv(degree$schoolName, from="UTF-8", to="ASCII//TRANSLIT")
              companyName <- iconv(job$companyName, from="UTF-8", to="ASCII//TRANSLIT")
              schoolName <- sub("&", '', schoolName)
              companyName <- sub("&", '', companyName)
              v1 <- vertex(name = schoolName, type = FALSE)
              v2 <- vertex(name = companyName, type = TRUE)
              if (is.na(match(schoolName, V(g)$name))) {
                g <- g + v1
                id1 <- as.numeric(V(g)[schoolName])
              }
              if (is.na(match(companyName, V(g)$name))) {
                g <- g + v2
                id2 <- as.numeric(V(g)[companyName])
              }
              if (g[id1, id2] == 0) {
                g <- g + edge(id1, id2, "weight" = 2)
              }
              g[id1, id2] <- g[id1, id2] + 1
            }
          }
        }
      }
    }
  }
}
gexf <- igraph.to.gexf(g)
print(gexf, paste(SOPHIA_BASE_DIR, GEXF_FILE, sep = ''))