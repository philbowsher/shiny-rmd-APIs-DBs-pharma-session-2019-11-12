library(tidyverse)
library(plotly)

data <- read_csv("~/ACOP-2019-R-for-Drug-Development-Workshop/nlmixr/theo_sd.csv")  %>% mutate(
  ID = factor(ID),
  CMT =  factor(CMT)
)

function(input, output) {
  
  dataset <- reactive({
    data[sample(nrow(data), input$sampleSize),]
  })
  
  output$plot <- renderPlotly({
    
    p <- ggplot(dataset(), aes_string(x=input$x, y=input$y)) + geom_point()
    
    if (input$color != 'None')
      p <- p + aes_string(color=input$color)
    
    facets <- paste(input$facet_row, '~', input$facet_col)
    if (facets != '. ~ .')
      p <- p + facet_grid(facets)
    
    if (input$jitter)
      p <- p + geom_jitter()
    if (input$smooth)
      p <- p + geom_smooth()
    
    ggplotly(p)
    
  })
  
  
  # Filter data based on selections
  output$table <- DT::renderDataTable({
    DT::datatable({
      # data <- read_csv("~/PAGE-2019-Intro-R-4-Drug-Development-Workshop/nlmixr/theo_sd.csv")
      if (input$CMT != "All") {
        data <- data[data$CMT == input$CMT,]
      }
      
      data
      
    },
    
    filter = list(position = 'top', clear = FALSE),
    options = list(pageLength = 15), 
    rownames = FALSE)
  })
  
}