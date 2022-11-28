library(bibliometrix)
library(tidyverse)

wos <- convert2df(file = "wos-plaintext-savedrecs.txt", dbsource="wos",format="plaintext")
scopb <- convert2df(file = "2022-bibliometric-workshop/scopus-bib-crc.bib", dbsource = "scopus", format = "bibtex")
pubmed <- convert2df(file = "pubmed-plaintext-colorectal-set.txt", dbsource = "pubmed", format = "plaintext")

fulldb <- mergeDbSources(wos, scopb, pubmed, remove.duplicated = TRUE)

#check the row count difference between the merged and the full count of all the databases
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

#Below is a technique to curate the list further by viewing the title and abstract on 
#each paper selecting only the papers that are most worthy. This method opens a new 
#window to perform the survey which does not work in the virtual environment. Try it
#out in your local RStudio!
library(metagear)

#Change the sentence case from full capitalize to only the first word of the sentence.
crc <- fulldb %>% 
  mutate(AB = str_to_sentence(AB)) %>%
  mutate(TI = str_to_sentence(TI))

#Create the file for abstract_screener
effort_distribute(crc, reviewers = 'Colton', initialize = TRUE, save_split = TRUE)

#Open GUI for screening papers
abstract_screener('effort_Colton.csv', 'Colton', abstractColumnName = 'AB', titleColumnName = 'TI', windowWidth = 120)
