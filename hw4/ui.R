library(shiny)
library(ggplot2)

shinyUI(fluidPage(
	headerPanel("Data Sciense HW4"),
	sidebarLayout(
	sidebarPanel(
     	uiOutput("methods"),
  		uiOutput("target")
    ),
	mainPanel(
		plotOutput("plot", width = "100%")
    )
  )
))