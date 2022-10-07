#A script to create a readability list from Scopus/WoS search results

library(bibliometrix)  #Load the site search results
library(quanteda.textstats) # analysis tool for readability - https://www.rdocumentation.org/packages/quanteda.textstats/versions/0.96
                            # https://www.rdocumentation.org/packages/quanteda.textstats/versions/0.95/topics/textstat_readability
library(dplyr)
library(gt)
# Converting database search export files into R bibliographic dataframe
M <- convert2df(file="scopus_CRC_MandM.bib", dbsource="scopus",format="bibtex")

#create an abstract only vector
abstracts <- M$AB

###
#From Write better, publish better
#(https://link.springer.com/article/10.1007/S11192-019-03332-4)
#readability metrics are Flesch Reading Ease = `"Flesch"`,
#Flesch-Kincaid = `"Flesch.Kincaid"`, Gunning Fog = `"FOG"`,
#Simple Measure of Gobbledegook = `"SMOG"`, Dale Chall = `"Dale.Chall"`
#NOTE: the Dale.Chall need modification to mimic
#the work documented in the paper linked.
#See the Dale-Chall link here -> https://www.erinhengel.com/software/textatistic/
#
#The below statistics are from the "quanteda.textstats" package which is 
#comparable to the "textatistic" python library
###

#We could build a dataframe for each individual statistic
##The old formula from Dale and Chall 1948. the higher the score the higher the
##grade of the writing. >9 is college.
dc <- textstat_readability(abstracts, measure = "Dale.Chall.old")
head(dc)

##
fk <- textstat_readability(abstracts, measure = "Flesch.Kincaid")
head(fk)

fog <- textstat_readability(abstracts, measure = "FOG")
head(fog)

smog <- textstat_readability(abstracts, measure = "SMOG")
head(smog)

f <- textstat_readability(abstracts, measure = "Flesch")
head(f)

#Can we combine these stats into a single dataframe?
merged_stats <- do.call(cbind, list(dc, fk, fog, smog, f))
head(merged_stats)

#Now we have numerous duplicate rows that need to be removed
merged_stats <- merged_stats[ , !duplicated(colnames(merged_stats))]
head(merged_stats)

#This can all be done in a single command where we use `c()` to combine arguments
#While this simplification removes many redundant lines of code, it also prevents
#Errors in the data manipulation 
all_stats <- textstat_readability(M$AB, measure = c("Dale.Chall.old",
                                       "Flesch.Kincaid",
                                       "FOG", 
                                       "SMOG",
                                       "Flesch"))
head(all_stats)


#In addition, using the dplyr package, we can `pipe` sequential commands like so...
r.ab <- M$AB %>% 
  textstat_readability(measure = c("Dale.Chall.old", #min
                                   "Flesch.Kincaid", #min
                                   "FOG", #min
                                   "SMOG", #min
                                   "Flesch")) %>% #max 
  cbind(M$TI) %>% #add titles
  rename(Titles=7)%>%
  na.omit() #remove NA values

#Summarize the data
summary(r.ab)



#Finally, let's create a list of readability. If I create a subset from the 
#original dataframe column that is ranked, I get a ranked list of 1-10.
sort(r.ab$Dale.Chall.old)
head(r.ab$Dale.Chall.old, n = 10)

sort(head(r.ab$Dale.Chall.old, n = 10))

#Placing a `?` in front of a command will show documnetation on the command
?head()
?sort()

#If I create a ranked list from the original dataframe column that is a subset, 
#I get a ranked list of the readability metric.
head(sort(r.ab$Dale.Chall.old), n = 10)

#We could try creating a sorted database, but what's wrong with this?
ranked_list <- r.ab %>%
  mutate(dco_rank = sort(Dale.Chall.old), 
         fk_rank = sort(Flesch.Kincaid), 
         fog_rank = sort(FOG), 
         smog_rank = sort(SMOG),
         f_rank = sort(Flesch, decreasing = TRUE))
#We get new columns that are tied to the rows in an incorrect order!

#Let's try a different approach! `arrange()` is a dplyr function that will create
#a similar output as `sort()`. With the `gt` library, we can make pretty tables!
r.ab %>%  
  arrange(Dale.Chall.old) %>%
  head(n=10) %>%
  select(Titles, Dale.Chall.old) %>%
  gt(groupname_col = "Titles") %>%
  fmt_number(columns = Dale.Chall.old, decimals = 2) 

r.ab %>%  
  arrange(Flesch.Kincaid) %>%
  head(n=10) %>%
  select(Titles, Flesch.Kincaid) %>%
  gt(groupname_col = "Titles") %>%
  fmt_number(columns = Flesch.Kincaid, decimals = 2)

r.ab %>%  
  arrange(FOG) %>%
  head(n=10) %>%
  select(Titles, FOG) %>%
  gt(groupname_col = "Titles") %>%
  fmt_number(columns = FOG, decimals = 2)

r.ab %>%  
  arrange(SMOG) %>%
  head(n=10) %>%
  select(Titles, SMOG) %>%
  gt(groupname_col = "Titles") %>%
  fmt_number(columns = SMOG, decimals = 2)

r.ab %>%  
  arrange(desc(Flesch)) %>%
  head(n=10) %>%
  select(Titles, Flesch) %>%
  gt(groupname_col = "Titles") %>%
  fmt_number(columns = Flesch, decimals = 2)
  
#The first two in this sample may suggest; (1) I need to perform a better search 
#that will eliminate corrections 
print(M[166,"AB"])
print(M[51,"AB"])
print(M[166,"url"])

#Can I make a for loop? duck if i know
df <- data.frame()
for (i in length(colnames(r.ab))) {
  if (i %in% c(1,7)) next
  if (i %in% 6){
    df <- arrange((r.ab[i])) %>%
      select(Titles) %>%
      head(n=10)
  }
  else {
    df <- sort(r.ab[i]) %>%
      filter(head(n=10))
  }
  df1[[i]] <- df
}
head(df)