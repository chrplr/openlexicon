btn_show_helper = "Show Quick How-To"
btn_hide_helper = "Hide Quick How-To"
go_btn = tags$b("Go!")
paste_words = "Items to search"
join_column = "Word"
type_column = "TypeItem"

helper_alert <-
  tags$div(id = "helper_box",
           class="alert alert-info",
           tags$p("Quick how-to:"),
           tags$ul(
             tags$li("Paste a custom list of words and/or pseudowords in the", tags$b(paste_words), "section."),
             tags$li("Click on the", go_btn, "button to generate the table."),
             tags$li("Download the result by clicking on the button below the table.")
           )
            )
