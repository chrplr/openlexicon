# shiny R code for lexique.org
# Time-stamp: <2019-04-21 06:44:44 christophe@pallier.org>

library(shiny)
library(DT)
library(dplyr)

source('../set-variables.R')

load(file.path(RDATA, 'Lexique382.RData'))

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
  mots2<-reactive({strsplit(input$mots,"[ \n\t]")})
  # num pourra servir à récupérer l'ordre original des mots rentrés par l'utilisateur.
  # Pour l'instant ça ne marche pas (il faudrait juste trier lexique_mots par num) mais ça devrait marcher un jour
  num<-reactive({seq(from=1,to=nrow(mots2))})
  mots2df<-reactive({data.frame(ortho=matrix(unlist(mots2())))})
  lexique_mots <- reactive({merge(mots2df(),lexique,by.x="ortho",by.y="ortho",all.x=TRUE)})
  
  output$caption <- renderText({
    "Lexique3.82" 
  })

  output$table <- renderDT(lexique_mots()[,input$show_vars, drop=FALSE],
                           server=TRUE, escape = TRUE, selection = 'none',
                           #filter=list(position = 'top', clear = FALSE),
                           options=list(pageLength=20,
                                                      lengthMenu = c(20, 50, 1000),
                                                      regex = TRUE,
                                                      searching = FALSE,
                                                      caseInsensitive = FALSE
                                      )
  )
  
  output$download <- downloadHandler(
    filename = function() {
      paste("Lexique-query-", Sys.time(), ".csv", sep="")
    },
    content = function(fname){
      # write.csv(datasetInput(), fname)
      dt = lexique_mots()[input[["table_rows_all"]], ]
      write.table(dt,
                file=fname,
                quote=FALSE,
                sep=";",
                row.names=FALSE)
    })
  url  <- a("Mode d'emploi", href="http://www.lexique.org/?page_id=166")
  #output$help = renderUI({ tagList(tags$h4("Aide pour les recherches :", url)) })
  
}


shinyApp(ui, server)
