# shiny R code for lexique.org
# Time-stamp: <2019-04-06 15:23:39 christophe@pallier.org>

library(shiny)
library(DT)

# lexique <- read.csv('Lexique380.utf8.csv')
# brulex <- read.csv('Brulex.utf8.csv')

load('../rdata/Lexique382.RData')
load('../rdata/Brulex.RData')
load('../rdata/flp-pseudowords.RData')
load('../rdata/flp-words.RData')
load('../rdata/Chronolex.RData')
load('../rdata/Frantext.RData')
load('../rdata/gougenheim.RData')
load('../rdata/images400.RData')
load('../rdata/SUBTLEXus.RData')
load('../rdata/Megalex-auditory.RData')
load('../rdata/Megalex-visual.RData')
load('../rdata/Voisins.RData')


server <- function(input, output) {
    datasetInput <- reactive({
        switch(input$dataset,
               "Lexique3.82" = lexique,
               "Brulex" = brulex,
               "Voisins" = voisins,
               "Gougenheim" = gougenheim,
               "400images" = images400,
               "Frantext" = frantext,
               "FLP.words" = flp.words,
               "FLP.pseudo" = flp.pseudowords,
               "Chronolex" = chronolex,
               "SUBTLEXus" = subtlexus,
               "Megalex-auditory" = megalex.auditory,
               "Megalex-visual" = megalex.visual)
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
}

ui <- fluidPage(
        titlePanel("OpenLexique"),

        sidebarLayout(
            sidebarPanel(
                selectInput("dataset", "Choose a dataset:",
                            choices = c("Lexique3.82", "Brulex", "Voisins", "Frantext", "FLP.pseudo", "FLP.words", "Chronolex",  "400images", "Gougenheim", "SUBTLEXus", "Megalex-auditory", "Megalex-visual")),
                width=2
            ),
        mainPanel(
            h3(textOutput("caption", container = span)),
            fluidRow(DTOutput(outputId="table")),
            downloadButton(outputId='download', label="Download filtered data")
            )
        )
    )

shinyApp(ui, server)
