# shiny R code for generate pseudowords <www.lexique.org>
# Authors: Boris New & C. Pallier
# Time-stamp: <2019-07-22 10:41:54 christophe@pallier.org>

#### Functions ####
rm(list = ls())
source('www/functions/loadPackages.R')
source('www/functions/generatePseudo.R')
source('www/data/uiElements.R')

# Loading datasets and UI
source('../../datasets-info/fetch_datasets.R')
source('www/data/loadingDatasets.R')

# Load filter functions at the end for dependencies reasons
source('www/functions/filterFunctions.R')

# For bug test
# source('www/functions/test.R')

js <- "
var text = '';
// On button click, set variable text to text of button clicked (can't get id reliably)
$(document).click(function(event) {
    text = $(event.target).text();
});

$(document).on('shiny:busy', function(event) {
  // Check that button clicked is not btn_generate. If not, disable interface.
  if (!['Show Word Import Tool', 'Hide Word Import Tool'].some(function(v) { return text.indexOf(v) >= 0; })){
    var $inputs = $('button,input,textarea');
    $inputs.prop('disabled', true);
  }
});

// Enable back interface when shiny is idle.
$(document).on('shiny:idle', function() {
  var $inputs = $('button,input,textarea');
  $inputs.prop('disabled', false);
})

// Get timezone
$(document).on('shiny:sessioninitialized', function(){
  const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  Shiny.setInputValue('currentTZ', timezone);
})
"

#### Script begins ####
ui <- fluidPage(
  # Spinner showing during computing time
  add_busy_spinner(
    spin = "double-bounce",
    color = "#112446",
    timeout = 100,
    position = "bottom-right",
    onstart = TRUE,
    margins = c(10, 10),
    height = "50px",
    width = "50px"
    ),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles/main.css"),
    tags$script(HTML(js))
  ),
  useShinyjs(),
  useShinyalert(),

  titlePanel(tags$a(href="http://www.lexique.org/?page_id=582", app_name)),
  title = app_name,

  sidebarLayout(
    sidebarPanel(
      id="sidebarPanel",
      # uiOutput("helper_alert"),
      # br(),
      # helper_alert,
      div(tags$div(pickerInput(
                           inputId = "longueur",
                           label = length_choice,
                           choices = 3:15,
                           selected = 6,
                           width = "100%",
                           options = pickerOptions(
                             dropupAuto = FALSE
                           )
                           ))),
      div(uiOutput("olenGram")),
      uiOutput("outlang"),
      uiOutput("outbtngenerator"),
      br(),
      hidden(
        div(id="divGenerator", style = "padding-top:1.5em;padding-bottom:1.5em;margin-bottom:1em;background-color:#E0E0E0;padding-left:1em;padding-right:1em;border-radius: 1em;",
          hidden(uiOutput("outgram_class")),
          uiOutput("outgenerateDB")
      )),
      div(uiOutput("oMots")),
      div(uiOutput("oShowFilters")),
      hidden(div(
        id="filter_box",
        lapply(1:length(filtersList), function(i) {
          filterInput(
            filtersList[[i]][["name"]],
            filtersList[[i]][["options"]],
            filtersList[[i]][["pretty_name"]],
            filtersList[[i]][["tooltip"]]
          )
      }))),
      div(uiOutput("oNbpseudos")),
      div(style="text-align:center;",actionButton("go", go_btn)),
      uiOutput("oInfoGeneration"),
      width=3
    ),
  mainPanel(
    id="mainPanel",
    width=9,
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
                 DTOutput(outputId="pseudomots"),
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
                 helpText("This table contains the pseudowords (first column) and all words used to generate them.",br()," For each word, parts used to compose the final pseudoword are", tags$span("red-colored", style='color:red;font-weight:bold'), "while the letters used at each step as a basis to find next bigram or trigram are", tags$span("orange-colored", style='color:orange;font-weight:bold'), style="margin:2em;margin-top:0.5em;font-size:12px"),
                 DTOutput(outputId="pseudomotsFull"),
        uiOutput("outdownloadFull")
      )))
    )
)))


