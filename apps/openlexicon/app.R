# shiny R code for lexique.org
# Time-stamp: <2019-06-04 21:51:05 christophe@pallier.org>
# Afficher info deuxième database en haut

library(shiny)
library(shinyBS)
library(DT)
library(writexl)
library(plyr)
library(data.table)
library(rlist)
library(stringr)

#### Functions ####
usePackage <- function(i){
  if(! i %in% installed.packages()){
    install.packages(i, dependencies = TRUE)
  }
  require(i, character.only = TRUE)
}
usePackage("shinyWidgets")

extendedCheckboxGroup <- function(..., extensions = list()) {
  cbg <- checkboxGroupInput(...)
  nExtensions <- length(extensions)
  nChoices <- length(cbg$children[[2]]$children[[1]])
  
  if (nExtensions > 0 && nChoices > 0) {
    lapply(1:min(nExtensions, nChoices), function(i) {
      # For each Extension, add the element as a child (to one of the checkboxes)
      cbg$children[[2]]$children[[1]][[i]]$children[[2]] <<- extensions[[i]]
    })
  }
  cbg
}

get_mandatory_columns <- function(dataset_name) {
  if (!is.null(dsmandcol[[dataset_name]])) {
    return(dsmandcol[[dataset_name]])
  }
  else {
    return (colnames(dstable[[dataset_name]]))
  }
}

#### Script begins ####

# loads datasets
source(file.path('..', '..', 'datasets-info/fetch_datasets.R'))
french_datasets <- c('Lexique383', 'FrenchLexiconProject-words', 'WorldLex-French','Megalex-visual', 'Megalex-auditory')
english_datasets <- c('WorldLex-English','SUBTLEX-US')
others <- c('Voisins','anagrammes')

dataset_ids <- c(french_datasets,english_datasets,others)

datasets = list()
for (ds in dataset_ids)
{
    datasets[[ds]] <- fetch_dataset(ds, format='rds')
}

join_column = "Word"

dsnames <- list()
dsdesc <- list()
dsreadme <- list()
dstable <- list()
dsweb <- list()
dsmandcol <- list()
colnames_dataset <- list()

for (i in 1:length(datasets)) {
    name <- datasets[[i]]$name
    dsnames[[name]] <- name
    dsdesc[[name]] <- datasets[[i]]$description
    dsreadme[[name]] <- datasets[[i]]$readme
    dsweb[[name]] <- datasets[[i]]$website
    dsmandcol[[name]] <- datasets[[i]]$mandatory_columns
    dstable[[name]] <- readRDS(datasets[[i]]$datatables[[1]])
    colnames(dstable[[name]])[1] <- join_column
    colnames_dataset[[name]] <- colnames(dstable[[name]])
    if (is.null(dsmandcol[[name]])) {
      dsmandcol[[name]] <- colnames_dataset[[name]]
    }
}

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
                      tags$li("Choose a language to see the available datasets in this language below."),
                      tags$li("Select desired datasets. If you want more informations about a specific dataset, you can click on its tooltip."),
                      tags$li("Select columns to display for each dataset."),
                      tags$li("For each column in the table, you can:"),
                      tags$ul(
                               tags$li("Filter using intervals (e.g. 40...500) or ", tags$a(class="alert-link", href="http://regextutorials.com/index.html", "regexes", target="_blank"), ".", sep =""),
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
                        br(),
                        uiOutput("outlang"),
                        br(),
                        uiOutput("outdatabases"),
                        br(),
                        uiOutput("outshow_vars"),
                        br(),
           width=4
        ),
            mainPanel(
              fluidRow(tags$style(HTML("
                  thead:first-child > tr:first-child > th {
                      border-top: 0;
                      font-size: normal;
                      font-weight: bold;
                  }
              ")), 
                       DTOutput(outputId="table")),
              uiOutput("outdownload")
              #h3(textOutput("caption", container = span)),
            )
        )
    )

