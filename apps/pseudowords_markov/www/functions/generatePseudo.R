generate_pseudowords <- function (n, len, models, exclude=NULL, time.out=15)
  # generate pseudowords by chaining trigrams
  # n: number of pseudowords to return
  # len: length (nchar) of these pseudowords
  # models: vector of items to get trigrams from (all of the same length!)
  # exclude: vector of items to exclude
  # time.out = a time in seconds to stop
{
  time.out = n*0.5
  exclude=strsplit(french_list,"[ \n\t]")[[1]] # exclude french words
  if (length(models) == 0) {
    shinyalert("Error", paste0(
      'Failed to generate the pseudowords. Please enter words of the desired length in the \"',
      paste_words, '\" section.'),
      type = "error")
    return ()
    }
  
  # create data frame of trigrams
  trigs = data.frame(matrix(ncol = 0, nrow = length(models)))  #  store lists of trigrams by starting position
  for (cpos in 1:(len - 2))
    trigs[[cpos]] <- substring(models, cpos, cpos + 2)
  trigs$models <- models
  
  # create dataframe for final list of pseudowords
  final_list <- data.frame(matrix(ncol = length(trigs), nrow = n))
  new_colnames <- c()
  for (num_word in 1:(ncol(trigs)-1)){
    new_colnames <- c(new_colnames, paste("Word", num_word, sep="."))
  }
  new_colnames <- c(new_colnames, "Pseudoword")
  colnames(final_list) <- new_colnames
  
  start.time <- Sys.time()
  
  np = 1
  while ((np <= n) && ((Sys.time() - start.time) < time.out)) {
    # sample a random beginning trigram
    random_item <- trigs[sample(nrow(trigs), 1),]
    final_list[["Word.1"]][np] <- paste0(font_first_element, substr(random_item[["models"]], 1, 3), font_second_element,substr(random_item[["models"]], 4, nchar(random_item[["models"]]))) 
    final_list[["Word.1"]][np] <- paste0(font_fade, final_list[["Word.1"]][np], font_fade_end)
    item <- random_item[[1]]
    
    # Build the item letter by letter by adding compatible trigrams
    for(pos in 2:(len - 2)) {
      # get the last 2 letters of the current item
      lastbigram <- substr(item, pos, pos + 1)
      
      # Select trigrams staring in position 'pos' and which are compatibles with 'lastbigram'
      compat <- trigs[grep(paste(sep="" , "^", lastbigram), trigs[[pos]]), ]
      if (length(compat) == 0) break  # must start again
      
      random_compat <- compat[sample(nrow(compat), 1),]
      final_list[[paste("Word", pos, sep=".")]][np] <- paste0(substr(random_compat[["models"]], 1, pos+1), font_first_element, substr(random_compat[["models"]], pos+2, pos+2), font_second_element,substr(random_compat[["models"]], pos+3, nchar(random_compat[["models"]]))) 
      final_list[[paste("Word", pos, sep=".")]][np] <- paste0(font_fade, final_list[[paste("Word", pos, sep=".")]][np], font_fade_end)
      item <- paste(item, substr(random_compat[[pos]], 3, 3), sep="")  # add the last letter of the trigram
    }
    
    # keep item only if not in the 'models', 'exclude' or 'pseudos' list
    if (!(item %in% c(models, exclude, final_list$Pseudoword[np]))) {
      final_list$Pseudoword[np] = paste0(font_first_element, item, font_second_element)
      np = np + 1
    }
  }
  if (np > n) {
    return(final_list)
  } else {
    shinyalert("Error", paste0(
      'Failed to generate the requested number of pseudowords. Please enter a larger number of words in the \"',
      paste_words, '\" section.'),
      type = "error")
    return()
  }
}