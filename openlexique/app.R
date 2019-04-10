# shiny R code for lexique.org
# Time-stamp: <2019-04-10 08:04:18 christophe@pallier.org>

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
load('../rdata/FrFam.RData')


helper_alert =
    tags$div(class="alert alert-info",
             tags$h4(class="alert-heading", "Foreword on usage"),
             tags$p("Documentation is available at ",
                    tags$a(class="alert-link", href="http://www.lexique.org/?page_id=166", "here"),
                    "."
                    ),
             tags$hr(""),
             tags$p("Crash course:"),
             tags$ul(
                      tags$li("Select desired dataset on the left"),
                      tags$li("For each column you can:"),
                      tags$ul(
                               tags$li("sort (ascending or descending)"),
                               tags$li("Filter using intervals (e.g. 40...500), or ", tags$a(href="http://regextutorials.com/index.html", "regexes"), ".")
                           ),
                      tags$li("Download the result of your manipulations")
                  )
             )


ui <- fluidPage(
    titlePanel("OpenLexique"),

    sidebarLayout(
        sidebarPanel(
            selectInput("dataset", "Choose a dataset:",
                        choices = c("Lexique3.82", "Brulex", "Voisins", "Frantext", "FLP.pseudo", "FLP.words", "Chronolex",  "400images", "Gougenheim", "SUBTLEXus", "Megalex-auditory", "Megalex-visual", "FrFamiliarité")),
            width=2
        ),
        mainPanel(
            helper_alert,
            h3(textOutput("caption", container = span)),
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
               )
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
