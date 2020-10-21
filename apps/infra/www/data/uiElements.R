btn_show_helper = "Show Quick How-To"
btn_hide_helper = "Hide Quick How-To"
go_btn = tags$b("Go!")
paste_words = "Words to search"

helper_alert <-
  tags$div(id = "helper_box",
           class="alert alert-info",
           tags$p("Quick how-to:"),
           tags$ul(
             tags$li("Select the nature of the stimuli you want to search."),
             tags$li("Then, paste a custom list of words or pseudowords in the", tags$b(paste_words), "section."),
             tags$li("Finally, click on the", go_btn, "button to generate the table."),
             tags$li("Download the result by clicking on the button below the table.")
           )
            )
