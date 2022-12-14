#A script to create a readability list from Scopus/WoS search results

library(dplyr) # Data manipulation
library(gt) #Presentation-ready tables
library(bibliometrix)  #Load the site search results
library(quanteda.textstats) # analysis tool for readability - https://www.rdocumentation.org/packages/quanteda.textstats/versions/0.96
                            # https://www.rdocumentation.org/packages/quanteda.textstats/versions/0.95/topics/textstat_readability

# Converting database search export files into R bibliographic dataframe
M <- convert2df(file="scopus-bib-crc.bib", dbsource="scopus",format="bibtex")
class(M)
glimpse(M)


#create an abstract only character vector
abstracts <- M$AB
class(abstracts)
glimpse(abstracts)

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

#But now we have numerous duplicate rows that need to be removed
merged_stats <- merged_stats[ , !duplicated(colnames(merged_stats))]
head(merged_stats)

#This can all be done in a single command where we use `c()` to combine 
#arguments. While this simplification removes many redundant lines of code, it 
#also prevents errors in the data manipulation 
all_stats <- textstat_readability(M$AB, measure = c("Dale.Chall.old",
                                       "Flesch.Kincaid",
                                       "FOG", 
                                       "SMOG",
                                       "Flesch"))
head(all_stats)
class(all_stats)
glimpse(all_stats)

#In addition, using the dplyr package, we can `pipe` sequential commands 
#like so... This creates 
r.ab <- M$AB %>% 
  textstat_readability(measure = c("Dale.Chall.old", #min
                                   "Flesch.Kincaid", #min
                                   "FOG", #min
                                   "SMOG", #min
                                   "Flesch")) %>% #max 
  cbind(M$TI) %>% #add titles
  rename(Titles=7)%>%
  cbind(M$DI) %>%
  rename(DI=8) %>%
  na.omit() #remove NA values
class(r.ab)
glimpse(r.ab)

#Summarize the data to see basic metrics of the values per column
summary(r.ab)



#Let's create some lists of document readability. 

#Using the `sort()` and `head()`commands, 
#we can start to create some basic lists.
#These commands are both part of base R.
#Placing a `?` in front of a command will show documnetation on the command
?head()
?sort()

sort(r.ab$Dale.Chall.old)
head(r.ab$Dale.Chall.old, n = 10)

#If I create a subset from a dataframe column that is ranked, 
#I get a ranked list of 1-10.
sort(head(r.ab$Dale.Chall.old, n = 10))

#If I create a ranked list from the original dataframe column that is a subset, 
#I get a ranked list of the readability metric.
head(sort(r.ab$Dale.Chall.old), n = 10)

#The `mutate()` command is from the dplyr package. It allows us to 
#"create, modify, and delete columns" in our database.
#We could try creating a sorted database, but what's wrong with this?
ranked_list <- r.ab %>%
  mutate(dco_rank = sort(Dale.Chall.old), 
         fk_rank = sort(Flesch.Kincaid), 
         fog_rank = sort(FOG), 
         smog_rank = sort(SMOG),
         f_rank = sort(Flesch, decreasing = TRUE))
#We get new columns that are tied to the rows in an incorrect order!

#Let's try a different approach! `arrange()` is a dplyr function 
#that will create a similar output as `sort()`. With the `gt` library, 
#we can make pretty tables!
r.ab %>%  
  arrange(Flesch.Kincaid) %>%
  head(n=10) %>%
  select(Titles, Flesch.Kincaid) %>%
  gt(groupname_col = "Titles") %>%
  fmt_number(columns = Flesch.Kincaid, decimals = 2)


r.ab %>%  
  arrange(Dale.Chall.old) %>%
  head(n=10) %>%
  select(Titles, Dale.Chall.old, document) %>%
  gt(groupname_col = "Titles") %>%
  fmt_number(columns = Dale.Chall.old, decimals = 2)

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
  
#The first sample may suggest I need to refine my search 
#to eliminate document corrections.
top_n(r.ab, 1, Flesch)

print(M[51,"AB"])
print(M[51,"url"])

