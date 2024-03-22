#' Return a list of the available datasets
#'
#' @return List of available datasets
#' @export
#'
#' @examples
#' \dontrun{
#' available_datasets()
#' }

available_datasets <- function () {

    # available locations of json files
    locations_url <- "https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/locations.toml"

    # retrieving the content of the locations.toml file
    locations <- blogdown::read_toml(locations_url)

    # returning these locations
    return (locations)

}
