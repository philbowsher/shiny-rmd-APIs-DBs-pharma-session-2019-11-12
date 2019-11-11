#Required libraries
library(shiny)
library(dplyr)
library(plotly)
library(EnvStats)
library(dbplyr)
library(DBI)


con <- dbConnect(RSQLite::SQLite(), "database.sqlite")
RSQLite::initExtension(con)

# Set WD
# con <- dbConnect(RSQLite::SQLite(), "database.sqlite")
# RSQLite::initExtension(con)
# table_names
# dbListTables(con)
# screen <- tbl(con,  "screening_01") 
# confirm <- tbl(con,  "confirmatory_01") 
# dbListFields(con, "confirmatory_01")
# DS <- screenconfirm <- left_join(screen, confirm) %>% mutate(Signal_Response_Difference = (as.numeric(Signal_Response_No_Drug) - as.numeric(Signal_Response_Drug))* 1.0) %>% mutate(Signal_Response_Divide = as.numeric(Signal_Response_Difference) / as.numeric(Signal_Response_No_Drug)) %>% mutate(Percent_Signal_Inhibition_Drug = as.numeric(Signal_Response_Divide) * 100) %>% collect()

shinyServer(function(input, output, session) {
  
  screeningDatanew <- reactive({
    tbl_selected <- input$table1
    if(tbl_selected == "{Select Table}"){
      NULL
    } else {
      tbl(con, tbl_selected) 
    }
  })
  
  confirmatoryDatanew <- reactive({
    tbl_selected <- input$table2
    if(tbl_selected == "{Select Table}"){
      NULL
    } else {
      tbl(con, tbl_selected) 
    }
  })
  
  titerDatanew <- reactive({
    tbl_selected <- input$table3
    if(tbl_selected == "{Select Table}"){
      NULL
    } else {
      tbl(con, tbl_selected) 
    }
  })
  
  # Next part, data wrangling via dplyr
  
  
  #Add Log10 screening to ALL screening data ___________________________________________
  screening_cp_np_log <- reactive ({
    
    if (is.null(screeningDatanew())) return(NULL)
    
    df <- screeningDatanew() %>% 
      mutate(Screening_Cutpoint = !! input$screening_cutpoint) %>% 
      mutate(Signal_Response_No_Drug_log10 = log10(Signal_Response_No_Drug)) %>%
      collect()
  })
  
  
  
  #Add CP and Pos Neg to screening and only keep screening ___________________________________________
  screening_cp_np <- reactive ({
    
    if (is.null(screeningDatanew())) return(NULL)
    
    df <- screeningDatanew() %>% 
      mutate(Screening_Cutpoint = !! input$screening_cutpoint) %>%
      mutate(Screening_Result_Drug = ifelse(Signal_Response_No_Drug > Screening_Cutpoint, "Positive", "Negative")) %>% 
      filter(Screening_Result_Drug == "Positive") %>% 
      mutate(Signal_Response_No_Drug_log10 = log10(Signal_Response_No_Drug)) %>%
      head(1000) %>%
      collect()
  })
  
  
  #Add confirmatory data to pos screening and calc Percent_Signal_Inhibition_Drug and find NP ____________________
  confirmatory_cp_np <- reactive ({
    
    if (is.null(confirmatoryDatanew())) return(NULL)
    if (is.null(screeningDatanew())) return(NULL)
    
    screeningDatanew() %>% 
      mutate(Screening_Cutpoint = !! input$screening_cutpoint) %>%
      mutate(Screening_Result_Drug = ifelse(Signal_Response_No_Drug > Screening_Cutpoint, "Positive", "Negative")) %>% 
      filter(Screening_Result_Drug == "Positive") %>% 
      mutate(Signal_Response_No_Drug_log10 = log10(Signal_Response_No_Drug)) %>% 
      left_join(confirmatoryDatanew(), by = "Sample_Number") %>%
      mutate(Signal_Response_Difference = (as.numeric(Signal_Response_No_Drug) - as.numeric(Signal_Response_Drug))* 1.0)  %>%
      mutate(Signal_Response_Divide = as.numeric(Signal_Response_Difference) / as.numeric(Signal_Response_No_Drug)) %>%
      mutate(Percent_Signal_Inhibition_Drug = as.numeric(Signal_Response_Divide) * 100) %>% 
      mutate(Confirmatory_Cutpoint = !! input$confirmatory_cutpoint) %>%
      mutate(Confirmatory_Result_Drug = ifelse(Percent_Signal_Inhibition_Drug > Confirmatory_Cutpoint, "Positive", "Negative")) %>% 
      select(-Signal_Response_Difference, -Signal_Response_Divide) %>%
      collect()
  })
  
  
  #Add titer to screening and confiratory data for reporting with P _________________________________
  titer_confirmatory <- reactive ({
    
    if (is.null(titerDatanew()))
      return(NULL)
    
    screeningDatanew() %>% 
      mutate(Screening_Cutpoint = !! input$screening_cutpoint) %>%
      mutate(Screening_Result_Drug = ifelse(Signal_Response_No_Drug > Screening_Cutpoint, "Positive", "Negative")) %>% 
      filter(Screening_Result_Drug == "Positive") %>% 
      mutate(Signal_Response_No_Drug_log10 = log10(Signal_Response_No_Drug)) %>% 
      left_join(confirmatoryDatanew(), by = "Sample_Number") %>%
      mutate(Signal_Response_Difference = (as.numeric(Signal_Response_No_Drug) - as.numeric(Signal_Response_Drug))* 1.0) %>%
      mutate(Signal_Response_Divide = as.numeric(Signal_Response_Difference) / as.numeric(Signal_Response_No_Drug)) %>%
      mutate(Percent_Signal_Inhibition_Drug = as.numeric(Signal_Response_Divide) * 100) %>% 
      mutate(Confirmatory_Cutpoint = !! input$confirmatory_cutpoint) %>%
      mutate(Confirmatory_Result_Drug = ifelse(Percent_Signal_Inhibition_Drug > Confirmatory_Cutpoint, "Positive", "Negative")) %>% 
      select(-Signal_Response_Difference, -Signal_Response_Divide) %>%
      left_join(titerDatanew(), by = "Sample_Number") %>%
      collect()
    
  })
  
  
  #True Positives from confirmatory tier _____________________
  true_positives <- reactive ({
    
    if (is.null(titerDatanew())) return(NULL)
    
    titer_confirmatory() %>% 
      filter(Confirmatory_Result_Drug == "Positive") %>%
      collect()
  })
  
  
  #File Download Button for true positives __________________
  output$downloadData1 <- downloadHandler(
    
    filename = function() {file = paste('true_positives','-',Sys.Date(),'.csv', sep = '')},
    content = function(file) {
      write.csv(true_positives(), file, row.names = FALSE)
    })
  
  
  # Show the screening data which are only pos if cutpoint is > then 0 ______________________
  output$screening <- DT::renderDataTable({
    DT::datatable(screening_cp_np(),
                  options = list(pageLength = 10, searching = FALSE),
                  rownames = FALSE)
  })
  
  
  # Show the confirmatory data - will be neg and pos from confirm ________________
  output$confirmatory <- DT::renderDataTable({
    DT::datatable(confirmatory_cp_np(),
                  options = list(scrollX = TRUE, pageLength = 10, searching = FALSE),
                  rownames = FALSE)
  })
  
  
  # Show the titer data - will be neg and pos from confirm ____________________
  output$titer <- DT::renderDataTable({
    DT::datatable(titer_confirmatory(),
                  options = list(scrollX = TRUE, pageLength = 10, searching = FALSE),
                  rownames = FALSE)
  })
  
  
  # Show only the true pos from confirm ____________________________
  output$truepositives <- DT::renderDataTable({
    DT::datatable(true_positives(),
                  options = list(scrollX = TRUE, pageLength = 10, searching = FALSE),
                  rownames = FALSE)
  })
  
  
  #Output plot neg pos of confirm with titer _________________________
  output$plot <- renderPlotly({
    
    if (is.null(titerDatanew())) return(NULL)
    
    p <- qplot(
      Signal_Response_No_Drug, 
      Percent_Signal_Inhibition_Drug, 
      data=true_positives(), 
      colour=Screening_Result_Drug)
    
    ggplotly(p)
    
  })
  
  
  #Output plot pos of screening and only show if tier 3 titer is loaded _________________________
  output$plot2 <- renderPlotly({
    
    if (is.null(titerDatanew())) return(NULL)
    
    p <- screening_cp_np() %>%
      select(Signal_Response_No_Drug) %>%
      collect() %>%
      ggplot(aes(x=Signal_Response_No_Drug)) + 
      geom_histogram(aes(y = ..density..)) + 
      geom_density(fill="red", alpha = 0.2) 
    
    ggplotly(p)
  })
  
  
  #Show plotly hover _________________________
  output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) "Hover on a point!" else d
  })
  
  
  
  
  #Output plot pos and neg of screening and show dist of log 10 screening _________________________
  output$plot3 <- renderPlotly({
    
    if (is.null(screening_cp_np_log()))
      return(NULL)
    
    p3 = ggplot(screening_cp_np_log(), aes(x=screening_cp_np_log()$Signal_Response_No_Drug_log10)) +
      geom_histogram(aes(y = ..density..), binwidth=density(screening_cp_np_log()$Signal_Response_No_Drug_log10)$bw) +
      geom_density(fill="red", alpha = 0.2)
    
    p3 = ggplotly(p3)
    
    p3
    
  })
  
  #Show table of samples above percentile for all samples screening _________________________
  output$results <- renderPrint({
    
    if (is.null(screeningDatanew()))
      return(NULL)
    
    # Gets the IDs of the qualifying samples
    samples <- screeningDatanew() %>%
      select(Signal_Response_No_Drug, Sample_Number) %>%
      collect() %>% 
      filter(Signal_Response_No_Drug >= quantile(Signal_Response_No_Drug, !! input$stDev)) %>%
      pull(Sample_Number)
    
    # Uses the vector of the IDs to run another SQL statement
    screeningDatanew() %>%
      filter(Sample_Number %in% samples) %>%
      collect()
    
    
    
  })
  
  #Summary stats on all screening samples _________________________
  output$table <- renderPrint({
    screeningDatanew() %>%
      pull(Signal_Response_No_Drug) %>%
      summaryFull()
  })
  
})