server <- function(input, output, session) {
  track_usage(storage_mode = store_json(path = get_log.home(app_name))) # initialize logs
  # QA_test(QA_check=TRUE)

  # duplicate_ds will not be empty if some databases have the same id (language or id_lang, see loading_datasets). So if an id is already in use, subsequent databases with same id will not be loaded and user will be warned
  if (length(duplicate_ds) > 0){
      shinyalert("Warning", paste("Databases", paste(duplicate_ds, collapse = ', '), "could not be loaded because they do not have a unique id_lang or language in their json file."))
  }

  v <- reactiveValues(
    language_selected = "English",
    gram_class_is_shown = FALSE,
    info_tooltip = "",
    datasets = c(),
    grammatical_choices = c(default_none),
    gram_selected = default_none,
    # button_helperalert = btn_hide_helper,
    nb_pseudowords = 0,
    button_generator = btn_show_generator_name,
    words_to_search = c(),
    len_gram = algo_choices[1],
    len_wordsok = 0,
    button_filter = btn_show_filter
  )

    #### Toggle helper_alert ####

    # output$helper_alert <- renderUI({
    #   actionButton("btn", v$button_helperalert)
    # })
    #
    # observeEvent(input$btn, {
    #   if (v$button_helperalert == btn_show_helper){
    #     v$button_helperalert = btn_hide_helper
    #   }else{
    #     v$button_helperalert = btn_show_helper
    #   }
    # })
    #
    # observe({
    #   shinyjs::toggle("helper_box", anim = TRUE, animType = "slide", condition = v$button_helperalert == btn_hide_helper)
    # })

    #### Toggle list search ####

    output$outbtngenerator <- renderUI({
      div(
      actionButton("btn_generator", v$button_generator),
      tippy(circleButton("btn_generatorTooltip", "?", status = "info", size = "xs"), trigger="click", interactive = TRUE, theme = 'light left-align', tooltip = btn_generator_tooltip))
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
      div(
        h5(tags$b("Choose a language"), tippy(circleButton("langTooltip", "?", status = "info", size = "xs"), interactive = TRUE, trigger="click", theme = 'light left-align', tooltip = lang_tooltip)),
        pickerInput(inputId = "language",
                    choices = language_choices,
                    selected = v$language_selected,
                    options = pickerOptions(
                      dropupAuto = FALSE
                    )
                  )
      )
    })

    # Update dataset based on language selection

    output$outgenerateDB <- renderUI({
      div(
        actionButton("generateDB", generateDB_neutral),
        tippy(circleButton("generateTooltip", "?", status = "info", size = "xs"), interactive = TRUE, trigger="click", theme = 'light', tooltip = v$info_tooltip)
      )
    })
    outputOptions(output, "outgenerateDB", suspendWhenHidden=FALSE)

    observeEvent(input$language, {
      v$language_selected <- input$language
      v$words_to_search <- c() # Reset words to search on language change
      v$grammatical_choices <- c(default_none)
      v$gram_selected = default_none # Reset gram class on language change

      load_language(input$language)
      if (input$language == default_other) {
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
          v$grammatical_choices <- c(default_none, unique(dictionary_databases[["Lexique383"]][['dstable']][['cgram']]))
        }else {
          # Hide grammatical class selection if previously shown
          if (v$gram_class_is_shown){
            toggle("outgram_class", anim = TRUE, animType = "slide")
            v$gram_class_is_shown=FALSE
          }
        }
        # Create database information tooltip
        info_tooltip = paste("<span",tooltip_style,">Words will be selected from the <b>", v$datasets[1], "</b> database.")
        info_tooltip = paste(info_tooltip, "<div><p>",
              str_replace_all(dictionary_databases[[v$datasets[1]]][["dsdesc"]],"'","&#39"), "", sep = "")
        if (!is.null(dictionary_databases[[v$datasets[1]]][["dsweb"]])
            && RCurl::url.exists(dictionary_databases[[v$datasets[1]]][["dsweb"]])){
          info_tooltip = paste(info_tooltip, "</p><p><a href=",
          dictionary_databases[[v$datasets[1]]][["dsweb"]],
          " target='_blank'>Website</a></p></div></span>",sep = "")
        }
        # Update tooltip in reactive values and enable generation
        v$info_tooltip = info_tooltip
        enable("generateDB")
        show("generateTooltip")

        # Update filters
        for (filter in filtersList){
          new_val = default_filter_option
          for (preset in filter[["preset"]]){
            if (input$language %in% filter[["preset"]][["languages"]]){
              new_val = filter[["preset"]][["value"]]
              break
            }
          }
          updatePickerInput(session, filter[["name"]], selected=new_val)
        }
      }
    })

    # Select grammatical class (french only)

    output$outgram_class <- renderUI({
      pickerInput(inputId = "gram_class",
                  label = grammatical_class_label,
                  choices = v$grammatical_choices,
                  selected = v$gram_selected,
                  multiple = FALSE,
                  options = pickerOptions(
                    dropupAuto = FALSE
                  ))
    })

    #### Generate words from database ####

    observeEvent(input$generateDB, {
      longueur = as.numeric(input$longueur)
      if (v$language_selected != default_other){
        words <- get_dataset_words(
          datasets=v$datasets,
          nbchar=longueur,
          gram_class=input$gram_class
        )
      }else {
        words <- c()
      }
      wordsok <- words[nchar(words) == longueur]
      wordsok <- tolower(wordsok) # to avoid case-sensitive
      wordsok <- wordsok[!duplicated(wordsok)]
      wordsok <- as.character(wordsok)
      v$words_to_search <- paste(wordsok, collapse="\n")
      updateTextAreaInput(session, "mots", value = v$words_to_search)
    })

    output$oMots <- renderUI({
      div(
      h5(tags$b(paste_words), tippy(circleButton("oMotsTooltip", "?", status = "info", size = "xs"), interactive = TRUE, trigger="click", theme = 'light', tooltip = input_mots_tooltip)),
      helpText(paste0("Please separate your words with a line break.")),
      textAreaInput("mots",
                  label = NULL,
                  rows = 10, value = v$words_to_search, resize = "none")
                )
    })

    #### Handle filters ####
    output$oShowFilters <- renderUI({
      div(
        actionButton("btnFilter", v$button_filter),
        tippy(circleButton("oFiltersTooltip", "?", status="info", size="xs"), interactive=TRUE, trigger="click", theme="light", tooltip = input_filter_tooltip)
      )
    })

    observeEvent(input$btnFilter, {
      if (grepl(btn_show_filter, v$button_filter)){
        v$button_filter = btn_hide_filter
      }else{
        v$button_filter = btn_show_filter
      }
    })

    observe({
      shinyjs::toggle("filter_box", anim = TRUE, animType = "slide", condition = grepl(btn_hide_filter, v$button_filter))
    })

    #### Handle number of pseudowords ####
    output$oNbpseudos <- renderUI({
      div(
        h5(number_choice, tippy(circleButton("oNbPseudosTooltip", "?", status = "info", size = "xs"), interactive = TRUE, trigger="click", theme = 'light', tooltip = nb_pseudos_tooltip
      )),
      helpText(paste0("Please enter a number between ", min_nbpseudos, " and ", max_nbpseudos, ".")),
        numericInput("nbpseudos",
            label = NULL,
            value = default_nbpseudos,
            min = min_nbpseudos,
            max = max_nbpseudos,
            width = "100%")
      )
    })

    #### len grams ####

    observeEvent(input$longueur, {
      if (input$longueur == 3){
        v$len_gram = algo_choices[1]
        updatePickerInput(session, "lenGram", selected = v$len_gram, choices = algo_choices[1])
      }
      else{
        if (input$longueur == 4 || input$longueur == 5){
          v$len_gram = algo_choices[1]
        }else{
          v$len_gram = algo_choices[2]
        }
        updatePickerInput(session, "lenGram", selected = v$len_gram, choices = algo_choices)
      }
    })

    output$olenGram <- renderUI({
      div(
        h5(lenGram_choice, tippy(circleButton("lenGramTooltip", "?", status = "info", size = "xs"), interactive = TRUE, trigger="click", theme = 'light', tooltip = lenGram_tooltip)),
        pickerInput(inputId = "lenGram",
                    choices = algo_choices,
                    selected = v$len_gram,
                    width = "100%",
                    options = pickerOptions(
                      dropupAuto = FALSE
                    )
                  )
      )
    })

    #### show pseudowords ####

    pseudowords <- eventReactive(input$go,
    {
       # Handle number of pseudowords lower than min_nbpseudos or higher than max_nbpseudos (numericInput does not fully handle it by itself : entering unallowed value directly by hand is... allowed)
       if(input$nbpseudos < min_nbpseudos || input$nbpseudos > max_nbpseudos){
           shinyalert("Error", paste0("Please enter a ", number_choice_raw, " between ", min_nbpseudos, " and ", max_nbpseudos, "."))
           NULL # return NULL for observeEvent pseudowords, to avoid null datatable
       }else{
           nbpseudos = as.numeric(input$nbpseudos)
           longueur = as.numeric(input$longueur)
           algo = input$lenGram
           words <- strsplit(input$mots,"[\n]")[[1]]
           wordsok <- words[nchar(words) == longueur]
           wordsok <- tolower(wordsok) # to avoid case-sensitive
           wordsok <- wordsok[!duplicated(wordsok)] # remove duplicate models
           wordsok <- as.character(wordsok)
           v$len_wordsok <- length(wordsok)
           if (v$language_selected != default_other){
             exclude <- get_dataset_words(
               datasets=v$datasets,
               nbchar=longueur
             )
           }else{
             exclude <- NULL
           }
           generate_pseudowords(
             n=nbpseudos,
             len=longueur,
             models=wordsok,
             len_grams=algo,
             language=v$language_selected,
             input=input,
             exclude = exclude)
       }
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
                   ))
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
                               scrollX=TRUE,
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
              getDate(input$currentTZ),
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
          paste("Pseudowords-details-query-",
                getDate(input$currentTZ),
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
