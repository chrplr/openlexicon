# shiny R code for lexique.org
# Time-stamp: <2019-06-04 21:51:05 christophe@pallier.org>

#### Functions ####
rm(list = ls())
source('www/functions/loadPackages.R')
source('www/functions/customCheckboxGroup.R')
source('www/functions/getMandatory.R')
source('www/functions/customDropdownButton.R')
source('www/functions/qTips.R')
source('www/functions/updateFromTree.R')
source('www/functions/updateFromDB.R')

#### Script begins ####

# loads datasets
#source('https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/fetch_datasets.R')
source('../../datasets-info/fetch_datasets.R')

source('www/data/loadingDatasets.R')
source('www/data/uiElements.R')

js <- "
$(document).on('shiny:busy', function(event) {
  // we need to define inputs each time function is called because on first call not all elements are present on page, so inputs variable would not contain all elements
  // we do not disable textarea (words list search) since database is updated constantly when entering words in this area (so we lose focus all the time)
  var $inputs = $('button,input,dropdown');
  var $buttons = $('.dropdown.bootstrap-select.form-control');
  $buttons.each(function(){
    $(this).removeClass('open');
  })
  $inputs.prop('disabled', true);
});

// Enable back interface when shiny is idle.
$(document).on('shiny:idle', function() {
  var $inputs = $('button,input,dropdown');
  $inputs.prop('disabled', false);
});
"

#### UI ####
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
  tags$link(rel = "stylesheet", type = "text/css", href = "functions/jquery.qtip.css"),
  tags$script(type = "text/javascript", src = "functions/jquery.qtip.js"),

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles/main.css"),
    tags$script(HTML(js)),
  tags$style(HTML('
  #tree-search-input{
    border-bottom-left-radius:0px;
    border-bottom-right-radius:0px;
    }'))),

    useShinyjs(),
    useShinyalert(),

    titlePanel(tags$a(href="http://chrplr.github.io/openlexicon/", "Open Lexicon")),
    title = "Open Lexicon",

    sidebarLayout(
        sidebarPanel(
                        id="sidebarPanel",
                        uiOutput("helper_alert"),
                        br(),
                        helper_alert,
                        uiOutput("outlang"),
                        uiOutput("outbtnlistsearch"),
                        br(),
                        hidden(
                        div(
                          id="divMots",
                          h5(strong("Words to search")),
                          helpText(paste0("Please separate your words with a line break.")),
                          textAreaInput("mots",
                                 label = NULL,
                                 rows = 10,
                                 resize = "none")
                        )),
                        uiOutput("consigne"),
                        uiOutput("shinyTreeTest"),
                        br(),
                        uiOutput("outdatabases"),
                        br(),
           width=3#, style = "position:fixed;width:inherit;"
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
                 DTOutput(outputId="table") %>% withSpinner(type=3,
                                                            color.background="#ffffff",
                                                            hide.element.when.recalculating = FALSE,
                                                            proxy.height = 0)),
              uiOutput("outdownload"),
              width=9
            )
        )
    )

