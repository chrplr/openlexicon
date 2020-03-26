# shiny R code for lexique.org
# Time-stamp: <2019-06-04 21:51:05 christophe@pallier.org>
# Afficher info deuxième database en haut

library(shiny)
library(shinyBS)
library(shinyjs)
library(DT)
library(writexl)
library(plyr)
library(data.table)
library(rlist)
library(stringr)
library(RCurl) # To test if string is url
library(tippy) # Tooltip
library(comprehenr) # Comprehension list
library(shinyTree)

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
    return (colnames(dictionary_databases[[dataset_name]][["dstable"]]))
  }
}

dropdownButton2 <- function(label = "", status = c("default", "primary", "success", "info", "warning", "danger"), ..., width = NULL) {
  
  status <- match.arg(status)
  # dropdown button content
  html_ul <- list(
    class = "dropdown-menu",
    style = if (!is.null(width)) 
      paste0("width: ", validateCssUnit(width), ";"),
    lapply(X = list(...), FUN = tags$li, style = "margin-left: 10px; margin-right: 10px;")
  )
  # dropdown button apparence
  html_button <- list(
    class = paste0("btn btn-", status," dropdown-toggle"),
    type = "button", 
    `data-toggle` = "dropdown"
  )
  html_button <- c(html_button, list(label))
  html_button <- c(html_button, list(tags$span(class = "caret")))
  # final result
  tags$div(
    class = "dropdown",
    do.call(tags$button, html_button),
    do.call(tags$ul, html_ul),
    tags$script(
      "$('.dropdown-menu').click(function(e) {
      e.stopPropagation();
});")
  )
}

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
btn_show_name = "Show List Search"
btn_hide_name = "Hide List Search"
prefix_multiple = ""
#prefix_multiple = "<span style='font-size:12px; color:grey;'>"
suffix_multiple = "</span><br>"
prefix_single = ""
suffix_single = "<br>"

dictionary_databases <- list()
dslanguage <- list()

# We try to load the databases
for (ds in names(datasets)) {
  tryCatch({
    json_url <- datasets[[ds]][1]
    rds_file <- datasets[[ds]][2]
    dictionary_databases[[ds]][["dstable"]] <- readRDS(get_dataset_from_json(json_url, rds_file))
  },
  error = function(e) {
    message(paste("Couldn't load database ", ds, ". Check json and rds files.", sep = ""))
  } 
  )
}

# Removes not loaded datasets from the list
for (ds in names(datasets)) { if (is.null(dictionary_databases[[ds]][["dstable"]])) { datasets[[ds]] <- NULL}}
       
for (ds in names(datasets)) {
  json_url <- datasets[[ds]][1]
  info = get_info_from_json(json_url)
  dslanguage[[ds]]['name'] <- info$language
  dictionary_databases[[ds]][["dsdesc"]] <- info$description
  dictionary_databases[[ds]][["dsreadme"]] <- info$readme
  dictionary_databases[[ds]][["dsweb"]] <- info$website
  dictionary_databases[[ds]][["dsmandcol"]] <- get_mandatory_columns(ds, info)
  dictionary_databases[[ds]][["colnames_dataset"]] <- list()
  colnames(dictionary_databases[[ds]][["dstable"]])[1] <- join_column
  
  # Column names description
  for (j in 2:length(colnames(dictionary_databases[[ds]][["dstable"]]))) {
    current_colname = colnames(dictionary_databases[[ds]][["dstable"]])[j]
    if (typeof(info$column_names[[current_colname]]) == "NULL"){
      dictionary_databases[[ds]][["colnames_dataset"]][[current_colname]] = ""
    }
    else{
      dictionary_databases[[ds]][["colnames_dataset"]][[current_colname]] = info$column_names[[current_colname]]
    }
  }
  
  if (is.null(dictionary_databases[[ds]][["dsmandcol"]])) {
    dictionary_databases[[ds]][["dsmandcol"]] <- names(dictionary_databases[[ds]][["colnames_dataset"]])
  }
}

helper_alert <-
    tags$div(class="alert alert-info",
             tags$p("Quick how-to:"),
             tags$ul(
                      tags$li("Choose a language to see the available datasets in this language below."),
                      tags$li("Select desired datasets. If you want more informations about a specific dataset, you can hover over its tooltip."),
                      tags$li("Select columns to display for each dataset."),
                      tags$li("For each column in the table, you can:"),
                      tags$ul(
                               tags$li("Hover the mouse over the column name to see a brief description (ongoing work)"),
                               tags$li("Filter using ", tags$b("intervals (e.g. 40...500) "), "or ", tags$a(class="alert-link", href="http://www.lexique.org/?page_id=101", "regular expressions", target="_blank"), ".", sep =""),
                               tags$li("sort, ascending or descending")
                           ),
                      tags$li(paste("Click on the button \"", btn_show_name, "\" to enter words that you want to search in the table.", sep = "")),
                      tags$li("Download the result of your manipulations by clicking on the button below the table")
                  )
             #tags$hr(),
             #tags$p(tags$a(href="https://chrplr.github.io/openlexicon/datasets-info/", "More information about the datatasets"))
             )

