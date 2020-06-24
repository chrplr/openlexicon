generate_pseudowords <- function (n, len, models, exclude=NULL, time.out=1)
  # generate pseudowords by chaining trigrams
  # n: number of pseudowords to return
  # len: length (nchar) of these pseudowords
  # models: vector of items to get trigrams from (all of the same length!)
  # exclude: vector of items to exclude
  # time.out = a time in seconds to stop
{
  print(models)
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
  if (np > n) {
    return(pseudos)
  } else {
    shinyalert("Error", paste(
      'Failed to generate the requested number of words. Please enter a larger number of words in the \"',
      paste_words, '\" section.'),
      type = "error")
    return()
  }
}