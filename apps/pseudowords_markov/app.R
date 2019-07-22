# shiny R code for generate pseudowords <www.lexique.org>
# Authors: Boris New & C. Pallier
# Time-stamp: <2019-07-22 10:41:54 christophe@pallier.org>

library(shiny)
library(DT)
library(dplyr)
library(writexl)


generate_pseudowords <- function (n, len, models, exclude=NULL, time.out=5)
  # generate pseudowords by chaining trigrams
  # n: number of pseudowords to return
  # len: length (nchar) of these pseudowords
  # models: vector of items to get trigrams from (all of the same length!)
                                        # exclude: vector of items to exclude
    # time.out = a time in seconds to stop
{
  if (length(models) == 0) { return (NULL) }

  trigs = list()  #  store lists of trigrams by starting position
  for (cpos in 1:(len - 1))
    trigs[[cpos]] <- substring(models, cpos, cpos + 2)

  pseudos <- character(n)  # will contain the generated pseudowords

  start.time <- Sys.time()

  np = 1
  while ((np <= n) && ((Sys.time() - start.time) < time.out)) {
    # sample a random beginning trigram
    item <- sample(trigs[[1]], 1)

    # Build the item letter by letter by adding compatible trigrams
    for(pos in 2:(len - 1)) {
      # get the last 2 letters of the current item
      lastbigram <- substr(item, pos, pos + 1)

      # Select trigrams staring in position 'pos' and which are compatibles with 'lastbigram'
      compat <- trigs[[pos]][grep(paste(sep="" , "^", lastbigram), trigs[[pos]])]
      if (length(compat) == 0) break  # must start again

      item <- paste(item, substr(sample(compat, 1), 3, 3), sep="")  # add the last letter of the trigram
    }

    # keep item only if not in the 'models', 'exclude' or 'pseudos' list
    if (!(item %in% c(models, exclude, pseudos))) {
      pseudos[np] = item
      np = np + 1
    }
  }
  return (pseudos)
}


ui <- fluidPage(
  title = "Pseudoword Generator",
  fluidRow(
      column(5,
             textarea_demo <- textAreaInput("mots",
                                            label = h4("Paste here a list of words from which pseudowords will be generated"),
                                            rows = 10)
             ),
      column(3,
             tags$div(selectInput("nbpseudos",
                                  "Select number of pseudowords",
                                  c(1,5,20,50,100),
                                  width = "100%"))
             ),
      column(3,
             tags$div(selectInput("longueur",
                                  "Select length of pseudowords",
                                  4:15,
                                  width = "100%"))
             ),
      column(3, 
             actionButton("go", "Press here to generate pseudowords!"))
            ),
  fluidRow(column(8, 
                  offset = 3,
                  textarea_output <- textOutput("pseudomots"))
           ),
  downloadButton(outputId='download', label="Download pseudowords")
)


server <- function(input, output) {
    pseudowords <- eventReactive(input$go,
    {
       nbpseudos = as.numeric(input$nbpseudos)
       longueur = as.numeric(input$longueur)
       words <- strsplit(input$mots,"[ \n\t]")[[1]]
       wordsok <- words[nchar(words) == longueur]
       generate_pseudowords(nbpseudos, longueur, wordsok)
    }
    )

    output$pseudomots = renderText(pseudowords())

    output$download <- downloadHandler(
        filename = function() {
            paste("pseudos-query-", Sys.time(), ".xlsx", sep="")
        },
        content = function(fname) {
            dt = pseudomots()
            write_xlsx(dt, fname)
        }
    )
}

shinyApp(ui, server)