#### Server ####
server <- function(input, output, session) {
  v <- reactiveValues(language_selected = default_language,
                      categories = names(list.filter(dslanguage, tolower(default_language) %in% tolower(name))),
                      dataset_selected = c(default_db),
                      selected_columns = list(),
                      col_tooltips = list(),
                      button_listsearch = btn_show_name,
                      button_helperalert = btn_hide_helper,
                      prefix_col = prefix_single,
                      suffix_col = suffix_single,
                      labeldropdown = "",
                      needTreeRender = FALSE,
                      change_language = FALSE,
                      total_col = 0,
                      my_tables = list()) # each subject has a specific list for his specific session (avoid share because we need to empty dictionary when we update dataset selection, which is not very compatible with sessionshare)

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

  #### Render column filter ####

  output$consigne <- renderUI({
    if (length(input$databases) >= 1){
      h5(strong("Choose columns to display"))
    }
  })

  output$shinyTreeTest <- renderUI({
    if (length(input$databases) >= 1){
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

  output$tree <- renderTree({
    if (v$needTreeRender == TRUE){
      finaltree <- list()
      starting = 1

      for (database in names(v$selected_columns)){
        finaltree[[database]] <- list()

        for (col in names(dictionary_databases[[database]][["colnames_dataset"]])){
          finaltree[[database]][[col]] = toString(starting)
          starting = starting + 1

          if (col %in% names(v$selected_columns[[database]])){
            attr(finaltree[[database]][[col]],"stselected")=TRUE # <---
          }
        }
      }

      v$needTreeRender <- FALSE
      finaltree
    }
  })

  output$dropdownlabel <- renderText({
    if (!(length(input$databases) >= 1)
        || !(length(names(v$selected_columns)) > 0)){
      v$labeldropdown <- "Nothing selected"
    }else{
      if (length(v$col_tooltips) <= 3){
        v$labeldropdown <- paste(colnames(retable())[2:length(colnames(retable()))], collapse = ", ")
      }
      else{
        v$labeldropdown <- paste(length(v$col_tooltips), "columns out of ", v$total_col, " selected")
      }
    }
    v$labeldropdown })

  #### Toggle list search ####

  output$outbtnlistsearch <- renderUI({
    if (v$language_selected != "\n") {
      actionButton("btn_listsearch", v$button_listsearch)
    }else if (grepl(btn_hide_name, v$button_listsearch)){
      v$button_listsearch = btn_show_name
    }
  })

  observeEvent(input$btn_listsearch, {
    if (grepl(btn_show_name, v$button_listsearch)){
      v$button_listsearch = btn_hide_name
    }else{
      v$button_listsearch = btn_show_name
    }
  })

  observe({
    shinyjs::toggle("divMots", anim = TRUE, animType = "slide", condition = grepl(btn_hide_name, v$button_listsearch))
  })

  # Transform list search input
  mots2 <- reactive( {
    current_words <- input$mots
    expressions <- stri_extract_all_regex(current_words, '"[^"]*"')[[1]]
    expressions <- expressions[!is.na(expressions)]
    if (length(expressions) > 0){
      for (expression_num in 1:length(expressions)){
        expression <- expressions[expression_num]
        current_words <- str_remove_all(current_words, expression)
        expressions[expression_num] <- str_remove_all(expression, "\"")
      }
      c(expressions, strsplit(current_words,"[\n]")[[1]])
    }else{
      strsplit(current_words,"[\n]")[[1]]
    }
    } )

  #### Select a language ####

  output$outlang <- renderUI({
    div(
      h5(tags$b("Choose a language")),
      pickerInput(inputId = "language",
                choices = language_choices,
                selected = v$language_selected,
                options = pickerOptions(
                  dropupAuto = FALSE
                )
              )
      )
  })

  #### Show databases filter ####

  # Update categories based on language selection

  observeEvent(input$language, {
    v$language_selected <- input$language
    v$change_language <- TRUE

    if (input$language == "\n") {
      v$categories <- c()
      v$dataset_selected <- ""
    }
    else {
      v$categories <- names(list.filter(dslanguage, tolower(input$language) %in% tolower(name)))
      v$dataset_selected <- v$categories[[1]]
    }

  })

  # Show databases checkbox group

  output$outdatabases <- renderUI({
    if (v$language_selected != "\n") {
      tooltips = list()

      for (i in 1:length(v$categories)) {
        info_tooltip = paste("<span style='font-size:14px;'>", "<div><p>",
              str_replace_all(dictionary_databases[[v$categories[i]]][["dsdesc"]],"'","&#39"), "<span>", sep = "")

        if (!is.null(dictionary_databases[[v$categories[i]]][["dsweb"]])
            && RCurl::url.exists(dictionary_databases[[v$categories[i]]][["dsweb"]])){
          info_tooltip = paste(info_tooltip, "</p><p><a href=",
          dictionary_databases[[v$categories[i]]][["dsweb"]],
          " target='_blank'>Website</a></p></div>",sep = "")
        }

        tooltips <- list.append(tooltips, tippy(bsButton(paste("pB",i,sep=""), "?", style = "info", size = "extra-small"),
                                                interactive = TRUE,
                                                theme = 'light',
                                                tooltip = info_tooltip))
      }

      extendedCheckboxGroup("databases", label = "",
                            choiceNames  = to_list(for (x in v$categories) tags$span(x, style = "color: black;")),
                            choiceValues = v$categories,
                            selected = v$dataset_selected,
                            extensions = tooltips
                            )
    }

    else {
      checkboxGroupInput("databases", "",
                         choices = c())
    }
  })

  #### Update column selection ####

  # Update selected_columns when input databases is changed

  observeEvent(input$databases, ignoreNULL = FALSE, {
    v$needTreeRender <- TRUE

    if (length(input$databases) == 1){
      v$prefix_col = prefix_single
      v$suffix_col = suffix_single
    }else if(length(input$databases) > 1){
      v$prefix_col = prefix_multiple
      v$suffix_col = suffix_multiple
    }

    v$my_tables <- load_tables(input$databases, v$my_tables)
    output <- updateFromDB(input$databases,
                           v$selected_columns,
                           dictionary_databases,
                           v$prefix_col,
                           v$suffix_col)

    v$selected_columns <- output[[1]]
    v$col_tooltips <- output[[2]]
    v$total_col <- output[[3]]
  })

  # Update selected_columns when input tree is changed

  observeEvent(input$tree, {
    output <- updateColFromTree(input$tree,
                                input$databases,
                                v$prefix_col,
                                v$suffix_col,
                                dictionary_databases)

    v$selected_columns <- output[[1]]
    v$col_tooltips <- output[[2]]
  })

  #### Create table ####

  # Update column names and rows selected

  datasetInput <- reactive({
    list_df <- list()
    not_loaded_db <- c()
    for (database in names(v$selected_columns)){
      dat <- v$my_tables[[database]]
      for (col in names(v$selected_columns[[database]])){
        colnames(dat)[colnames(dat)==col] <- v$selected_columns[[database]][[col]]

      }

      # if table for a given database could not be loaded, it is not included in the table displayed to user.
      if (!is.null(dat)){
        list_df <- list.append(list_df,dat)
      }else {
        not_loaded_db <- c(not_loaded_db, database)
      }
    }
    # Display warning message if some databases could not be loaded
    if (length(not_loaded_db) > 0){
      shinyalert("Warning", paste("Databases", paste(not_loaded_db, collapse = ', '), "could not be loaded. Check json and rds files."))
    }

    if (length(mots2()) > 0){
      if (grepl(btn_hide_name, v$button_listsearch)){
        Reduce(function(x,y) merge(x, y, by=join_column, all.x = TRUE), list_df)
      }else{
        Reduce(function(x,y) merge(x, y, by=join_column), list_df)
      }
    }else{
      Reduce(function(x,y) merge(x, y, by=join_column), list_df)
    }
  })

  # Update table

  retable <- reactive({
    to_return <- datasetInput()[,c(join_column,
                                      to_vec(for (database in (names(v$selected_columns)))
                                        for (col in names(v$selected_columns[[database]]))
                                          v$selected_columns[[database]][[col]])),
                                        drop=FALSE]

    if (length(mots2()) > 0){
      if (grepl(btn_hide_name, v$button_listsearch)){
        to_return[datasetInput()[[join_column]] %in% mots2(), ]
      }else{
        to_return
      }
      # to_return[grep(paste(mots2(), collapse = "|"), datasetInput()[[join_column]]), ] # Substring option
    }else{
      to_return
    }
  })

  # Render table

  output$table <- renderDT({
    if (length(input$databases) >= 1 && length(names(v$selected_columns)) > 0){
      dat <- retable()

      # Adding tooltips for column names
      col_tooltips <- c()

      for (elt in colnames(dat)){
        col_tooltips <- c(col_tooltips, v$col_tooltips[[elt]])
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
               rownames= FALSE,
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
  }, server = TRUE)

  #### Download options ####

  output$outdownload <- renderUI({
    if (length(input$databases) >= 1
        && length(names(v$selected_columns)) > 0)
    {
      downloadButton('download.xlsx', label="Download filtered data")
    }
  })

  output$download.xlsx <- downloadHandler(
    filename = function() {
      paste("Lexique-query-",
            format(Sys.time(), "%Y-%m-%d"), ' ',
            paste(hour(Sys.time()), minute(Sys.time()), second(Sys.time()), sep = "-"),
            ".xlsx", sep="")
    },
    content = function(fname){
      dt = retable()[input[["table_rows_all"]], ]
      if (length(input$databases) > 1){
        names(dt) = c(join_column,
                      to_vec(for (database in (names(v$selected_columns)))
                        for (col in names(v$selected_columns[[database]]))
                          paste(database, col, sep = " ")))
      }
      write_xlsx(dt, fname)
    })
}

#options(warn = 2, shiny.error = recover)
shinyApp(ui, server)
