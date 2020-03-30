# shiny R code for lexique.org
# Time-stamp: <2019-06-04 21:51:05 christophe@pallier.org>

#### Functions ####
source('www/functions/loadPackages.R')
source('www/functions/customCheckboxGroup.R')
source('www/functions/getMandatory.R')
source('www/functions/customDropdownButton.R')

#### Script begins ####

# loads datasets
#source('https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/fetch_datasets.R')
source('../../datasets-info/fetch_datasets.R')

source('www/data/loadingDatasets.R')
source('www/data/uiElements.R')

#### UI ####
ui <- fluidPage(
  tags$head(tags$style(HTML('
  #tree-search-input{
    border-bottom-left-radius:0px;
    border-bottom-right-radius:0px;
    }'))),
    useShinyjs(),
    titlePanel(tags$a(href="http://chrplr.github.io/openlexicon/", "Open Lexicon")),
    title = "Open Lexicon",
    sidebarLayout(
        sidebarPanel(
                        helper_alert,
                        uiOutput("outbtnlistsearch"),
                        br(),
                        hidden(textAreaInput("mots",
                                             label = h5(strong("Words to search")),
                                             rows = 10,
                                             resize = "none")),
                        uiOutput("outlang"),
                        uiOutput("consigne"),
                        uiOutput("shinyTreeTest"),
                        br(),
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
                       DTOutput(outputId="table") %>% withSpinner(type=3, color.background="#ffffff")),
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
                      col_tooltips = list(),
                      button_listsearch = btn_show_name,
                      prefix_col = prefix_single,
                      suffix_col = suffix_single,
                      labeldropdown = "",
                      needTreeRender = TRUE)
  
  #### Render column filter ####

  output$consigne <- renderUI({
    if (length(input$databases) > 0){
      h5(strong("Choose columns to display"))
    }
  })
  
  output$shinyTreeTest <- renderUI({
    if (length(input$databases) > 0){
      dropdownButton2(
        textAreaInput("tree-search-input", label = NULL, placeholder = "Type to filter", resize = "none"),
        shinyTree("tree",
                  checkbox = TRUE,
                  search = "tree-search-input",
                  themeIcons = FALSE,
                  themeDots = FALSE,
                  theme = "proton"),
        width ="100%", label = v$labeldropdown, status = "default"
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
  
  #### Toggle list search ####
  
  output$outbtnlistsearch <- renderUI({
    actionButton("btn", v$button_listsearch)
  })
  
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
  
  #### Select a language ####
  
  output$outlang <- renderUI({
    selectInput("language", "Choose a language",
                choices = c('\n','French', 'English', 'Multiple languages'),
                selected = v$language_selected)
  })
  
  #### Show databases filter ####
  
  # Update categories
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

  # Show filter
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
          " >Website</a></p></div>",sep = "")
        }
        tooltips <- list.append(tooltips, tippy(bsButton(paste("pB",i,sep=""), "?", style = "info", size = "extra-small"),
                                                interactive = TRUE,
                                                tooltip = info_tooltip))
      }
      extendedCheckboxGroup("databases", label = "Choose datasets",
                            choiceNames  = v$categories,
                            choiceValues = v$categories,
                            selected = v$first_dataset_selected, 
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
  
  observeEvent(input$databases, {
    selected_columns <- list()
    col_tooltips <- list()
    v$needTreeRender <- TRUE
    if (length(input$databases) > 0) {
      if (length(input$databases) == 1){
        v$prefix_col = prefix_single
        v$suffix_col = suffix_single
      }else{
        v$prefix_col = prefix_multiple
        v$suffix_col = suffix_multiple
      }
    }
    for (i in 1:length(input$databases)){
      if (input$databases[i] %in% v$selected_columns){
        selected_columns[[input$databases[i]]] <- v$selected_columns[[input$databases[i]]]
        for (elt in names(selected_columns[[input$databases[i]]])){
          col_tooltips[[selected_columns[[input$databases[i]]][[elt]]]] <- dictionary_databases[[input$databases[[i]]]][["colnames_dataset"]][[elt]]
        }
      }
      else{
        selected_columns[[input$databases[i]]] <- list()
        for (j in names(dictionary_databases[[input$databases[i]]][['colnames_dataset']])) {
          original_name = j
          if (original_name %in% dictionary_databases[[input$databases[i]]][["dsmandcol"]]){
            if (length(input$databases) > 1){
              new_name <- paste0(v$prefix_col, input$databases[i],v$suffix_col, original_name)
            }
            else {
              new_name <- original_name
            }
            selected_columns[[input$databases[i]]][[original_name]] <- new_name
            col_tooltips[[new_name]] <- dictionary_databases[[input$databases[[i]]]][["colnames_dataset"]][[original_name]]
          }
        }
      }
    }
    v$selected_columns <- selected_columns
    v$col_tooltips <- col_tooltips
  })
  
  # Update selected_columns when input tree is changed
  
  observeEvent(input$tree, {
    selected_columns <- list()
    col_tooltips <- list()
    for (x in (get_selected(input$tree, format = "names"))){
      if (length(attr(x, "ancestry")) > 0){
        if (!(attr(x, "ancestry") %in% names(selected_columns))){
         selected_columns[[attr(x, "ancestry")]] <- list()
        }
        if (length(input$databases) > 1){
          new_name <- paste0(v$prefix_col, attr(x, "ancestry"),v$suffix_col, x)
        }
        else {
          new_name <- x
        }
        selected_columns[[attr(x, "ancestry")]][[x]] <- new_name
        col_tooltips[[new_name]] <- dictionary_databases[[attr(x, "ancestry")]][["colnames_dataset"]][[x]]
      }
    }
    v$selected_columns <- selected_columns
    v$col_tooltips <- col_tooltips
  })
  
  #### Create table ####
  
  # Update column names
  
  datasetInput <- reactive({
    list_df <- list()
    
    for (database in names(v$selected_columns)){
      dat <- dictionary_databases[[database]][["dstable"]]
      for (col in names(v$selected_columns[[database]])){
        colnames(dat)[colnames(dat)==col] <- v$selected_columns[[database]][[col]]
        
      }
      list_df <- list.append(list_df,dat)
    }
    if (v$button_listsearch == btn_hide_name && length(mots2()) > 0){
      Reduce(function(x,y) merge(x, y, by=join_column, all.x = TRUE), list_df)
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
    if (v$button_listsearch == btn_hide_name && length(mots2()) > 0){
      to_return[datasetInput()[[join_column]] %in% mots2(), ]
    }else{
      to_return
    }
  })
  
  # Render table
  output$table <- renderDT({
                  if (length(input$databases) > 0
                      && length(names(v$selected_columns)) > 0){
                    dat <- retable()
                  
                    # Adding tooltips for column names
                    col_tooltips <- c()
                    for (elt in colnames(retable())){
                      col_tooltips <- c(col_tooltips, v$col_tooltips[[elt]])
                    }
                    headerCallback <- c(
                      "function(thead, data, start, end, display){",
                      sprintf("  var tooltips = [%s];", toString(paste0("\"", col_tooltips, "\""))),
                      "  for(var i = 1; i <= tooltips.length; i++){",
                      "    $('th:eq('+i+')',thead).attr('title', tooltips[i-1].replace(`'`,`\'`));",
                      "  }",
                      "}"
                    )
                    
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
                           ))}
  }, server = TRUE)
  
  #### Download options ####
  
  output$outdownload <- renderUI({
    if (length(input$databases) > 0
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
      names(dt) = c(join_column,
                    to_vec(for (database in (names(v$selected_columns)))
                      for (col in names(v$selected_columns[[database]]))
                        paste(database, col, sep = " \n")))
      write_xlsx(dt, fname)
    })
}
  
#options(warn = 2, shiny.error = recover)
shinyApp(ui, server)
