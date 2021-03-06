library(shiny)
library(ggplot2)

shinyServer(function(input, output) {
    
	output$methods <- renderUI({
		methods_list = list.files("./methods/")
		checkboxGroupInput("methods", label = "Choose methods:", 
                       choices = methods_list)
  	})

	output$target <- renderUI({
		radioButtons("target", "Choose target:",
               c("male" = "male","female" = "female"))
  	})

	output$plot <- renderPlot({

		files <- input$methods 

		if(is.null(files)) {
			return()
		}

		target = input$target
		sensitivityResult <- c()
		specificityResult <- c()

		for(file in files) {
		  d <- read.table(paste0("./methods/",file), header = T, sep = ",")
		  
		  sensitivity <- round(calSensitivity(d$prediction, d$reference, target), digit = 2)
		  specificity <- round(calSpecificity(d$prediction, d$reference, target), digit = 2)

		  sensitivity <- replace(sensitivity, is.nan(sensitivity), 0)
		  specificity <- replace(specificity, is.nan(specificity), 0)
		  
		  sensitivityResult <- c(sensitivityResult, sensitivity)
		  specificityResult <- c(specificityResult, specificity)
		}

		data = do.call(rbind.data.frame, Map('c', sensitivityResult, specificityResult))
		ggplot(data, aes(x=specificityResult, y=sensitivityResult)) + geom_point()
		
	})   

	output$table <- renderTable({

		files <- input$methods 
		

		if(is.null(files)) {
			return()
		}

		target = input$target
		sensitivityResult <- c()
		specificityResult <- c()
		methods <- c()

		for(file in files) {
		  d <- read.table(paste0("./methods/",file), header = T, sep = ",")
		  
  		  method <- gsub(".csv", "", basename(file))
		  sensitivity <- round(calSensitivity(d$prediction, d$reference, target), digit = 2)
		  specificity <- round(calSpecificity(d$prediction, d$reference, target), digit = 2)

		  sensitivity <- replace(sensitivity, is.nan(sensitivity), 0)
		  specificity <- replace(specificity, is.nan(specificity), 0)
		  
		  methods <- c(methods, method)
		  sensitivityResult <- c(sensitivityResult, sensitivity)
		  specificityResult <- c(specificityResult, specificity)
		}

		data <- cbind(method=methods, sensensitivity=sensitivityResult, specificity=specificityResult)
		data
   

	})     
})

calConfusionMatrix <- function(pred, ref, target) {
  tandf = c(pred == ref)
  pandn = c(pred == target)
  confusionmatrix <- table(truth = tandf, prediction = pandn)
  return (confusionmatrix)
}


calSensitivity <- function(pred, ref, target) {
  confusionmatrix <- calConfusionMatrix(pred, ref, target)
  return (confusionmatrix[4] / (confusionmatrix[4] + confusionmatrix[1]))
}

calSpecificity <- function(pred, ref, target) {
  confusionmatrix <- calConfusionMatrix(pred, ref, target)
  return (confusionmatrix[2] / (confusionmatrix[2] + confusionmatrix[3]))
}
