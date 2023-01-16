get_dataset_words <- function(datasets, nbchar=NULL, gram_class=NULL){
  for (dataset in datasets){
      # Load dataset if needed
      load_dataset_table(dataset)
      words <- dictionary_databases[[dataset]][['dstable']]
      freqCol = "BlogFreqPm"
      nbcharCol = "nbcar"
      freqThreshold = 0.5

      if (dataset == "Lexique383"){
        freqCol = "freqfilms2"
        nbcharCol = "nblettres"
        freqThreshold = 0.5
      }

      # No blog freq value (all zeros) for these languages so we need to "remove" threshold
      if (dataset == "WorldLex-Greenlandic" || dataset == "WorldLex-Uzbek"){
        freqThreshold = -1
      }

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

generate_pseudowords <- function (n, len, models, len_grams, language, input=NULL, exclude=NULL, time.out=500, testing=FALSE)
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
  len_models <- length(models)
  if (len_models == 0) {
    shinyjs::html(id = 'oInfoGeneration', paste("<div", info_style, ">Failed to generate pseudowords from", len_models, "source words...</div>"))
    if(!testing){
      shinyalert("Error", paste0(
        'Please provide words of the desired length in the "Words to use" section !'),
        type = "error")
        return ()
      }else{
        return("Not enough words")
      }
    }

  shinyjs::html(id = 'oInfoGeneration', paste("<div", info_style, ">Generating from", len_models, "source words...</div>"))

  # Limit number of source words for non latin languages due to performance issues
  if((language == default_other || language %in% non_latin_languages) && len_models > 2000){
    models <- sample(models, 2000)
  }

  if (len_grams == big_choice){
    len_substring = 2
  }else if (len_grams == trig_choice){
    len_substring = 3
  }else{
    shinyalert("Error", paste0(
      'Wrong substring type selected.'),
      type = "error")
    return ()
  }

  count_key = 0
  count_char = 0
  # Create dictionaries of substrings (trigrams or bigrams), of wordsindex (to get models from which we select characters when building pseudowords) and of frequencies (to select grams according to their frequency in the input set)
  substrings <- list()
  wordsindex <- list()
  frequencies <- list()
  for (step in 1:(len-len_substring)){
    substrings[[step]] <- list()
    wordsindex[[step]] <- list()
    frequencies[[step]] <- list()
  }
  for (model_num in 1:length(models)){
    model <- models[[model_num]]
    modelChars <- strsplit(model, "")[[1]]
    for (char_num in 2:(len - len_substring + 1)){
      dict_index <- char_num-1 # Pseudoword build step (new version of cpos)
      curSubstr <- substr(model, char_num, char_num+len_substring-2)
      nextChar <- modelChars[[char_num+len_substring-1]]
      # Initialize new vector if found new substring at a given dict_index
      if (!(curSubstr %in% names(substrings[[dict_index]]))){
        substrings[[dict_index]][[curSubstr]] <- c()
        wordsindex[[dict_index]][[curSubstr]] <- c()
        frequencies[[dict_index]][[curSubstr]] <- list()
        frequencies[[dict_index]][[curSubstr]][["individual"]] <- c() # to count all iterations for each curSubstr/nextchar association
        frequencies[[dict_index]][[curSubstr]][["all"]] <- 0 # to count all times curSubstr is encountered
        count_key = count_key+1
      }
      # Add char to vector if not already assigned to this substring at this step (dict_index). Also assign model index to wordsindex.
      if (!(nextChar %in% substrings[[dict_index]][[curSubstr]])){
        # Add nextChar in the vector
        substrings[[dict_index]][[curSubstr]] <- c(substrings[[dict_index]][[curSubstr]], nextChar)
        # Add model_num in the vector
        wordsindex[[dict_index]][[curSubstr]] <- c(wordsindex[[dict_index]][[curSubstr]], as.character(model_num)) # If new entry, store model index as character
        # Initialize frequencies for this CurSubstr/nextChar association
        frequencies[[dict_index]][[curSubstr]][["individual"]] <- c(frequencies[[dict_index]][[curSubstr]][["individual"]], 1)
        count_char = count_char+1
      }else{ # If not new entry, concatenate previous model nums and new model num as a string with elements separated with comma
        index_char <- which(substrings[[dict_index]][[curSubstr]] == nextChar)[[1]] # get index char from substrings dict (since index_char is unique in substrings[[dict_index]][[curSubstr]] due to test above)
        # add model_num at correct position in the wordsindex vector. The vector is like c("1,6", "2,3,4", "5,7"). So if we add for instance 8 to position 3, it will be c("1,6", "2,3,4", "5,7,8")
        wordsindex[[dict_index]][[curSubstr]][[index_char]] <- paste(c(wordsindex[[dict_index]][[curSubstr]][[index_char]], model_num), collapse=",")
        # increment at correct position in the frequencies vector. The vector is like c(1, 1, 4). So if we increment in position 2, it will be c(1, 2, 4).
        frequencies[[dict_index]][[curSubstr]][["individual"]][[index_char]] <- frequencies[[dict_index]][[curSubstr]][["individual"]][[index_char]] + 1
      }
      frequencies[[dict_index]][[curSubstr]][["all"]] <- frequencies[[dict_index]][[curSubstr]][["all"]] + 1
    }
  }

  # create dataframe for final list of pseudowords
  final_list <- data.frame(matrix(ncol = len-len_substring+2, nrow = n))
  new_colnames <- c()
  for (num_word in 1:(len-len_substring+1)){
    new_colnames <- c(new_colnames, paste("Word", num_word, sep="."))
  }
  new_colnames <- c("Pseudoword", new_colnames)
  colnames(final_list) <- new_colnames

  # Recursive function to build pseudoword
  build_pseudoword_rec <- function(pseudoword_vec, source_vec, step){
    # Return finished pseudoword
    if (step == len-len_substring+1){
      return(c(paste(pseudoword_vec, collapse=""), source_vec))
    }
    # First step : we select a random word and take its two or third first characters
    if (step == 0){
      model <- sample(models, 1)
      return(build_pseudoword_rec(
        c(strsplit(substr(model,1,len_substring), "")[[1]]),
        c(model),
        step+1
      ))
    }
    # Set last_letters, which is the last letters of the current pseudoword we must take to determine where to look in substrings dictionary to find next character
    last_letters <- pseudoword_vec[length(pseudoword_vec)]
    if (len_substring == 3){
      last_letters <- paste(pseudoword_vec[length(pseudoword_vec)-1], last_letters, sep="")
    }
    # Vector from which to choose next characters
    current_vec <- substrings[[step]][[last_letters]]
    #random_int <- sample(1:length(current_vec), 1)
    # select a random int between 1 and all iterations for this curString (last_letters)
    random_int <- sample(1:frequencies[[step]][[last_letters]][["all"]],1)
    count_frequency <- 0
    # search the nextchar with frequency corresponding to random int selected. For instance if we got random int 112. We cumulate frequencies starting from first nextchar until we get a frequency >= our random int. E.g., first is 72, second is 40, so the good nextchar is the second one.
    for (num_nextChar in 1:length(frequencies[[step]][[last_letters]][["individual"]])){
      count_frequency <- count_frequency + frequencies[[step]][[last_letters]][["individual"]][[num_nextChar]]
      if (count_frequency >= random_int){
        break
      }
    }
    # Recursive call
    # Select a random model from models that gave this gram in wordsindex, to show in pseudowords with details
    model_index <- as.integer(sample(strsplit(wordsindex[[step]][[last_letters]][[num_nextChar]], ",")[[1]], 1))
    return(build_pseudoword_rec(
      c(pseudoword_vec, current_vec[[num_nextChar]]),
      c(source_vec, models[model_index]),
      step+1
    ))
  }

  # Function that calls recursive function to build pseudowords with initial parameters (empty vectors and step 0)
  build_pseudoword <- function(){
    return(build_pseudoword_rec(c(), c(), 0))
  }

  # Build pseudowords
  np = 0
  time.out = 500
  start_time <- as.numeric(Sys.time())*1000
  total_time <- as.numeric(Sys.time())*1000
  while (np < n && (as.numeric(Sys.time())*1000 - start_time) < time.out){
    validWord <- TRUE
    line <- build_pseudoword()
    pseudoword <- line[[1]]

    ##########################
    ###### BEGIN CHECKS ######
    ##########################

    if (!is.null(input)){
      for (filter in filtersList){
        if (input[[filter[["name"]]]] != default_filter_option){
          validWord = filter[["checkFunc"]](pseudoword, as.numeric(input[[filter[["name"]]]]))
          if (!validWord){
            break
          }
        }
      }
    }

    # Check not duplicate word (validWord check should not be useful)
    if (isTRUE(validWord) && !(pseudoword %in% c(models, exclude)) && !(paste0(font_first_element, pseudoword, font_second_element) %in% final_list$Pseudoword)) {
      np = np + 1
      final_list$Pseudoword[np] = paste0(font_first_element, pseudoword, font_second_element)
    }else{
      next
    }

    ########################
    ###### END CHECKS ######
    ########################

    # Color word selected for pseudoword beginning
    final_list[["Word.1"]][np] <- paste0(
        font_first_element,
        substr(line[[2]], 1, len_substring),
        font_second_element,
        substr(line[[2]], len_substring+1, nchar(line[[2]])))
    final_list[["Word.1"]][np] <- paste0(font_fade, final_list[["Word.1"]][np], font_fade_end)

    # Color each word selected for further steps of pseudoword build
    for (word_num in 2:(len - len_substring + 1)){
      final_list[[paste("Word", word_num, sep=".")]][np] <- paste0(
        substr(line[[word_num+1]], 1, word_num-1),
        font_previous_letters,
        substr(line[[word_num+1]], word_num, word_num+(len_substring-2)),
        font_second_element,
        font_first_element,
        substr(line[[word_num+1]], word_num+(len_substring-1), word_num+(len_substring-1)),
        font_second_element,
        substr(line[[word_num+1]], word_num+len_substring, nchar(line[[word_num+1]]))
      )
      final_list[[paste("Word", word_num, sep=".")]][np] <- paste0(font_fade, final_list[[paste("Word", word_num, sep=".")]][np], font_fade_end)
    }

    # reset timeout
    start_time <- as.numeric(Sys.time())*1000
  }
  # print(as.numeric(Sys.time())*1000 - total_time)

  # Show alert if not enough pseudowords and while broke
  if (np < n){
    final_list <- final_list[-c(np+1:n), ] # remove lines not filled with pseudowords from df
    if (!testing){
      shinyalert("Error", paste0(
        'Failed to generate the requested number of pseudowords : not enough valid source words provided.\nWe generated ', np, ' on the ', n, ' requested.\nPlease enter words of the desired length in the \"',
        paste_words, '\" section.\nThe more pseudowords you need, the more words you need to provide in the \"',
        paste_words, '\" section.\nA minimum of 100 words for 20 pseudowords is a good basis, unfortunately there is no fixed minimal number of words. You need to proceed with trial-and-error or use the \"',
        generator_name, '\" for easier pseudowords generation.'),
        type = "error")
      if (np == 0){
        shinyjs::html(id = 'oInfoGeneration', paste("<div", info_style, ">Failed to generate pseudowords from", len_models, "source words...</div>"))
      }else{
        shinyjs::html(id = 'oInfoGeneration', paste("<div", info_style, ">", np, "pseudowords generated from", len_models, "source words...</div>"))
      }
    }
  }else{
    shinyjs::html(id = 'oInfoGeneration', paste("<div", info_style, ">", n, "pseudowords generated from", len_models, "source words !</div>"))
  }
  return(final_list)
}
