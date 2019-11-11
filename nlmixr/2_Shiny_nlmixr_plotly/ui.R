library(DT)
library(tidyverse)
library(plotly)

dataset <- read_csv("~/ACOP-2019-R-for-Drug-Development-Workshop/nlmixr/theo_sd.csv")  %>% mutate(
  ID = factor(ID),
  CMT =  factor(CMT)
)

navbarPage("Navbar!",
           tabPanel("Plot",
                    
                    fluidPage(
                      
                      title = "Theophiline Explorer",
                      
                      plotlyOutput('plot', height = 350),
                      
                      hr(),
                      
    fluidRow(
    column(3,
           h4("Theophiline Explorer"),
           sliderInput('sampleSize', 'Sample Size', 
                       min=1, max=nrow(dataset),
                       value=min(144, nrow(dataset)), 
                       step=6, round=0),
           br(),
           checkboxInput('jitter', 'Jitter'),
           checkboxInput('smooth', 'Smooth')
    ),
    column(4, offset = 1,
           selectInput('x', 'X', names(dataset)),
           selectInput('y', 'Y', names(dataset), names(dataset)[[2]]),
           selectInput('color', 'Color', c('None', names(dataset)))
    ),
    column(4,
           selectInput('facet_row', 'Facet Row',
                       c(None='.', names(dataset[sapply(dataset, is.factor)]))),
           selectInput('facet_col', 'Facet Column',
                       c(None='.', names(dataset[sapply(dataset, is.factor)])))
    )
  )
)
),

tabPanel("Data",
         fluidPage(
           titlePanel("Basic DataTable for Theophiline"),
           
           
           # Create a new Row in the UI for selectInputs
           fluidRow(
             column(4,
                    selectInput("CMT",
                                "Compartment Number:",
                                c("All",
                                  unique(as.character(dataset$CMT))))
             )
           )
           ,
           # Create a new row for the table.
           fluidRow(
             DT::dataTableOutput("table")
           )
         )
)
)