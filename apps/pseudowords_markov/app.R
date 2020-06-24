# shiny R code for generate pseudowords <www.lexique.org>
# Authors: Boris New & C. Pallier
# Time-stamp: <2019-07-22 10:41:54 christophe@pallier.org>

rm(list = ls())
source('www/functions/generatePseudo.R')
source('www/functions/loadPackages.R')

ui <- fluidPage(
  titlePanel(tags$a(href="http://chrplr.github.io/pseudowords_markov/", "Pseudoword Generator")),
  title = "Pseudoword Generator",
  
  sidebarLayout(
    sidebarPanel(
      uiOutput("helper_alert"),
      #br(),
      #helper_alert,
      textAreaInput("mots",
                                     label = h4("Paste here a list of words from which pseudowords will be generated"),
                                     rows = 10),
      tags$div(selectInput("nbpseudos",
                           "Select number of pseudowords to create",
                           c(1,5,20,50,100),
                           width = "100%"),
      tags$div(selectInput("longueur",
                           "Select length of pseudowords to create",
                           4:15,
                           width = "100%")),
      tags$div(selectInput("timeout",
                           "Maximum time to run (in seconds)",
                           c(1, 5, 10, 30, 60, 120, 300, 600),
                           width = "100%")),
      actionButton("go", "Press here to generate pseudowords!")),
      br(),
      width=4#, style = "position:fixed;width:inherit;"
    ),
  mainPanel(
  fluidRow(column(8, 
                  offset = 3,
                  textarea_output <- textOutput("pseudomots"))
  ),
  downloadButton(outputId='download', label="Download pseudowords")
)))


server <- function(input, output) {
    pseudowords <- eventReactive(input$go,
    {
       nbpseudos = as.numeric(input$nbpseudos)
       longueur = as.numeric(input$longueur)
       words <- strsplit(input$mots,"[ \n\t]")[[1]]
       wordsok <- words[nchar(words) == longueur]
       timeout <- as.numeric(input$timeout)
       generate_pseudowords(nbpseudos, longueur, wordsok, exclude=NULL, timeout)
    }
    )

    output$pseudomots = renderText(pseudowords())

    output$download <- downloadHandler(
      filename = function() {
        paste("pseudos-query-",
              format(Sys.time(), "%Y-%m-%d"), ' ',
              paste(hour(Sys.time()), minute(Sys.time()), round(second(Sys.time()),0), sep = "-"),
              ".xlsx", sep="")
      },
        content = function(fname) {
            dt = data.frame(as.list(pseudowords()))
            write_xlsx(dt, fname)
        }
    )
}

shinyApp(ui, server)
