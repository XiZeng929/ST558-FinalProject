Readme
================
Xi Zeng
2022-12-13

## Description of the App

This is an app for data exploration and modelling as well as subsetting
data for the raisin dataset from UCI machine learning repository,see
<https://archive.ics.uci.edu/ml/datasets/Raisin+Dataset#> for more
details.

## Packages list needed to nun the App

[`shiny`](https://cran.r-project.org/web/packages/shiny/index.html)  
[`tidyverse`](https://www.tidyverse.org/)  
[`shinydashboard`](https://cran.r-project.org/web/packages/shinydashboard/index.html)  
[`DT`](https://www.rdocumentation.org/packages/DT/versions/0.16)  
[`readxl`](https://readxl.tidyverse.org/)  
[`tree`](https://www.rdocumentation.org/packages/tree/versions/1.0-42)  
[`randomForest`](https://www.rdocumentation.org/packages/randomForest/versions/4.7-1.1)  
[`caret`](https://topepo.github.io/caret/)

# Code for Install Package Lists

``` r
install.packages(c("shiny", "tidyverse", "shinydashboard",
                   "DT", "readxl", "tree", "randomForest","caret))
```

## Code for run the App

``` r
shiny::runGitHub(repo = "ST558-FinalProject", username = "XiZeng929",subdir = "Final_Project/")
```

# Code to render README file

``` r
rmarkdown::render("README.rmd", 
          output_format = "github_document",
          output_file = "README.md",
          output_options = list(
            html_preview = FALSE))
```
