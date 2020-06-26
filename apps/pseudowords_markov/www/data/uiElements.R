btn_show_helper = "Show Quick How-To"
btn_hide_helper = "Hide Quick How-To"
go_btn = tags$b("Go!")
anim_btn = tags$b("See animation")
paste_words = "Words to use"
font_first_element = "<font color='red'><b>"
font_second_element = "</b></font>"
font_fade = "<font color ='grey'>"
font_fade_end = "</font>"
generateDB_btn = tags$b("Use words from Lexique")
length_choice = tags$b("Pseudowords length")
number_choice = tags$b("Number of pseudowords")
punctuation = c('!', '\"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/',
                ':', ';', '?', '@', '[', '\\', ']', '^', '_', '`', '{', '|', '}', '~')


helper_alert <-
  tags$div(id = "helper_box",
           class="alert alert-info",
           tags$p("Quick how-to:"),
           tags$ul(
             tags$li("First, select the desired length of pseudowords with the", length_choice, "option."),
             tags$li("Then, paste a custom list in the", tags$b(paste_words), "section, or click the", generateDB_btn, "button to generate a list from", tags$a(class="alert-link", href="http://www.lexique.org/", "Lexique", target="_blank"), "words (only available in French)."),
             tags$li("Select the number of pseudowords you want to create with the", number_choice, "option."),
             tags$li("Finally, click on the", go_btn, "button to generate pseudowords."),
             #tags$li("If you want an overview of how pseudowords are generated from real words, check the", anim_btn, "button."),
             tags$li("Download the result by clicking on the button below the table. The table contains the pseudowords (last column) and all words used to generate them. For each word, parts used to compose the final pseudoword are written in bold and red-colored.")
           )
            )