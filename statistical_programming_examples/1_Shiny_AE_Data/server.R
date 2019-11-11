library(datasets)
library(haven)

function(input, output) {
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- read_sas("ae.sas7bdat") %>%
    select(STUDYID, DOMAIN, AELLT, AEDECOD, AEHLGT, AESEV, AESER, AEACN, AEREL,  AEOUT,   AESDTH,  EPOCH,   AESTDTC, AEENDTC )
    if (input$AESEV != "All") {
      data <- data[data$AESEV == input$AESEV,]
    }
    data
  }))
  
}