#### Server ####
server <- function(input, output, session) {
  v <- reactiveValues(language_selected = 'French',
                      categories = french_datasets,
                      first_dataset_selected = french_datasets[1],
                      selected_columns = c())
  
  # To select a language
  output$outlang <- renderUI({
    selectInput("language", "Choose a language",
                choices = c('\n','French', 'English'),
                selected = v$language_selected)
  })
  
  # Updating second dataset categories
  observeEvent(input$language, {
    v$language_selected <- input$language
    if (input$language == "French") {
      v$categories <- french_datasets
      v$first_dataset_selected <- french_datasets[1]
    }
    else if (input$language == "English") {
      v$categories <- english_datasets
      v$first_dataset_selected <- english_datasets[1]
    }
    else {
      v$categories <- c()
      v$first_dataset_selected <- ""
    }
  })
  
  output$outdatabases <- renderUI({
    if (v$language_selected != "\n") {
      tooltips = list()
      for (i in 1:length(v$categories)) {
        tooltips <- list.append(tooltips, popify(bsButton(paste("pB",i,sep=""), "?", style = "info", size = "extra-small"), trigger = "click hover",
                                                 title = v$categories[i],
                                                 content= paste("<div><p>",
                                                                str_replace_all(dsdesc[[v$categories[i]]],"'",'"'),
                                                                "</p><p><a href=",
                                                                dsreadme[[v$categories[i]]],
                                                                ">More info</a></p><p><a href =",
                                                                dsweb[[v$categories[i]]],
                                                                ">Website</a></p></div>",sep = "")
                                                 ))
      }
      extendedCheckboxGroup("databases", label = "Choose datasets", choiceNames  = v$categories, choiceValues = v$categories, selected = v$first_dataset_selected, 
                            extensions = tooltips
                            )
    }
    else {
      checkboxGroupInput("databases", "",
                         choices = c())
    }
  })
  
  # Changes table content according to the number of datasets
  datasetInput <- reactive({
    selected_columns<- c()
    if (length(input$databases) > 0) {
      list_df <- list()
      for (i in 1:length(input$databases)){
        dat <- dstable[[input$databases[i]]]
        for (j in 2:ncol(dat)) {
          if (length(input$databases) > 1){
            colnames(dat)[j] <- paste(input$databases[i],"<br>", colnames_dataset[[input$databases[i]]][j], sep = "")
          }
          else {
            colnames(dat)[j] <- colnames_dataset[[input$databases[i]]][j]
          }
          if (colnames_dataset[[input$databases[i]]][j] %in% dsmandcol[[input$databases[i]]]){
            selected_columns <- c(selected_columns, colnames(dat)[j])
          }
        }
        list_df <- list.append(list_df,dat)
      }
      v$selected_columns <- selected_columns
      Reduce(function(x,y) merge(x,y, by=join_column), list_df)
    }
  }
  )
  
  # Column filter
  output$outshow_vars <- renderUI({
    if (length(input$databases) >= 1) {
      pickerInput(
        inputId = "show_vars", 
        label = "Choose columns to display", 
        choices = lapply(names(datasetInput()),function(n){str_replace(n, "<br>","\n")}), 
        selected = c(join_column,lapply(v$selected_columns,function(n){str_replace(n, "<br>","\n")})),#lapply(names(datasetInput()),function(n){str_replace(n, "<br>","\n")}),
        options = list(
          `actions-box` = TRUE,
          size = 10,
          `dropup-auto` = FALSE,
          `selected-text-format`= "count > 3"
        ), 
        multiple = TRUE
      )
    } else {
      checkboxGroupInput("show_vars",
                         label = "")
    }
  })
  
  # Displaying table
  retable <- eventReactive(input$show_vars, {datasetInput()[,str_replace_all(input$show_vars, "\n", "<br>"), drop=FALSE]})
  output$table <- renderDT(retable(),
                           server=TRUE, escape = FALSE, selection = 'none',
                           filter=list(position = 'top', clear = FALSE),
                           rownames= FALSE,
                           options=list(pageLength=10,
                                        columnDefs = list(list(className = 'dt-center', targets = "_all")),
                                        sDom  = '<"top">lrt<"bottom">ip',
                                        lengthMenu = c(10, 25, 100, 500, 1000),
                                        search=list(searching = TRUE,
                                                    regex=TRUE,
                                                    caseInsensitive = FALSE)
                           )
  )
  
  output$outdownload <- renderUI({
    if (length(input$databases) >= 1)
    {
      downloadButton('download.xlsx', label="Download filtered data")
    }
  })
  
  output$download.xlsx <- downloadHandler(
    filename = function() {
      paste("Lexique-query-", Sys.time(), ".xlsx", sep="")
    },
    content = function(fname){
      # write.csv(datasetInput(), fname)
      dt = datasetInput()[input[["table_rows_all"]],str_replace_all(input$show_vars, "\n", "<br>")]
      names(dt) = lapply(names(dt),function(n){str_replace(n, "<br>","\n")})
      write_xlsx(dt, fname)
    })
  #url  <- a("Help!", href="http://www.lexique.org/?page_id=166")
  #output$help = renderUI({ tagList("", url) })
}
  
#options(warn = 2, shiny.error = recover)
shinyApp(ui, server)
