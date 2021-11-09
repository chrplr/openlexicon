btn_show_helper = "Show Quick How-To"
btn_hide_helper = "Hide Quick How-To"
generator_name = "Word Import Tool"
btn_show_generator_name = tags$b(paste("Show", generator_name, sep= " "))
btn_hide_generator_name = tags$b(paste("Hide", generator_name, sep= " "))
go_btn = tags$b("Go!")
anim_btn = tags$b("See animation")
paste_words = "Words to use"
font_first_element = "<font color='red'><b>"
font_second_element = "</b></font>"
font_previous_letters = "<font color='orange'><b>"
font_fade = "<font color ='grey'>"
font_fade_end = "</font>"
generateDB_neutral = tags$b("Use words from database")
grammatical_class_label = "Select grammatical class"
length_choice = tags$b("Pseudowords length")
lenGram_choice = tags$b("Algorithm")
number_choice = tags$b("Number of pseudowords")
tab1 = tags$b("Pseudowords")
tab2 = tags$b("Pseudowords with details")

helper_alert <-
  tags$div(id = "helper_box",
           class="alert alert-info",
           tags$p("Quick how-to:"),
           tags$ul(
             tags$li("First, select the desired length of pseudowords with the", length_choice, "option."),
             tags$li("The", lenGram_choice, "option is set automatically, depending on the", length_choice, "option. More details", tippy(tags$b("here."), paste("The generation of pseudowords of length >= 5 is based on the random selection of an initial trigram (the", tags$b("trigram"), "algorithm). Then, compatible trigrams are selected until the generation of the pseudoword is complete. For shorter pseudowords (length < 5), we obtain better performance when replacing trigrams with bigrams (the", tags$b("bigram"), "algorithm). If you want to try both algorithms with different pseudoword lengths, you can change the", lenGram_choice, "option."), theme="light-border", placement="right")),
             tags$li("Then, paste a custom list in the", tags$b(paste_words), "section. Alternatively, you can click the", btn_show_generator_name, "button, and generate words from an", tags$b("OpenLexicon"), "database."),
               tags$ul(
                 tags$li("Click the", btn_show_generator_name, "button."),
                 tags$li("Choose a language amongst the 66 available."),
                 tags$li("If you choose French, you will also have the opportunity to select a grammatical class, to restrict the type of pseudowords that will be generated to be similar to words of this grammatical class."),
                 tags$li("Finally, click the", generateDB_neutral, "button to generate a list from an OpenLexicon database (see the tooltip next to the button for more details on the database used). More details", tippy(tags$b("here."), paste("Please note that words selected from Lexique are French lemmas. Words in other languages are selected from WorldLex. Please note that Lexique allows to select the grammatical class, giving more control on the type of pseudowords that will be generated. We will soon propose other customization options. For now, if you want to generate optimal non-french pseudowords, you may paste a custom list which controls parameters of interest (e.g., if you want to generate pseudowords that look alike verbs, paste only verbs in the",tags$b(paste_words), "section)."), theme="light-border", placement="right"))
               ),
             tags$li("Enter the number of pseudowords you want to create with the", number_choice, "option."),
             tags$li("Finally, click on the", go_btn, "button to generate pseudowords."),
             tags$li("Please note that the algorithm checks that the pseudowords generated are not words from the pasted list, or words from the OpenLexicon database if you chose one through the", tags$b(generator_name), ". Please check that the pseudowords generated are not words by any other way, in the language you are interested in."),
             #tags$li("If you want an overview of how pseudowords are generated from real words, check the", anim_btn, "button."),
             tags$li("Download the result by clicking on the button below the table. The table in the", tab1,"tab contains the generated pseudowords. If you want more details about the way pseudowords are created, click on the", tab2, "tab. This second table contains the pseudowords (first column) and all words used to generate them. For each word, parts used to compose the final pseudoword are written in bold and red-colored.")
           )
            )
