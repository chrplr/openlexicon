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
number_choice_raw = "Number of pseudowords"
number_choice = tags$b(number_choice_raw)
tab1 = tags$b("Pseudowords")
tab2 = tags$b("Pseudowords with details")
app_name = "UniPseudo"
min_nbpseudos = 1
max_nbpseudos = 2000
default_nbpseudos = 20
default_none = ""
default_other = "Other"
algo_choices = c("bigram", "trigram")

tooltip_style = "style='font-size:14px;display:block;text-align:justify'"
info_style = "style='font-size:14px;text-align:center;margin-top:1em;' class='help-block'"

lenGram_tooltip = paste("<span",tooltip_style,">The", lenGram_choice, "option is set automatically, depending on the", length_choice, "option. The generation of pseudowords of length >= 5 is based on the random selection of an initial trigram (the<b>", "trigram", "</b>algorithm). Then, compatible trigrams are selected until the generation of the pseudoword is complete. For shorter pseudowords (length <= 5), we obtain better performance when replacing trigrams with bigrams (the<b>", "bigram", "</b>algorithm). If you want to try both algorithms with different pseudoword lengths, you can change the", lenGram_choice, "option.</span>")

btn_generator_tooltip = paste("<span",tooltip_style,">Click the", btn_show_generator_name, "button to show import options.<br>Click the",
generateDB_neutral, "button to generate a list from an OpenLexicon database (see the tooltip next to the button for more details on the database used).<br>Please note that words selected from Lexique are French words. Words in other languages are selected from WorldLex. <b>Please note that Lexique allows to select the grammatical class, to restrict the type of pseudowords that will be generated to be similar to words of this grammatical class. We will soon propose other customization options.<br>For now, if you want to generate optimal non-french pseudowords, you may paste a custom list which controls parameters of interest (e.g., if you want to generate pseudowords that look alike verbs, paste only verbs in the<b>",paste_words,"section).</span>")

input_mots_tooltip = paste('<span',tooltip_style,'>Paste a custom list with words of the desired pseudowords length. Alternatively, you can click the', btn_show_generator_name, 'button, and generate words from an <b>OpenLexicon</b> database (see above).</span>')

nb_pseudos_tooltip = paste('<span',tooltip_style,'>The more pseudowords you want, the more words you need to provide in the<b>',
paste_words, '</b>section. A minimum of 100 words for 20 pseudowords is a good basis, unfortunately there is no fixed minimal number of words. You may need to proceed with trial-and-error or use the<b>',
generator_name, '</b>for easier pseudowords generation.</span>')

# helper_alert <-
#   tags$div(id = "helper_box",
#            class="alert alert-info",
#            tags$p("Quick how-to:"),
#            tags$ul(
             # tags$li("Finally, click on the", go_btn, "button to generate pseudowords.", tippy(tags$span(style="color:red; text-decoration:underline; font-weight:bold","More details here."), paste0("Please note that the algorithm checks that the pseudowords generated are not words from the pasted list, or words from the OpenLexicon database if you chose one through the ", tags$b(generator_name), ". Please check that the pseudowords generated are not words by any other way, in the language you are interested in."), theme="light-border", placement="right")),
             #tags$li("If you want an overview of how pseudowords are generated from real words, check the", anim_btn, "button."),
             # tags$li("Download the result by clicking on the button below the table. The table in the", tab1,"tab contains the generated pseudowords. If you want more details about the way pseudowords are created, click on the", tab2, "tab. This second table contains the pseudowords (first column) and all words used to generate them. For each word, parts used to compose the final pseudoword are written in bold and red-colored.")
           # )
           #  )
