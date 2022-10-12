# Dropdown area : https://stackoverflow.com/questions/34530142/drop-down-checkbox-input-in-shiny
dropdownButton2 <- function(label = "", status = c("default", "primary", "success", "info", "warning", "danger"), ..., width = NULL) {
  
  status <- match.arg(status)
  # dropdown button content
  html_ul <- list(
    class = "dropdown-menu",
    style = if (!is.null(width)) 
      paste0("width: ", validateCssUnit(width), ";"),
    lapply(X = list(...), FUN = tags$li, style = "margin-top: -10px; margin-left: 0px; margin-right: 0px;")
  )
  # dropdown button apparence
  html_button <- list(
    class = paste0("btn btn-", status," dropdown-toggle"),
    style = if (!is.null(width)) 
      paste0("width: ", validateCssUnit(width), ";"),
    type = "button", 
    `data-toggle` = "dropdown"
  )
  html_button <- c(html_button, list(tags$span(label, style = "float: left; text-overflow: '.'; white-space: nowrap; overflow: hidden; max-width: 90%; ")))
  html_button <- c(html_button, list(tags$span(class = "pull-right", tags$span(class = "caret"))))
  # final result
  tags$div(
    class = "dropdown",
    do.call(tags$button, html_button),
    do.call(tags$ul, html_ul),
    tags$script(
      "$('.dropdown-menu').click(function(e) {
      e.stopPropagation();
});")
  )
}