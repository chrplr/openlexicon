# shiny R code for lexique.org
# Time-stamp: <2019-04-06 18:12:44 christophe@pallier.org>

library(shiny)
library(DT)


load('../rdata/Lexique382.RData')

lexique$cgram <- as.factor(lexique$cgram)


ui <- fluidPage(
        title = "Lexique",
        sidebarLayout(
            sidebarPanel(
                checkboxGroupInput("show_vars", "Columns to display",
                                   names(lexique),
                                   selected = c('ortho', 'nblettres', 'orthosyll', 'cgram', 'lemme', 'freqlivres', 'freqfilms2', 'phon', 'nbphons', 'syll', 'p_cvcv')
                                   ),
                width=2
                ),
            mainPanel(
            h3(textOutput("caption", container = span)),
            fluidRow(DTOutput(outputId="table")),
            downloadButton(outputId='download', label="Download filtered data"),
            h3(textOutput("help", container = span)),
            )
        )
    )


server <- function(input, output) {
    datasetInput <- reactive({lexique})

    output$caption <- renderText({
        "Lexique3.82"
    })

    output$table <- renderDT(datasetInput()[,input$show_vars, drop=FALSE],
                             server=TRUE, escape = TRUE, selection = 'none',
                             filter=list(position = 'top', clear = FALSE),
                             options=list(search = list(regex = TRUE,
                                                        caseInsensitive = FALSE,
                                                        pageLength=50,
                                                        lengthMenu = c(20, 50, 100, 500))))

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
        }),
    output$help = render Text({'<a href="http://www.lexique.org/?page_id=166">Mode d\'emploi</a>'})
}


shinyApp(ui, server)
