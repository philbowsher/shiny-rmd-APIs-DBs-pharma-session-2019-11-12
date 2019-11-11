library(shiny)

n <- 200

ui <- bootstrapPage(
  numericInput('n', 'Number of obs', n),
  plotOutput('plot')
)

server <- function(input, output){
  output$plot <- renderPlot({
    hist(rnorm(input$n))
    
  })
  

}

shinyApp(ui = ui, server = server)
