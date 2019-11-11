library(shiny)

# https://shiny.rstudio.com/reference/shiny/latest/req.html
# Reactivity - Shiny has this built in and most apps and users lean
# on it as is. Shiny has many controls for managing as seen in the
# next app.

## Only run examples in interactive R sessions
if (interactive()) {
  ui <- fluidPage(
    
    # App title ----
    titlePanel("Explore datasets package"),
    
    sidebarLayout(
    
    sidebarPanel(
      
    textInput('data', 'Enter a dataset from the "datasets" package', 'cars'),
    p('(E.g. "cars", "mtcars", "pressure", "faithful")'), hr(),
    # Output: Verbatim text for data summary ----
    verbatimTextOutput("summary")
    
    ),
    
    mainPanel(
    
    fluidRow(
      DT::dataTableOutput("table")
    )
  )
 )
)
  
  server <- function(input, output) {
    output$table <- DT::renderDataTable(DT::datatable({
      req(exists(input$data, "package:datasets", inherits = FALSE),
          cancelOutput = TRUE)
      data <- get(input$data, "package:datasets", inherits = FALSE)
      data
    }))
    
    # Generate a summary of the dataset ----
    # The output$summary depends on the datasetInput reactive
    # expression, so will be re-executed whenever datasetInput is
    # invalidated, i.e. whenever the input$dataset changes
    output$summary <- renderPrint({
      data <- get(input$data, "package:datasets", inherits = FALSE)
      summary(data)
    })
  }
  
  shinyApp(ui, server)
}