#ST558 Final Project
#Xi Zeng

#Packaged used
library(shiny)
library(tidyverse)
library(DT)
library(readxl)
library(shinydashboard)

#Read in data
raisin <- read_excel("Raisin_Dataset.xlsx", sheet = "Raisin_Grains_Dataset")


#Define UI output
header <- dashboardHeader(title = "Final Project")

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("About", tabName = "desc"),
        menuItem("Data Exploration", tabName = "explore"),
        menuItem("Modeling ", tabName = "model",
                 menuSubItem("Modeling Info", tabName = "info"),
                 menuSubItem("Model Fitting", tabName = "fitting"),
                 menuSubItem("Prediction", tabName = "pred")),
        menuItem("Data", tabName = "data")
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "desc",
                h2("Data Description"),
                imageOutput("image"),
                br(),
                h3("Purpose"),
                br(),
                "This App is used for manipulating data and model fitting, and also related to utility of R shiny package as well as shinydashboard package.",
                br(),
                h3("Data"),
                br(),
                "The dataset is a raisins dataset that comes from UCI Machine Learning Repository. ",
                a("(Data Source here) ",href = "https://archive.ics.uci.edu/ml/datasets/Raisin+Dataset#"),
                "It has a binary response, and 7 continuous predictors, and it has total of 900 observations.",
                br(),
                "Here, the application has total of 4 pages. The About page gives an introduction of the project as well as the dataset. The Data Exploration page can enable creating numerical and graphical summares as well as some user-defined option for data and plots. In Model Fitting page, 3 supervised learning model will be utilized to model the data. At last, the Data page enables user to subset and save data.",  
        ),
        tabItem(tabName = "explore",
                h2("Data Exploration"),
                box(
                    selectInput("var",
                                "Variable",
                                choices = c(Area = "area",                                                                          MajorAxisLength = "majoraxis",
                                            MinorAxisLength = "minoraxis",
                                            Eccentricity = "eccentricity",
                                            ConvexArea = "convex",
                                            Extent = "extent",
                                            Perimeter = "peri"),
                                selected = "area")
                ),
                plotOutput("scatter"),
        ),
        
        tabItem(tabName = "model",
                h2("Modelling")
        ),
        tabItem(tabName = "data",
                h2("Data glance and subsetting")
        )
    )
)


dashboardPage(
    header,
    sidebar,
    body
)