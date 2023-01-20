# shiny R code for generate pseudowords <www.lexique.org>
# Authors: Boris New, C. Pallier & J. Bourgin
# Time-stamp: <2020-10-21 17:08:14 jessica.bourgin@univ-smb.fr>

#### Functions ####
rm(list = ls())
source('www/functions/loadPackages.R')
source('www/functions/qTips.R')
source('www/functions/customDropdownButton.R')
source('www/functions/updateFromTree.R')
source('www/functions/customCheckboxGroup.R')
source('www/functions/swapFunctions.R')

# Loading datasets and UI
source('../../datasets-info/fetch_datasets.R')
source('www/data/loadingDatasets.R')

source('www/data/uiElements.R')

js <- "
$(document).on('shiny:busy', function(event) {
  // we need to define inputs each time function is called because on first call not all elements are present on page, so inputs variable would not contain all elements
  var $inputs = $('button,input,textarea,dropdown');
  $inputs.prop('disabled', true);
});

// Enable back interface when shiny is idle.
$(document).on('shiny:idle', function() {
  var $inputs = $('button,input,textarea,dropdown');
  $inputs.prop('disabled', false);
});
"

#### Script begins ####
ui <- fluidPage(
    tags$head(
      # Qtips
      tags$link(rel = "stylesheet", type = "text/css", href = "functions/jquery.qtip.css"),
      tags$script(HTML(js)),
      tags$script(type = "text/javascript", src = "functions/jquery.qtip.js"),
      tags$link(rel = "stylesheet", type = "text/css", href = "styles/main.css"),
    ),

  useShinyjs(),
  useShinyalert(),

  titlePanel(tags$a(href="http://chrplr.github.io/openlexicon/", "Lexique Infra 1.11")),
  title = "Lexique Infra 1.11",

  sidebarLayout(
    sidebarPanel(
      id="sidebarPanel",
      uiOutput("helper_alert"),
      br(),
      helper_alert,
      br(),
      div(textAreaInput("mots",
                  label = tags$b(paste_words),
                  rows = 10, resize = "none")),
      uiOutput("consigne"),
      uiOutput("shinyTreeCol"),
      br(),
      uiOutput("outOptions"),
      div(style="text-align:center;",actionButton("go", go_btn)),
      width=3
    ),
  mainPanel(
      id="mainPanel",
      fluidRow(tags$style(HTML("
                      thead:first-child > tr:first-child > th {
                          border-top: 0;
                          font-size: normal;
                          font-weight: bold;
                      }
                  ")),
                 br(),
                 DTOutput(outputId="infra") %>% withSpinner(type=3,
                            color.background="#ffffff",
                            hide.element.when.recalculating = FALSE,
                            proxy.height = 0),
        uiOutput("outdownload"),
        br()
      ),
      width=9)
    )
)

server <- function(input, output, session) {
  v <- reactiveValues(
    button_helperalert = btn_hide_helper,
    cols = initialCols,
    selected_columns = initialSelectedCols,
    go_clicked = FALSE,
    optionsSelected = c())

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
      shinyjs::toggle("helper_box", anim = TRUE, animType = "slide", condition = grepl(btn_hide_helper, v$button_helperalert))
    })

    #### Generate word list ####

    words_list <- eventReactive(input$go,
    {
        ## Add/remove hamming distance element in selected columns if needed. We do it there since we need to add it only if user clicks the go button and chose this option (we assume they want the column displayed in this case) and if we update selected_columns value in renderDT, it leads to a circular phenomenon.
        if (hamming_distance_opt %in% input$optionsGroup){
          addToSelectedColumns(v, nb_hamming_distance, hamming_position)
          addToSelectedColumns(v, hamming_distance_opt, hamming_position+1)
        }else if (!(hamming_distance_opt %in% input$optionsGroup)){
          removeFromSelectedColumns(v, hamming_distance_opt)
          removeFromSelectedColumns(v, nb_hamming_distance)
        }
        if (v$go_clicked == FALSE){
          v$go_clicked = TRUE
        }
        v$optionsSelected <- input$optionsGroup
        words <- strsplit(input$mots,"[ \n\t]")[[1]]
        # Keep only words with at least one character (removes empty rows)
        words <- str_subset(words, ".+")
        wordsok <- unique(words[!grepl("[[:punct:][:space:]]", words)]) # remove words with punctuation or space, and duplicates. Words with space (such as a priori) are not included in 'Lexique-Infra-word_frequency'
        })

    #### Column filter ####

    output$consigne <- renderUI({
      if (v$go_clicked == TRUE){
        h5(strong("Choose columns to display"))
      }
    })

    output$shinyTreeCol <- renderUI({
      if (v$go_clicked == TRUE){
        dropdownButton2(
          textAreaInput("tree-search-input", label = NULL, placeholder = "Type to filter", resize = "none"),
          shinyTree("tree",
                    checkbox = TRUE,
                    search = "tree-search-input",
                    themeIcons = FALSE,
                    themeDots = FALSE,
                    theme = "proton"),
          width ="100%", label = textOutput("dropdownlabel"), status = "default"
        )
      }
    })

    output$dropdownlabel <- renderText({
      paste(length(v$selected_columns), "columns out of ", length(v$cols), " selected")
    })

    output$tree <- renderTree({
      finaltree <- list()
      starting = 1

      for (col in v$cols){
          finaltree[[col]] = toString(starting)
          starting = starting + 1
          if (col %in% v$selected_columns){
            attr(finaltree[[col]],"stselected")=TRUE
          }
      }

      finaltree
    })

    observeEvent(input$tree, {
      v$selected_columns <- updateColFromTree(input$tree, dictionary_databases)
    })

    #### Computation options ####

    output$outOptions <- renderUI({
      tooltips <- list()
      tooltipContent <- c(hamming_tooltip)
      optionList <- c(hamming_distance_opt)
      for (i in 1:length(optionList)){
        tooltips <- list.append(tooltips,
        tippy(bsButton(paste("pB",i,sep=""), "?", style = "info", size = "extra-small"),
                  interactive = TRUE,
                  trigger="click",
                  theme = 'light',
                  tooltip = tooltipContent[i]))
      }
      div(
        h5(tags$b("Options"), id="optionsTitle"),
        extendedCheckboxGroup("optionsGroup", label = "",
                              choiceNames  = optionList,
                              choiceValues = optionList,
                              extensions = tooltips
                              )
        )
    })


    #### Handle go btn ####

    observeEvent(input$mots, {
      if (trimws(input$mots) == ""){
        shinyjs::disable("go")
      }else{
        shinyjs::enable("go")
      }
    })

    #### Table ####

    retable <- reactive({
        words_list <- words_list()
        if (!is.null(words_list)){
            final_dt <- data.frame()
            inc_count = 0

            # Get words
            withProgress(message = "Building table", value = 0, {
            for (word in words_list){
                inc_count = inc_count + 1
                incProgress(1/length(words_list), detail = paste0("Word ", inc_count, "/", length(words_list)))
                word <- tolower(word)
                # If elt is word, we get it in the word_frequency dt
                if (is.element(word,unlist(whole_dt[[join_column]]))){
                    new_line <- subset(whole_dt, Word == word)
                    new_line[[type_column]] <- "Word"
                    is_word <- TRUE
                # else we calculate its values
                }else{
                    is_word <- FALSE
                    dic_info <- list()
                    # Dic values
                    for (type in types_list){
                        dic_info[[type]] <- list()
                        for (subtype in subtypes_list){
                            dic_info[[type]][[subtype]] <- list()
                            dic_info[[type]][[subtype]][["sum"]] <- 0.0
                            dic_info[[type]][[subtype]][["decomp"]] <- ""
                        }
                    }

                    count <- 0
                    for (type in types_list){
                        for (num_elt in 1:(nchar(word) -count)){
                            ok_pseudoword <- TRUE
                            current_line <- subset(dt_info[[type]], Word == substring(word, num_elt, num_elt+count))
                            # If part of the pseudoword is not found in the table, we will add a 0 instead of info for this part
                            if (NROW(current_line) == 0){
                                ok_pseudoword <- FALSE
                            }
                            # Initial, middle or final position
                            if (num_elt == 1){
                                spec = "I"
                                separator = ""
                            }else if(num_elt==(nchar(word)-count)){
                                spec="F"
                                separator = "-"
                            }else{
                                spec="M"
                                separator = "-"
                            }
                            # Get info in dictionary
                            for (subtype in subtypes_list){
                                if (ok_pseudoword){
                                    new_sum_info <- as.double(current_line[[paste(type,subtype,spec,sep="")]])
                                    new_decomp_info <- as.character(current_line[[paste(type,subtype,spec,sep="")]])
                                }else{
                                    new_sum_info <- 0
                                    new_decomp_info <- 0
                                }
                                dic_info[[type]][[subtype]][["sum"]] <- dic_info[[type]][[subtype]][["sum"]] + new_sum_info

                                dic_info[[type]][[subtype]][["decomp"]] <- paste(dic_info[[type]][[subtype]][["decomp"]], new_decomp_info, sep=separator)
                            }
                        }
                        count = count+1
                    }
                    # Line creation
                    new_line <- data.frame()
                    new_line[1,1] <- word
                    new_line[1,2] <- "Pseudoword"
                    for (i in 3:6){
                        new_line[1,i] <- ""
                    }
                    count <- 0
                    count_col <- 7
                    for (type in types_list){
                        for (subtype in subtypes_list){
                            new_line[1,count_col] <- dic_info[[type]][[subtype]][["decomp"]]
                            new_line[1,count_col+1] <-dic_info[[type]][[subtype]][["sum"]]/(nchar(word)-count)
                            count_col <- count_col +2
                        }
                        count <- count +1
                    }
                    for (i in 19:34){
                        new_line[1,i] <- ""
                    }
                }
                colnames(new_line) <- colnames(whole_dt)
                # Disabled by default because slow. WARNING : since retable is reactive, using input$optionsGroup here and checking/unchecking hamming distance would directly update the table if there was already one drawn. So we use an intermediate variable v$optionsSelected that we update when pushing go button.
                if (hamming_distance_opt %in% v$optionsSelected){
                  distance <- vwr::hamming.distance(word, dictionary_databases[['Lexique383']][['dstable']][dictionary_databases[['Lexique383']][['dstable']][["nblettres"]] == nchar(word),][['Word']])
                  neighbors = names(distance[distance==1])
                  new_line <- populateEachRow(new_line, length(neighbors), nb_hamming_distance, hamming_position)
                  new_line <- populateEachRow(new_line, paste(neighbors, collapse=","), hamming_distance_opt, hamming_position+1)
                }
                final_dt <- rbind(final_dt, new_line)
            }
            })

            final_dt
            }
        })

    output$infra = renderDT({
        if (!is.null(words_list())){
            # We do this retable step independently from column filter below, to avoid recall of retable every time we filter columns
            dat <- retable()

            # Rename word column
            if (nrow(dat) > 0){
              colnames(dat)[colnames(dat) == join_column] <- join_column_alt
              v$cols <- colnames(dat)[colnames(dat) != join_column_alt]

              # return datatable
              dat <- dat[,c(join_column_alt, to_vec(for (col in names(v$selected_columns)) v$selected_columns[[col]])), drop=FALSE]

              # adding tooltips for column names
              col_tooltips <- c()

              for (elt in colnames(dat)){
                col_tooltips <- c(col_tooltips, initialColTooltips[[elt]])
              }

              headerCallback <- c(
                "function(thead, data, start, end, display){",
                qTips(col_tooltips),
                "  for(var i = 1; i <= tooltips.length; i++){",
                "if(tooltips[i-1]['content']['text'].length > 0){",
                "      $('th:eq('+i+')',thead).qtip(tooltips[i-1]);",
                "    }",
                "  }",
                "}"
              )

              datatable(dat,
                        escape = FALSE, selection = 'none',
                        filter=list(position = 'top', clear = FALSE),
                        rownames= FALSE, #extensions = 'Buttons',
                        width = 200,
                        options=list(headerCallback = JS(headerCallback),
                                     pageLength=20,
                                     scrollX=TRUE,
                                     columnDefs = list(list(className = 'dt-center', targets = "_all")),
                                     sDom  = '<"top">lrt<"bottom">ip',
                                     lengthMenu = c(20,100, 500, 1000),
                                     search=list(searching = TRUE,
                                                 regex=TRUE,
                                                 caseInsensitive = FALSE)
                         ))
            }
        }
    }, server = TRUE)

    #### Download options ####

    output$outdownload <- renderUI({
        if (!is.null(words_list()) && nrow(retable()) > 0){
            downloadButton('download.xlsx', label="Download infra query")
        }
    })

    output$download.xlsx <- downloadHandler(
      filename = function() {
        paste("Infra-query-",
              format(Sys.time(), "%Y-%m-%d"), ' ',
              paste(hour(Sys.time()), minute(Sys.time()), second(Sys.time()), sep = "-"),
              ".xlsx", sep="")
      },
      content = function(fname) {
        dat <- retable()[input[["infra_rows_all"]], ]
        colnames(dat)[colnames(dat) == join_column] <- join_column_alt

        # return datatable
        dat <- dat[,c(join_column_alt, to_vec(for (col in names(v$selected_columns)) v$selected_columns[[col]])), drop=FALSE]
        write_xlsx(dat, fname)
      })
}

shinyApp(ui, server)
