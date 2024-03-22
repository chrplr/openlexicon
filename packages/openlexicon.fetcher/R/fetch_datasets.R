#' Returns a list of datasets (downloading those datasets from the internet if needed)
#'
#' @param datasets A list of datasets to be loaded.
#'
#' @return Local locations of datasets.
#' @export
#'
#' @examples
#' \dontrun{
#' fetch_datasets(c("Lexique3", "Voisins", "Anagrammes") )
#' }

fetch_datasets <- function (
        datasets = c("Lexique3", "Voisins", "Anagrammes")
        ) {

    # stop if the provided URL does not exist
    # stopifnot(RCurl::url.exists(locations) )

    # retrieving the content of the locations.toml file
    locations <- blogdown::read_toml(
        "https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/locations.toml"
        )

    # retrieving the names of the datasets in locations
    locations_datasets <- names(locations)

    # stop if the provided datasets are not present in locations
    if (!all(c(datasets, "babar") %in% locations_datasets) ) {

        stop(
            paste(
                "Some datasets are unknown:",
                paste(
                    setdiff(c(datasets, "babar", "babar2"), locations_datasets),
                    collapse = ", "
                    ),
                "\n\nAvailable datasets:",
                paste(locations_datasets, collapse = ", ")
                )
            )

    }

    # initialising en empty list
    locs <- list()

    # for each dataset in the database
    for (dataset in datasets) {

        locs <- append(locs, get_dataset_from_json(locations[[dataset]]$url, dataset) )

    }

    # returning a list of paths where the rds file are to be found
    names(locs) <- datasets

    # returning a list of paths where the rds file are to be found
    return (locs)

}
