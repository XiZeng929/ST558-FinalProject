#ST558 Final Project
#Xi Zeng

#Packaged used
library(shiny)
library(tidyverse)
library(DT)
library(readxl)
library(shinydashboard)
library(randomForest)

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
#Define the body of the ui
body <- dashboardBody(
    #Define the first data page
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
                "It has a binary response,each class of response have 450 count. The datset also contains 7 continuous predictors, and it has total of 900 observations.",
                br(),
                "Here, the application has total of 4 pages. The About page gives an introduction of the project as well as the dataset. The Data Exploration page can enable creating numerical and graphical summares as well as some user-defined option for data and plots. In Model Fitting page, 3 supervised learning model will be utilized to model the data. At last, the Data page enables user to subset and save data."
        ),
        #Define the data exploration tab
        tabItem(tabName = "explore",
                h2("Data Exploration"),
                box(
                    #Subsetting dataset using class
                    selectInput("subset",
                                "Class for subsetting dataset",
                                choices = c("Kecimen" = "Kecimen",
                                            "Besni" = "Besni",
                                            "Both Class" = "both"),
                                selected = "Kecimen"),
                    #Define user input for graphical summaries
                    selectInput("var",
                                "Variable selected for plot",
                                choices = c(Area = "Area",
                                            MajorAxisLength = "MajorAxisLength",
                                            MinorAxisLength = "MinorAxisLength",
                                            Eccentricity = "Eccentricity",
                                            ConvexArea = "ConvexArea",
                                            Extent = "Extent",
                                            Perimeter = "Perimeter"),
                                            selected = "Area"),
                    #Define typr of the plot shown
                    conditionalPanel(condition = "input.var !=  'Class'",
                                     selectInput("type",
                                                 "Type of graphical summary",
                                                 choices = c(Scatterplot = "scatter",
                                                            Histogram = "hist"))
                    ),
                    #Set options for coloring the points by Class
                    conditionalPanel(condition = "input.subset =='both'",
                                     checkboxInput("color",
                                                   "Also change color based on class?")),
                    #Set options for calculating summary statistics
                    selectInput("var2",
                                "Variable selected for summary statistic",
                                choices = c(Area = "Area",
                                            MajorAxisLength = "MajorAxisLength",
                                            MinorAxisLength = "MinorAxisLength",
                                            Eccentricity = "Eccentricity",
                                            ConvexArea = "ConvexArea",
                                            Extent = "Extent",
                                            Perimeter = "Perimeter"),
                                            selected = "Area"),
                    selectInput("stat",
                                "Type of summary statistic",
                                choices = c(mean = "mean",
                                            maximum = "maximum",
                                            minimum = "minimun",
                                            "standard deviation" = "standard deviation"),
                                selected = "mean")),
                    
                #The graphical summaries and statistic summaries output
                plotOutput("graph"),
                textOutput("summary"),
                dataTableOutput("table")
        ),
        
        #Define the model info tab
        tabItem(tabName = "info",
                h2("Model Information"),
                br(),
                h3("Generalized Linear Regression"),
                p(strong("Logistic regression"), " is a generalized linear regression model. It typically is for a binary response, and it uses a logit link function to connnect the log odds with linear combination of the predictors. It makes no assumptions about distributions of classes in the feature space, but it assumes linearity between dependent variables and the independent variables. The model equation is constructed below: "),
                #The model equation for logistic regression
                withMathJax(),
                helpText('$$log\\frac{P(Class = Besni)}{1-P(Class = Besni)}=\\beta_0+\\beta_1x_1+\\beta_2x_2+...+\\beta_px_p$$'),
                br(),
                h3("Classification Tree"),
                p(strong("Classification tree"), " is a machine learning algorithm for classification. It is a structural mapping of binary desicions that lead to a decision about the class of an object. It is easy to interpret, and it is non-parametric, which means it does not require that the data associated with a particular class on a particular attribute follow any specific distribution (such as a normal distribution). However, it can have poor results for small datasets, and overfitting can easily occur. Also, the tree may need to be pruned for generalization."),
                br(),
                h3("Random Forest"),
                p(strong("Random forest"), " is an ensemble learning method for classification, regression and other tasks that operates by constructing a multitude of decision trees at training time. Here for classification tasks, the output of the random forest is the class selected by most trees. Since it averages multiple decision trees, it often achieves higher accuracy than a single desicion tree fit, but it also sacrifices interprebility because of this.")
                ),
        #Define the model fitting tab
        tabItem(tabName = "fitting",
                tabPanel(
                 h2("Model Fitting"),
                 h3("Note: In model fitting, Class Kecimen is assigned to be 0, while Besni is assigned to 1"),
                 sliderInput("prop",
                             "Select the proportion of data for train set",
                             min = 0,
                             max = 1,
                             step = 0.05,
                             value = 0.7),
                 checkboxGroupInput("logitvar",
                                    "Select predictors used for Logistic Regression",
                                    choices = names(raisin%>%select(-Class))),
                                    #selected = "Area"),
                 checkboxGroupInput("treevar",
                                    "Select predictors used for Classification Tree",
                                    choices = names(raisin%>%select(-Class))),
                                    #selected = "Area"),
                 #User input for setting tuning parameters for rf model 
                 sliderInput("rfmtry",
                             "Select the maximum tuning parameter mtry for random forest model",
                             min = 0,
                             max = 7,
                             step = 1,
                             value = 2),
                checkboxInput("cv", "Also use Cross-Validation?"),
                #Set folds for cv
                conditionalPanel("input.cv",
                                  numericInput("fold",
                                               "How many folds for cross-validation?",
                                                value = 5,
                                                min = 1, 
                                                max = 100, 
                                                step = 1)),
                actionButton("action",h3("Start model fitting")),
                br(),
                
                #Output for the 3 types of models
                textOutput("inslogit"),
                verbatimTextOutput("logit"),
                textOutput("instree"),
                plotOutput("treeplot"),
                verbatimTextOutput("tree"),
                textOutput("insrf"),
                verbatimTextOutput("rf"),
                plotOutput("rfplot"),
                ),
        ),
        #Define the prediction tab
        tabItem(tabName = "pred",
                h2("Prediction"),
                h3("Note: In model fitting, Class Kecimen is assigned to be 0, while Besni is assigned to 1"),
                #Input for type of the model used to predict
                selectInput("model",
                            "Model selected for prediction",
                            choices = c("Logistic Regression"  = "logit",
                                        "Classification Tree" = "tree",
                                        "Random Forset" = "rf"),
                            selected = "logit"),
                #Input for new data point
                numericInput("Area","Area",min = 0,value = round(mean(raisin$Area))),
                numericInput("MajorAxisLength","MajorAxisLength",value = round(mean(raisin$MajorAxisLength))),
                numericInput("MinorAxisLength","MinorAxisLength",min = 0,value = round(mean(raisin$MinorAxisLength))),
                numericInput("Eccentricity","Eccentricity",min = 0,value = round(mean(raisin$Eccentricity))),
                numericInput("ConvexArea","ConvexArea",min = 0,value = round(mean(raisin$ConvexArea))),
                numericInput("Extent","Extent",min = 0,value = round(mean(raisin$Extent))),
                numericInput("Perimeter","Perimeter",min = 0,value = round(mean(raisin$Perimeter))),
                #Output prediction result
                verbatimTextOutput("prediction")
        ),
        
        #Define the last data subseting tab
        tabItem(tabName = "data",
                h2("Data subsetting"),
                p("In this page, users can scroll through the daset, also can subset the raisin data and download the subsetted data as a csv file. "),
                #Define the columns for subset data
                selectInput(
                    inputId = "subcol",
                    label = "Select columns:",
                    choices = names(raisin),
                    multiple = TRUE),
                
                #Define the row numbers for subset data
                numericInput("startrow","Start Row Number",min = 1,max = length(raisin$Class),value = 1,step = 1),
                numericInput("endrow","End Row Number",min = 1, max = length(raisin$Class),value = 50, step = 1),
                
                #Set the download button for downloading the dataset
                downloadButton(outputId = "download",
                               label = "Download"),
                br(),
                #Output data table
                dataTableOutput("data")
        
        )
    )
)

 
#Wrap the header, sidebar and body
dashboardPage(
    header,
    sidebar,
    body
)