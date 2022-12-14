#ST558 Final Project
#Xi Zeng

#Packaged used
library(shiny)
library(tidyverse)
library(DT)
library(readxl)
library(caret)
library(tree)
library(randomForest)
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
    
    #Add image regarding the raisin
    output$image <- renderImage({
        list(src = "raisin_image.jpg",
             width = 400,
             height = 400)
    } ,deleteFile = FALSE)
    
    #Output summary graphics according to ui input
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
    
    #Output summary statistics
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
    
    #Output data table that have been subsetted according to the user input
    output$table <- renderDataTable({
        newdata <- data()
    })
    
    #Create index for splitting data
    index <- reactive ({
        value <- input$prop
        raisinIndex <- createDataPartition(raisin$Class, p = value, list = FALSE)
        raisinIndex
    })
   
     #Create training set
    train <- reactive({
        raisinIndex <- index()
        raisin$Class = as.factor(ifelse(raisin$Class == "Kecimen", 0, 1))
        train <- raisin[raisinIndex, ]
        train
    })
    
    #Create test set
    test <- reactive({
        raisinIndex <- index()
        raisin$Class = as.factor(ifelse(raisin$Class == "Kecimen", 0, 1))
        test <- raisin[-raisinIndex, ]
        test
    })
    
    #Logistic regression model fitting
    logit_data <- reactive ({
        train <- train()
        form <- sprintf("%s~%s","Class",paste0(input$logitvar,collapse="+"))
        logreg <- glm(as.formula(form),family=binomial(),data=train)
        logreg
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
        if(input$action){
            logreg <- logit_data()
            test <- test()
            logit_pred <- predict(logreg, newdata = test,type = "response")
            logit_pred <-as.factor(ifelse(logit_pred >= 0.5,1,0))
            cm <- confusionMatrix(data = test$Class, reference = logit_pred)
            return(list("Summary of train set" = summary(logreg),
                        "Confusion matrix  for test set" = cm))}
        })
    
    #Classification tree model fitting
    tree_data <- reactive ({
        train <- train()
        form <- sprintf("%s~%s","Class",paste0(input$treevar,collapse= "+" ))
        if(input$action){
            treefit <- tree(as.formula(form),data = train)
            treefit}
       })
    
    #Print out text that summarizes the classification tree model
    output$instree <- renderText({
        if(input$action == 1){
        data <- tree_data()
        form <- sprintf("%s~%s","Class",paste0(input$treevar,collapse= "+" ))
        paste0("The output of Classification tree model on training set is shown below:")}
    })
    
    #Print out the classification tree plot along with text
    output$treeplot <- renderPlot({
        if(input$action){
            treefit <- tree_data()
              plot(treefit)
              text(treefit)}
    })
    #Print out the summary of classification tree model fit and performance metrics of test set
    output$tree <- renderPrint({
        if(input$action){
            treefit <- tree_data()
            test <- test()
            tree_pred <- predict(treefit,test)
            tree_pred <-as.factor(ifelse(tree_pred[,2] >= 0.5,1,0))
            cm <- confusionMatrix(data = test$Class, reference = tree_pred)
            return(list("Output for train set" = summary(treefit),
                        "Confusion matrix for test set"=cm))
            }
    })
    
    #Random Forest modeling
    rf_data <- reactive ({
        train <- train()
        if(input$action){
        if(input$cv){
            rffit <- caret::train(Class ~ .,
                           data = train,
                           method = "rf",
                           trControl = trainControl(method = "cv",
                                                    number = input$fold),
                           tuneGrid = data.frame(mtry = c(1:input$rfmtry)))
                      rfmodel <- randomForest(Class ~ ., data = train, mtry= rffit$bestTune[[1]])}
         else{
         rfmodel <- randomForest(Class ~ ., data = train, mtry = input$rfmtry)
        }
        return(rfmodel)}
                       
    })
    
    #Print out text that summarizes the random forest model
    output$insrf <- renderText({
        if(input$action){
        paste0("The output of Random forest model is shown below:")}
    })
    
    #Print out the summary of the random forest model
    output$rf <- renderPrint({
        if(input$action){
        rfmodel <- rf_data()
        test <- test()
        rfPred <- predict(rfmodel, newdata = test)
        cm <- confusionMatrix(data = test$Class,reference = rfPred)
        print(list("Output for train set" = rfmodel,
                  "Confusion matrix for test set" = cm))
        }
    })
    
    #Produce Variable importance plot for final random forest model
    output$rfplot <- renderPlot({
        if(input$action){
        rfmodel <- rf_data()
        varImpPlot(rfmodel)}
    })
    
    ###Prediction
    #Define a new data frame for the new data
    df <- reactive({
        df <- data.frame("Area" = input$Area,
                         "MajorAxisLength" = input$MajorAxisLength,
                         "MinorAxisLength"= input$MinorAxisLength,
                         "Eccentricity"= input$Eccentricity,
                         "ConvexArea"= input$ConvexArea,
                          "Extent"= input$Extent,
                         "Perimeter" = input$Perimeter)
    })
    
    #Create the output for prediction according to user input
    output$prediction <- renderPrint({
        if (input$model == "logit"){
           final_model <-logit_data()
           prediction <- predict(final_model, newdata = df(),type = "response")
           result <- data.frame(prediction,Class = ifelse(prediction > 0.5,"Besni","Kecimen"))
           print(result)
        }
        else if (input$model == "tree"){
            final_model <- tree_data()
           predict(final_model, newdata = df(),type = "class")
        }
        else {
            final_model <- rf_data()
            predict(final_model, newdata = df(),type = "vote")
        }
    })
    
    #Subsetting data according to the user input
    subdata <- reactive({
        colname <- input$subcol
        newdata <- raisin%>% select(colname)
        newdata <- newdata[input$startrow:input$endrow,]
        newdata
    })
    
    #Output the subsetted data as data table on the ui
    output$data <- renderDataTable({
        subdata <- subdata()
        subdata
    })
    
    #Define the option for downloading the subsetted data
    output$download <- downloadHandler(
        filename = "Raisin subset.csv",
        content = function(file){
            write_csv(subdata(),file)
        })
})

