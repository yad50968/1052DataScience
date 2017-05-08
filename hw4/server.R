library(shiny)

channel_chr = list.files("./methods/")

ui <- fluidPage(
  headerPanel("Data Sciense HW4"),
  checkboxGroupInput("methods", label = "methods", 
                       choices = channel_chr),
  plotOutput("plot", click = "plot_click"),
  verbatimTextOutput("info")
 
)

server <- function(input, output) {
    
    output$plot <- renderPlot({
    	plot(c(1,2,4), c(1,2,4))
  	})
}

shinyApp(ui = ui, server = server, options = list(port = 5335))