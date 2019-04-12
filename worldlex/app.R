# shiny R code for lexique.org
# Time-stamp: <2019-04-10 08:04:18 christophe@pallier.org>

library(shiny)
library(DT)

# lexique <- read.csv('Lexique380.utf8.csv')
# brulex <- read.csv('Brulex.utf8.csv')

load('../rdata/WorldLex_FR.RData')
load('../rdata/WorldLex_EN.RData')


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
                        choices = c("WorldLex_FR", "WorldLex_EN" )),
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
               "WorldLex_FR" = worldlexfr,
               "WorldLex_EN" = worldlexen
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
