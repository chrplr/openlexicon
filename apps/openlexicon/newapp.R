# shiny R code for lexique.org
# Time-stamp: <2019-11-23 12:25:24 christophe@pallier.org>

library(shiny)
library(DT)
library(writexl)

# loads datasets

source('https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/fetch_datasets.R')



datasets <- list()

datasets[['Lexique']] = c('http://www.lexique.org/databases/_json/Lexique383.json', 
                          'Lexique383.rds')

datasets[['Megalex-visual']] = c('http://www.lexique.org/databases/_json/Megalex-visual.json',
                                 'Megalex-visual.rds')

datasets[['Megalex-auditory']] = c('http://www.lexique.org/databases/_json/Megalex-auditory.json',
                                   'Megalex-auditory.rds')

datasets[['Aoa32lang']] = c('http://www.lexique.org/databases/_json/AoA-32lang.json',
                            'AoA32lang.rds')

datasets[['SUBTLEX-US']] = c('http://www.lexique.org/databases/_json/SUBTLEX-US.json',
                            'SUBTLEXus.rds')

datasets[['anagrammes']] = c('http://www.lexique.org/databases/_json/anagrammes.json',
                             'Anagrammes.rds')

datasets[['Voisins']] =  c('http://www.lexique.org/databases/_json/Voisins.json',
                           'Voisins.rds')


# TODO:

# datasets[['FrenchLexiconProject-words']] =

# datasets[['WorldLex-French']] =

# datasets[['WorldLex-English']] =


# Note: we should find a better way to identify the language, it should be a tag in the info listed in the json
french_datasets <- c('Megalex-visual', 'Megalex-auditory', 'Lexique383', 'FrenchLexiconProject-words', 'WorldLex-French')
english_datasets <- c('SUBTLEX-US', 'WorldLex-English')
others <- c('Voisins','anagrammes')


join_column = "Word"

dsnames <- list()
dsdesc <- list()
dsreadme <- list()
dstable <- list()
dsweb <- list()

for (ds in names(datasets))
{
  json_url = datasets[[ds]][1]
  rds_file = datasets[[ds]][2]
  print(json_url)
  info = get_info_from_json(json_url)

  dsnames[[ds]] = ds
  dsdesc[[ds]] <- info$description
  dsreadme[[ds]] <- info$readme
  dsweb[[ds]] <- info$website
  dstable[[ds]] <- readRDS(get_dataset_from_json(json_url, rds_file))
  colnames(dstable[[ds]])[1] <- join_column
}


button_several_datasets = "Two datasets"
button_one_dataset = "One dataset"
select_first_dataset_text = "Choose a first dataset"
select_dataset_text = "Choose a dataset"

dataset_info <-
  tags$div(class="alert-info",
     #tags$h3(dsnames[[1]]),
     tags$p(dsdesc[[1]]),
     tags$p(tags$a(href=dsreadme[[1]], "More info"))
  )

helper_alert <-
    tags$div(class="alert alert-info",
             tags$p("Quick how-to:"),
             tags$ul(
                      tags$li("Select desired dataset below"),
                      tags$li("If you want to get informations from several datasets, click on the ", tags$b(button_several_datasets), "button, and then select two datasets below."),
                      tags$li("For each column in the table, you can:"),
                      tags$ul(
                               tags$li("Filter using intervals (e.g. 40...500) or", tags$a(class="alert-link", href="http://regextutorials.com/index.html", "regexes", target="_blank"), "."),
                               tags$li("sort, ascending or descending")
                           ),
                      tags$li("Download the result of your manipulations by clicking on the button below the table")
                  )
             #tags$hr(),
             #tags$p(tags$a(href="https://chrplr.github.io/openlexicon/datasets-info/", "More information about the datatasets"))
             )


#### UI ####
ui <- fluidPage(
    titlePanel(tags$a(href="http://chrplr.github.io/openlexicon/", "OpenLexicon")),

    sidebarLayout(
        sidebarPanel(
            helper_alert,
            actionButton('join_button', label=button_several_datasets),
            br(),
            br(),
            uiOutput("outdataset"),
            uiOutput("outsecond_dataset"),
           width=4
        ),
            mainPanel(
                h3(textOutput("caption", container = span)),
                tags$div(class="alert-info",
                         tags$p(textOutput(outputId="currentdesc")),
                         tags$p(uiOutput("readmelink")),
                         tags$p(uiOutput("website"))),
                fluidRow(DTOutput(outputId="table")),
                uiOutput("outdownload")
            )
        )
    )

