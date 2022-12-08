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
                br(),
                h3("Purpose"),
                br(),
                "This App is used for manipulating data and model fitting, and also related to utility of R shiny",
                br(),
                h3("Data"),
                br(),
                "The data comes from UCI Machine Learning Repository. ",
                a("(Data Source here) ",href = "https://archive.ics.uci.edu/ml/datasets/Raisin+Dataset#"),
                "It has a binary response, and 7 continuous predictors, and it has total of 900 observations.",
                br(),
                "Here, the application has total of 4 pages. The About page gives an introduction of the project as well as the dataset. The Data Exploration page can enable creating numerical and graphical summares as well as some user-defined option for data and plots. In Model Fitting page, 3 supervised learning model will be utilized to model the data. At last, the Data page enables user to subset and save data.",  
                "∗ Include a picture related to the data (for instance, if the data was about the world wildlife fund, you might include a picture of their logo)",
        ),
        tabItem(tabName = "explore",
                h2("Data Exploration")
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