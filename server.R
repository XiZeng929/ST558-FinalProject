#ST558 Final Project
#Xi Zeng

#Packaged used
library(shiny)
library(tidyverse)
library(DT)
library(readxl)
library(caret)
set.seed(1001)

#Read in data
raisin <- read_excel("Raisin_Dataset.xlsx", sheet = "Raisin_Grains_Dataset")

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
    #Generate subset data according to the user input
    data <- reactive({
        value <- input$subset
        ifelse(input$subset == "both",subdata <- raisin,subdata <- raisin%>%filter(Class == value))
        subdata
    })

    output$image <- renderImage({
        list(src = "raisin_image.jpg",
             width = 400,
             height = 400)
    } ,deleteFile = FALSE)
    output$graph <- renderPlot({
         newdata <- data()
         options(repr.plot.width = 1, repr.plot.height =1)
         if (input$color & input$type == "scatter") {
             ggplot(newdata,aes_string(x = 1:dim(newdata)[1], y = input$var)) + geom_point(aes(col = Class)) + xlab("index") + ylab(input$var)
         } else if (input$color & input$type == "hist") {
             ggplot(newdata, aes_string(x = input$var,fill = "Class"))+geom_histogram(alpha = 0.5, position = "identity", bins = 50)
         } else if(input$type == "scatter"){
         ggplot(newdata,aes_string(x = 1:dim(newdata)[1], y = input$var)) + geom_point() + xlab("index") + ylab(input$var)
         } else if(input$type == "hist"){
         ggplot(newdata, aes_string(x = input$var))+geom_histogram(bins = 50)  
         }
         
    },
    width = 300, height = 300)
    output$summary <- renderText({
        newdata <- data()
        if (input$stat == "minimum"){
            out = round(min(newdata[, input$var2]),2)
        } 
         else if (input$stat == "maximum") {
             out = round(max(newdata[, input$var2]),2)
         }else if (input$stat == "mean") {
             out = round(mean(newdata[, input$var2][[1]]),2)
         }else{
             out = round(sd(newdata[, input$var2][[1]]),2)
         }
        paste0("The ", input$stat, " of " , input$var2, " is ", out)
    })
    output$table <- renderTable({
        newdata <- data()
    })
    # model_data <- reactive({
    #     value <- input$prop
    #     raisinIndex <- createDataPartition(diamonds$price, p = value, list = FALSE)
    #     train <- raisin[raisindIndex, ]
    #     test <- raisin[-raisinIndex, ]
    #     train
    #     test
    # })
    # #Logistic regression model fitting
    # output$logit <- renderText({
    #     data <- model_data() 
    #     glmFit <- glm(Class ~ input$logitvar, data = train, family = "binomial")  
    # })
    

})