#### Server ####
server <- function(input, output, session) {
  v <- reactiveValues(button_label = button_several_datasets,
                      second_categories = c(),
                      first_choice = select_dataset_text,
                      first_dataset_selected = '\n')
  
  # To select a dataset
  output$outdataset <- renderUI({
    selectInput("dataset", v$first_choice,
                choices = c('\n',names(datasets)), selected = v$first_dataset_selected)
  })
  
  # To select a second dataset
  output$outsecond_dataset <- renderUI({
    if (!is.null(input$dataset) && input$dataset %in% names(datasets) && v$button_label == button_one_dataset) {
      selectInput("second_dataset", "Choose a second dataset:",
                  choices = c('\n',v$second_categories), selected = '\n')
    }
  })
  
  # Updating second dataset categories
  observeEvent(input$dataset, {
    v$first_dataset_selected <- input$dataset
    if (input$dataset %in% french_datasets) {
      v$second_categories <- french_datasets[french_datasets != input$dataset]
    }
    else if (input$dataset %in% english_datasets) {
      v$second_categories <- english_datasets[english_datasets != input$dataset]
    }
    else {
      v$second_categories <- c()
    }
  })
  
  # Handling merge button label
  observeEvent(input$join_button, {
    if (v$button_label == button_several_datasets){
      v$button_label <- button_one_dataset
      v$first_choice <- select_first_dataset_text
    }
    else{
      v$button_label <- button_several_datasets
      v$first_choice <- select_dataset_text
    }
    updateActionButton(session, "join_button", label = v$button_label)
  })
  
  # Changes table content according to the number of datasets
  datasetInput <- reactive({
    if (!is.null(input$dataset) && input$dataset %in% names(datasets))
    {
      if (!is.null(input$second_dataset) && input$second_dataset %in% names(datasets) && v$button_label == button_one_dataset)
      {
        merge(x=dstable[[input$dataset]], y=dstable[[input$second_dataset]], by=join_column)
      }
      else
      {
        dstable[[input$dataset]]
      }
    }
  })

  output$caption <- renderText({
    if (!is.null(input$dataset) && input$dataset %in% names(datasets))
    {
      input$dataset
    }
  })

  output$currentdesc <- renderText({
    if (!is.null(input$dataset) && input$dataset %in% names(datasets))
    {
      dsdesc[[input$dataset]]
    }
  })
  
  output$website <- renderUI({
    if (!is.null(input$dataset) && input$dataset %in% names(datasets))
    {
      url <- a("Website", href=dsweb[[input$dataset]], target="_blank")
    tagList("", url)
    }
  })
  
  output$readmelink <- renderUI({
    if (!is.null(input$dataset) && input$dataset %in% names(datasets))
    {
      url <- a("More info", href=dsreadme[[input$dataset]], target="_blank")
    tagList("", url)
    }
  })

  output$table <- renderDT(datasetInput(),
                           server=TRUE, escape = TRUE, selection = 'none',
                           filter=list(position = 'top', clear = FALSE),
                           rownames= FALSE,
                           options=list(pageLength=20,
                                        sDom  = '<"top">lrt<"bottom">ip',
                                        lengthMenu = c(20, 100, 500, 1000),
                                        search=list(searching = TRUE, regex=TRUE, caseInsensitive = FALSE)
                                        )
                          )  
  
  
  output$outdownload <- renderUI({
    if (!is.null(input$dataset) && input$dataset %in% names(datasets))
    {
      downloadButton('download', label="Download filtered data")
    }
  })
  
  output$download <- downloadHandler(
      filename = function() {
          paste("Lexique-query-", Sys.time(), ".xlsx", sep="")
      },
      content = function(fname){
          # write.csv(datasetInput(), fname)
          dt = datasetInput()[input[["table_rows_all"]], ]
          write_xlsx(dt, fname)
          })
  #url  <- a("Help!", href="http://www.lexique.org/?page_id=166")
  #output$help = renderUI({ tagList("", url) })
}

shinyApp(ui, server)
