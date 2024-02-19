#' Download all the datasets listed in locations (only if not already downloaded)
#'
#' @param locations A list of locations.
#'
#' @return Local locations of all datasets listed in locations.
#' @export
#'
#' @examples
#' \dontrun{
#' loc <- "https://github.com/chrplr/openlexicon/tree/master/datasets-info/locations.toml"
#' get_all_datasets(loc)
#' }

get_all_datasets <- function (locations = "https://github.com/chrplr/openlexicon/tree/master/datasets-info/locations.toml") {

    return (fetch_datasets(names(locations), locations) )

}
