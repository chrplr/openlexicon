usePackage("dplyr")
usePackage("data.table")

QA_test <- function(QA_check=FALSE, character_check=FALSE, load_check=FALSE, consonants_check=FALSE){
  # Init test directory
  testdir <- "tests"
  dir.create(testdir)
  init = TRUE

  # Assign nb_pseudos value
  nb_pseudos = 20

  # Loop through languages
  for (lang_test in language_choices){
    if (lang_test != default_other){
      # Init vectors for df creation
      Length <- c()
      Algorithm <- c()
      Language <- c()
      NbPseudowords <- c()
      Success <- c()
      Pseudowords <- c()
      NbWords <- c()
      print(paste("Language:", lang_test))

      # Load dataset for this language
      load_language(lang_test)
      datasets = names(list.filter(dslanguage, tolower(lang_test) %in% tolower(name)))

      # Get characters, to have an overview of which characters are used for a given language
      if (character_check){
        words <- get_dataset_words(datasets, dictionary_databases)
        fwrite(get_characters(words),
          file.path(testdir, paste0("character_",lang_test,".txt")), sep="\n", append=FALSE)
      }

      # Check how many words with 4 or more consonants in Worldlex
      # Check how many word with 3 time consecutive the same letter
      # Do this only for latin languages (this does not necessarily suit to languages such as Japanese or other)
      if (consonants_check){
        if (lang_test %in% latin_languages){
          nb_repeat_consonants = 0
          nb_repeat_same_letter = 0
          words <- get_dataset_words(datasets, dictionary_databases)
          nb_words = length(words)
          consonants = c()
          vowels = c()
          for (word in words){
            # All consonants are replaced by a C. Excludes vowels (with accents included) and some punctuation.
            # Convert from UTF-8 (characters are encoded this way on dataset import) to ASCII (remove accents)
            b <- gsub("[^ɯαÅaáάαăàąǎâäāåãeéėèēεęêëiíίıİīïoóόòơôöºőόõøūuúûůüyýœɔɛə\\'\\.[:space:]-]","C",iconv(tolower(word), from="UTF-8", to="ASCII//TRANSLIT"))
            # Count words with 4 consecutive consonants minimum
            if (grepl("CCCC", b, fixed=TRUE)){
              nb_repeat_consonants = nb_repeat_consonants + 1
            }
            wordChars <- strsplit(word, "")[[1]]
            bChars <- strsplit(b, "") [[1]]
            # For 3-letter words minimum, check that we do not have more than 2 times in a row the same letter
            if (length(wordChars) >= 3){
              for (charCount in 1:(length(wordChars)-2)){
                char <- tolower(wordChars[charCount])
                if (char == wordChars[charCount+1] && char == wordChars[charCount+2]){
                  nb_repeat_same_letter = nb_repeat_same_letter + 1
                  break
                }
              }
            }
            # Put letters detected as consonants and vowels in lists that are printed, to check if detection is done correctly
            for (charCount in 1:length(wordChars)){
              char <- tolower(wordChars[charCount])
              if (bChars[charCount] == "C"){
                if (!(char %in% consonants)){
                  consonants = c(consonants, char)
                }
              }else{ # Note that punctuation will also be contained in vowels : not a problem since we only transform consonants to C
                if (!(char %in% vowels)){
                  vowels = c(vowels, char)
                }
              }
            }
          }
          print(nb_words)
          print(consonants)
          print(vowels)
          fwrite(as.list(paste(lang_test, ":", nb_repeat_consonants/nb_words*100)),
            file.path(testdir, paste0("consonants.txt")), sep="\n", append=!(init))
          fwrite(as.list(paste(lang_test, ":", nb_repeat_same_letter/nb_words*100)),
            file.path(testdir, paste0("sameletter.txt")), sep="\n", append=!(init))
            date_time<-Sys.time()
            while((as.numeric(Sys.time()) - as.numeric(date_time))<10){}
        }
      }

      # Check how many words are loaded for each language, to check how much frequency threshold removes, and if there are import issues
      if (load_check){
        words <- get_dataset_words(datasets, dictionary_databases)
        words <- words[!duplicated(words)]
        words <- as.character(words)
        fwrite(as.list(paste(lang_test, ":", length(words))),
          file.path(testdir, paste0("load.txt")), sep="\n", append=!(init))
      }

      # Generate pseudowords for each language, each length and each algorithm
      if (QA_check){
        for (longueur in c(3:15)){
          print(paste("Length:", longueur))
          words <- get_dataset_words(datasets, dictionary_databases, longueur)
          NbWords <- c(NbWords, length(words))
          for (algo in c("bigram", "trigram")){
            # Does not perform check for trigram algo and length 3 because it can't work ! (we would only get a word of 3 letters, and not a pseudoword)
            if (algo == "bigram" || (algo == "trigram" && longueur > 3)){
              print(paste("Algorithm:", algo))
              Length <- c(Length, longueur)
              Algorithm <- c(Algorithm, algo)
              Language <- c(Language, lang_test)
              NbPseudowords <- c(NbPseudowords, nb_pseudos)
              pseudowords <- generate_pseudowords(
                n=nb_pseudos,
                len=longueur,
                models=words,
                len_grams=algo,
                exclude=words,
                language=lang_test,
                testing=TRUE)
              # If no pseudowords generated for a given condition
              if(is.null(pseudowords)){
                Success <- c(Success, 0)
                Pseudowords <- c(Pseudowords, c(""))
                print(paste0("Failed to generate ", nb_pseudos, " pseudowords for language ", lang_test, ", algo ", algo, ", length ", longueur))
              }else{
                Success <- c(Success, 1)
                Pseudowords <- c(Pseudowords, paste(stringr::str_replace_all(stringr::str_replace_all(
                  pseudowords$Pseudoword,
                  font_first_element,
                  ""), font_second_element, "")
                , collapse = " "))
              }
            }
          }
        }
        # Assign df and write to csv
        df <- data.frame(Length, Algorithm, Language, NbPseudowords, Success,
          Pseudowords)
        write.csv(df,file.path(testdir, paste0("pseudogen_",lang_test,".csv")), row.names = FALSE)
      }
      # After loop on first language, init set to false
      init = FALSE
    }
  }
}

# Returns list of unique characters in a vector of words
get_characters <- function(words){
  return(as.list(sort(unique(unlist(strsplit(words, ''))))))
}
