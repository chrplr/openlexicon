#' Returning a list of datasets (downloading those datasets from the internet if needed)
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

    # retrieving the content of the locations.toml file
    locations <- blogdown::read_toml(
        "https://raw.githubusercontent.com/chrplr/openlexicon/master/datasets-info/locations.toml"
        )

    # retrieving a list of the names of the datasets in locations
    locations_datasets <- names(locations)

    # stop if the provided datasets are not present in locations
    if (!all(datasets %in% locations_datasets) ) {

        stop(
            paste(
                "Some datasets are unknown:",
                paste(
                    setdiff(datasets, locations_datasets),
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

        # printing progress (sanity check)
        # cat("Processing dataset:", dataset)

        # downloading this dataset
        locs <- append(locs, get_dataset_from_json(locations[[dataset]]$url, dataset) )

        # debugging: trying to process the dataset and catch any errors
        # tryCatch ({
        #     # attempting to download this dataset
        #     locs <- append(locs, get_dataset_from_json(locations[[dataset]]$url, dataset))
        #     }, error = function(e) {
        #         # logging the dataset that caused an error
        #         # error_datasets <- append(error_datasets, dataset)
        #         # printing the error message
        #         cat("Error processing dataset:", dataset, "\n")
        #         cat("Error message:", e$message, "\n")
        #     })

    }

    # returning a list of paths where the rds file are to be found
    names(locs) <- datasets

    # returning a list of paths where the rds file are to be found
    return (locs)

}
