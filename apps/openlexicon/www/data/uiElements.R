btn_show_name = "Show List Search"
btn_hide_name = "Hide List Search"
btn_select_deselect = "Select/Deselect all"
prefix_multiple = ""
prefix_multiple = "<span style='font-size:12px; color:grey;'>"
suffix_multiple = "</span><br>"
prefix_single = ""
suffix_single = "<br>"

helper_alert <-
  tags$div(class="alert alert-info",
           tags$p("Quick how-to:"),
           tags$ul(
             tags$li("Choose a language to see the available datasets in this language below."),
             tags$li("Select desired datasets. If you want more informations about a specific dataset, you can hover over its tooltip."),
             tags$li("Select columns to display for each dataset."),
             tags$li("For each column in the table, you can:"),
             tags$ul(
               tags$li("Hover the mouse over the column name to see a brief description (ongoing work)"),
               tags$li("Filter using ", tags$b("intervals (e.g. 40...500) "), "or ", tags$a(class="alert-link", href="http://www.lexique.org/?page_id=101", "regular expressions", target="_blank"), ".", sep =""),
               tags$li("sort, ascending or descending")
             ),
             tags$li(paste("Click on the button \"", btn_show_name, "\" to enter words that you want to search in the table.", sep = "")),
             tags$li("Download the result of your manipulations by clicking on the button below the table")
           )
           #tags$hr(),
           #tags$p(tags$a(href="https://chrplr.github.io/openlexicon/datasets-info/", "More information about the datatasets"))
  )