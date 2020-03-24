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
library(RCurl) # To test if string is url
library(tippy)
library(comprehenr)

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

get_mandatory_columns <- function(dataset_name, info) {
  if (!is.null(info$mandatory_columns)) {
    return(info$mandatory_columns)
  }
  else {
    return (colnames(dstable[[dataset_name]]))
  }
}
# Essai
#### Script begins ####

# loads datasets
#source('https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/fetch_datasets.R')
source('../../datasets-info/fetch_datasets.R')

# Les datasets-id sont les noms des json
# Pb avec anagrammes
dataset_ids <- c('Lexique383','AoA_FreqSub_1493','AoA_FamConcept_1225','Assoc_520','Assoc_366','Concr_ContextAv_ValEmo_Arous_1659','Concr_Imag_FreqSub_Valemo_866',
                  'FrenchLexiconProject-words','FreqSub_Adulte_Senior_660','FreqSub_Imag_1916','FreqSub_Imag_3600','Img_AoA_..._400','Imag_1493','Manulex-Ortho','Manulex-Lemmes',
                  'Megalex-visual','Megalex-auditory','SUBTLEX-US','Aoa32lang',
                  'RT_LD_NMG_FLP_Mono_1482','SensoryExp_1659','SensoryExp_1659',
                  'ValEmo_Arous_Imag_835','ValEmo_Arous_1286',
                  'Valemo_Enfants_600','Valemo_Adultes_604', 'Voisins','WorldLex-English','FreqTwitter-WorldLex-French')
                 
datasets <- list()
# ex_filenames_ds dictionnaire associe dataset_ids et le nom du json puis du rds
ex_filenames_ds <- list('FrenchLexiconProject-words' = c('RT_FrenchLexiconProject-words', 'flp-words'),
                        'FreqTwitter-WorldLex-French' = c('WorldLex-French','WorldLex_FR'),
                        'WorldLex-English' = c('WorldLex-English', 'WorldLex_EN'),
                        'Manulex-Ortho' = c('Manulex', 'Manulex-Ortho'),
                        'Manulex-Lemmes' = c('Manulex', 'Manulex-Lemmes'),
                        'Aoa32lang' = c('AoA-32lang', 'AoA32lang'),
                        'SUBTLEX-US' = c('SUBTLEX-US', 'SUBTLEXus'),
                        'anagrammes' = c('anagrammes', 'Anagrammes')
                        )

#json_folder = 'http://www.lexique.org/databases/_json/'
json_folder = '../../../openlexicon/datasets-info/_json/'

for (ds in dataset_ids)
{
    #datasets[[ds]] <- fetch_dataset(ds, format='rds')
    rds_file <- ds
    json_file <- ds
    if (!is.null(ex_filenames_ds[[ds]])) {
      json_file <- ex_filenames_ds[[ds]][1]
      rds_file <- ex_filenames_ds[[ds]][2]
    }
    datasets[[ds]] = c(paste(json_folder,json_file,'.json', sep = ""),
                       paste(rds_file,'.rds', sep = ""))
}

join_column = "Word"

dsnames <- list()
dsdesc <- list()
dsreadme <- list()
dstable <- list()
dsweb <- list()
dsmandcol <- list()
dslanguage <- list()
colnames_dataset <- list()
colnames_tooltips <- list()

# We try to load the databases
for (ds in names(datasets)) {
  tryCatch({
    json_url <- datasets[[ds]][1]
    rds_file <- datasets[[ds]][2]
    dstable[[ds]] <- readRDS(get_dataset_from_json(json_url, rds_file))
  },
  error = function(e) {
    message(paste("Couldn't load database ", ds, ". Check json and rds files.", sep = ""))
  } 
  )
}

# Removes not loaded datasets from the list
for (ds in names(datasets)) { if (is.null(dstable[[ds]])) { datasets[[ds]] <- NULL}}
       
