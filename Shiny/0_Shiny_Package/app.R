library(shiny)
library(ggplot2)

# http://shiny.rstudio.com/gallery/reactivity.html
# Reactivity - Notice how the 2 table operate independently
# of each other

d <- data(package = "ggplot2")
c <- d$results[, "Item"]

ui <- fluidPage(
    
    # App title ----
    titlePanel("Explore datasets in a package"),
    
    sidebarLayout(
      
      sidebarPanel(
        
        # Input: Selector for choosing dataset ----
        selectInput(inputId = "dataset",
                    label = "Choose a dataset:",
                    choices = unique(c), selectize = FALSE),
        
        numericInput(inputId = "obs",
                     label = "Number of observations to view:",
                     value = 10)
        
      ),
      
      # Main panel for displaying outputs ----
      mainPanel(
        
        # Output: Formatted text for caption ----
        h3(textOutput("caption", container = span)),
        
        # Output: Verbatim text for data summary ----
        verbatimTextOutput("summary"),
        
        # Output: HTML table with requested number of observations ----
        tableOutput("view")
        
      )
    )
  )
  
  server <- function(input, output) {
  
      
      # Return the requested dataset ----
      # By declaring datasetInput as a reactive expression we ensure
      # that:
      #
      # 1. It is only called when the inputs it depends on changes
      # 2. The computation and result are shared by all the callers,
      #    i.e. it only executes a single time
      datasetInput <- reactive({
        get(input$dataset)
       })
      
      # Create caption ----
      # The output$caption is computed based on a reactive expression
      # that returns input$caption. When the user changes the
      # "caption" field:
      #
      # 1. This function is automatically called to recompute the output
      # 2. New caption is pushed back to the browser for re-display
      #
      # Note that because the data-oriented reactive expressions
      # below don't depend on input$caption, those expressions are
      # NOT called when input$caption changes
      output$caption <- renderText({
        input$caption
      })
      
      # Generate a summary of the dataset ----
      # The output$summary depends on the datasetInput reactive
      # expression, so will be re-executed whenever datasetInput is
      # invalidated, i.e. whenever the input$dataset changes
      output$summary <- renderPrint({
        dataset <- datasetInput()
        summary(dataset)
      })
      
      # Show the first "n" observations ----
      # The output$view depends on both the databaseInput reactive
      # expression and input$obs, so it will be re-executed whenever
      # input$dataset or input$obs is changed
      output$view <- renderTable({
        head(datasetInput(), n = input$obs)
      })
      
    }
    
    # Create Shiny app ----
    shinyApp(ui, server)