btn_show_helper = "Show Quick How-To"
btn_hide_helper = "Hide Quick How-To"
go_btn = tags$b("Go!")
paste_words = "Items to search"
join_column = "Word"
join_column_alt = "Item"
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

tooltip_style = "style='font-size:14px;display:block;text-align:justify'"

hamming_tooltip = paste("<span",tooltip_style,">The <b>Hamming distance</b> option computes the Hamming distance (the number of non-overlapping characters) between words of the same length. The computation is done between each item and the Lexique 3 database. For more information : <a href = 'https://www.rdocumentation.org/packages/vwr/versions/0.3.0/topics/hamming.distance'>hamming.distance</a>. <b>Please note that selecting this option will significantly increase computation time.</b></span>")
