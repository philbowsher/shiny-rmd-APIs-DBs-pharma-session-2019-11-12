library(tidyverse)
library(haven)
data <- read_sas("dmae.sas7bdat") %>% mutate(
    SEX = factor(SEX),
    AESEV =  factor(AESEV),
    RACE = factor(RACE)
)

# %>% mutate(SEX = factor(SEX), RACE = factor(RACE))

# %>% select(SEX, RACE, AESEV, AGE_mean, AGE_se, n_samples )

function(input, output) {
    
    dataset <- reactive({
        data[sample(nrow(data), input$sampleSize),]
    })
    
    
    output$plot <- renderPlot({
        
        p <- ggplot(dataset(), aes_string(x=input$x, y=input$y)) + geom_point()
        
        if (input$color != 'None')
            p <- p + aes_string(color=input$color)
        
        facets <- paste(input$facet_row, '~', input$facet_col)
        if (facets != '. ~ .')
            p <- p + facet_grid(facets)
        
        if (input$jitter)
            p <- p + geom_jitter()
        if (input$smooth)
            p <- p + geom_smooth()
        
        print(p)
        
    })
    
    # Filter data based on selections
    output$table <- DT::renderDataTable(DT::datatable({
        data <- data
        # data <- read_sas("ae.sas7bdat") %>%
        #   select(STUDYID, DOMAIN, AELLT, AEDECOD, AEHLGT, AESEV, AESER, AEACN, AEREL,  AEOUT,   AESDTH,  EPOCH,   AESTDTC, AEENDTC )
        if (input$AESEV != "All") {
            data <- data[data$AESEV == input$AESEV,]
        }
        data
    }))
    
}