# shiny R code for lexique.org
# Time-stamp: <2019-04-30 13:57:17 christophe@pallier.org>

# source('../set-variables.R')

library(shiny)
library(DT)

# loads all datasets
source('../../datasets-info/fetch_datasets.R')
dataset_ids <- c('Lexique382', 'SUBTLEX-US')

datasets = list()
for (ds in dataset_ids)
{
    datasets[[ds]] <- fetch_dataset(ds, format='rds')
}

dsnames <- list()
dsdesc <- list()
dsreadme <- list()
dstable <- list()

for (i in 1:length(datasets)) {
    name <- datasets[[i]]$name
    dsnames[[name]] <- name
    dsdesc[[name]] <- datasets[[i]]$description
    dsreadme[[name]] <- datasets[[i]]$readme
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
             tags$p("Crash course:"),
             tags$ul(
                      tags$li("Select desired dataset below"),
                      tags$li("For each column in the table, you can:"),
                      tags$ul(
                               tags$li("Filter using intervals (e.g. 40...500) or", tags$a(class="alert-link", href="http://regextutorials.com/index.html", "regexes"), "."),
                               tags$li("sort, ascending or descending")
                           ),
                      tags$li("Download the result of your manipulations by clicking on the button below the table")
                  )
             )


ui <- fluidPage(
    titlePanel("OpenLexicon"),

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
                         tags$p(tags$a(href=textOutput(outputId="currentreadme"), "More info"))),
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
    output$currentreadme <- renderText({
      dsreadme[[input$dataset]]
      })
    
    output$table <- renderDT(datasetInput(),
                             server=TRUE, escape = TRUE, selection = 'none',
                             filter=list(position = 'top', clear = FALSE),
                             options=list(search = list(regex = TRUE,
                                                        caseInsensitive = FALSE)))

    output$download <- downloadHandler(
        filename = function() {
            paste("Lexique-query-", Sys.time(), ".csv", sep="")
        },
        content = function(fname){
            # write.csv(datasetInput(), fname)
            dt = datasetInput()[input[["table_rows_all"]], ]
            write.csv(dt,
                      file=fname,
                      row.names=FALSE)
        })
    #url  <- a("Help!", href="http://www.lexique.org/?page_id=166")
    #output$help = renderUI({ tagList("", url) })
}

shinyApp(ui, server)
