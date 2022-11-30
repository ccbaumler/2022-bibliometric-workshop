[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ccbaumler/2022-bibliometric-workshop/HEAD/?urlpath=rstudio)

## Bibliometrics

> Bibliometrics turns the main tool of science, quantitative analysis, on itself. Essentially, bibliometrics is the application of quantitative analysis and statistics to publications such as journal articles and their accompanying citation counts. Quantitative evaluation of publication and citation data is now used in almost all scientific fields to evaluate growth, maturity, leading authors, conceptual and intellectual maps, trends of a scientific community.
>
> Bibliometrics is also used in research performance evaluation, especially in university and government labs, and also by policymakers, research directors and administrators, information specialists and librarians, and scholars themselves.
>
> From https://www.bibliometrix.org/vignettes/Introduction_to_bibliometrix.html

Finding the field of bibliometrics inspired me to create a template for:
1. Identifying the most relavent papers to a domain of science
2. Locate historical/seminal papers that shaped that domain
3. Create statistically-backed results to aid readers in attaining domain expertise

This method is preferable to my original training in scientific journal reading as it allows the mathematics to guide the reader to priority papers.

## Using this Repo

This repo has been set up to run in a Binder. A Binder is an "online service for building and sharing reproducible and interactive computational environments from online repositories."(https://mybinder.readthedocs.io/en/latest/introduction.html) 
[For more info on Binders and setting one up](https://mybinder.readthedocs.io/en/latest/index.html)

To access the interactive virtual Rstudio project containing the `create-combine-dbs.R` and `readability.R` file, click here **->** [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ccbaumler/2022-bibliometric-workshop/HEAD?urlpath=rstudio) **<-**

## Creating and Combining Query Results

The R script `create-combine-dbs.R` was used to identify the domain-specific documents of a combined bibliographic database query to consume to acquire competency quickest. Using three bibliometric techniques, this script:

1. Lists documents by mean normalized total citations
2. Identifies cited references of importance
3. Shows root historical documents

Order of script actions will be:
1. Load libraries. These are packages that have already been installed into the project, but require initialization through the `library()`
2. Create a dataframe combining all search export files.
3. Analyze bibliographic dataframe.
4. Create the outputs described above.
5. Suggest an additional method for sifting through documents quickly.

Note: Step 5 cannot load within a virtual environment. I have included it for local use only.

## Readability Metrics

The R script `readability.R` was used to analyze the readability of abstracts from a SCOPUS search result. There are five readability metrix used in this analysis based of the article [Write better, publish better](https://link.springer.com/article/10.1007/S11192-019-03332-4)

The readability metrics are: 
**ADD BASIC DESCRIPTION OF EACH**
1. Dale Chall
2. Gunning Fog
3. Simple Measure of Gobbledegook
4. Flesch
5. Flesh-Kincaid
[Formulas may be found here](https://www.rdocumentation.org/packages/quanteda.textstats/versions/0.95/topics/textstat_readability)

Order of script actions will be:
1. Load libraries. These are packages that have already been installed into the project, but require initialization through the `library()`
2. Create a dataframe from the SCOPUS search export file.
3. Isolate abstracts from the dataframe.
4. Play with the dataframe.
5. Create nice table of readability stats.
