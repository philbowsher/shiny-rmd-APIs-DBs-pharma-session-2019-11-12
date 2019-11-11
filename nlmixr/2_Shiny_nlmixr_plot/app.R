library(ggplot2)
library(Cairo)   # For nicer ggplot2 output when deployed on Linux

data <- read_csv("theo_sd.csv")

ui <- fluidPage(
    fluidRow(
        column(width = 6,
               plotOutput("plot1", height = 350,
                          click = "plot1_click",
                          brush = brushOpts(
                              id = "plot1_brush"
                          )
               ),
               actionButton("exclude_toggle", "Toggle points"),
               actionButton("exclude_reset", "Reset")
        )
    )
)

server <- function(input, output) {
    # For storing which rows have been excluded
    vals <- reactiveValues(
        keeprows = rep(TRUE, nrow(data))
    )
    
    output$plot1 <- renderPlot({
        # Plot the kept and excluded points as two separate data sets
        keep    <- data[ vals$keeprows, , drop = FALSE]
        exclude <- data[!vals$keeprows, , drop = FALSE]
        
        ggplot(keep, aes(TIME, DV, color = factor(ID))) + geom_point() + 
            stat_smooth(aes(color = NULL), size = 1.3) +
            geom_point(data = exclude, shape = 21, fill = NA, color = "black", alpha = 0.25) +
            coord_cartesian(xlim = c(0, 25), ylim = c(0,15))
    })
    
    # Toggle points that are clicked
    observeEvent(input$plot1_click, {
        res <- nearPoints(data, input$plot1_click, allRows = TRUE)
        
        vals$keeprows <- xor(vals$keeprows, res$selected_)
    })
    
    # Toggle points that are brushed, when button is clicked
    observeEvent(input$exclude_toggle, {
        res <- brushedPoints(data, input$plot1_brush, allRows = TRUE)
        
        vals$keeprows <- xor(vals$keeprows, res$selected_)
    })
    
    # Reset all points
    observeEvent(input$exclude_reset, {
        vals$keeprows <- rep(TRUE, nrow(data))
    })
    
}

shinyApp(ui, server)