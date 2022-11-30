# A script to familiarize one to bibliometric analysis for literature review

library(bibliometrix) #Load and analyze bibliograpic data
library(tidyverse) #Organize the data
library(gt) #Make a nice table

#Convert individual query export files from respective databases to a dataframe
wos <- convert2df(file = "wos-plaintext-savedrecs.txt", dbsource="wos",format="plaintext")
scop <- convert2df(file = "scopus-bib-crc.bib", dbsource = "scopus", format = "bibtex")
pubmed <- convert2df(file = "pubmed-plaintext-colorectal-set.txt", dbsource = "pubmed", format = "plaintext")

#Combine each dataframe into a single one without keeping duplications
fulldb <- mergeDbSources(wos, scop, pubmed, remove.duplicated = TRUE)
class(fulldb)
glimpse(fulldb)

#check the row count difference between the merged and the full count of all the databases
nrow(fulldb)
sum(nrow(wos)+nrow(scop)+nrow(pubmed))

#Perform bibliometric analysis on the full database
results <- biblioAnalysis(fulldb)
class(results)
glimpse(results)
summary(results, k=10, pause=T)
plot(x=results, k=10, pause=T)

#Look at the most cited papers within the database
glimpse(results[["MostCitedPapers"]])

#Separate the most cited papers, arrange them in descending order, and create
#a link for each one
mcp <- results[["MostCitedPapers"]] %>%
  arrange(desc(NTC)) %>%
  mutate(Links = sprintf('<a href = "https://www.doi.org/%s">%s</a>', 
                          DOI,
                          "To Paper"
                         ),
         Links = lapply(Links, gt::html))

#Only look at the first twenty most cited papers normalized for year published
#with a link to the paper
mcp %>% head(n=20) %>% gt()

#Great, everything works! But what about seminal papers?
#Create a historiograph of the citations.
histResults <- histNetwork(fulldb, sep = ";") 

#Once we plot these results we can trace the nodes back through time to identify
#central papers that are reference often.
net <- histPlot(histResults, n=30, size = 5, labelsize = 4)

#Another method for identifying important papers across a timespan is through
#a Reference Publication Year Spectroscopy plot.
peaks <- rpys(fulldb, sep = ";") #whoops, the timespan across the x-axis seems
                                 #to go back to 1826! Let's adjust.

#If we look at the year of publication for our search, we see that the oldest
#article is from 2008. That means that the "Reference" of "Reference Publication
#Year Spectroscopy" are the references of the articles from our database search.
#Interestingly, these references stretch back to the inception of bibliographic 
#records. That's Cool. Let's investigate further.

#Minimum and maximum publication year of papers with our database search
min(results[["Years"]], na.rm = T)
max(results[["Years"]], na.rm = T)

#Using the tidyverse/dplyr method we can see the spread of article
#across the years. As a table, or a plot.
#Table
fulldb %>% 
  group_by(PY) %>%
  summarise(n = n())

#Plot
fulldb %>% 
  group_by(PY) %>%
  summarise(n = n()) %>%
  ggplot() + geom_line(aes(PY, n), color = 'magenta')

# Identify the separation character
fulldb$CR[1] #its `;`!

#Now let's summarise the cited manuscripts across the timespan
CR <- citations(fulldb, field = "article", sep = ";")
CR %>% 
  as.data.frame() %>%
  group_by(Year) %>%
  #na.omit() %>%
  filter(Year>=1826) %>%
  summarise(n = n()) %>%
  print(n = 90)

#and identify the most cited reference by year
CR %>%
  as.data.frame() %>%
  filter(Year>=1826) %>%
  group_by(Year) %>%
  slice(which.max(Cited.Freq)) %>%
  print(n = 90)

#We can see from these summary tables that there is not much variation in cited
#frequency before 1970. That can be the new anchor to our timespan.
#When we look back at the truncated RPYS, we can now identify peaks in citation
#deviations from the median. At these peaks, refer back to our most cited
#reference per year table to look into that article.
peaks <- rpys(fulldb, timespan = c(1970,2022), sep = ";")
CR %>%
  as.data.frame() %>%
  filter(Year>=1826) %>%
  group_by(Year) %>%
  slice(which.max(Cited.Freq)) %>%
  print(n = 90) 

######

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

saveRDS(missingdb, file = "wos-scopus-pubmed-mdb.rds")
saveRDS(fulldb, file = "wos-scopus-pubmed-fdb.rds")