# shiny R code for recherche de par liste de mots on <www.lexique.org>
# Authors: Boris New & C. Pallier
# Time-stamp: <2019-05-01 09:29:55 christophe@pallier.org>

library(shiny)
library(DT)
library(dplyr)
library(writexl)

require(stringi)

generate_pseudowords <- function (n, len, models, exclude=NULL)
  # generate pseudowords by chaining trigrams.
  # n: number of pseudowords to return
  # len: lenght (nchar) of this pseudowords
  # models: list of items to get trigrams from
  # exclude: list of items to exclude
{
  if (length(models) == 0) { return (NULL) }
  #omodels <- models
  # models <- paste(" ", models, " ", sep="")
  trigs = list()  #  storing the list of trigrams by starting position
  for (cpos in 1:(len - 1))
    trigs[[cpos]] <- stri_encode(substring(models, cpos, cpos + 2), "", "UTF-8")
  
  pseudos <- character(n)  # will contain the generated pseudowords
  
  np = 1
  while (np <= n) {
    # Tire au hasard un trigramme en position initiale
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
    
    #item = substring(item, 2)
    # keep item only if not in the 'exclude' list
    if (any(models==item)) {  
    }  else {
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
                                          label = h4("Paste here your list of words from which pseudowords will be generated"),
                                          rows = 10)),
    column(3,
           # selectInput("longueur", "Select pseudoword length:",
           #             choices = 4:14,
           #             width=13))
           tags$div(selectInput("nbpseudos", "Select number of pseudowords", c(1,5,20,50,100),width = "100%"))),
  fluidRow(column(8, 
                  offset = 3,
                  textarea_output <- textOutput("pseudomots")))))

server <- function(input, output) {
  # Génère le dataframe avec les mots rentrés par l'utilisateur
  nbpseudos = reactive({ input$nbpseudos })
  mots2 <- reactive( { strsplit(input$mots,"[ \n\t]")[[1]] } )
  longueur = reactive(nchar(mots2()[1]))
  #print(longueur())
  pseudos = reactive({ print(paste("nbpseudos",nbpseudos()));
    if (!all(nchar(mots2())==longueur())){
      return("Error")
      print("Error")
    } else {
      generate_pseudowords(as.numeric(nbpseudos()), as.numeric(longueur()), mots2()) 

    }})
    output$pseudomots = renderText(pseudos())

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
