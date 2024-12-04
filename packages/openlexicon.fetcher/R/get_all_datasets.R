#' Download all the datasets (only if not already downloaded)
#'
#' @return Local locations of all datasets listed in locations.
#' @export
#'
#' @examples
#' \dontrun{
#' get_all_datasets()
#' }

get_all_datasets <- function () {

    # retrieving the content of the locations.toml file
    locations <- blogdown::read_toml(
        "https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/locations.toml"
        )

    # retrieving the names of the datasets in locations
    locations_datasets <- names(locations)

    # downloading and returning all datasets
    return (fetch_datasets(datasets = names(locations) ) )

}
