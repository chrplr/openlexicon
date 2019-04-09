# shiny R code for lexique.org
# Time-stamp: <2019-04-09 13:35:51 christophe@pallier.org>

library(shiny)
library(DT)


load('../rdata/Lexique382.RData')

lexique$cgram <- as.factor(lexique$cgram)

helper_alert =
  tags$div(class="alert alert-info",
    tags$h4(class="alert-heading", "Foreword on usage"),
    tags$p("The full documentation is available ",
      tags$a(class="alert-link", href="http://www.lexique.org/?page_id=166", "here"),
      "."
    ),
    tags$hr(""),
    tags$p("Crash course:"),
    tags$ul(
      tags$li("Select desired columns on the sidebar on the left"),
      tags$li("For each column you can:"),
      tags$ul(
        tags$li("sort (ascending or descending)"),
        tags$li("Filter using ", tags$a(href="http://regextutorials.com/index.html", "regexes"), ".")
      ),
      tags$li("Download the result of your manipulations")
    )
  )

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
                uiOutput("help"),
                h3(textOutput("caption", container = span)),
                helper_alert,
                fluidRow(DTOutput(outputId="table")),
                downloadButton(outputId='download', label="Download filtered data")
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
        })
    url  <- a("Au secours!", href="http://www.lexique.org/?page_id=166")
    output$help = renderUI({ tagList("Mode d'emploi :", url) })

}


shinyApp(ui, server)
