library(datasets)
library(DT)
library(haven)
library(dplyr)
data <- read_sas("ae.sas7bdat") %>%
  select(STUDYID, DOMAIN, AELLT, AEDECOD, AEHLGT, AESEV, AESER, AEACN, AEREL,  AEOUT,   AESDTH,  EPOCH,   AESTDTC, AEENDTC )

fluidPage(
  titlePanel("Basic DataTable for ToothGrowth"),
  
  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
           selectInput("AESEV",
                       "Severity:",
                       c("All",
                         unique(as.character(data$AESEV))))
    )
  )
  ,
  # Create a new row for the table.
  fluidRow(
    DT::dataTableOutput("table")
  )
)