library(shiny)

ui <- pageWithSidebar(
  headerPanel("Vitamin C effects on tooth growth of guinea pigs"),
  
  # Sidebar with select, sliders
  sidebarPanel(
    selectInput("supp", "Choose supplemental type:", 
                choices = c("Ascorbic acid" = "VC", "Orange juice" = "OJ")),
    sliderInput("dose", "Dose in milligrams:", 
                min = 0.5, max = 2, value = 1, step = 0.5)
  ),
  
  # Show a table summarizing the values entered
  mainPanel(
    plotOutput("myHist")
  )
)

# Define server logic to plot various variables against mpg ----
server <- function(input, output) {
    output$myHist <- renderPlot({
      newData = ToothGrowth [ToothGrowth$supp == input$supp|ToothGrowth$dose == input$dose,]
      hist(newData$len, xlab="Tooth length",main="Histogram")
      mu = mean (newData$len)
      lines(c(mu, mu), c(0, 200),col="red",lwd=5)
      text(63, 150, paste("mu = ", mu))
    })
  }

shinyApp(ui, server)