for (ds in names(datasets)) {
  json_url <- datasets[[ds]][1]
  info = get_info_from_json(json_url)
  dsnames[[ds]] <- ds
  dslanguage[[ds]]['name'] <- info$language
  dsdesc[[ds]] <- info$description
  dsreadme[[ds]] <- info$readme
  dsweb[[ds]] <- info$website
  dsmandcol[[ds]] <- get_mandatory_columns(ds, info)
  colnames_tooltips[[ds]] <- info$column_names
  colnames(dstable[[ds]])[1] <- join_column
  colnames_dataset[[ds]] <- colnames(dstable[[ds]])
  if (is.null(dsmandcol[[ds]])) {
    dsmandcol[[ds]] <- colnames_dataset[[ds]]
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
                      tags$li("Select desired datasets. If you want more informations about a specific dataset, you can hover over its tooltip."),
                      tags$li("Select columns to display for each dataset."),
                      tags$li("For each column in the table, you can:"),
                      tags$ul(
                               tags$li("Filter using ", tags$b("intervals (e.g. 40...500) "), "or ", tags$a(class="alert-link", href="http://www.lexique.org/?page_id=101", "regular expressions", target="_blank"), ".", sep =""),
                               tags$li("sort, ascending or descending")
                           ),
                      tags$li("Download the result of your manipulations by clicking on the button below the table")
                  )
             #tags$hr(),
             #tags$p(tags$a(href="https://chrplr.github.io/openlexicon/datasets-info/", "More information about the datatasets"))
             )

# To call tooltips for column names

headerCallback <- function(col_tooltips) {c(
  "function(thead, data, start, end, display){",
  sprintf("  var tooltips = [%s];", toString(paste0("'", col_tooltips, "'"))),
  "if (typeof(v$selected_columns) != 'undefined'){",
  " console.log(v$selected_columns)}",
  "console.log(tooltips)",
  "  for(var i = 1; i <= tooltips.length; i++){",
  "    $('th:eq('+i+')',thead).attr('title', tooltips[i-1]);",
  "  }",
  "}"
)}


#### UI ####
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .tippy-tooltip.tomato-theme {
      background-color: tomato;
      color: yellow;
    }
    "))
  ),
    titlePanel(tags$a(href="http://chrplr.github.io/openlexicon/", "Open Lexicon")),
    title = "Open Lexicon",
    sidebarLayout(
        sidebarPanel(
                        helper_alert,
                        uiOutput("outlang"),
                        uiOutput("outshow_vars"),
                        uiOutput("outdatabases"),
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
                      categories = names(list.filter(dslanguage, 'french' %in% tolower(name))),
                      first_dataset_selected = 'Lexique383',
                      selected_columns = c())
  
  # To select a language
  output$outlang <- renderUI({
    selectInput("language", "Choose a language",
                choices = c('\n','French', 'English', 'Multiple languages'),
                selected = v$language_selected)
  })
  
  # Updating second dataset categories
  observeEvent(input$language, {
    v$language_selected <- input$language
    if (input$language == "French") {
      v$categories <- names(list.filter(dslanguage, 'french' %in% tolower(name)))
      v$first_dataset_selected <- 'Lexique383'
    }
    else if (input$language == "English") {
      v$categories <- names(list.filter(dslanguage, 'english' %in% tolower(name)))
      v$first_dataset_selected <- 'SUBTLEX-US'
    }
    else if (input$language == "Multiple languages") {
      v$categories <- names(list.filter(dslanguage, 'multiple_languages' %in% tolower(name)))
      v$first_dataset_selected <- 'Aoa32lang'
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
        info_tooltip = paste("<span style='font-size:14px;'>", "<div><p>",
              str_replace_all(dsdesc[[v$categories[i]]],"'","&#39"), "<span>", sep = "")
        if (!is.null(dsweb[[v$categories[i]]]) && RCurl::url.exists(dsweb[[v$categories[i]]])){
          info_tooltip = paste(info_tooltip, "</p><p><a href=",
          # dsreadme[[v$categories[i]]],
          #">More info</a></p><p><a href =",
          dsweb[[v$categories[i]]],
          " >Website</a></p></div>",sep = "")
        }
        tooltips <- list.append(tooltips, tippy(bsButton(paste("pB",i,sep=""), "?", style = "info", size = "extra-small"), interactive = TRUE, tooltip = info_tooltip))
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
                           options=list(headerCallback = JS(headerCallback(to_list(for (x in v$selected_columns) x))),
                                        pageLength=20,
                                        columnDefs = list(list(className = 'dt-center', targets = "_all")),
                                        sDom  = '<"top">lrt<"bottom">ip',
                                        lengthMenu = c(20,100, 500, 1000),
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
