# server.R
require("jsonlite")
require("RCurl")
require(ggplot2)
require(dplyr)
require(shiny)

shinyServer(function(input, output) {

  output$distPlot <- renderPlot({
  # Start your code here.

  # The following is equivalent to KPI Story 2 Sheet 2 and Parameters Story 3 in "Crosstabs, KPIs, Barchart.twb"
      
  KPI_Low_Max_value = input$KPI1     
  KPI_Medium_Max_value = input$KPI2
      
df <- data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="select PH, QUALITY, sum_CITRIC_ACID, round(sum_RESIDUAL_SUGAR) as sum_residual_sugar, kpi as ratio, 
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
                                                ')), httPHeader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_pn4322', PASS='orcl_pn4322', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=KPI_Low_Max_value, p2=KPI_Medium_Max_value), verbose = TRUE))); 
  
  
      
  plot <- ggplot() + 
    coord_cartesian() + 
    scale_x_discrete() +
    scale_y_discrete() +
    labs(title='Wine Crosstab\nSUM_CITRIC_ACID, SUM_RESIDUAL_SUGAR, SUM_CITRIC_ACID / SUM_RESIDUAL_SUGAR') +
    labs(x=paste("PH"), y=paste("QUALITY")) +
    layer(data=df, 
          mapping=aes(x=round(PH,1), y=QUALITY, label=round(SUM_CITRIC_ACID, 2)), 
          stat="identity", 
          stat_params=list(), 
          geom="text",
          geom_params=list(colour="black"), 
          position=position_identity()
    ) +
    layer(data=df, 
          mapping=aes(x=PH, y=QUALITY, label=SUM_RESIDUAL_SUGAR), 
          stat="identity", 
          stat_params=list(), 
          geom="text",
          geom_params=list(colour="black", vjust=2), 
          position=position_identity()
    ) +
    layer(data=df, 
          mapping=aes(x=PH, y=QUALITY, label=round(RATIO, 2)), 
          stat="identity", 
          stat_params=list(), 
          geom="text",
          geom_params=list(colour="black", vjust=4), 
          position=position_identity()
    ) +
    layer(data=df, 
          mapping=aes(x=PH, y=QUALITY, fill=KPI), 
          stat="identity", 
          stat_params=list(), 
          geom="tile",
          geom_params=list(alpha=0.5), 
          position=position_identity()
    )
# End your code here.
return(plot)
  }) # output$distPlot
  
 ##_________________ 

output$distPlot <- renderPlot({
  # Start your code here.
  
  # The following is equivalent to KPI Story 2 Sheet 2 and Parameters Story 3 in "Crosstabs, KPIs, Barchart.twb"
  
  Lower_Limit = input$LowerLimit     
  Upper_Limit = input$UpperLimit
  
  df <- data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="select * from DataSet"')), httPHeader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_pn4322', PASS='orcl_pn4322', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=KPI_Low_Max_value, p2=KPI_Medium_Max_value), verbose = TRUE))); 
  
  plot <- ggplot() + 
    coord_cartesian() + 
    scale_x_continuous() +
    scale_y_continuous() +
    labs(title='Wine Scatter Plot') +
    labs(x="ALCOHOL", y=paste("DENSITY")) +
    layer(data=df, 
          mapping=aes(x=ALCOHOL, y=DENSITY), 
          stat="identity", 
          stat_params=list(color="blue"), 
          geom="point",
          geom_params=list(color="blue"), 
          #position=position_identity()
          position=position_jitter(width=0.3, height=0)
    )
  
  
  
  # End your code here.
  return(plot)
}) # output$distPlot
})












