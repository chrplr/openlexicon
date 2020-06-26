btn_show_helper = "Show Quick How-To"
btn_hide_helper = "Hide Quick How-To"
go_btn = tags$b("Go!")
anim_btn = tags$b("See animation")
lexique_btn = tags$b("Select words")
paste_words = "Words to use"
font_first_element = "<font color='red'><b>"
font_second_element = "</b></font>"
font_fade = "<font color ='grey'>"
font_fade_end = "</font>"

helper_alert <-
  tags$div(id = "helper_box",
           class="alert alert-info",
           tags$p("Quick how-to:"),
           tags$ul(
             tags$li("Paste a custom list or click the ", lexique_btn, " button to generate a list from Lexique words (only available in French).",
                     tags$b("Please note that words must all be of same length.")),
             tags$li("Select the number of pseudowords you want to create."),
             tags$li("Click on the ", go_btn, " button to generate pseudowords."),
             tags$li("If you want an overview of how pseudowords are generated from real words, check the ", anim_btn, "button."),
             tags$li("Download the result by clicking on the button below the table. The table contains the pseudowords (last column) and all words used to generate them.")
           )
            )