#### UI ####
ui <- fluidPage(
    useShinyjs(),
    titlePanel(tags$a(href="http://chrplr.github.io/openlexicon/", "Open Lexicon")),
    title = "Open Lexicon",
    sidebarLayout(
        sidebarPanel(
                        helper_alert,
                        uiOutput("shinyTreeTest"),
                        br(),
                        uiOutput("outbtnlistsearch"),
                        br(),
                        hidden(textAreaInput("mots",
                                             label = h5(strong("Words to search")),
                                             rows = 10,
                                             resize = "none")),
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
                      selected_columns = list(),
                      button_listsearch = btn_show_name,
                      prefix_col = prefix_single,
                      suffix_col = suffix_single)
  
  output$outbtnlistsearch <- renderUI({
    actionButton("btn", v$button_listsearch)
  })
  
  output$shinyTreeTest <- renderUI({ 
    dropdownButton2(
      shinyTree("tree", checkbox = TRUE, search = TRUE, themeIcons = FALSE, themeDots = FALSE),width ="100%", label = "Choose columns", status = "default"
    )
  })
  
  output$tree <- renderTree({ 
    list(  'I lorem impsum'= list( 
      'I.1 lorem impsum'   =  structure(list('I.1.1 lorem impsum'='1', 'I.1.2 lorem impsum'='2'),stselected=TRUE),  
      'I.2 lorem impsum'   =  structure(list('I.2.1 lorem impsum'='3'), stselected=TRUE)))
    
  })
  
  # Toggle list search
  observeEvent(input$btn, {
    # Change the following line for more examples
    toggle("mots", anim = TRUE, animType = "slide")
    if (v$button_listsearch == btn_show_name){
      v$button_listsearch = btn_hide_name
    }else{
      v$button_listsearch = btn_show_name
    }
  })
  
  # Transform list search input
  mots2 <- reactive( { strsplit(input$mots,"[ \n\t]")[[1]] } )
  
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
              str_replace_all(dictionary_databases[[v$categories[i]]][["dsdesc"]],"'","&#39"), "<span>", sep = "")
        if (!is.null(dictionary_databases[[v$categories[i]]][["dsweb"]]) && RCurl::url.exists(dictionary_databases[[v$categories[i]]][["dsweb"]])){
          info_tooltip = paste(info_tooltip, "</p><p><a href=",
          # dsreadme[[v$categories[i]]],
          #">More info</a></p><p><a href =",
          dictionary_databases[[v$categories[i]]][["dsweb"]],
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
    selected_columns <- list()
    if (length(input$databases) > 0) {
      list_df <- list()
      if (length(input$databases) == 1){
        v$prefix_col = prefix_single
        v$suffix_col = suffix_single
      }else{
        v$prefix_col = prefix_multiple
        v$suffix_col = suffix_multiple
      }
      for (i in 1:length(input$databases)){
        dat <- dictionary_databases[[input$databases[i]]][["dstable"]]
        for (j in 2:ncol(dat)) {
          original_name = colnames(dat)[j]
          if (length(input$databases) > 1){
            colnames(dat)[j] <- paste0(v$prefix_col, input$databases[i],v$suffix_col, original_name)
          }
          else {
            colnames(dat)[j] <- original_name
          }
          if (original_name %in% dictionary_databases[[input$databases[i]]][["dsmandcol"]]){
            selected_columns[[colnames(dat)[j]]] <- dictionary_databases[[input$databases[[i]]]][["colnames_dataset"]][[original_name]]
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
        choices = lapply(names(datasetInput()),
                         function(n){str_replace(gsub(v$prefix_col, "", n),
                                                 v$suffix_col,
                                                 "\n")}), 
        selected = c(join_column,lapply(names(v$selected_columns),
                                        function(n){str_replace(gsub(v$prefix_col, "", n),
                                                                v$suffix_col,
                                                                "\n")})),
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
  retable <- eventReactive(input$show_vars, {datasetInput()[,str_replace_all(paste0(v$prefix_col, input$show_vars),"\n", v$suffix_col),
                                                            drop=FALSE]})
  
  output$table <- renderDT({
                  dat <- retable()
                  
                  # Adding tooltips for column names
                  col_tooltips <- c()
                  for (elt in colnames(retable())){
                    col_tooltips <- c(col_tooltips, v$selected_columns[[elt]])
                  }
                  headerCallback <- c(
                    "function(thead, data, start, end, display){",
                    sprintf("  var tooltips = [%s];", toString(paste0("\"", col_tooltips, "\""))),
                    "  for(var i = 1; i <= tooltips.length; i++){",
                    "    $('th:eq('+i+')',thead).attr('title', tooltips[i-1].replace(`'`,`\'`));",
                    "  }",
                    "}"
                  )
                  
                  #https://laustep.github.io/stlahblog/posts/DTqTips.html
                  #https://stackoverflow.com/questions/58082260/shorten-column-names-provide-tooltip-on-hover-of-full-name
                  datatable(dat,
                           escape = FALSE, selection = 'none',
                           filter=list(position = 'top', clear = FALSE),
                           rownames= FALSE,
                           options=list(headerCallback = JS(headerCallback),
                                        pageLength=20,
                                        columnDefs = list(list(className = 'dt-center', targets = "_all")),
                                        sDom  = '<"top">lrt<"bottom">ip',
                                        lengthMenu = c(20,100, 500, 1000),
                                        search=list(searching = TRUE,
                                                    regex=TRUE,
                                                    caseInsensitive = FALSE)
                           ))
  }, server = TRUE)
  
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
      dt = datasetInput()[input[["table_rows_all"]],str_replace_all(paste0(v$prefix_col, input$show_vars), "\n", v$suffix_col)]
      names(dt) = lapply(names(dt),function(n){str_replace(gsub(v$prefix_col, "", n), v$psuffix_col,"\n")})
      write_xlsx(dt, fname)
    })
  #url  <- a("Help!", href="http://www.lexique.org/?page_id=166")
  #output$help = renderUI({ tagList("", url) })
}
  
#options(warn = 2, shiny.error = recover)
shinyApp(ui, server)