#Finally, lets make a table that is presentation-ready. 
#What is the best way to wrangle the data to create a 
#readable and visually pleasing table?
#Maybe we could use a for loop?
#Can I make a for loop? Nope, and I doooon't neeeed toooo!!!
#The `gt` package working with the `dplyr` package to 'simplify'
#the creation process.

#Let's concatenate the columns of readability
#stats into a column of names and values
looong <- tidyr::pivot_longer(r.ab, 
                              cols = c(Dale.Chall.old,
                                       FOG,
                                       SMOG,
                                       Flesch.Kincaid,
                                       Flesch)
                              )
class(looong)
glimpse(looong)

#This is a long list of dplyr functions that will highlight 
#the value of learning this type of command piping. 
#This table will display the top ten articles in
#each readability category. These articles will be displayed with the 'most' 
#readable document first in each category.
looong %>% #Use the longer dataframe
  mutate(Titles = sprintf('<a href = "https://www.doi.org/%s">%s</a>', 
                          DI, 
                          Titles),
         Titles = lapply(Titles, gt::html)) %>% #Hyperlink each Title with DOI link
  arrange(factor(name, levels = c("Flesch",
                                  "Dale.Chall.old",
                                  "FOG",
                                  "SMOG",
                                  "Flesch.Kincaid"
                                  )
          ), value) %>%
  group_by(name) %>% #while we could use 
                     #`group_by(name) %>% arrange(name, value)`
                     #using `arrange(factor())` allows us to
                     #set the order of the groups!
  filter((name %in% c("Dale.Chall.old", "FOG", "SMOG", "Flesch.Kincaid") & 
            row_number() %in% 1:10 |
            (name %in% "Flesch" & row_number() %in% (n()-9):n()))) %>% 
  #above we "filtered" the first 10 and bottom 10 rows of corresponding stats
  #remember that we have "arranged" each group by ascending values 
  arrange(value = ifelse(name %in% "Flesch", desc(value),
                        value)) %>% #if the name column contains Flesch
                                    #"arrange" by decreasing values 
  gt() %>%
  cols_hide(columns = c(document, DI)) %>%
  tab_stubhead(label = "Titles") %>%
  fmt_number(columns = value, decimals = 2)  %>%
  tab_header(
    title = md("The *most* readable documents"),
    subtitle = "Five readability statistics; Flesch, the old Dale-Chall, FOG, SMOG, and Flesch-Kincaid"
  ) %>%
  tab_style(
    locations = cells_title(groups = "title"),
    style     = list(
      cell_text(weight = "bold", 
                size = 24)
      )
    )%>%
  tab_options(
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    table.border.bottom.color = "transparent",
    data_row.padding = px(3),
    source_notes.font.size = 12,
    row_group.background.color = "grey") %>%
  tab_style(
    locations = cells_column_labels(columns = everything()),
    style     = list(
      cell_borders(sides = "bottom", 
                   weight = px(3)),
      cell_text(weight = "bold")
      )
    ) %>%
  tab_style(
    style = list(
      cell_text(
        align = "center",
        weight = "bold"
      )
    ),
    locations = list(
      cells_row_groups(
        groups = c("Dale.Chall.old",
                   "FOG",
                   "SMOG",
                   "Flesch.Kincaid",
                   "Flesch")
      )
    )
  ) %>%
  cols_align(
    align = "left",
    columns = Titles
  ) %>%
  tab_style(
    style = cell_text(size = px(12)),
    locations = cells_body(
      columns = Titles
    )
  ) %>%
  tab_source_note(
    source_note = md("Source: SCOPUS, Colorectal Metagenome and Metabolome Search")
  ) %>%
  tab_source_note(
    source_note = md(
      'Query: TITLE-ABS-KEY ( "colorectal cancer*"  OR  "colorectal neoplas*"  OR  "adenomatous polyposis coli"  OR  "colon* neoplas*"  OR  "rectal neoplas*"  OR  "hereditary nonpolypo*"  AND  "metagenom*"  AND  "metabol*" )'
    )
  ) %>%
  tab_footnote(
    footnote = md("The **lowest** estimated grade level."),
    locations = cells_body(
      columns = value, 
      rows = value == min(value)
    )
  ) %>%
  opt_footnote_marks(marks = c("*", "+"))

####

