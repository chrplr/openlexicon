# shiny R code for lexique.org
# Time-stamp: <2019-04-30 12:35:13 christophe@pallier.org>

# source('../set-variables.R')

library(shiny)
library(DT)

# loads all datasets
source('../../datasets-info/fetch_datasets.R')
dataset_ids <- c('Lexique382', 'SUBTLEX-US')



datasets = list()
for (ds in dataset_ids)
{
    datasets <- append(datasets, list(fetch_dataset(ds, format='RData')))
}

# each dataset is associated to a list with four elements
# lexique$name
# lexique$datatables   : list of local copies of the database
# lexique$description
# lexique$readme

dsnames <- list()
dsdesc <- list()
dsreadme <- list()

for (d in datasets) {
    dsnames <- append(dsnames, d$name)
    dsdesc <- append(dsdesc, d$description)
    dsreadme <- append(dsreadme, d$readme)
    for (t in d$datatables)
    {
        load(t)  # stupid problem: we do not know the name of the variable that holds the table!!! We might have to assume it is the same as the 'name' of the dataset :-(
    }
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
                      tags$li("Select desired dataset on the left"),
                      tags$li("For each column in the table bellow you can:"),
                      tags$ul(
                               tags$li("Filter using intervals (e.g. 40...500) or", tags$a(class="alert-link", href="http://regextutorials.com/index.html", "regexes"), "."),
                               tags$li("sort, ascending or descending")
                           ),
                      tags$li("Download the result of your manipulations by clicking on the button bellow the table")
                  )
             )


ui <- fluidPage(
    titlePanel("OpenLexique"),

    sidebarLayout(
        sidebarPanel(
            selectInput("dataset", "Choose a dataset:",
                        choices = dsnames),
                        width=4
                        ),
            mainPanel(
                helper_alert,
                h3(textOutput("caption", container = span)),
                dataset_info,
                fluidRow(DTOutput(outputId="table")),
                downloadButton(outputId='download', label="Download filtered data")
            )
        )
    )


server <- function(input, output) {
    datasetInput <- reactive({
        switch(input$dataset,
               "SUBTLEXus" = subtlexus,
               "Lexique3.82" = lexique,
               "Brulex" = brulex,
               "Voisins" = voisins,
               "Gougenheim" = gougenheim,
               "400images" = images400,
               "Frantext" = frantext,
               "FLP.words" = flp.words,
               "FLP.pseudo" = flp.pseudowords,
               "Chronolex" = chronolex,
               "Megalex-auditory" = megalex.auditory,
               "Megalex-visual" = megalex.visual,
               "FrFamiliarité" = frfam
               )  # TODO: change this to use the datasets list
    })

    output$caption <- renderText({
        input$dataset
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
