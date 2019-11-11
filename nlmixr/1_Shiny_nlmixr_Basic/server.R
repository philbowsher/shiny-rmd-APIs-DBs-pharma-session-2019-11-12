library(readr)

function(input, output) {
  
  # Filter data based on selections
  output$table <- DT::renderDataTable({
    DT::datatable({
    data <- read_csv("theo_sd.csv")
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