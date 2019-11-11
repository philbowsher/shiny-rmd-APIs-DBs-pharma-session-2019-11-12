library(DT)
library(readr)

theo_sd <- read_csv("theo_sd.csv")

fluidPage(
  titlePanel("Basic DataTable for Theophiline"),
  
  
  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
           selectInput("CMT",
                       "Compartment Number:",
                       c("All",
                         unique(as.character(theo_sd$CMT))))
    )
    )
  ,
  # Create a new row for the table.
  fluidRow(
    DT::dataTableOutput("table")
  )
)