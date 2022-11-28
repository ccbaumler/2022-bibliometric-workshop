library(bibliometrix)
library(tidyverse)
library(metagear)

wos <- convert2df(file = "wos-plaintext-savedrecs.txt", dbsource="wos",format="plaintext")
scop <- convert2df(file = "scopus-plaintext-crc.csv", dbsource = "scopus", format = "plaintext")
scopb <- convert2df(file = "2022-bibliometric-workshop/scopus-bib-crc.bib", dbsource = "scopus", format = "bibtex")
pubmed <- convert2df(file = "pubmed-plaintext-colorectal-set.txt", dbsource = "pubmed", format = "plaintext")

missingdb <- mergeDbSources(wos, scop, pubmed, remove.duplicated = TRUE)
fulldb <- mergeDbSources(wos, scopb, pubmed, remove.duplicated = TRUE)

#check the row count difference between the merged and the full count of all the databases
nrow(missingdb)
sum(nrow(wos)+nrow(scop)+nrow(pubmed))

nrow(fulldb)
sum(nrow(wos)+nrow(scopb)+nrow(pubmed))

results <- biblioAnalysis(fulldb)
glimpse(results[["MostCitedPapers"]])

mcp <- results[["MostCitedPapers"]] %>%
  arrange(desc(NTC)) %>%
  mutate(Links = sprintf('<a href = "https://www.doi.org/%s">%s</a>', 
                          DOI,
                          "To Paper"
                         ),
         Links = lapply(Links, gt::html))
summary(results, k=20)
plot(x=results, k=20, pause=F)

mcp %>% head(n=20) %>% gt()

#Change the sentence case from full capitalize to only the first word of the sentence.
crc <- fulldb %>% 
  mutate(AB = str_to_sentence(AB)) %>%
  mutate(TI = str_to_sentence(TI))

#Create the file for abstract_screener
effort_distribute(crc, reviewers = 'Colton', initialize = TRUE, save_split = TRUE)

#Open GUI for screening papers
abstract_screener('effort_Colton.csv', 'Colton', abstractColumnName = 'AB', titleColumnName = 'TI', windowWidth = 120)
