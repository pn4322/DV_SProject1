# server.R
require("jsonlite")
require("RCurl")
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(leaflet)
require(DT)

shinyServer(function(input, output) {
        
      KPI_Low_Max_value <- reactive({input$KPI1})     
      KPI_Medium_Max_value <- reactive({input$KPI2})
      rv <- reactiveValues(alpha = 0.50)
      observeEvent(input$light, { rv$alpha <- 0.50 })
      observeEvent(input$dark, { rv$alpha <- 0.75 })
    
      df1 <- eventReactive(input$clicks1, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query=
            "select PH, QUALITY, sum_CITRIC_ACID, round(sum_RESIDUAL_SUGAR) as sum_residual_sugar, kpi as ratio, 
case
when kpi < "p1" then \\\'03 Low\\\'
when kpi < "p2" then \\\'02 Medium\\\'
else \\\'01 High\\\'
end kpi
from (select PH, QUALITY, 
  sum(CITRIC_ACID) as sum_CITRIC_ACID, sum(RESIDUAL_SUGAR) as sum_RESIDUAL_SUGAR, 
  sum(CITRIC_ACID) / sum(RESIDUAL_SUGAR) as kpi
  from dataset
  group by PH, QUALITY)
  order by QUALITY;"
            ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_pn4322', PASS='orcl_pn4322', 
                 MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=KPI_Low_Max_value(), p2=KPI_Medium_Max_value()), verbose = TRUE)))
      })

      output$distPlot1 <- renderPlot(height=1000, width=2000,{             
            plot <- ggplot() + 
                  coord_cartesian() + 
                  scale_x_discrete() +
                  scale_y_discrete() +
                  labs(title=isolate(input$title)) +
                  labs(x=paste("PH"), y=paste("QUALITY")) +
                  layer(data=df1(), 
                        mapping=aes(x=PH, y=QUALITY, label=round(SUM_CITRIC_ACID,2)), 
                        stat="identity", 
                        stat_params=list(), 
                        geom="text",
                        geom_params=list(colour="black"), 
                        position=position_identity()
                  ) +
              layer(data=df1(), 
                    mapping=aes(x=PH, y=QUALITY, label=SUM_RESIDUAL_SUGAR), 
                    stat="identity", 
                    stat_params=list(), 
                    geom="text",
                    geom_params=list(colour="black", vjust=2), 
                    position=position_identity()
              ) +
              layer(data=df1(), 
                    mapping=aes(x=PH, y=QUALITY, label=round(RATIO, 2)), 
                    stat="identity", 
                    stat_params=list(), 
                    geom="text",
                    geom_params=list(colour="black", vjust=4), 
                    position=position_identity()
              ) +
                  layer(data=df1(), 
                        mapping=aes(x=PH, y=QUALITY, fill=KPI), 
                        stat="identity", 
                        stat_params=list(), 
                        geom="tile",
                        geom_params=list(alpha=rv$alpha), 
                        position=position_identity()
                  )
            plot
      }) 

      observeEvent(input$clicks, {
            print(as.numeric(input$clicks))
      })

# Begin code for Second Tab:

      df2 <- eventReactive(input$clicks2, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query=
            "select QUALITY, PH, AVG_ALCOHOL, avg(AVG_ALCOHOL) 
                                                                                     OVER (PARTITION BY PH ) as window_AVG_ALCOHOL
                                                                                     from (select QUALITY, PH, avg(Alcohol) AVG_ALCOHOL
                                                                                     from dataset
                                                                                     group by QUALITY, PH)
                                                                                     order by PH;"
            ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_pn4322', PASS='orcl_pn4322', 
            MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
      })

      output$distPlot2 <- renderPlot(height=1000, width=2000, {
            plot1 <- ggplot() + 
              coord_cartesian() + 
              scale_x_discrete() +
              scale_y_continuous() +
              facet_wrap(~PH, ncol=1) +
              labs(title='Wine Barchart\nAVERAGE_Alcohol, WINDOW_AVG_ALCOHOL, ') +
              labs(x=paste("QUALITY"), y=paste("AVG_ALCOHOL")) +
              layer(data=df2(), 
                    mapping=aes(x=QUALITY, y=AVG_ALCOHOL), 
                    stat="identity", 
                    stat_params=list(), 
                    geom="bar",
                    geom_params=list(colour="blue"), 
                    position=position_identity()
              ) + coord_flip() +
              layer(data=df2(), 
                    mapping=aes(x=QUALITY, y=AVG_ALCOHOL, label=round(AVG_ALCOHOL - WINDOW_AVG_ALCOHOL)), 
                    stat="identity", 
                    stat_params=list(), 
                    geom="text",
                    geom_params=list(colour="black", hjust=-5), 
                    position=position_identity()
              ) +
              layer(data=df2(), 
                    mapping=aes(x=QUALITY, y=AVG_ALCOHOL, label=round(AVG_ALCOHOL)), 
                    stat="identity", 
                    stat_params=list(), 
                    geom="text",
                    geom_params=list(colour="black", hjust=-0.5), 
                    position=position_identity()
              ) +
              layer(data=df2(), 
                    mapping=aes(x=QUALITY, y=AVG_ALCOHOL, label=round(WINDOW_AVG_ALCOHOL)), 
                    stat="identity", 
                    stat_params=list(), 
                    geom="text",
                    geom_params=list(colour="black", hjust=-2), 
                    position=position_identity()
              ) +
              layer(data=df2(), 
                    mapping=aes(yintercept = WINDOW_AVG_ALCOHOL), 
                    geom="hline",
                    geom_params=list(colour="red")
              )
              plot1
      })

# Begin code for Third Tab:

      df3 <- eventReactive(input$clicks3, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="select * from DataSet"')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_pn4322', PASS='orcl_pn4322', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
      })

      output$distPlot3 <- renderPlot({
            plot3 <- ggplot() + 
              coord_cartesian() + 
              scale_x_continuous() +
              scale_y_continuous() +
              labs(title='Wine Scatter Plot') +
              labs(x="ALCOHOL", y=paste("DENSITY")) +
              layer(data=df3(), 
                    mapping=aes(x=ALCOHOL, y=DENSITY), 
                    stat="identity", 
                    stat_params=list(color="blue"), 
                    geom="point",
                    geom_params=list(color="blue"), 
                    #position=position_identity()
                    position=position_jitter(width=0.3, height=0)
              )
              plot3
      })

# Begin code for Fourth Tab:
      output$map <- renderLeaflet({leaflet() %>% addTiles() %>% setView(-93.65, 42.0285, zoom = 17) %>% addPopups(-93.65, 42.0285, 'Here is the Department of Statistics, ISU')
      })

# Begin code for Fifth Tab:
      output$table <- renderDataTable({datatable(df1())
      })
})
