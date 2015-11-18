#ui.R 

library(shiny)

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(

# Application title
headerPanel("Hello Shiny!"),

# Sidebar with a slider input for number of observations
  sidebarPanel(
    sliderInput("KPI1", 
                "KPI_Low_Max_value:", 
                min = 0,
                max = 0.05, 
                value = 0.05),
    sliderInput("KPI2", 
                "KPI_Medium_Max_value:", 
                min = 0.05,
                max = 0.14, 
                value = 0.14),
    sliderInput("LowerLimit", 
                "Lower_Limit", 
                min = 0,
                max = 0.9917225, 
                value = 0.9917225),
    
    sliderInput("UpperLimit", 
                "Upper_Limit", 
                min = 0.9917225,
                max = 1.04, 
                value = 0.9961)
    
  ),

# Show a plot of the generated distribution
  mainPanel(
    plotOutput("distPlot")
    #plotOutput("distTable")
  )
))
