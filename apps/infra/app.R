# shiny R code for generate pseudowords <www.lexique.org>
# Authors: Boris New, C. Pallier & J. Bourgin
# Time-stamp: <2020-10-21 17:08:14 jessica.bourgin@univ-smb.fr>

#### Functions ####
rm(list = ls())
source('www/functions/loadPackages.R')

# Loading datasets and UI
source('../../datasets-info/fetch_datasets.R')
source('www/data/loadingDatasets.R')

source('www/data/uiElements.R')

#### Script begins ####
ui <- fluidPage(
  useShinyjs(),
  useShinyalert(),

  titlePanel(tags$a(href="http://chrplr.github.io/openlexicon/", "Infra")),
  title = "Infra",

  sidebarLayout(
    sidebarPanel(
      uiOutput("helper_alert"),
      br(),
      helper_alert,
      br(),
      div(textAreaInput("mots",
                  label = tags$b(paste_words),
                  rows = 10, resize = "none")),
      div(style="text-align:center;",actionButton("go", go_btn)),
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
                 br(),
                 DTOutput(outputId="infra") %>% withSpinner(type=3,
                            color.background="#ffffff",
                            hide.element.when.recalculating = FALSE,
                            proxy.height = 0),
        uiOutput("outdownload")
      ))
    )
)

server <- function(input, output, session) {
  v <- reactiveValues(
    button_helperalert = btn_hide_helper)

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


    #### Tables ####

    output$infra = renderDT({
        if (length(input$mots) > 1){
            print(length(input$mots))
        dt <- dictionary_databases[['Lexique-Infra-bigrammes']][['dstable']]

        datatable(dt,
                  escape = FALSE, selection = 'none',
                  filter=list(position = 'top', clear = FALSE),
                  rownames= FALSE, #extensions = 'Buttons',
                  width = 200,
                  options=list(pageLength=20,
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
        downloadButton('download.xlsx', label="Download infra query")
    })

    output$download.xlsx <- downloadHandler(
      filename = function() {
        paste("Infra-query-",
              format(Sys.time(), "%Y-%m-%d"), ' ',
              paste(hour(Sys.time()), minute(Sys.time()), second(Sys.time()), sep = "-"),
              ".xlsx", sep="")
      },
      content = function(fname) {
        dt = dictionary_databases[['Lexique-Infra-bigrammes']][['dstable']]
        write_xlsx(dt, fname)
      })
}

shinyApp(ui, server)
