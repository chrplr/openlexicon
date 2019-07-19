# shiny R code for lexique.org
# Time-stamp: <2019-06-04 21:51:05 christophe@pallier.org>

library(shiny)
library(DT)
library(writexl)


# loads datasets
source(file.path('..', '..', 'datasets-info/fetch_datasets.R'))
dataset_ids <- c('SUBTLEX-US', 'Megalex-visual', 'Megalex-auditory', 'Lexique383', 'FrenchLexiconProject-words', 'WorldLex-French', 'WorldLex-English','Voisins','anagrammes')

datasets = list()
for (ds in dataset_ids)
{
    datasets[[ds]] <- fetch_dataset(ds, format='rds')
}

dsnames <- list()
dsdesc <- list()
dsreadme <- list()
dstable <- list()
dsweb <- list()

for (i in 1:length(datasets)) {
    name <- datasets[[i]]$name
    dsnames[[name]] <- name
    dsdesc[[name]] <- datasets[[i]]$description
    dsreadme[[name]] <- datasets[[i]]$readme
    dsweb[[name]] <- datasets[[i]]$website
    dstable[[name]] <- readRDS(datasets[[i]]$datatables[[1]])
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
                      tags$li("Select desired dataset below"),
                      tags$li("For each column in the table, you can:"),
                      tags$ul(
                               tags$li("Filter using intervals (e.g. 40...500) or", tags$a(class="alert-link", href="http://regextutorials.com/index.html", "regexes", target="_blank"), "."),
                               tags$li("sort, ascending or descending")
                           ),
                      tags$li("Download the result of your manipulations by clicking on the button below the table")
                  )
             #tags$hr(),
             #tags$p(tags$a(href="https://chrplr.github.io/openlexicon/datasets-info/", "More information about the datatasets"))
             )


ui <- fluidPage(
    titlePanel(tags$a(href="http://chrplr.github.io/openlexicon/", "OpenLexicon")),

    sidebarLayout(
        sidebarPanel(
           helper_alert,
            selectInput("dataset", "Choose a dataset:",
                        choices = names(datasets)),
                        width=4
                        ),
            mainPanel(
                h3(textOutput("caption", container = span)),
                tags$div(class="alert-info",
                         tags$p(textOutput(outputId="currentdesc")),
                         tags$p(uiOutput("readmelink")),
                         tags$p(uiOutput("website"))),
                fluidRow(DTOutput(outputId="table")),
                downloadButton(outputId='download', label="Download filtered data")
            )
        )
    )


server <- function(input, output) {
    datasetInput <- reactive({
        dstable[[input$dataset]]
    })

    output$caption <- renderText({
        input$dataset
    })

    output$currentdesc <- renderText({
      dsdesc[[input$dataset]]
      })
    
    output$website <- renderUI({
        url <- a("Website", href=dsweb[[input$dataset]], target="_blank")
      tagList("", url)
    })
    
    output$readmelink <- renderUI({
        url <- a("More info", href=dsreadme[[input$dataset]], target="_blank")
      tagList("", url)
      })

    output$table <- renderDT(datasetInput(),
                             server=TRUE, escape = TRUE, selection = 'none',
                             filter=list(position = 'top', clear = FALSE),
                             rownames= FALSE,
                             options=list(pageLength=20,
                                          sDom  = '<"top">lrt<"bottom">ip',
                                          lengthMenu = c(20, 100, 500, 1000),
                                          search=list(searching = TRUE, regex=TRUE, caseInsensitive = FALSE)
                                          )
                            )  
    output$download <- downloadHandler(
        filename = function() {
            paste("Lexique-query-", Sys.time(), ".xlsx", sep="")
        },
        content = function(fname){
            # write.csv(datasetInput(), fname)
            dt = datasetInput()[input[["table_rows_all"]], ]
            write_xlsx(dt, fname)        })
    #url  <- a("Help!", href="http://www.lexique.org/?page_id=166")
    #output$help = renderUI({ tagList("", url) })
}

shinyApp(ui, server)
