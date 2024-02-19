#' Return the local locations of datasets listed in listdatasets (downloading them from the internet if needed)
#'
#' @param listofdatasets A list of datasets to be loaded.
#' @param locations A list of locations (hosted online).
#'
#' @return Local locations of datasets listed in listdatasets.
#' @export
#'
#' @examples
#' \dontrun{
#' fetch_datasets(c('Lexique3', 'Voisins', 'Anagrammes') )
#' }

fetch_datasets <- function (
        listofdatasets,
        locations = "https://github.com/chrplr/openlexicon/tree/master/datasets-info/locations.toml"
        ) {

    locations <- blogdown::read_toml(locations)
    locs <- list()

    for (name in names(locations) ) {

        locs <- append(locs, get_dataset_from_json(locations[[name]]$url, name) )

    }

    names(locs) <- listofdatasets

    return (locs)

}
