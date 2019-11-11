library(shiny)
library(tidyverse)
library(haven)
dataset <- read_sas("dmae.sas7bdat") %>% mutate(
    SEX = factor(SEX),
    AESEV =  factor(AESEV),
    RACE = factor(RACE)
)

navbarPage("Navbar!",
           tabPanel("Plot",
fluidPage(
    
    title = "AE Explorer",
    
    plotOutput('plot'),
    
    hr(),
    
    fluidRow(
        column(3,
               h4("AE Explorer"),
               sliderInput('sampleSize', 'Sample Size', 
                           min=1, max=nrow(dataset),
                           value=min(1000, nrow(dataset)), 
                           step=500, round=0),
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
             titlePanel("Basic DataTable for ToothGrowth"),
             
             # Create a new Row in the UI for selectInputs
             fluidRow(
                 column(4,
                        selectInput("AESEV",
                                    "Severity:",
                                    c("All",
                                      unique(as.character(dataset$AESEV))))
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