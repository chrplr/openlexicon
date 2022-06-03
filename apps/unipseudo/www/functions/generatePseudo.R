get_dataset_words <- function(datasets, dictionary_databases, nbchar=NULL, gram_class=NULL){
  for (dataset in datasets){
      freqCol = "BlogFreq"
      nbcharCol = "nbcar"
      freqThreshold = 1

      if (dataset == "Lexique383"){
        freqCol = "freqfilms2"
        nbcharCol = "nblettres"
        freqThreshold = 0.01
      }

      # No blog freq value (all zeros) for these languages so we need to "remove" threshold
      if (dataset == "WorldLex-Greenlandic" || dataset == "WorldLex-Uzbek"){
        freqThreshold = -1
      }

      words <- dictionary_databases[[dataset]][['dstable']]
      # for testing purposes
      if (is.null(nbchar)){
        words <- words[words[[freqCol]] > freqThreshold,]
      }
      # Special case for Lexique383, when a grammatical class is selected
      else if (gram_class != default_none && !(is.null(gram_class)) && dataset == "Lexique383"){
        # Select words for a specific grammatical class in Lexique
        words <- words[words[["cgram"]] == gram_class & words[[nbcharCol]] == nbchar & words[[freqCol]] > freqThreshold,]
      # Default case : frequency and number of characters filters
      }else{
        words <- words[words[[freqCol]] > freqThreshold & words[[nbcharCol]] == nbchar,]
      }
    }
  return(words[["Word"]])
}

generate_pseudowords <- function (n, len, models, len_grams, language, exclude=NULL, time.out=15, testing=FALSE)
  # generate pseudowords by chaining trigrams or bigrams
  # n: number of pseudowords to return
  # len: length (nchar) of these pseudoword
  # models: vector of items to get grams from (all of the same length!)
  # len_grams : bigram or trigram string (algorithm)
  # language : string language (for constraints purposes)
  # exclude: vector of items to exclude
  # time.out = a time in seconds to stop
  # testing boolean to set to TRUE when performing QA tests
{
  time.out = n*0.5
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

      # Select random substring starting in position 'pos' and compatible with 'lastpart'
      shuffled_substrings <- substrings[sample(1:nrow(substrings)), ]
      random_compat <- NULL
      for (row in 1:nrow(shuffled_substrings)){
        if (!is.na(shuffled_substrings[row, pos]) && startsWith(shuffled_substrings[row, pos], lastpart)) {
          random_compat <- shuffled_substrings[row,]
          break
        }
      }
      if (is.null(random_compat)){
        validWord = FALSE
        break
      }

      future_item <- paste0(item,substr(random_compat[[pos]], len_substring, len_substring))
      # Check for triple consonants with bigram algo
      if (len_grams == "bigram" && nchar(future_item) >= 3 && language %in% latin_languages){
        # Exclude "nordic" languages, for they love consonants
        if (!(language %in% c("Danish", "Dutch", "German", "Norwegian", "Swedish", "Welsh"))){
          # Concatenates current item (pseudoword in formation) and selected compat, and transform all consonants to uppercase character C
          b <- gsub("[^ɯαÅaáάαăàąǎâäāåãeéėèēεęêëiíίıİīïoóόòơôöºőόõøūuúûůüyýœɔɛə\\'\\.[:space:]-]","C",iconv(tolower(future_item), from="UTF-8", to="ASCII//TRANSLIT"))
          # Remove pseudowords with 4 following consonants
          if (grepl("CCCC", b, fixed=TRUE)){
            print(paste("four consonants", future_item))
            validWord=FALSE
            break
          }
        }

        # Check we do not have more than 2 times the same consecutive letter
        wordChars <- strsplit(future_item, "")[[1]]
        if (length(wordChars) >= 3){
          for (charCount in 1:(length(wordChars)-2)){
            char <- tolower(wordChars[charCount])
            if (char == wordChars[charCount+1] && char == wordChars[charCount+2]){
              validWord=FALSE
              break
            }
          }
          if (!(validWord)){
            print(paste("same letter", future_item))
            break
          }
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
    # We keep the length test for cases when we break : we need to not to include these items in the final_list. validWord boolean should be enough though.
    if (nchar(item) == len && isTRUE(validWord) && !(item %in% c(models, exclude)) && !(paste0(font_first_element, item, font_second_element) %in% final_list$Pseudoword)) {
      final_list$Pseudoword[np] = paste0(font_first_element, item, font_second_element)
      np = np + 1
    }
  }
  if (np > n) {
    return(final_list)
  } else {
    if (!testing){
      shinyalert("Error", paste0(
        'Failed to generate the requested number of pseudowords. Please enter a larger number of words in the \"',
        paste_words, '\" section.'),
        type = "error")
    }
    return()
  }
}
