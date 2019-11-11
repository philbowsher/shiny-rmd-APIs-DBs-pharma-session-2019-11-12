library(shiny)
library(crosstalk)
library(d3scatter)

ui <- fluidPage(
  fluidRow(
    column(6, d3scatterOutput("scatter1")),
    column(6, d3scatterOutput("scatter2"))
  )
)

server <- function(input, output, session) {
  shared_ToothGrowth <- SharedData$new(ToothGrowth)
  
  output$scatter1 <- renderD3scatter({
    d3scatter(shared_ToothGrowth, ~len, ~dose, ~dose, width = "100%")
  })
  
  output$scatter2 <- renderD3scatter({
    d3scatter(shared_ToothGrowth, ~dose, ~len, ~dose, width = "100%")
  })
}

shinyApp(ui, server)