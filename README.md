[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ccbaumler/2022-bibliometric-workshop/HEAD/?urlpath=rstudio)

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ccbaumler/2022-bibliometric-workshop/script/?urlpath=rstudio)

# Background

## Bibliometrics

> Bibliometrics turns the main tool of science, quantitative analysis, on itself. Essentially, bibliometrics is the application of quantitative analysis and statistics to publications such as journal articles and their accompanying citation counts. Quantitative evaluation of publication and citation data is now used in almost all scientific fields to evaluate growth, maturity, leading authors, conceptual and intellectual maps, trends of a scientific community.
>
> Bibliometrics is also used in research performance evaluation, especially in university and government labs, and also by policymakers, research directors and administrators, information specialists and librarians, and scholars themselves.
>
> From https://www.bibliometrix.org/vignettes/Introduction_to_bibliometrix.html

## Readability Metrics

This R script was used to analyze the readability of abstracts from a SCOPUS search result. There are five readability metrix used in this analysis based of the article [Write better, publish better](https://link.springer.com/article/10.1007/S11192-019-03332-4)

The readability metrics are:
1. Dale Chall
2. Gunning Fog
3. Simple Measure of Gobbledegook
4. Flesch
5. Flesh-Kincaid

**ADD BASIC DESCRIPTION OF EACH**

## Using the script

This repo has been set up to run in a Binder. A Binder is an "online service for building and sharing reproducible and interactive computational environments from online repositories."(https://mybinder.readthedocs.io/en/latest/introduction.html) 
[For more info on Binders and setting one up](https://mybinder.readthedocs.io/en/latest/index.html)

To access the interactive virtual Rstudio project containing the `readbaility.R` file, click here **->** [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ccbaumler/2022-bibliometric-workshop/HEAD?urlpath=rstudio) **<-**

Order of action will be:
1. Load libraries. These are packages that have already been installed into the project, but require initialization through the `library()`
2. Create a dataframe from the SCOPUS search export file.
3. Isolate abstracts from the dataframe.
4. Create lists on lists on lists of readability metrics (defined above).

1. 
