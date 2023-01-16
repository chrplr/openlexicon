filterInput <- function(name, options, pretty_name, tooltip){
  div(
    helpText(pretty_name, tippy(circleButton("langTooltip", "?", status = "info", size = "xs"), interactive = TRUE, trigger="click", theme = 'light left-align', tooltip = tooltip)),
    pickerInput(inputId = name,
                choices = options,
                selected = options[0],
                options = pickerOptions(
                  dropupAuto = FALSE
                )
              )
    )
}

# Check for subsequent consonants
checkConsonants <- function(pseudoword, nb_max_consonants){
  # nb_max_consonants is number of consonants (words with more following consonants are invalid, not words with equal number)
  if (nchar(pseudoword) > nb_max_consonants){
    # Concatenates current item (pseudoword in formation) and selected compat, and transform all consonants to uppercase character C
    b <- gsub("[^ɯαÅaáάαăàąǎâäāåãeéėèēεęêëiíίıİīïoóόòơôöºőόõøūuúûůüyýœɔɛə\\'\\.[:space:]-]","C",iconv(tolower(pseudoword), from="UTF-8", to="ASCII//TRANSLIT"))
    # Remove pseudowords with more than nb_max_consonants following consonants
    if (grepl(paste(rep("C",nb_max_consonants+1),collapse=""), b, fixed=TRUE)){
      return(FALSE)
    }
  }
  return(TRUE)
}

# Check we do not have more than nb_same_letters times the same consecutive letter
checkSameLetter <- function(pseudoword, nb_max_times_same){
  # nb_max_times_same is number of times we have the same letter consecutively (words with more times the same letter consecutive than nb_max_times_same are invalid, not words with equal number)
  if (nchar(pseudoword) > nb_max_times_same){
    wordChars <- strsplit(pseudoword, "")[[1]]
    nb_times_same <- 1
    for (charCount in 2:(length(wordChars))){
      char <- tolower(wordChars[charCount])
      if (char == wordChars[charCount-1]){
        nb_times_same <- nb_times_same + 1
      }else{
        nb_times_same <- 1
      }
      if (nb_times_same > nb_max_times_same){
        return(FALSE)
      }
    }
  }
  return(TRUE)
}

# https://en.wikipedia.org/wiki/List_of_Unicode_characters
accent_unicodes = c(192:197,200:214, 217:221, 224:229, 232:246, 249:253, 255, 256:304, 308:329, 332:337, 340:382)

# Check for more than nb_accent diacritical characters
# In spanish, no more than one
checkDiacritic <- function(pseudoword, nb_max_accent){
  if (nchar(pseudoword) > nb_max_accent){
    wordChars <- strsplit(pseudoword, "")[[1]]
    nb_accent = 0
    for (charCount in seq_along(wordChars)){
      char <- tolower(wordChars[charCount])
      if (utf8ToInt(char) %in% accent_unicodes){
        nb_accent = nb_accent + 1
      }
      if (nb_accent > nb_max_accent){
        return(FALSE)
      }
    }
  }
  return(TRUE)
}

filtersList <- list(
  list(
    name = "filterConsonants",
    options = c(default_filter_option, "1", "2", "3", "4"),
    pretty_name = "Max. consecutive consonants",
    tooltip = consonant_filter_tooltip,
    preset = list(languages = setdiff(latin_languages, c("Danish", "Dutch", "German", "Norwegian", "Swedish", "Welsh")), value = 3),
    checkFunc = checkConsonants
  ),
  list(
    name = "filterSameLetter",
    options = c(default_filter_option, "1", "2", "3"),
    pretty_name = "Max. same letter consecutive",
    tooltip = same_letter_filter_tooltip,
    preset = list(languages = latin_languages, value = 2),
    checkFunc = checkSameLetter
  ),
  list(
    name = "filterDiacritic",
    options = c(default_filter_option, "1", "2", "3"),
    pretty_name = "Max. diacritical letters",
    tooltip = diacritic_filter_tooltip,
    preset = list(languages = c("Spanish Latin America", "Spanish Spain"), value=1),
    checkFunc = checkDiacritic
  )
)
