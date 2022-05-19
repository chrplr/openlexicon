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

js <- "
$(document).ready(function() {
  $('#pseudomots').on('shiny:recalculating', function() {
    $('#go').prop('disabled', true);
  });
  $('#pseudomots').on('shiny:recalculated', function() {
    $('#go').prop('disabled', false);
  });
});
"

#### Script begins ####
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "data/tooltips.css"),
    tags$script(HTML(js))
  ),
  useShinyjs(),
  useShinyalert(),

  titlePanel(tags$a(href="http://chrplr.github.io/pseudowords_markov/", "UniPseudo")),
  title = "UniPseudo",

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
      uiOutput("outbtngenerator"),
      br(),
      hidden(div(id="divGenerator", style = "background-color:#E0E0E0;padding:1em;border-radius: 1em;",
          uiOutput("outlang"),
          hidden(uiOutput("outgram_class")),
          uiOutput("outgenerateDB"),
          br()
      )),
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
    language_selected = '\n',
    gram_class_is_shown = FALSE,
    info_tooltip = "",
    datasets = c(),
    grammatical_choices = c("\n"),
    gram_selected = "\n",
    button_helperalert = btn_hide_helper,
    nb_pseudowords = 0,
    button_generator = btn_show_generator_name,
    words_to_search = c(),
    len_gram = "bigram")

    #### Toggle helper_alert ####

    output$helper_alert <- renderUI({
      actionButton("btn", v$button_helperalert)
    })

    observeEvent(input$btn, {
      if (v$button_helperalert == btn_show_helper){
        v$button_helperalert = btn_hide_helper
      }else{
        v$button_helperalert = btn_show_helper
      }
    })

    observe({
      shinyjs::toggle("helper_box", anim = TRUE, animType = "slide", condition = v$button_helperalert == btn_hide_helper)
    })

    #### Toggle list search ####

    output$outbtngenerator <- renderUI({
      actionButton("btn_generator", v$button_generator)
    })

    observeEvent(input$btn_generator, {
      if (grepl(btn_show_generator_name, v$button_generator)){
        v$button_generator = btn_hide_generator_name
      }else{
        v$button_generator = btn_show_generator_name
      }
    })

    observe({
      shinyjs::toggle("divGenerator", anim = TRUE, animType = "slide", condition = grepl(btn_hide_generator_name, v$button_generator))
    })

    #### Select a language ####

    output$outlang <- renderUI({
      selectInput("language", "Choose a language",
                  choices = language_choices,
                  selected = v$language_selected)
    })

    # Update dataset based on language selection

    output$outgenerateDB <- renderUI({
      div(
        actionButton("generateDB", generateDB_neutral),
        tippy(bsButton("generateTooltip", "?", style = "info", size = "extra-small"), interactive = TRUE, theme = 'light', tooltip = v$info_tooltip)
      )
    })

    observeEvent(input$language, {
      v$language_selected <- input$language
      v$words_to_search <- c() # Reset words to search on language change
      v$grammatical_choices <- c("\n")
      v$gram_selected = "\n" # Reset gram class on language change

      load_language(input$language)
      if (input$language == "\n") {
        v$datasets <- ""
        # Hide grammatical class selection if previously shown
        if (v$gram_class_is_shown){
          toggle("outgram_class", anim = TRUE, animType = "slide")
          v$gram_class_is_shown=FALSE
        }
        # Disable generate words button and hide tooltip with database information
        disable("generateDB")
        hide("generateTooltip")
      }
      else {
        v$datasets <- names(list.filter(dslanguage, tolower(input$language) %in% tolower(name)))
        if (input$language == "French"){
          # Show grammatical class selection if was hidden
          if (!v$gram_class_is_shown){
            toggle("outgram_class", anim = TRUE, animType = "slide")
            v$gram_class_is_shown=TRUE
          }
          # Pick grammatical classes in Lexique
          v$grammatical_choices <- c("\n", unique(dictionary_databases[["Lexique383"]][['dstable']][['cgram']]))
        }else {
          # Hide grammatical class selection if previously shown
          if (v$gram_class_is_shown){
            toggle("outgram_class", anim = TRUE, animType = "slide")
            v$gram_class_is_shown=FALSE
          }
        }
        # Create database information tooltip
        info_tooltip = paste("<span style='font-size:14px;'>Words will be selected from the <b>", v$datasets[1], "</b> database.")
        info_tooltip = paste(info_tooltip, "<div><p>",
              str_replace_all(dictionary_databases[[v$datasets[1]]][["dsdesc"]],"'","&#39"), "<span>", sep = "")
        if (!is.null(dictionary_databases[[v$datasets[1]]][["dsweb"]])
            && RCurl::url.exists(dictionary_databases[[v$datasets[1]]][["dsweb"]])){
          info_tooltip = paste(info_tooltip, "</p><p><a href=",
          dictionary_databases[[v$datasets[1]]][["dsweb"]],
          " target='_blank'>Website</a></p></div>",sep = "")
        }
        # Update tooltip in reactive values and enable generation
        v$info_tooltip = info_tooltip
        enable("generateDB")
        show("generateTooltip")
      }
    })

    # Select grammatical class (french only)

    output$outgram_class <- renderUI({
      selectInput("gram_class", grammatical_class_label,
                  choices = v$grammatical_choices,
                  selected = v$gram_selected)
    })

    #### Generate words from database ####

    observeEvent(input$generateDB, {
      longueur = as.numeric(input$longueur)
      if (v$language_selected != "\n"){
        words <- get_dataset_words(v$datasets, dictionary_databases, input$gram_class)
      }else {
        words <- c()
      }
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
       if (v$language_selected != "\n"){
         exclude <- get_dataset_words(v$datasets, dictionary_databases)
       }else{
         exclude <- NULL
       }
       generate_pseudowords(nbpseudos, longueur, wordsok, algo, exclude = exclude)
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
            dt[, col] <- gsub(font_previous_letters, "", dt[, col])
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
            dt[, col] <- gsub(font_previous_letters, "", dt[, col])
            dt[, col] <- gsub(font_fade, "", dt[, col])
            dt[, col] <- gsub(font_fade_end, "", dt[, col])
          }
          write_xlsx(dt, fname)
        })
}

shinyApp(ui, server)
