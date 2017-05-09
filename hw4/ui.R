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
		tabsetPanel(type = "tabs", 
                  tabPanel("plot", plotOutput("plot")),
                  tabPanel("table", tableOutput("table"))
      )

    )
  )
))