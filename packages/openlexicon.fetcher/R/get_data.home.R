#' Return the path of the local folder where to put datasets
#'
#' @return A path for the datasets folder.
#' @export
#'
#' @examples
#' get_data.home()

get_data.home <- function() {

    data.home <- Sys.getenv('OPENLEXICON_DATASETS')
    xdg.data.home <- Sys.getenv('XDG_DATA_HOME')

    if (data.home == "") {

        if (xdg.data.home == "") {

            data.home <- file.path(path.expand('~'), 'openlexicon_datasets')

        } else {

            data.home <- file.path(xdg.data.home, 'openlexicon_datasets')

        }

    }

    dir.create(data.home, showWarnings = FALSE, recursive = TRUE)
    data.home

}
