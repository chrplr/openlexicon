get_dataset_words <- function(datasets, dictionary_databases, nbchar, gram_class=NULL){
  for (dataset in datasets){
    if (dataset == "Lexique383"){
      if (gram_class != default_none && !(is.null(gram_class))){
        # Select words for a specific grammatical class in Lexique
        words <- subset(dictionary_databases[[dataset]][['dstable']], cgram == gram_class & nblettres == nbchar)[["Word"]]
      }else{
        words <- subset(dictionary_databases[[dataset]][['dstable']], nblettres == nbchar)[["Word"]]
      }
    }else {
      words <- subset(dictionary_databases[[dataset]][['dstable']], nbcar == nbchar)[["Word"]]
    }
  }
  return(words)
}

generate_pseudowords <- function (n, len, models, len_grams, exclude=NULL, time.out=15)
  # generate pseudowords by chaining trigrams
  # n: number of pseudowords to return
  # len: length (nchar) of these pseudowords
  # models: vector of items to get trigrams from (all of the same length!)
  # exclude: vector of items to exclude
  # time.out = a time in seconds to stop
{
  time.out = n*0.5
  # exclude=strsplit(french_list,"[ \n\t]")[[1]] # exclude french words
  if (length(models) == 0) {
    shinyalert("Error", paste0(
      'Failed to generate the pseudowords.\nPlease enter words of the desired length in the \"',
      paste_words, '\" section.\nThe more pseudowords you need, the more words you need to provide in the \"',
      paste_words, '\" section.\nA minimum of 100 words for 20 pseudowords is a good basis, unfortunately there is no fixed minimal number of words. You need to proceed with trial-and-error or use the \"',
      generator_name, '\" for easier pseudowords generation.'),
      type = "error")
    return ()
    }

  if (len_grams == "bigram"){
    len_substring = 2
  }else if (len_grams == "trigram"){
    len_substring = 3
  }else{
    shinyalert("Error", paste0(
      'Wrong substring type selected.'),
      type = "error")
    return ()
  }

  # create data frame of substrings (trigrams or bigrams)
  substrings = data.frame(matrix(ncol = 0, nrow = length(models)))  #  store lists of substrings by starting position
  for (cpos in 1:(len - (len_substring-1))){
    substrings[[cpos]] <- substring(models, cpos, cpos + (len_substring-1))
  }
  substrings$models <- models

  # create dataframe for final list of pseudowords
  final_list <- data.frame(matrix(ncol = length(substrings), nrow = n))
  new_colnames <- c()
  for (num_word in 1:(ncol(substrings)-1)){
    new_colnames <- c(new_colnames, paste("Word", num_word, sep="."))
  }
  new_colnames <- c("Pseudoword", new_colnames)
  colnames(final_list) <- new_colnames

  start.time <- Sys.time()

  np = 1
  while ((np <= n) && ((Sys.time() - start.time) < time.out)) {
    validWord=TRUE
    # sample a random beginning substring
    # first part (trigram or bigram) of the pseudoword
    random_item <- substrings[sample(nrow(substrings), 1),]
    final_list[["Word.1"]][np] <- paste0(
        font_first_element,
        substr(random_item[["models"]], 1, len_substring),
        font_second_element,
        substr(random_item[["models"]], len_substring+1, nchar(random_item[["models"]])))
    final_list[["Word.1"]][np] <- paste0(font_fade, final_list[["Word.1"]][np], font_fade_end)
    item <- random_item[[1]]

    # Build the item letter by letter by adding compatible substrings
    for(pos in 2:(len - (len_substring-1))) {
      # following bigrams or trigrams of the pseudoword
      # get the last letters (1 or 2) of the current item
      lastpart <- substr(item, pos, pos+(len_substring-2))

      # Select substrings starting in position 'pos' and which are compatibles with 'lastpart'
      compat <- substrings[grep(paste(sep="" , "^", lastpart), substrings[[pos]]), ]
      if (length(compat) == 0) break  # must start again

      random_compat <- compat[sample(nrow(compat), 1),]
      # Check for triple consonants or vowels in short words
      if (len_grams == "bigram" && nchar(item) >= 2){
        b <- gsub("[^aeiouyAEIOUY]","C",iconv(paste0(item,substr(random_compat[[pos]], len_substring, len_substring)), from="UTF-8",to="ASCII//TRANSLIT"))
        if (substr(b, nchar(b)-2,nchar(b)) == "CCC" || !(str_detect(substr(b, nchar(b)-2,nchar(b)), "C"))){
          # print(paste0(item,substr(random_compat[[pos]], len_substring, len_substring)))
          validWord=FALSE
          break
        }
      }
      final_list[[paste("Word", pos, sep=".")]][np] <- paste0(
        substr(random_compat[["models"]], 1, pos-1),
        font_previous_letters,
        substr(random_compat[["models"]], pos, pos+(len_substring-2)),
        font_second_element,
        font_first_element,
        substr(random_compat[["models"]], pos+(len_substring-1), pos+(len_substring-1)),
        font_second_element,
        substr(random_compat[["models"]], pos+len_substring, nchar(random_compat[["models"]]))
      )
      final_list[[paste("Word", pos, sep=".")]][np] <- paste0(font_fade, final_list[[paste("Word", pos, sep=".")]][np], font_fade_end)
      item <- paste(item, substr(random_compat[[pos]], len_substring, len_substring), sep="")  # add the last letter of the substring
    }

    # keep item only if not in the 'models', 'exclude' or 'pseudos' list
    # Column for whole item (whole in red)
    if (nchar(item) == len && isTRUE(validWord) && !(item %in% c(models, exclude)) && !(paste0(font_first_element, item, font_second_element) %in% final_list$Pseudoword)) {
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
