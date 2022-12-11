#ST558 Final Project
#Xi Zeng

#Packaged used
library(shiny)
library(tidyverse)
library(DT)
library(readxl)
library(caret)
library(tree)
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
    #Logistic regression model fitting
    logit_data <- reactive ({
        value <- input$prop
        raisin$Class = as.factor(ifelse(raisin$Class == "Kecimen", 0, 1))
        raisinIndex <- createDataPartition(raisin$Class, p = value, list = FALSE)
        train <- raisin[raisinIndex, ]
        test <- raisin[-raisinIndex, ]
        # summary(glm(raisin$Class ~ raisin[, variable], family = "binomial"))
        form <- sprintf("%s~%s","Class",paste0(input$logitvar,collapse="+"))
        
        if(input$action){
            logreg <-glm(as.formula(form),family=binomial(),data=train)
             summary(logreg)}
        })
    #Print out text that summarizes the logistic regression model
    output$inslogit <- renderText({
        if(input$action == 1){
        data <- logit_data()
        form <- sprintf("%s~%s","Class",paste0(input$logitvar,collapse= "+" ))
        paste0("The output of logistic regression model on training set is shown below, ",
               "and the formula used for Logistic regression is: " , form)}
    })
    #Print summary of the logistic regression
    output$logit <- renderPrint({
        logit_data()
        })
    
    #Classification tree model fitting
    tree_data <- reactive ({
        value <- input$prop
        raisin$Class = as.factor(ifelse(raisin$Class == "Kecimen", 0, 1))
        raisinIndex <- createDataPartition(raisin$Class, p = value, list = FALSE)
        train <- raisin[raisinIndex, ]
        test <- raisin[-raisinIndex, ]
        print(input$treevar)
        form <- sprintf("%s~%s","Class",paste0(input$treevar,collapse= "+" ))
        #print(paste0("Formula form: ", form))
        if(input$action){
            treefit <- tree(as.formula(form),data = train)
            treefit}
       })
    #Print out text that summarizes the classification tree model
    output$instree <- renderText({
        if(input$action == 1){
        data <- tree_data()
        form <- sprintf("%s~%s","Class",paste0(input$treevar,collapse= "+" ))
        paste0("The output of Classification tree model on training set is shown below, ",
               "and the formula used for Logistic regression is: " , form)}
    })
    #Ad  summary(tree fit as well)
    output$tree <- renderPlot({
        if(input$action){treefit <- tree_data()
              plot(treefit)
              text(treefit)}
    })
    
    #Random Forest modeling
    rf_data <- reactive ({
        value <- input$prop
        raisin$Class = as.factor(ifelse(raisin$Class == "Kecimen", 0, 1))
        
        raisinIndex <- createDataPartition(raisin$Class, p = value, list = FALSE)
        train <- raisin[raisinIndex, ]
        test <- raisin[-raisinIndex, ]
        form <- sprintf("%s~%s","Class",paste0(input$rfvar,collapse= "+" ))
        #print(paste0("Formula form: ", form))  #Add text output
        if(input$action){rffit <- train(as.formula(form),
                       data = train,
                       method = "rf",
                       trControl = trainControl(method = "cv",
                                                number = 5),
                       tuneGrid = data.frame(mtry = 1:input$rfmtry))
        rfPred <- predict(rffit, newdata = test)}
        #rfRMSE <- sqrt(mean((rfPred-diamondsTest$price)^2))
        # Variable importance plot
        #varImpPlot(classifier_RF)
        #treefit
    })
    #Print out text that summarizes the random forest model
    output$instree <- renderText({
        if(input$action){
        data <- rf_data()
        form <- sprintf("%s~%s","Class",paste0(input$rfvar,collapse= "+" ))
        paste0("The output of Random Forest model on training set is shown below, ",
               "and the formula used for Random forest classification is: " , form)}
    })
})
# output$logit <- renderText({
#     data <- model_data()
#     glmFit <- glm(Class ~ input$logitvar, data = train, family = "binomial")
