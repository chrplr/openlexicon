qTips <- function(titles){
  settings <- sprintf(paste(
    "{",
    "  content: {",
    "    text: '%s'",
    "  },",
    "  show: {",
    "    ready: false",
    "  },",
    "  position: {",
    "    my: 'bottom %%s',",
    "    at: 'center center'",
    "  },",
    "  style: {",
    "    classes: 'qtip-youtube'",
    "  }",
    "}",
    sep = "\n"
  ), titles)
  n <- length(titles)
  settings <- sprintf(settings, ifelse(1:n > n/2, "right", "left"))
  sprintf("var tooltips = [%s];", paste0(settings, collapse=","))
}