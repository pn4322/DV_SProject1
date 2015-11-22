#ui.R 

library(shiny)

navbarPage(
  title = "Elements of Visualization",
  tabPanel(title = "Crosstab",
           sidebarPanel(
             actionButton(inputId = "light", label = "Light"),
             actionButton(inputId = "dark", label = "Dark"),
             sliderInput("KPI1", "KPI_Low_Max_value:", 
                         min = 0, max = 0.05,  value = 0.05),
             sliderInput("KPI2", "KPI_Medium_Max_value:", 
                         min = 0.05, max = 0.14,  value = 0.14),
             textInput(inputId = "title", 
                       label = "Crosstab Title",
                       value = "Wine Crosstab\nSUM_CITRIC_ACID, SUM_RESIDUAL_SUGAR, SUM_CITRIC_ACID / SUM_RESIDUAL_SUGAR"),
             actionButton(inputId = "clicks1",  label = "Click me")
           ),
           
           mainPanel(plotOutput("distPlot1")
           )
  ),
  tabPanel(title = "Barchart",
           sidebarPanel(
             actionButton(inputId = "clicks2",  label = "Click me")
           ),
           
           mainPanel(plotOutput("distPlot2")
           )
  ),
  tabPanel(title = "Scatterplot",
           sidebarPanel(
             actionButton(inputId = "clicks3",  label = "Click me")
           ),
           
           mainPanel(plotOutput("distPlot3")
           )        
  )
)