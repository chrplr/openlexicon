# shiny R code for generate pseudowords <www.lexique.org>
# Authors: Boris New & C. Pallier
# Time-stamp: <2019-07-22 10:41:54 christophe@pallier.org>

#### Functions ####
rm(list = ls())
source('www/functions/generatePseudo.R')
source('www/functions/loadPackages.R')

# Loading datasets and UI
source('../../datasets-info/fetch_datasets.R')
source('www/data/loadingDatasets.R')

source('www/data/uiElements.R')
source('www/data/listedemotsfrancais.R', encoding='latin1')

#### Script begins ####
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "data/tooltips.css")
  ),
  useShinyjs(),
  useShinyalert(),

  titlePanel(tags$a(href="http://chrplr.github.io/pseudowords_markov/", "Pseudoword Generator")),
  title = "Pseudoword Generator",

  sidebarLayout(
    sidebarPanel(
      uiOutput("helper_alert"),
      br(),
      helper_alert,
      tags$div(selectInput("longueur",
                           length_choice,
                           3:15,
                           selected = 4,
                           width = "100%")),
      uiOutput("olenGram"),
      actionButton("generateDB", generateDB_btn),
      br(),
      br(),
      uiOutput("oMots"),
      tags$div(numericInput("nbpseudos",
                           number_choice,
                           value = 20,
                           min = 1,
                           max = 1000,
                           width = "100%")),
      actionButton("go", go_btn),
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
             DTOutput(outputId="pseudomots") %>% withSpinner(type=3,
                                                              color.background="#ffffff",
                                                              hide.element.when.recalculating = FALSE,
                                                              proxy.height = 0)),
    uiOutput("outdownload")
)))


server <- function(input, output) {
  v <- reactiveValues(
    button_helperalert = btn_hide_helper,
    nb_pseudowords = 0,
    words_to_search = c(),
    len_gram = "bigram")

    #### Toggle helper_alert ####

    output$helper_alert <- renderUI({
      actionButton("btn", v$button_helperalert)
    })

    observeEvent(input$btn, {
      shinyjs::toggle("helper_box", anim = TRUE, animType = "slide")

      if (v$button_helperalert == btn_show_helper){
        v$button_helperalert = btn_hide_helper
      }else{
        v$button_helperalert = btn_show_helper
      }
    })

    #### Generate words from Lexique ####

    observeEvent(input$generateDB, {
      longueur = as.numeric(input$longueur)
      words <- dictionary_databases[['Lexique383']][['dstable']][['lemme']]
      wordsok <- words[nchar(words) == longueur]
      wordsok <- wordsok[!duplicated(wordsok)]
      wordsok <- as.character(wordsok)
      wordsok <- wordsok[!grepl("[[:punct:][:space:]]", wordsok)]
      v$words_to_search <- paste(wordsok, collapse="\n")
    })

    output$oMots <- renderUI({
      textAreaInput("mots",
                  label = tags$b(paste_words),
                  rows = 10, value = v$words_to_search, resize = "none")
    })

    #### len grams ####

    observeEvent(input$longueur, {
      if (input$longueur <= 4){
        v$len_gram = "bigram"
      }else{
        v$len_gram = "trigram"
      }
      })

    output$olenGram <- renderUI({
      selectInput("lenGram",
                           lenGram_choice,
                           c("bigram", "trigram"),
                           selected = v$len_gram,
                           width = "100%")
    })

    #### show pseudowords ####

    pseudowords <- eventReactive(input$go,
    {
       nbpseudos = as.numeric(input$nbpseudos)
       longueur = as.numeric(input$longueur)
       algo = input$lenGram
       words <- strsplit(input$mots,"[ \n\t]")[[1]]
       wordsok <- words[nchar(words) == longueur]
       wordsok <- wordsok[!grepl("[[:punct:][:space:]]", wordsok)] # remove words with punctuation or space
       generate_pseudowords(nbpseudos, longueur, wordsok, algo)
    }
    )

    output$pseudomots = renderDT({
      dt <- pseudowords()
      v$nb_pseudowords <- length(dt)

      datatable(dt,
                escape = FALSE, selection = 'none',
                filter=list(position = 'top', clear = FALSE),
                rownames= FALSE,
                options=list(pageLength=20,
                             columnDefs = list(list(className = 'dt-center', targets = "_all")),
                             sDom  = '<"top">lrt<"bottom">ip',
                             lengthMenu = c(20,100, 500, 1000),
                             search=list(searching = TRUE,
                                         regex=TRUE,
                                         caseInsensitive = FALSE)
                ))
    }, server = TRUE)

    #### Download options ####

    output$outdownload <- renderUI({
      if (v$nb_pseudowords > 0)
      {
        downloadButton('download.xlsx', label="Download pseudowords")
      }
    })

    output$download.xlsx <- downloadHandler(
      filename = function() {
        paste("Pseudowords-query-",
              format(Sys.time(), "%Y-%m-%d"), ' ',
              paste(hour(Sys.time()), minute(Sys.time()), second(Sys.time()), sep = "-"),
              ".xlsx", sep="")
      },
      content = function(fname) {
        dt <- pseudowords()
        for (col in 1:ncol(dt)){
          dt[, col] <- gsub(font_first_element, "", dt[, col])
          dt[, col] <- gsub(font_second_element, "", dt[, col])
          dt[, col] <- gsub(font_fade, "", dt[, col])
          dt[, col] <- gsub(font_fade_end, "", dt[, col])
        }
        write_xlsx(dt, fname)
      })
}


shinyApp(ui, server)
