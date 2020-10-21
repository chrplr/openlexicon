# shiny R code for generate pseudowords <www.lexique.org>
# Authors: Boris New & C. Pallier
# Time-stamp: <2019-07-22 10:41:54 christophe@pallier.org>

#### Functions ####
rm(list = ls())
source('www/functions/loadPackages.R')

#### Script begins ####
ui <- fluidPage(
  useShinyjs(),
  useShinyalert(),

  titlePanel(tags$a(href="http://chrplr.github.io/infra/", "Infra")),
  title = "Infra",

  sidebarLayout(
    sidebarPanel(
      uiOutput("helper_alert"),
      br(),
      helper_alert,
      div(tags$div(selectInput("longueur",
                           length_choice,
                           3:15,
                           selected = 6,
                           width = "100%"))),
      div(uiOutput("olenGram")),
      div(actionButton("generateDB", generateDB_btn)),
      br(),
      div(uiOutput("oMots")),
      div(tags$div(numericInput("nbpseudos",
                           number_choice,
                           value = 20,
                           min = 1,
                           max = 1000,
                           width = "100%"))),
      div(style="text-align:center;",actionButton("go", go_btn)),
      width=4
    ),
  mainPanel(
    tabsetPanel(type = "tabs",
      tabPanel(tab1,
        (fluidRow(tags$style(HTML("
                      thead:first-child > tr:first-child > th {
                          border-top: 0;
                          font-size: normal;
                          font-weight: bold;
                      }
                  ")),
                 br(),
                 DTOutput(outputId="pseudomots") %>% withSpinner(type=3,
                            color.background="#ffffff",
                            hide.element.when.recalculating = FALSE,
                            proxy.height = 0),
        uiOutput("outdownload")
      )), class = "col-sm-4"),
      tabPanel(tab2,
        (fluidRow(tags$style(HTML("
                      thead:first-child > tr:first-child > th {
                          border-top: 0;
                          font-size: normal;
                          font-weight: bold;
                      }
                  ")),
                 br(),
                 DTOutput(outputId="pseudomotsFull") %>% withSpinner(type=3,
                            color.background="#ffffff",
                            hide.element.when.recalculating = FALSE,
                            proxy.height = 0),
        uiOutput("outdownloadFull")
      )))
    )
)))


server <- function(input, output, session) {
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
      updateTextAreaInput(session, "mots", value = v$words_to_search)
    })

    output$oMots <- renderUI({
      textAreaInput("mots",
                  label = tags$b(paste_words),
                  rows = 10, value = v$words_to_search, resize = "none")
    })

    #### len grams ####

    observeEvent(input$longueur, {
      if (input$longueur == 3 || input$longueur == 4){
        v$len_gram = "bigram"
      }else{
        v$len_gram = "trigram"
      }
      updateSelectInput(session, "lenGram", selected = v$len_gram)
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

    #### Tables ####

    output$pseudomots = renderDT({
      if (!is.null(pseudowords())){
        dt <- pseudowords()
        v$nb_pseudowords <- length(dt)

        datatable(dt,
                  escape = FALSE, selection = 'none',
                  filter=list(position = 'top', clear = FALSE),
                  rownames= FALSE, #extensions = 'Buttons',
                  width = 200,
                  options=list(pageLength=20,
                               stateSave = TRUE,
                               stateLoadParams = DT::JS("function (settings, data) {return false;}"),
                               columnDefs = list(list(className = 'dt-center', targets = "_all"),
                               list(visible=FALSE, targets=c(1:(ncol(dt)-1)))
                               ),
                               sDom  = '<"top">lrt<"bottom">ip',
                               #sDom  = '<"top">Brt<"bottom">ip',
                               #buttons = list(list(extend = 'colvis', columns = c(1:(ncol(dt)-1)), text = "Words used")),

                               lengthMenu = c(20,100, 500, 1000),
                               search=list(searching = TRUE,
                                           regex=TRUE,
                                           caseInsensitive = FALSE)
                   ))#%>%
        # formatStyle(
        #   'Word.1',
        #   color = 'grey', backgroundColor = 'white', fontWeight = 'bold'
        # )
      }
    }, server = TRUE)

    output$pseudomotsFull = renderDT({
      if (!is.null(pseudowords())){
        dt <- pseudowords()
        v$nb_pseudowords <- length(dt)

        datatable(dt,
                  escape = FALSE, selection = 'none',
                  filter=list(position = 'top', clear = FALSE),
                  rownames= FALSE,
                  width = 200,
                  options=list(pageLength=20,
                               stateSave = TRUE,
                               stateLoadParams = DT::JS("function (settings, data) {return false;}"),
                               columnDefs = list(list(className = 'dt-center', targets = "_all")),
                               sDom  = '<"top">lrt<"bottom">ip',
                               lengthMenu = c(20,100, 500, 1000),
                               search=list(searching = TRUE,
                                           regex=TRUE,
                                           caseInsensitive = FALSE)
                   ))
      }
    }, server = TRUE)

    #### Download options ####

    output$outdownload <- renderUI({
      if (v$nb_pseudowords > 0 && !is.null(pseudowords()))
      {
        downloadButton('download.xlsx', label="Download pseudowords")
      }
    })

    output$outdownloadFull <- renderUI({
      if (v$nb_pseudowords > 0 && !is.null(pseudowords()))
      {
        downloadButton('download2.xlsx', label="Download pseudowords")
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
        dt <- pseudowords()[input[["pseudomots_rows_all"]], ]
        to_drop <- c()
        for (col in 1:ncol(dt)){
          if (isFALSE(input$pseudomots_state$columns[[col]]$visible)){
            to_drop <- c(to_drop, col)
          }else{
            dt[, col] <- gsub(font_first_element, "", dt[, col])
            dt[, col] <- gsub(font_second_element, "", dt[, col])
            dt[, col] <- gsub(font_fade, "", dt[, col])
            dt[, col] <- gsub(font_fade_end, "", dt[, col])
          }
        }
        dt <- dt[-to_drop]
        write_xlsx(dt, fname)
      })

      output$download2.xlsx <- downloadHandler(
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
