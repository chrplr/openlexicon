# shiny R code for recherche de par liste de mots on <www.lexique.org>
# Authors: Boris New & C. Pallier
# Time-stamp: <2019-11-26 07:44:54 christophe@pallier.org>

library(shiny)
library(DT)
library(dplyr)
library(writexl)


source("https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/fetch_datasets.R")
lexique <- get_lexique383_rds()

ui <- fluidPage(
  title = "Lexique",
  fluidRow(
    column(8,offset = 3,
           textarea_demo <- textAreaInput(
             "mots",
             label = h3("Liste de mots à rechercher dans la table"),
             cols =20,
             rows = 10
            )
    )
  ),
  fluidRow(
    column(2,
      wellPanel(
        checkboxGroupInput("show_vars", "Columns to display",
                           names(lexique),
                           selected = c('ortho', 'nblettres','cgramortho','islem', 'cgram', 'nblettres', 'nbsyll','lemme', 'freqlemfilms2', 'freqfilms2', 'phon')
        )
      )
    ),
    column(10,
           #uiOutput("help"),
           h3(textOutput("caption", container = span)),
           DTOutput(outputId="table"),
           downloadButton(outputId='download', label="Download filtered data")
      )
  )
)

server <- function(input, output) {
  # Génère le dataframe avec les mots rentrés par l'utilisateur
  mots2 <- reactive( { strsplit(input$mots,"[ \n\t]")[[1]] } )
  lexique_mots <- reactive( { merge(data.frame(ortho=mots2()),
                                    lexique,
                                    by.x="ortho",
                                    by.y="ortho",
                                    all.x=TRUE)} )

  output$caption <- renderText({
    "Lexique3.82" 
  })

  output$table <- renderDT(lexique_mots()[,input$show_vars, drop=FALSE],
                           server=TRUE, escape = TRUE, selection = 'none',
                           #filter=list(position = 'top', clear = FALSE),
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
            dt = lexique_mots()[input[["table_rows_all"]], ]
            write_xlsx(dt, fname)        })
    url  <- a("Mode d'emploi", href="http://www.lexique.org/?page_id=166")
}


shinyApp(ui, server)
