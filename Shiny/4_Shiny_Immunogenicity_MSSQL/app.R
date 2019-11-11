library(shinydashboard)
library(shiny)
library(dplyr)
library(dbplyr)
library(odbc)
library(DBI)
library(dbplot)
library(ggplot2)
library(waffle)
library(DT)

# load("samples.Rdata")

# Database connection ----------------------
con <- dbConnect(odbc(), 
                 "SQL Server (DSN)",
                 Database = "immunogenicity")

screening <- tbl(con, in_schema("study_01", "screening"))
confirmatory <- tbl(con, in_schema("study_01", "confirmatory"))
titer <- tbl(con, in_schema("study_01", "titer")) %>%
  select(- Site, - Subject)
subjects <- tbl(con, in_schema("study_01", "subjects"))

samples <- screening %>%
  left_join(confirmatory, by = "Sample_Number") %>%
  left_join(titer, by = "Sample_Number") %>%
  left_join(subjects, by = "Subject") %>%
  mutate_if(is.integer, as.numeric) %>%
  mutate(Signal_Response_Difference = Signal_Response_No_Drug - Signal_Response_Drug)  %>%
  mutate(Signal_Response_Divide = Signal_Response_Difference / Signal_Response_No_Drug)  %>%
  mutate(Percent_Signal_Inhibition_Drug = Signal_Response_Divide * 100)


# Data prep for Side Menu -------------------

# schemata <- odbc:::connection_sql_tables(con@ptr, "", "%", "", "")[["table_schema"]]
# schemata <- schemata[schemata != "INFORMATION_SCHEMA"]
# schemata <- schemata[schemata != "sys"]

schemata <- c("study_01")

blood <- samples %>%
  group_by(Blood_Type) %>%
  summarise() %>%
  pull()

ranges <- samples %>%
  summarise(
    max_weight = max(Weight, na.rm = TRUE),
    min_weight = min(Weight, na.rm = TRUE),
    max_sreening = max(Signal_Response_Drug, na.rm = TRUE),
    max_confirmatory = max(Signal_Response_No_Drug, na.rm = TRUE)
  ) %>%
  collect()

ui <- function(request) {
  dashboardPage(
    dashboardHeader(title = "Study Results"),
    dashboardSidebar(
      selectInput("schema", "Select schema:",
                  schemata,
                  selected = 1
      ),
      checkboxInput("tp_only", "True Positives Only"),
      selectInput("blood", "Blood Type:",
                  blood,
                  multiple = TRUE,
                  size = 5,
                  selected = blood,
                  selectize = FALSE
      ),
      sliderInput("min_weight",
                  "Minimum Weight:",
                  min = ranges$min_weight,
                  max = ranges$max_weight,
                  value = ranges$min_weight
      ),
      sliderInput("max_weight",
                  "Maximum Weight:",
                  min = ranges$min_weight,
                  max = ranges$max_weight,
                  value = ranges$max_weight
      ),
      sliderInput("screening_cutoff",
                  "Screening Cutoff:",
                  min = 0,
                  max = ranges$max_sreening,
                  value = 0
      ),
      sliderInput("confirmatory_cutoff",
                  "Confirmatory Cutoff:",
                  min = 0,
                  max = ranges$max_sreening,
                  value = 0
      ),
      bookmarkButton()
    ),
    dashboardBody(
      tabsetPanel(
        id = "tabs",
        tabPanel(
          title = "Study Results",
          value = "page1",
          fluidRow(
            valueBoxOutput("no_samples", width = 3),
            valueBoxOutput("true_positives", width = 3),
            valueBoxOutput("avg_weight", width = 3),
            valueBoxOutput("avg_percent", width = 3)
          ),
          fluidRow(
            box(
              plotOutput("hist_drug",
                         height = 250,
                         click = "plot_click",
                         dblclick = "plot_dblclick",
                         hover = "plot_hover",
                         brush = "plot_brush"
              ),
              title = "Signal Response Drug",
              width = 4, height = 320,
              background = "light-blue"
            ),
            box(
              plotOutput("hist_no_drug", height = 250),
              title = "Signal Response No Drug",
              width = 4, height = 320,
              background = "light-blue"
            ),
            box(
              plotOutput("hist_percent", height = 250),
              title = "Percent Signal Inhibition Drug",
              width = 4, height = 320,
              background = "teal"
            )
          ),
          fluidRow(
            box(
              plotOutput(
                "by_blood",
                height = 250,
                click = "blood_click"
              ),
              title = "Samples by Blood Type",
              width = 3, height = 320,
              background = "blue"
            ),
            box(
              plotOutput("hist_weight", height = 250),
              title = "Subject's Weight",
              width = 3, height = 320,
              background = "purple"
            ),
            box(
              plotOutput("tp_waffle", height = 250),
              title = "Cut off results",
              width = 6, height = 320,
              background = "green"
            )
          )
        ),
        tabPanel(
          title = "Details",
          value = "page2",
          fluidRow(
            box(
              title = "Detail - Top 10 Records",
              width = 12,
              dataTableOutput("details")
            )
          )
        )
      )
    )
  )
}

