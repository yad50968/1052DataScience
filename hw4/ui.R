library(shiny)
channel_chr = list("a","d")

shinyUI(fluidPage(
   checkboxGroupInput("channel", label = "Channel(s)", 
                       choices = channel_chr,
                       selected = as.character(channel_chr))
))