#Now let's quickly create a table that shows the readability of documents within
#the shared database file we saved from the create-combine-dbs.R script.
fdb <- readRDS("wos-scopus-pubmed-fdb.rds")

fdb.ab <- fdb$AB %>% 
  textstat_readability(measure = c("Dale.Chall.old", #min
                                   "Flesch.Kincaid", #min
                                   "FOG", #min
                                   "SMOG", #min
                                   "Flesch")) %>% #max 
  cbind(fdb$TI) %>% #add titles
  rename(Titles=7)%>%
  cbind(fdb$DI) %>%
  rename(DI=8) %>%
  na.omit() #remove NA values

looong <- tidyr::pivot_longer(fdb.ab, 
                              cols = c(Dale.Chall.old,
                                       FOG,
                                       SMOG,
                                       Flesch.Kincaid,
                                       Flesch)
)

looong %>% #Use the longer dataframe
  mutate(Titles = sprintf('<a href = "https://www.doi.org/%s">%s</a>', 
                          DI, 
                          Titles),
         Titles = lapply(Titles, gt::html)) %>% #Hyperlink each Title with DOI link
  arrange(factor(name, levels = c("Flesch",
                                  "Dale.Chall.old",
                                  "FOG",
                                  "SMOG",
                                  "Flesch.Kincaid"
  )
  ), value) %>%
  group_by(name) %>% #while we could use 
  #`group_by(name) %>% arrange(name, value)`
  #using `arrange(factor())` allows us to
  #set the order of the groups!
  filter((name %in% c("Dale.Chall.old", "FOG", "SMOG", "Flesch.Kincaid") & 
            row_number() %in% 1:20 |
            (name %in% "Flesch" & row_number() %in% (n()-19):n()))) %>% 
  #above we "filtered" the first 10 and bottom 10 rows of corresponding stats
  #remember that we have "arranged" each group by ascending values 
  arrange(value = ifelse(name %in% "Flesch", desc(value),
                         value)) %>% #if the name column contains Flesch
  #"arrange" by decreasing values 
  gt() %>%
  cols_hide(columns = c(document, DI)) %>%
  tab_stubhead(label = "Titles") %>%
  fmt_number(columns = value, decimals = 2)  %>%
  tab_header(
    title = md("The *most* readable documents"),
    subtitle = "Five readability statistics; Flesch, the old Dale-Chall, FOG, SMOG, and Flesch-Kincaid"
  ) %>%
  tab_style(
    locations = cells_title(groups = "title"),
    style     = list(
      cell_text(weight = "bold", 
                size = 24)
    )
  )%>%
  tab_options(
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    table.border.bottom.color = "transparent",
    data_row.padding = px(3),
    source_notes.font.size = 12,
    row_group.background.color = "grey") %>%
  tab_style(
    locations = cells_column_labels(columns = everything()),
    style     = list(
      cell_borders(sides = "bottom", 
                   weight = px(3)),
      cell_text(weight = "bold")
    )
  ) %>%
  tab_style(
    style = list(
      cell_text(
        align = "center",
        weight = "bold"
      )
    ),
    locations = list(
      cells_row_groups(
        groups = c("Dale.Chall.old",
                   "FOG",
                   "SMOG",
                   "Flesch.Kincaid",
                   "Flesch")
      )
    )
  ) %>%
  cols_align(
    align = "left",
    columns = Titles
  ) %>%
  tab_style(
    style = cell_text(size = px(12)),
    locations = cells_body(
      columns = Titles
    )
  ) %>%
  tab_source_note(
    source_note = md("Source: SCOPUS, Colorectal Metagenome and Metabolome Search")
  ) %>%
  tab_source_note(
    source_note = md(
      'Query: TITLE-ABS-KEY ( "colorectal cancer*"  OR  "colorectal neoplas*"  OR  "adenomatous polyposis coli"  OR  "colon* neoplas*"  OR  "rectal neoplas*"  OR  "hereditary nonpolypo*"  AND  "metagenom*"  AND  "metabol*" )'
    )
  ) %>%
  tab_footnote(
    footnote = md("The **lowest** estimated grade level."),
    locations = cells_body(
      columns = value, 
      rows = value == min(value)
    )
  ) %>%
  opt_footnote_marks(marks = c("*", "+"))