server <- function(input, output, session) {
  # Reactive master query prep ---------------------------
  sample_data <- reactive({
    df <- samples %>%
      filter(
        Blood_Type %in% !! input$blood,
        Weight >= !! input$min_weight,
        Weight <= !! input$max_weight
      ) %>%
      mutate(
        Response_Drug = ifelse(Signal_Response_Drug >= !! input$screening_cutoff, "Positive", "Negative"),
        Response_No_Drug = ifelse(Signal_Response_No_Drug >= !! input$confirmatory_cutoff, "Positive", "Negative")
      ) %>%
      mutate(
        True_Positive = ifelse(Response_Drug == Response_No_Drug, "Yes", "No")
      )
    if (input$tp_only == 1) df <- filter(df, True_Positive == "Yes")
    df
  })
  # Render - No of samples value box ----------------------
  output$no_samples <- renderValueBox({
    valueBox(
      sample_data() %>%
        tally() %>%
        pull(),
      "No. of samples",
      icon = icon("flask")
    )
  })
  
  # Render - True positives value box ---------------------
  output$true_positives <- renderValueBox({
    valueBox(
      sample_data() %>%
        filter(True_Positive == "Yes") %>%
        tally() %>%
        pull(),
      "True Positives",
      icon = icon("check"),
      color = "green"
    )
  })
  
  # Render - Avg Weight value box -------------------------
  output$avg_weight <- renderValueBox({
    valueBox(
      sample_data() %>%
        summarise(w = mean(Weight, na.rm = TRUE)) %>%
        pull() %>%
        round(., 0),
      "Avg. Weight",
      icon = icon("user"),
      color = "purple"
    )
  })
  
  # Render - Avg percent value box ------------------------
  output$avg_percent <- renderValueBox({
    valueBox(
      sample_data() %>%
        summarise(per = mean(Percent_Signal_Inhibition_Drug, na.rm = TRUE)) %>%
        pull() %>%
        round(., 2),
      "Avg. Signal Percent",
      icon = icon("percent"),
      color = "teal"
    )
  })
  # Render - Drug histogram -------------------------------
  output$hist_drug <- renderPlot({
    sample_data() %>%
      dbplot_histogram(Signal_Response_Drug) +
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        title = element_blank()
      )
  })
  # Render - No Drug histogram ----------------------------
  output$hist_no_drug <- renderPlot({
    sample_data() %>%
      dbplot_histogram(Signal_Response_No_Drug) +
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        title = element_blank()
      )
  })
  # Render - Percent histogram ----------------------------
  output$hist_percent <- renderPlot({
    sample_data() %>%
      dbplot_histogram(Percent_Signal_Inhibition_Drug) +
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        title = element_blank()
      )
  })
  # Render - Blood column plot ----------------------------
  output$by_blood <- renderPlot({
    sample_data() %>%
      db_compute_count(Blood_Type) %>%
      rename(count = `n()`) %>%
      ggplot() +
      geom_col(aes(Blood_Type, count, fill = count), alpha = 0.4) +
      geom_label(aes(Blood_Type, count, label = paste0(Blood_Type, " : ", count, " samples")), label.padding = unit(0.75, "lines"), hjust = 1) +
      coord_flip() +
      theme_minimal() +
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        title = element_blank(),
        axis.text = element_blank(),
        panel.grid = element_blank(),
        legend.position = "none"
      )
  })
  # Render - Weight histogram -----------------------------
  output$hist_weight <- renderPlot({
    sample_data() %>%
      dbplot_histogram(Weight) +
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        title = element_blank()
      )
  })
  # Render - True positives waffle plot -------------------
  output$tp_waffle <- renderPlot({
    tp <- sample_data() %>%
      group_by(True_Positive) %>%
      tally() %>%
      collect()
    parts <- c(
      "False Positive" = pull(filter(tp, True_Positive == "No")),
      "True Positive" = pull(filter(tp, True_Positive == "Yes"))
    )
    waffle_colors <- c("#969696", "#1879bf", "white")
    if (length(parts) == 1) waffle_colors <- "#1879bf"
    waffle(parts,
           rows = 5,
           colors = waffle_colors,
           legend_pos = "bottom"
    )
  })
  # Details table -----------------------------------------
  output$details <- renderDataTable(
    sample_data() %>%
      select(
        Sample_Number,
        Site,
        Subject,
        Signal_Response_Drug,
        Signal_Response_No_Drug,
        Blood_Type,
        Weight,
        Percent_Signal_Inhibition_Drug,
        True_Positive
      ) %>%
      head(10) %>%
      collect()
  )
  # Click-event blood -------------------------------------
  observeEvent(input$blood_click, {
    vals <- round(input$blood_click$y, 0)
    vals <- blood[vals]
    
    updateSelectInput(session, "blood",
                      selected = vals
    )
    
    updateTabsetPanel(session, "tabs", selected = "page2")
  })
}

shinyApp(ui, server, enableBookmarking = "url")
