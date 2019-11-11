library(ggplot2)
library(datasets)

dataset <- ToothGrowth

navbarPage("Navbar!",
           tabPanel("Plot",
           fluidPage(
             
             fluidRow(
               column(width = 6,class = "well",
                      plotOutput("plot1", height = 350,
                                 click = "plot1_click",
                                 brush = brushOpts(
                                   id = "plot1_brush"
                                 )
                      ),
                      actionButton("exclude_toggle", "Toggle points"),
                      actionButton("exclude_reset", "Reset")),
               
               column(width = 6, class = "well",
                      plotOutput('plot', height = 350),
                      
                      hr(),
                      
                      fluidRow(
                        column(3,
                               h4("ToothGrowth Explorer"),
                               sliderInput('sampleSize', 'Sample Size', 
                                           min=30, max=nrow(dataset),
                                           value=min(60, nrow(dataset)), 
                                           step=10, round=0),
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
                                           c(None='.', names(ToothGrowth[sapply(ToothGrowth, is.factor)]))),
                               selectInput('facet_col', 'Facet Column',
                                           c(None='.', names(ToothGrowth[sapply(ToothGrowth, is.factor)])))
                        )
                      )
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
                               selectInput("supp",
                                           "Supplement:",
                                           c("All",
                                             unique(as.character(ToothGrowth$supp))))
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








