#' Return the path of the folder where to put logs
#'
#' @param app_name A character vector with, at most, one element.
#'
#' @return A path to the logs folder.
#' @export
#'
#' @examples
#' get_log.home

get_log.home <- function (app_name) {

    is_local <- Sys.getenv('SHINY_PORT') == ""
    # True if used in local, else false if in production

    log.home = Sys.getenv("SHINY_LOG")

    if (log.home == "") {

        if (is_local) {

            log.home <- file.path(path.expand('~'), 'shiny_log', app_name)

        } else {

            log.home <- file.path('/var', 'shiny_log', app_name)

        }

    }

    dir.create(log.home, showWarnings = FALSE, recursive = TRUE)
    log.home

}
